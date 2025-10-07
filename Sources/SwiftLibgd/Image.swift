#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation
import gd

public class Image {
    // MARK: Private properties
    private var internalImage: gdImagePtr

    // MARK: - Public properties
    public enum FlipMode {
        case horizontal, vertical, both
    }

    public var size: Size {
        Size(width: internalImage.pointee.sx, height: internalImage.pointee.sy)
    }

    public var transparent: Bool = false {
        didSet {
            gdImageSaveAlpha(internalImage, transparent ? 1 : 0)
            gdImageAlphaBlending(internalImage, transparent ? 0 : 1)
        }
    }

    // MARK: - Init
    public init?(width: Int, height: Int) {
        internalImage = gdImageCreateTrueColor(Int32(width), Int32(height))
    }

    private init(gdImage: gdImagePtr) {
        self.internalImage = gdImage
    }

    public convenience init?(url: URL) {
        guard let file = fopen(url.path, "rb") else { return nil }
        defer { fclose(file) }

        let ext = url.lastPathComponent.lowercased()
        let img: gdImagePtr? = ext.hasSuffix("jpg") || ext.hasSuffix("jpeg")
        ? gdImageCreateFromJpeg(file)
        : ext.hasSuffix("png") ? gdImageCreateFromPng(file) : nil

        guard let loadedImage = img else { return nil }
        self.init(gdImage: loadedImage)
    }

    public convenience init(data: Data, as format: ImportableFormat = .any) throws {
        try self.init(gdImage: format.imagePtr(of: data))
    }

    // MARK: - Deinit
    deinit {
        gdImageDestroy(internalImage)
    }
}

// MARK: - Transform Operations
public extension Image {
    func cloned() -> Image? {
        gdImageClone(internalImage).map { Image(gdImage: $0) }
    }

    func resizedTo(width: Int, height: Int, smooth: Bool = true) -> Image? {
        setInterpolation(smooth: smooth, from: size, to: Size(width: width, height: height))
        return gdImageScale(internalImage, UInt32(width), UInt32(height)).map { Image(gdImage: $0) }
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
        var r = gdRect(x: Int32(rect.point.x), y: Int32(rect.point.y),
                       width: Int32(rect.size.width), height: Int32(rect.size.height))
        return gdImageCrop(internalImage, &r).map { Image(gdImage: $0) }
    }

    func rotated(_ angle: Angle) -> Image? {
        gdImageRotateInterpolated(internalImage, Float(angle.degrees), 0).map { Image(gdImage: $0) }
    }

    func flipped(_ mode: FlipMode) -> Image? {
        guard let copy = gdImageClone(internalImage) else { return nil }
        applyFlip(to: copy, mode: mode)
        return Image(gdImage: copy)
    }

    func flip(_ mode: FlipMode) {
        applyFlip(to: internalImage, mode: mode)
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
        defer { gdImageColorDeallocate(internalImage, c) }

        var box: [Int32] = .init(repeating: 0, count: 8)
        gdImageStringFT(
            internalImage,
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
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageFill(internalImage, Int32(from.x), Int32(from.y), c)
    }

    func drawLine(from: Point, to: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageLine(internalImage, Int32(from.x), Int32(from.y), Int32(to.x), Int32(to.y), c)
    }

    @MainActor
    func drawImage(_ image: Image, at topLeft: Point = .zero) {
        gdImageCopy(
            internalImage,
            image.internalImage,
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
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageSetPixel(internalImage, Int32(pixel.x), Int32(pixel.y), c)
    }

    func get(pixel: Point) -> Color {
        let c = gdImageGetTrueColorPixel(internalImage, Int32(pixel.x), Int32(pixel.y))
        return Color(
            red: Double((c >> 16) & 0xFF) / 255,
            green: Double((c >> 8) & 0xFF) / 255,
            blue: Double(c & 0xFF) / 255,
            alpha: 1 - Double((c >> 24) & 0xFF) / 127
        )
    }

    func strokeEllipse(center: Point, size: Size, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageEllipse(
            internalImage,
            Int32(center.x),
            Int32(center.y),
            Int32(size.width),
            Int32(size.height),
            c
        )
    }

    func fillEllipse(center: Point, size: Size, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageFilledEllipse(
            internalImage,
            Int32(center.x),
            Int32(center.y),
            Int32(size.width),
            Int32(size.height),
            c
        )
    }

    func strokeRectangle(topLeft: Point, bottomRight: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageRectangle(
            internalImage,
            Int32(topLeft.x),
            Int32(topLeft.y),
            Int32(bottomRight.x),
            Int32(bottomRight.y),
            c
        )
    }

    func fillRectangle(topLeft: Point, bottomRight: Point, color: Color) {
        let c = allocateColor(color)
        defer { gdImageColorDeallocate(internalImage, c) }
        gdImageFilledRectangle(
            internalImage,
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
        gdImagePixelate(internalImage, Int32(blockSize), GD_PIXELATE_AVERAGE.rawValue)
    }

    func blur(radius: Int) {
        if let result = gdImageCopyGaussianBlurred(internalImage, Int32(radius), -1) {
            gdImageDestroy(internalImage)
            internalImage = result
        }
    }

    func colorize(using color: Color) {
        let c = colorComponents(color)
        gdImageColor(internalImage, c.0, c.1, c.2, c.3)
    }

    func desaturate() {
        gdImageGrayScale(internalImage)
    }

    func reduceColors(max numberOfColors: Int, dither: Bool = true) throws {
        guard numberOfColors > 1 else {
            throw Error.invalidMaxColors(reason: "Indexed images must have at least 2 colors")
        }
        gdImageTrueColorToPalette(internalImage, dither ? 1 : 0, Int32(numberOfColors))
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
            gdImageSaveAlpha(internalImage, 1)
            gdImagePng(internalImage, file)
        } else {
            gdImageJpeg(internalImage, file, Int32(quality))
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
        return gdImageColorAllocateAlpha(internalImage, c.0, c.1, c.2, c.3)
    }

    func colorComponents(_ color: Color) -> (Int32, Int32, Int32, Int32) {
        (Int32(color.redComponent * 255), Int32(color.greenComponent * 255),
         Int32(color.blueComponent * 255), 127 - Int32(color.alphaComponent * 127))
    }

    func setInterpolation(smooth: Bool, from: Size, to: Size) {
        guard smooth else {
            gdImageSetInterpolationMethod(internalImage, GD_NEAREST_NEIGHBOUR)
            return
        }
        let method = from > to ? GD_SINC : from < to ? GD_MITCHELL : GD_NEAREST_NEIGHBOUR
        gdImageSetInterpolationMethod(internalImage, method)
    }

    func applyFlip(to image: gdImagePtr, mode: FlipMode) {
        switch mode {
        case .horizontal: gdImageFlipHorizontal(image)
        case .vertical: gdImageFlipVertical(image)
        case .both: gdImageFlipBoth(image)
        }
    }
}
