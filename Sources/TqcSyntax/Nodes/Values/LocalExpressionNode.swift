import TqcSystem

public final class LocalExpressionNode: ExpressionNode {
    public let letOrConstKeyword: TokenNode
    public let type: ExpressionNode?
    public let name: IdentifierExpressionNode

    public init(_ letOrConstKeyword: TokenNode, _ type: ExpressionNode?, _ name: IdentifierExpressionNode) {
        self.letOrConstKeyword = letOrConstKeyword
        self.type = type
        self.name = name
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .append(letOrConstKeyword.toString()).appendSyntaxNode(type).appendSyntaxNode(name)
    }
}
