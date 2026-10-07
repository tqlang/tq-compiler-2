import TqcSystem

public final class CompoundIdentifierExpressionNode: ExpressionNode {
    public let identifier: [(token: TokenNode, dot: TokenNode?)]

    public init(_ identifier: [(token: TokenNode, dot: TokenNode?)]) {
        self.identifier = identifier
        super.init()
    }

    public var value: [String] { identifier.map { $0.token.value! } }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        for (ident, dot) in identifier {
            sb.appendSyntaxNode(ident)
            if let dot { sb.appendSyntaxNode(dot) }
        }
        return sb
    }
}
