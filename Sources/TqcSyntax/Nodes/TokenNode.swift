import TqcSystem

public final class TokenNode: SyntaxNode {
    private var trivia: [TriviaNode]
    public var value: String?
    public var kind: TokenKind
    public var line: Int
    public var column: Int

    init(_ trivia: [TriviaNode], _ value: TokenValue) {
        self.trivia = trivia
        self.value = value.value
        self.kind = value.kind
        self.line = value.line
        self.column = value.column
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        for i in trivia { i.appendSyntaxToStringBuilder(sb) }
        return sb.append(value)
    }
}
