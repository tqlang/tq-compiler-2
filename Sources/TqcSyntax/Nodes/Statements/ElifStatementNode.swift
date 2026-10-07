import TqcSystem

public final class ElifStatementNode: StatementNode {
    public let elifKeyword: TokenNode
    public let condition: ExpressionNode
    public let statement: StatementNode

    public init(_ elifKeyword: TokenNode, _ condition: ExpressionNode, _ statement: StatementNode) {
        self.elifKeyword = elifKeyword
        self.condition = condition
        self.statement = statement
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(elifKeyword)
            .appendSyntaxNode(condition)
            .appendSyntaxNode(statement)
    }
}
