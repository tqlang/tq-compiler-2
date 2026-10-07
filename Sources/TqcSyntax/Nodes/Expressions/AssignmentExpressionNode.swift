import TqcSystem

public final class AssignmentExpressionNode: ExpressionNode {
    public let left: ExpressionNode
    public let op: TokenNode
    public let right: ExpressionNode

    public init(_ left: ExpressionNode, _ op: TokenNode, _ right: ExpressionNode) {
        self.left = left
        self.op = op
        self.right = right
        super.init()
    }

    public var operatorValue: String { op.value! }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(left)
            .appendSyntaxNode(op)
            .appendSyntaxNode(right)
    }
}
