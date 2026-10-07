import TqcSystem

public final class IntegerLiteralExpressionNode: ExpressionNode {
    public let token: TokenNode
    public let value: BigInteger

    /// `BigInteger.Parse(Token.Value!)` — lança FormatException se inválido.
    public init(_ token: TokenNode) throws {
        self.token = token
        self.value = try BigInteger.parse(token.value!)
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return token.appendSyntaxToStringBuilder(sb)
    }
}
