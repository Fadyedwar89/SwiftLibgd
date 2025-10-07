public struct Color {
    public var redComponent: Double
    public var greenComponent: Double
    public var blueComponent: Double
    public var alphaComponent: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        redComponent = red
        greenComponent = green
        blueComponent = blue
        alphaComponent = alpha
    }
}

// MARK: - Presets

@MainActor
extension Color {
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 1, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1)
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
}

// MARK: - Hex Support

extension Color {
    /// Creates a color from hex string like "#ff0000" or "f00"
    /// Supports: RGB, RGBA, #RGB, #RGBA, RRGGBB, RRGGBBAA, #RRGGBB, #RRGGBBAA
    public init(hex: String, leadingAlpha: Bool = false) throws {
        let sanitized = try Self.sanitize(hex: hex, leadingAlpha: leadingAlpha)
        guard let code = Int(sanitized, radix: 16) else {
            throw Error.invalidColor(reason: "\(hex) is not valid hex")
        }
        self.init(hex: code, leadingAlpha: leadingAlpha)
    }

    /// Creates a color from hex integer like 0xff0000
    public init(hex: Int, leadingAlpha: Bool = false) {
        let r = Double((hex >> 24) & 0xff) / 255.0
        let g = Double((hex >> 16) & 0xff) / 255.0
        let b = Double((hex >> 8) & 0xff) / 255.0
        let a = Double(hex & 0xff) / 255.0

        self = leadingAlpha
            ? Color(red: g, green: b, blue: a, alpha: r)  // ARGB
            : Color(red: r, green: g, blue: b, alpha: a)  // RGBA
    }

    private static func sanitize(hex: String, leadingAlpha: Bool) throws -> String {
        var s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        // Expand short forms: "f0a" -> "ff00aa"
        if s.count == 3 || s.count == 4 {
            s = s.map { "\($0)\($0)" }.joined()
        }

        // Add alpha if missing
        switch s.count {
        case 6: return leadingAlpha ? "ff" + s : s + "ff"
        case 8: return s
        default: throw Error.invalidColor(reason: "\(hex) has invalid length")
        }
    }
}
