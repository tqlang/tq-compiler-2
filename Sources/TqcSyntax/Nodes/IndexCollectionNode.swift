import TqcSystem

public final class IndexCollectionNode: SyntaxNode {
    public let leftBrackets: TokenNode
    public let arguments: [(node: ExpressionNode, comma: TokenNode?)]
    public let rightBrackets: TokenNode

    public init(
        _ leftBrackets: TokenNode,
        _ arguments: [(node: ExpressionNode, comma: TokenNode?)],
        _ rightBrackets: TokenNode
    ) {
        self.leftBrackets = leftBrackets
        self.arguments = arguments
        self.rightBrackets = rightBrackets
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb.appendSyntaxNode(leftBrackets)
        for (node, comma) in arguments {
            sb.append(node.toString())
            if let comma { sb.append(comma.toString()) }
        }
        sb.appendSyntaxNode(rightBrackets)
        return sb
    }
}
