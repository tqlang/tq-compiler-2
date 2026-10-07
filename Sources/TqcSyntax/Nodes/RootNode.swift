import TqcSystem

public final class RootNode: SyntaxNode, Sequence {
    public let children: [SyntaxNode]

    public init(_ children: [SyntaxNode]) {
        self.children = children
        super.init()
    }

    public func makeIterator() -> IndexingIterator<[SyntaxNode]> { children.makeIterator() }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        for i in children { i.appendSyntaxToStringBuilder(sb) }
        return sb
    }
}
