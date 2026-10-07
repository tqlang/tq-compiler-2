import TqcSystem

public final class ArgumentsCollectionNode: SyntaxNode {
    public let leftParenthesis: TokenNode
    public let arguments: [(node: ExpressionNode, comma: TokenNode?)]
    public let rightParenthesis: TokenNode

    public init(
        _ leftParenthesis: TokenNode,
        _ arguments: [(node: ExpressionNode, comma: TokenNode?)],
        _ rightParenthesis: TokenNode
    ) {
        self.leftParenthesis = leftParenthesis
        self.arguments = arguments
        self.rightParenthesis = rightParenthesis
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        leftParenthesis.appendSyntaxToStringBuilder(sb)
        for (node, comma) in arguments {
            sb.append(node.toString())
            if let comma { sb.append(comma.toString()) }
        }
        rightParenthesis.appendSyntaxToStringBuilder(sb)
        return sb
    }
}
