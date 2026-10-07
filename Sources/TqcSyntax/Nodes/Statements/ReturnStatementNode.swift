import TqcSystem

public final class ReturnStatementNode: StatementNode {
    public let returnKeyword: TokenNode
    public let expression: ExpressionNode?

    public init(_ returnKeyword: TokenNode, _ expression: ExpressionNode?) {
        self.returnKeyword = returnKeyword
        self.expression = expression
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(returnKeyword)
            .appendSyntaxNode(expression)
    }
}
