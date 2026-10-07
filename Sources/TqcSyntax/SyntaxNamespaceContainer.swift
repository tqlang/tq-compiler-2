public final class SyntaxNamespaceContainer {
    public let name: String
    public var namespaces: [SyntaxNamespaceContainer] = []
    public var trees: [SyntaxTree] = []

    public init(_ name: String) {
        self.name = name
    }
}
