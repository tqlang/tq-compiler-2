import TqcSystem

public final class ParametersCollectionNode: SyntaxNode {
    public let leftParenthesis: TokenNode
    public let parameters: [(node: ParameterNode, comma: TokenNode?)]
    public let rightParenthesis: TokenNode

    public init(
        _ leftParenthesis: TokenNode,
        _ parameters: [(node: ParameterNode, comma: TokenNode?)],
        _ rightParenthesis: TokenNode
    ) {
        self.leftParenthesis = leftParenthesis
        self.parameters = parameters
        self.rightParenthesis = rightParenthesis
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb.appendSyntaxNode(leftParenthesis)
        for (node, comma) in parameters {
            sb.append(node.toString())
            if let comma { sb.append(comma.toString()) }
        }
        sb.appendSyntaxNode(rightParenthesis)
        return sb
    }
}
