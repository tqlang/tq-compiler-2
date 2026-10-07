import TqcSystem

public final class ParameterNode: SyntaxNode {
    public let type: ExpressionNode
    public let name: IdentifierExpressionNode

    public init(_ type: ExpressionNode, _ name: IdentifierExpressionNode) {
        self.type = type
        self.name = name
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(type)
            .appendSyntaxNode(name)
    }
}
