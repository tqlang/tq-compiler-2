import TqcSystem

public final class ScopeNode: StatementNode, Sequence {
    public let leftBrace: TokenNode
    public let children: [StatementNode]
    public let rightBrace: TokenNode

    public init(_ leftBrace: TokenNode, _ children: [StatementNode], _ rightBrace: TokenNode) {
        self.leftBrace = leftBrace
        self.children = children
        self.rightBrace = rightBrace
        super.init()
    }

    public func makeIterator() -> IndexingIterator<[StatementNode]> { children.makeIterator() }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        leftBrace.appendSyntaxToStringBuilder(sb)
        for i in children { i.appendSyntaxToStringBuilder(sb) }
        return rightBrace.appendSyntaxToStringBuilder(sb)
    }
}
