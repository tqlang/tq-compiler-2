import TqcSystem

public final class UnaryPrefixExpressionNode: ExpressionNode {
    public let op: TokenNode
    public let exp: ExpressionNode

    public init(_ op: TokenNode, _ exp: ExpressionNode) {
        self.op = op
        self.exp = exp
        super.init()
    }

    public var operatorValue: String { op.value! }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(op)
            .appendSyntaxNode(exp)
    }
}
