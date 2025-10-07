#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation
import gd

public final class Image {
    // MARK: - Private properties
    private var internalImage: GDImage

    // MARK: - Public properties
    public enum FlipMode {
        case horizontal, vertical, both
    }

    public var size: Size {
        Size(width: internalImage.ptr.pointee.sx, height: internalImage.ptr.pointee.sy)
    }

    public var transparent: Bool = false {
        didSet {
            gdImageSaveAlpha(internalImage.ptr, transparent ? 1 : 0)
            gdImageAlphaBlending(internalImage.ptr, transparent ? 0 : 1)
        }
    }

    // MARK: - Init
    public init?(width: Int, height: Int) {
        guard let ptr = gdImageCreateTrueColor(Int32(width), Int32(height)) else {
            return nil
        }
        self.internalImage = GDImage(ptr)
    }

    private init(gdImage: GDImage) {
        self.internalImage = gdImage
    }

    public convenience init?(url: URL) {
        guard let file = fopen(url.path, "rb") else { return nil }
        defer { fclose(file) }

        let ext = url.pathExtension.lowercased()
        var loadedPtr: gdImagePtr?

        if ext == "jpg" || ext == "jpeg" {
            loadedPtr = gdImageCreateFromJpeg(file)
        } else if ext == "png" {
            loadedPtr = gdImageCreateFromPng(file)
        } else {
            loadedPtr = nil
        }

        guard let ptr = loadedPtr else { return nil }
        self.init(gdImage: GDImage(ptr))
    }

    public convenience init(data: Data, as format: ImportableFormat = .any) throws {
        let gdImage = try format.image(of: data) // returns GDImage
        self.init(gdImage: gdImage)
    }
}

// MARK: - Transform Operations
public extension Image {
    func cloned() -> Image? {
        guard let clonedPtr = gdImageClone(internalImage.ptr) else { return nil }
        let clonedGDImage = GDImage(clonedPtr)
        return Image(gdImage: clonedGDImage)
    }

    func resizedTo(width: Int, height: Int, smooth: Bool = true) -> Image? {
        setInterpolation(smooth: smooth, from: size, to: Size(width: width, height: height))

        guard let scaledPtr = gdImageScale(internalImage.ptr, UInt32(width), UInt32(height)) else {
            return nil
        }

        let scaledGDImage = GDImage(scaledPtr)
        return Image(gdImage: scaledGDImage)
    }

    func resizedTo(width: Int, smooth: Bool = true) -> Image? {
        let ratio = Double(width) / Double(size.width)
        let newHeight = Int32(Double(size.height) * ratio)
        return resizedTo(width: width, height: Int(newHeight), smooth: smooth)
    }

    func resizedTo(height: Int, smooth: Bool = true) -> Image? {
        let ratio = Double(height) / Double(size.height)
        let newWidth = Int32(Double(size.width) * ratio)
        return resizedTo(width: Int(newWidth), height: height, smooth: smooth)
    }

    func cropped(to rect: Rectangle) -> Image? {
        var r = gdRect(
            x: Int32(rect.point.x),
            y: Int32(rect.point.y),
            width: Int32(rect.size.width),
            height: Int32(rect.size.height)
        )

        guard let croppedPtr = gdImageCrop(internalImage.ptr, &r) else { return nil }

        let croppedGDImage = GDImage(croppedPtr)
        return Image(gdImage: croppedGDImage)
    }

    func rotated(_ angle: Angle) -> Image? {
        guard let rotatedPtr = gdImageRotateInterpolated(internalImage.ptr, Float(angle.degrees), 0) else { return nil }
        let rotatedGDImage = GDImage(rotatedPtr)
        return Image(gdImage: rotatedGDImage)
    }

    func flipped(_ mode: FlipMode) -> Image? {
        guard let copyPtr = gdImageClone(internalImage.ptr) else { return nil }
        applyFlip(to: copyPtr, mode: mode)

        let copyGDImage = GDImage(copyPtr)
        return Image(gdImage: copyGDImage)
    }

    func flip(_ mode: FlipMode) {
        applyFlip(to: internalImage.ptr, mode: mode)
    }
}

// MARK: - Drawing Operations
public extension Image {
    @MainActor
    func renderText(
        _ text: String,
        from: Point,
        fontList: [String],
        color: Color,
        size: Double,
        angle: Angle = .zero
    ) -> (upperLeft: Point, upperRight: Point, lowerRight: Point, lowerLeft: Point) {
        guard !text.isEmpty, !fontList.isEmpty,
              var textCChar = text.cString(using: .utf8),
              var fonts = fontList.joined(separator: ";").cString(using: .utf8)
        else { return (.zero, .zero, .zero, .zero) }

        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }

        var box: [Int32] = .init(repeating: 0, count: 8)
        gdImageStringFT(
            internalImage.ptr,
            &box,
            c,
            &fonts,
            size,
            -angle.radians,
            Int32(from.x),
            Int32(from.y),
            &textCChar
        )

