import TqcSystem

public final class ReferenceTypeModifierNode: ExpressionNode {
    public let starToken: TokenNode
    public let valueType: ExpressionNode

    public init(_ starToken: TokenNode, _ valueType: ExpressionNode) {
        self.starToken = starToken
        self.valueType = valueType
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(starToken)
            .appendSyntaxNode(valueType)
    }
}
