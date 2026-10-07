import TqcSystem

public final class PropertyDeclarationNode: DeclarationNode {
    public let letKeyword: TokenNode
    public let type: ExpressionNode?
    public let name: IdentifierExpressionNode
    public let leftBracket: TokenNode
    public let getter: (keyword: TokenNode, expression: TokenNode?)?
    public let setter: (keyword: TokenNode, expression: TokenNode?)?
    public let rightBracket: TokenNode

    public init(
        _ attributes: [AttributeNode],
        _ letKeyword: TokenNode,
        _ type: ExpressionNode?,
        _ name: IdentifierExpressionNode,
        _ leftBracket: TokenNode,
        _ getter: (keyword: TokenNode, expression: TokenNode?)?,
        _ setter: (keyword: TokenNode, expression: TokenNode?)?,
        _ rightBracket: TokenNode
    ) {
        self.letKeyword = letKeyword
        self.type = type
        self.name = name
        self.leftBracket = leftBracket
        self.getter = getter
        self.setter = setter
        self.rightBracket = rightBracket
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb
            .appendSyntaxNode(letKeyword)
            .appendSyntaxNode(type)
            .appendSyntaxNode(name)
            .appendSyntaxNode(leftBracket)

        if let get = self.getter {
            sb
                .appendSyntaxNode(get.keyword)
                .appendSyntaxNode(get.expression)
        }

        if let set = self.setter {
            sb
                .appendSyntaxNode(set.keyword)
                .appendSyntaxNode(set.expression)
        }

        sb.appendSyntaxNode(rightBracket)
        return sb
    }
}
