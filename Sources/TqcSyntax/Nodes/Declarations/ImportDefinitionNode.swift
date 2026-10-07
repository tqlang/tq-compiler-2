import TqcSystem

public final class ImportDefinitionNode: SyntaxNode {
    public let fromToken: TokenNode
    public let namespaceIdentifier: CompoundIdentifierExpressionNode
    public let importToken: TokenNode
    public let importMembers: MembersCollectionNode?

    public init(_ fromToken: TokenNode, _ namespaceIdentifier: CompoundIdentifierExpressionNode, _ importToken: TokenNode, _ importMembers: MembersCollectionNode?) {
        self.fromToken = fromToken
        self.namespaceIdentifier = namespaceIdentifier
        self.importToken = importToken
        self.importMembers = importMembers
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(fromToken)
            .appendSyntaxNode(namespaceIdentifier)
            .appendSyntaxNode(importToken)
            .appendSyntaxNode(importMembers)
    }
}
