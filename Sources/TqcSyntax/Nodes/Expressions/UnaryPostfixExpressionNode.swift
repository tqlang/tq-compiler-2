import TqcSystem

public final class UnaryPostfixExpressionNode: ExpressionNode {
    public let exp: ExpressionNode
    public let op: TokenNode

    public init(_ exp: ExpressionNode, _ op: TokenNode) {
        self.exp = exp
        self.op = op
        super.init()
    }

    public var operatorValue: String { op.value! }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(exp)
            .appendSyntaxNode(op)
    }
}
