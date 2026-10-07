import TqcSystem

public final class StructDeclarationNode: DeclarationNode {
    public let structKeyword: TokenNode
    public let name: IdentifierExpressionNode
    public let parameters: ParametersCollectionNode?
    public let extends: (extends: SyntaxNode, type: ExpressionNode)?
    public let body: BlockNode

    public init(
        _ attributes: [AttributeNode],
        _ structKeyword: TokenNode,
        _ name: IdentifierExpressionNode,
        _ parameters: ParametersCollectionNode?,
        _ extends: (extends: SyntaxNode, type: ExpressionNode)?,
        _ body: BlockNode
    ) {
        self.structKeyword = structKeyword
        self.name = name
        self.parameters = parameters
        self.extends = extends
        self.body = body
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb
            .appendSyntaxNode(structKeyword)
            .appendSyntaxNode(name)
            .appendSyntaxNode(parameters)

        if let extends = self.extends {
            sb
                .appendSyntaxNode(extends.extends)
                .appendSyntaxNode(extends.type)
        }

        sb.appendSyntaxNode(body)

        return sb
    }
}
