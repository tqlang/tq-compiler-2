import TqcSystem

public final class FieldDeclarationNode: DeclarationNode {
    public let letKeyword: TokenNode
    public let type: ExpressionNode?
    public let name: IdentifierExpressionNode
    public let equalsToken: TokenNode?
    public let value: ExpressionNode?

    public init(_ attributes: [AttributeNode], _ letKeyword: TokenNode, _ type: ExpressionNode?, _ name: IdentifierExpressionNode, _ equalsToken: TokenNode?, _ value: ExpressionNode?) {
        self.letKeyword = letKeyword
        self.type = type
        self.name = name
        self.equalsToken = equalsToken
        self.value = value
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(letKeyword)
            .appendSyntaxNode(type)
            .appendSyntaxNode(name)
            .appendSyntaxNode(equalsToken)
            .appendSyntaxNode(value)
    }
}
