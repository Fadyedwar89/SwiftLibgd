public struct Rectangle: Equatable {
    public var point: Point
    public var size: Size

    public init(point: Point, size: Size) {
        self.point = point
        self.size = size
    }

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.init(point: Point(x: x, y: y), size: Size(width: width, height: height))
    }

    public init(x: Int32, y: Int32, width: Int32, height: Int32) {
        self.init(x: Int(x), y: Int(y), width: Int(width), height: Int(height))
    }

    @MainActor
    public static let zero = Rectangle(point: .zero, size: .zero)
}
