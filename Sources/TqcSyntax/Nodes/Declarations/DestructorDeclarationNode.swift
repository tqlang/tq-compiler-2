import TqcSystem

public final class DestructorDeclarationNode: DeclarationNode {
    public let destructorKeyword: TokenNode
    public let parameters: ParametersCollectionNode
    public let returnType: ExpressionNode?
    public let body: ScopeNode?

    public init(_ attributes: [AttributeNode], _ destructorKeyword: TokenNode, _ parameters: ParametersCollectionNode, _ returnType: ExpressionNode?, _ body: ScopeNode?) {
        self.destructorKeyword = destructorKeyword
        self.parameters = parameters
        self.returnType = returnType
        self.body = body
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(destructorKeyword)
            .appendSyntaxNode(parameters)
            .appendSyntaxNode(returnType)
            .appendSyntaxNode(body)
    }
}
