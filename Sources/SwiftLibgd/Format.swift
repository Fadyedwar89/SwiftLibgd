#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation
import gd

// MARK: - Import Formats

public enum ImportableFormat {
    case bmp, gif, jpg, png, tiff, tga, wbmp, webp, avif, any

    /// Returns a managed GD image that will automatically be destroyed when deallocated
    public func image(of data: Data) throws -> GDImage {
        if case .any = self {
            return try tryAllFormats(data: data)
        }

        let (ptr, size) = try data.memoryPointer()

        let creator: (Int32, UnsafeMutableRawPointer) -> gdImagePtr? = switch self {
            case .bmp: gdImageCreateFromBmpPtr
            case .gif: gdImageCreateFromGifPtr
            case .jpg: gdImageCreateFromJpegPtr
            case .png: gdImageCreateFromPngPtr
            case .tiff: gdImageCreateFromTiffPtr
            case .tga: gdImageCreateFromTgaPtr
            case .wbmp: gdImageCreateFromWBMPPtr
            case .webp: gdImageCreateFromWebpPtr
            case .avif: gdImageCreateFromAvifPtr
            case .any: gdImageCreateFromPngPtr // Never reached
        }

        guard let imagePtr = creator(size, ptr) else {
            throw Error.invalidFormat
        }
        return GDImage(imagePtr)
    }

    private func tryAllFormats(data: Data) throws -> GDImage {
        let formats: [ImportableFormat] = [.jpg, .png, .gif, .webp, .tiff, .bmp, .wbmp]
        for format in formats {
            if let image = try? format.image(of: data) {
                return image
            }
        }
        throw Error.invalidImage(reason: "No matching format found")
    }
}

// MARK: - Export Formats

public enum ExportableFormat {
    case bmp(compression: Bool = false)
    case gif
    case jpg(quality: Int32 = -1)
    case png
    case tiff
    case wbmp(index: Int32)
    case webp
    case avif

    public func data(of gdImage: GDImage) throws -> Data {
        var size: Int32 = 0

        let bytes: UnsafeMutableRawPointer? = switch self {
            case .bmp(let compress):
                gdImageBmpPtr(gdImage.ptr, &size, compress ? 1 : 0)
            case .gif:
                gdImageGifPtr(gdImage.ptr, &size)
            case .jpg(let quality):
                gdImageJpegPtr(gdImage.ptr, &size, quality)
            case .png:
                gdImagePngPtr(gdImage.ptr, &size)
            case .tiff:
                gdImageTiffPtr(gdImage.ptr, &size)
            case .wbmp(let index):
                gdImageWBMPPtr(gdImage.ptr, &size, index)
            case .webp:
                gdImageWebpPtr(gdImage.ptr, &size)
            case .avif:
                gdImageAvifPtr(gdImage.ptr, &size)
        }

        guard let bytes = bytes else {
            throw Error.invalidFormat
        }

        return Data(bytesNoCopy: bytes, count: Int(size), deallocator: .custom { ptr, _ in
            gdFree(ptr)
        })
    }
}

// MARK: - Memory-Safe GD Image Wrapper
/// Wraps `gdImagePtr` and automatically destroys the image on deinit
public final class GDImage {
    public var ptr: gdImagePtr

    public init(_ ptr: gdImagePtr) {
        self.ptr = ptr
    }

    deinit {
        gdImageDestroy(ptr)
    }
}

// MARK: - Data Helper

private extension Data {
    func memoryPointer() throws -> (pointer: UnsafeMutableRawPointer, size: Int32) {
        guard count < Int32.max else {
            throw Error.invalidImage(reason: "Image data exceeds Int32.max")
        }

        return try withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                throw Error.invalidImage(reason: "Invalid memory address")
            }
            return (UnsafeMutableRawPointer(mutating: baseAddress), Int32(count))
        }
    }
}
