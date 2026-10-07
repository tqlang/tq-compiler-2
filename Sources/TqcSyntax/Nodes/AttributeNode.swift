import TqcSystem

public final class AttributeNode: SyntaxNode {
    public let atToken: TokenNode
    public let identifier: IdentifierExpressionNode
    public let arguments: ArgumentsCollectionNode?

    public init(_ atToken: TokenNode, _ identifier: IdentifierExpressionNode, _ arguments: ArgumentsCollectionNode?) {
        self.atToken = atToken
        self.identifier = identifier
        self.arguments = arguments
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(atToken)
            .appendSyntaxNode(identifier)
            .appendSyntaxNode(arguments)
    }
}
