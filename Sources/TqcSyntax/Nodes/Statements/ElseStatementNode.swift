import TqcSystem

public final class ElseStatementNode: StatementNode {
    public let elseKeyword: TokenNode
    public let statement: StatementNode

    public init(_ elseKeyword: TokenNode, _ statement: StatementNode) {
        self.elseKeyword = elseKeyword
        self.statement = statement
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(elseKeyword)
            .appendSyntaxNode(statement)
    }
}
