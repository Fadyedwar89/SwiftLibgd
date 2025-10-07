public enum Error: Swift.Error {
    case invalidFormat
    case invalidImage(reason: String)
    case invalidColor(reason: String)
    case invalidMaxColors(reason: String)
}
