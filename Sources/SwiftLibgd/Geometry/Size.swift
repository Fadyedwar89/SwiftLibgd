public struct Size: Comparable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public init(width: Int32, height: Int32) {
        self.init(width: Int(width), height: Int(height))
    }

    @MainActor
    public static let zero = Size(width: 0, height: 0)

    public static func < (lhs: Size, rhs: Size) -> Bool {
        lhs.width < rhs.width && lhs.height < rhs.height
    }
}
