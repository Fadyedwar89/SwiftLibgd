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

    public func imagePtr(of data: Data) throws -> gdImagePtr {
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

        guard let image = creator(size, ptr) else {
            throw Error.invalidFormat
        }
        return image
    }

    private func tryAllFormats(data: Data) throws -> gdImagePtr {
        let formats: [ImportableFormat] = [.jpg, .png, .gif, .webp, .tiff, .bmp, .wbmp]
        for format in formats {
            if let image = try? format.imagePtr(of: data) {
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

    public func data(of imagePtr: gdImagePtr) throws -> Data {
        var size: Int32 = 0

        let bytes: UnsafeMutableRawPointer? = switch self {
            case .bmp(let compress):
                gdImageBmpPtr(imagePtr, &size, compress ? 1 : 0)
            case .gif:
                gdImageGifPtr(imagePtr, &size)
            case .jpg(let quality):
                gdImageJpegPtr(imagePtr, &size, quality)
            case .png:
                gdImagePngPtr(imagePtr, &size)
            case .tiff:
                gdImageTiffPtr(imagePtr, &size)
            case .wbmp(let index):
                gdImageWBMPPtr(imagePtr, &size, index)
            case .webp:
                gdImageWebpPtr(imagePtr, &size)
            case .avif:
                gdImageAvifPtr(imagePtr, &size)
        }

        guard let bytes = bytes else {
            throw Error.invalidFormat
        }

        // Use custom deallocator for formats that need gdFree
        if case .bmp = self {
            return Data(bytesNoCopy: bytes, count: Int(size),
                       deallocator: .custom({ ptr, _ in gdFree(ptr) }))
        } else if case .jpg = self {
            return Data(bytesNoCopy: bytes, count: Int(size),
                       deallocator: .custom({ ptr, _ in gdFree(ptr) }))
        } else if case .wbmp = self {
            return Data(bytesNoCopy: bytes, count: Int(size),
                       deallocator: .custom({ ptr, _ in gdFree(ptr) }))
        }

        return Data(bytes: bytes, count: Int(size))
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
