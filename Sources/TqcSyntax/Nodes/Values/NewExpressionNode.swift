import TqcSystem

public final class NewExpressionNode: ExpressionNode {
    public let newKeyword: TokenNode
    public let type: ExpressionNode
    public let arguments: ArgumentsCollectionNode

    public init(_ newKeyword: TokenNode, _ type: ExpressionNode, _ arguments: ArgumentsCollectionNode) {
        self.newKeyword = newKeyword
        self.type = type
        self.arguments = arguments
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .append(newKeyword.toString()).appendSyntaxNode(type).appendSyntaxNode(arguments)
    }
}
