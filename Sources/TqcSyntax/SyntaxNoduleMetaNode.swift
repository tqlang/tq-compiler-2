public final class SyntaxModuleContainer {
    public let name: String
    public let root: SyntaxNamespaceContainer

    public init(_ name: String, _ root: SyntaxNamespaceContainer) {
        self.name = name
        self.root = root
    }
}
