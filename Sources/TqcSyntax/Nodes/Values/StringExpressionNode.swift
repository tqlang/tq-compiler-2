import TqcSystem

public final class StringExpressionNode: ExpressionNode {
    public let leftDoubleQuotes: TokenNode
    public let contents: [StringContentNode]
    public let rightDoubleQuotes: TokenNode

    public init(_ leftDoubleQuotes: TokenNode, _ contents: [StringContentNode], _ rightDoubleQuotes: TokenNode) {
        self.leftDoubleQuotes = leftDoubleQuotes
        self.contents = contents
        self.rightDoubleQuotes = rightDoubleQuotes
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb.appendSyntaxNode(leftDoubleQuotes)
        for i in contents { sb.appendSyntaxNode(i) }
        sb.appendSyntaxNode(rightDoubleQuotes)
        return sb
    }
}

public class StringContentNode: SyntaxNode {}

public final class StringCharacterLiteralNode: StringContentNode {
    public let value: TokenNode

    public init(_ value: TokenNode) {
        self.value = value
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb.appendSyntaxNode(value)
    }
}

public final class StringLiteralNode: StringContentNode {
    public let value: TokenNode

    public init(_ value: TokenNode) {
        self.value = value
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb.appendSyntaxNode(value)
    }
}

public final class InterpolatedExpressionNode: StringContentNode {
    public let leftEscapedBrace: TokenNode
    public let expresison: ExpressionNode // (sic)
    public let rightBrace: TokenNode

    public init(_ leftEscapedBrace: TokenNode, _ expresison: ExpressionNode, _ rightBrace: TokenNode) {
        self.leftEscapedBrace = leftEscapedBrace
        self.expresison = expresison
        self.rightBrace = rightBrace
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendSyntaxNode(leftEscapedBrace)
            .appendSyntaxNode(expresison)
            .appendSyntaxNode(rightBrace)
    }
}