        return (
            Point(x: box[6], y: box[7]),
            Point(x: box[4], y: box[5]),
            Point(x: box[2], y: box[3]),
            Point(x: box[0], y: box[1])
        )
    }

    func fill(from: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageFill(internalImage.ptr, Int32(from.x), Int32(from.y), c)
    }

    func drawLine(from: Point, to: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageLine(internalImage.ptr, Int32(from.x), Int32(from.y), Int32(to.x), Int32(to.y), c)
    }

    @MainActor
    func drawImage(_ image: Image, at topLeft: Point = .zero) {
        gdImageCopy(
            internalImage.ptr,
            image.internalImage.ptr,
            Int32(topLeft.x),
            Int32(topLeft.y),
            0,
            0,
            Int32(size.width - topLeft.x),
            Int32(size.height - topLeft.y)
        )
    }

    func set(pixel: Point, to color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageSetPixel(internalImage.ptr, Int32(pixel.x), Int32(pixel.y), c)
    }

    func get(pixel: Point) -> Color {
        let c = gdImageGetTrueColorPixel(internalImage.ptr, Int32(pixel.x), Int32(pixel.y))
        return Color(
            red: Double((c >> 16) & 0xFF) / 255,
            green: Double((c >> 8) & 0xFF) / 255,
            blue: Double(c & 0xFF) / 255,
            alpha: 1 - Double((c >> 24) & 0xFF) / 127
        )
    }

    func strokeEllipse(center: Point, size: Size, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageEllipse(
            internalImage.ptr,
            Int32(center.x),
            Int32(center.y),
            Int32(size.width),
            Int32(size.height),
            c
        )
    }

    func fillEllipse(center: Point, size: Size, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageFilledEllipse(
            internalImage.ptr,
            Int32(center.x),
            Int32(center.y),
            Int32(size.width),
            Int32(size.height),
            c
        )
    }

    func strokeRectangle(topLeft: Point, bottomRight: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageRectangle(
            internalImage.ptr,
            Int32(topLeft.x),
            Int32(topLeft.y),
            Int32(bottomRight.x),
            Int32(bottomRight.y),
            c
        )
    }

    func fillRectangle(topLeft: Point, bottomRight: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage.ptr, c) }
        gdImageFilledRectangle(
            internalImage.ptr,
            Int32(topLeft.x),
            Int32(topLeft.y),
            Int32(bottomRight.x),
            Int32(bottomRight.y),
            c
        )
    }
}

// MARK: - Effects
public extension Image {
    func pixelate(blockSize: Int) {
        gdImagePixelate(internalImage.ptr, Int32(blockSize), GD_PIXELATE_AVERAGE.rawValue)
    }

    func blur(radius: Int) {
        if let result = gdImageCopyGaussianBlurred(internalImage.ptr, Int32(radius), -1) {
            gdImageDestroy(internalImage.ptr)
            internalImage.ptr = result
        }
    }

    func colorize(using color: Color) {
        let c = colorComponents(color)
        gdImageColor(internalImage.ptr, c.0, c.1, c.2, c.3)
    }

    func desaturate() {
        gdImageGrayScale(internalImage.ptr)
    }

    func reduceColors(max numberOfColors: Int, dither: Bool = true) throws {
        guard numberOfColors > 1 else {
            throw Error.invalidMaxColors(reason: "Indexed images must have at least 2 colors")
        }
        gdImageTrueColorToPalette(internalImage.ptr, dither ? 1 : 0, Int32(numberOfColors))
    }
}

// MARK: - Export
public extension Image {
    @discardableResult
    func write(to url: URL, quality: Int = 100, allowOverwrite: Bool = false) -> Bool {
        let ext = url.pathExtension.lowercased()
        guard ext == "png" || ext == "jpeg" || ext == "jpg" else { return false }
        guard allowOverwrite || !FileManager.default.fileExists(atPath: url.path) else { return false }
        guard let file = fopen(url.path, "wb") else { return false }
        defer { fclose(file) }

        if ext == "png" {
            gdImageSaveAlpha(internalImage.ptr, 1)
            gdImagePng(internalImage.ptr, file)
        } else {
            gdImageJpeg(internalImage.ptr, file, Int32(quality))
        }

        return FileManager.default.fileExists(atPath: url.path)
    }

    func export(as format: ExportableFormat = .png) throws -> Data {
        try format.data(of: internalImage)
    }
}

// MARK: - Private Helpers
private extension Image {
    func allocateColor(_ color: Color) -> Int32 {
        let c = colorComponents(color)
        return gdImageColorAllocateAlpha(internalImage.ptr, c.0, c.1, c.2, c.3)
    }

    func colorComponents(_ color: Color) -> (Int32, Int32, Int32, Int32) {
        (Int32(color.redComponent * 255), Int32(color.greenComponent * 255),
         Int32(color.blueComponent * 255), 127 - Int32(color.alphaComponent * 127))
    }

    func setInterpolation(smooth: Bool, from: Size, to: Size) {
        guard smooth else {
            gdImageSetInterpolationMethod(internalImage.ptr, GD_NEAREST_NEIGHBOUR)
            return
        }
        let method = from > to ? GD_SINC : from < to ? GD_MITCHELL : GD_NEAREST_NEIGHBOUR
        gdImageSetInterpolationMethod(internalImage.ptr, method)
    }

    func applyFlip(to image: gdImagePtr, mode: FlipMode) {
        switch mode {
        case .horizontal: gdImageFlipHorizontal(image)
        case .vertical: gdImageFlipVertical(image)
        case .both: gdImageFlipBoth(image)
        }
    }
}
