import TqcSystem

public final class MemberAccessExpressionNode: ExpressionNode {
    public let left: ExpressionNode
    public let dot: TokenNode
    public let right: IdentifierExpressionNode

    public init(_ left: ExpressionNode, _ dot: TokenNode, _ right: IdentifierExpressionNode) {
        self.left = left
        self.dot = dot
        self.right = right
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(left)
            .appendSyntaxNode(dot)
            .appendSyntaxNode(right)
    }
}
