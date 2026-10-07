import TqcSystem

public final class ExpressionStatementNode: StatementNode {
    public let node: ExpressionNode

    public init(_ node: ExpressionNode) {
        self.node = node
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(node)
    }
}
