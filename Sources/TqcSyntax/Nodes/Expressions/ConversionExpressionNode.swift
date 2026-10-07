import TqcSystem

public final class ConversionExpressionNode: ExpressionNode {
    public let expression: ExpressionNode
    public let asKeyword: TokenNode
    public let type: ExpressionNode

    public init(_ expression: ExpressionNode, _ asKeyword: TokenNode, _ type: ExpressionNode) {
        self.expression = expression
        self.asKeyword = asKeyword
        self.type = type
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(expression)
            .appendSyntaxNode(asKeyword)
            .appendSyntaxNode(type)
    }
}
