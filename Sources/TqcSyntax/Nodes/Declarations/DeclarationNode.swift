public class DeclarationNode: SyntaxNode {
    public let attributes: [AttributeNode]

    public init(_ attributes: [AttributeNode]) {
        self.attributes = attributes
        super.init()
    }
}
