import TqcSystem

public final class SliceTypeModifierNode: ExpressionNode {
    public let leftBracket: TokenNode
    public let rightBracket: TokenNode
    public let elementType: ExpressionNode

    public init(_ leftBracket: TokenNode, _ rightBracket: TokenNode, _ elementType: ExpressionNode) {
        self.leftBracket = leftBracket
        self.rightBracket = rightBracket
        self.elementType = elementType
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(leftBracket)
            .appendSyntaxNode(rightBracket)
            .appendSyntaxNode(elementType)
    }
}
