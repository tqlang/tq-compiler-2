import TqcSystem

public final class CallExpressionNode: ExpressionNode {
    public let callee: ExpressionNode
    public let arguments: ArgumentsCollectionNode

    public init(_ callee: ExpressionNode, _ arguments: ArgumentsCollectionNode) {
        self.callee = callee
        self.arguments = arguments
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(callee)
            .appendSyntaxNode(arguments)
    }
}
