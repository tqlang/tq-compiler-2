import TqcSystem

public final class IdentifierExpressionNode: ExpressionNode {
    public let token: TokenNode

    public init(_ token: TokenNode) {
        self.token = token
        super.init()
    }

    public var value: String { token.value! }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return token.appendSyntaxToStringBuilder(sb)
    }
}
