import TqcSystem

public final class MembersCollectionNode: SyntaxNode {
    public let leftBrace: TokenNode
    public let identifiers: [(node: IdentifierExpressionNode, comma: TokenNode?)]
    public let rightBrace: TokenNode

    public init(
        _ leftBrace: TokenNode,
        _ identifiers: [(node: IdentifierExpressionNode, comma: TokenNode?)],
        _ rightBrace: TokenNode
    ) {
        self.leftBrace = leftBrace
        self.identifiers = identifiers
        self.rightBrace = rightBrace
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb.appendSyntaxNode(leftBrace)
        for (node, comma) in identifiers {
            sb.append(node.toString())
            if let comma { sb.append(comma.toString()) }
        }
        sb.appendSyntaxNode(rightBrace)
        return sb
    }
}
