import TqcSystem

public final class IfStatementNode: StatementNode {
    public let ifKeyword: TokenNode
    public let condition: ExpressionNode
    public let statement: StatementNode

    public init(_ ifKeyword: TokenNode, _ condition: ExpressionNode, _ statement: StatementNode) {
        self.ifKeyword = ifKeyword
        self.condition = condition
        self.statement = statement
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(ifKeyword)
            .appendSyntaxNode(condition)
            .appendSyntaxNode(statement)
    }
}
