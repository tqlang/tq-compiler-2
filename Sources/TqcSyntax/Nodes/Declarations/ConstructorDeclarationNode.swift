import TqcSystem

public final class ConstructorDeclarationNode: DeclarationNode {
    public let constructorToken: TokenNode
    public let parameters: ParametersCollectionNode
    public let returnType: ExpressionNode?
    public let body: ScopeNode?

    public init(_ attributes: [AttributeNode], _ constructorToken: TokenNode, _ parameters: ParametersCollectionNode, _ returnType: ExpressionNode?, _ body: ScopeNode?) {
        self.constructorToken = constructorToken
        self.parameters = parameters
        self.returnType = returnType
        self.body = body
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(constructorToken)
            .appendSyntaxNode(parameters)
            .appendSyntaxNode(returnType)
            .appendSyntaxNode(body)
    }
}
