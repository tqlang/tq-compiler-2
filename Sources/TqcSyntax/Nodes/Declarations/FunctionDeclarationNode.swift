import TqcSystem

public final class FunctionDeclarationNode: DeclarationNode {
    public let funcToken: TokenNode
    public let name: IdentifierExpressionNode
    public let parameters: ParametersCollectionNode
    public let returnType: ExpressionNode?
    public let body: ScopeNode?

    public init(_ attributes: [AttributeNode], _ funcToken: TokenNode, _ name: IdentifierExpressionNode, _ parameters: ParametersCollectionNode, _ returnType: ExpressionNode?, _ body: ScopeNode?) {
        self.funcToken = funcToken
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.body = body
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendAttributesSyntaxNode(attributes)
            .appendSyntaxNode(funcToken)
            .appendSyntaxNode(name)
            .appendSyntaxNode(parameters)
            .appendSyntaxNode(returnType)
            .appendSyntaxNode(body)
    }
}
