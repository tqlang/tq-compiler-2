import TqcSystem

public final class BlockNode: SyntaxNode, Sequence {
    public let leftBrace: TokenNode
    public let children: [SyntaxNode]
    public let rightBrace: TokenNode

    public init(_ leftBrace: TokenNode, _ children: [SyntaxNode], _ rightBrace: TokenNode) {
        self.leftBrace = leftBrace
        self.children = children
        self.rightBrace = rightBrace
        super.init()
    }

    public func makeIterator() -> IndexingIterator<[SyntaxNode]> { children.makeIterator() }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        leftBrace.appendSyntaxToStringBuilder(sb)
        for i in children { i.appendSyntaxToStringBuilder(sb) }
        return rightBrace.appendSyntaxToStringBuilder(sb)
    }
}
