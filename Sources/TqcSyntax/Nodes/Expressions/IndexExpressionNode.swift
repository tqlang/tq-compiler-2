import TqcSystem

public final class IndexExpressionNode: ExpressionNode {
    public let callee: ExpressionNode
    public let indices: IndexCollectionNode

    public init(_ callee: ExpressionNode, _ indices: IndexCollectionNode) {
        self.callee = callee
        self.indices = indices
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(callee)
            .appendSyntaxNode(indices)
    }
}
