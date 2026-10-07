import Foundation
import TqcSystem

public final class DecimalLiteralExpressionNode: ExpressionNode {
    public let token: TokenNode
    public let value: Decimal

    /// `decimal.Parse(Token.Value!)` — lança FormatException se inválido.
    public init(_ token: TokenNode) throws {
        self.token = token
        let text = token.value!
        let valid = !text.isEmpty
            && text.allSatisfy { $0.isASCII && ($0.isNumber || $0 == ".") }
            && text.contains { $0.isNumber }
        guard valid, let parsed = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX")) else {
            throw FormatException("The input string '\(text)' was not in a correct format.")
        }
        self.value = parsed
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb.appendSyntaxNode(token)
    }
}
