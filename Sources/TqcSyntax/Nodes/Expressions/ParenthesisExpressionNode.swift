import TqcSystem

public final class ParenthesisExpressionNode: ExpressionNode {
    public let leftParenthesis: TokenNode
    public let expression: ExpressionNode
    public let rightParenthesis: TokenNode

    public init(_ leftParenthesis: TokenNode, _ expression: ExpressionNode, _ rightParenthesis: TokenNode) {
        self.leftParenthesis = leftParenthesis
        self.expression = expression
        self.rightParenthesis = rightParenthesis
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(leftParenthesis)
            .appendSyntaxNode(expression)
            .appendSyntaxNode(rightParenthesis)
    }
}
