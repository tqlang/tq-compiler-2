import TqcDiagnostics
import TqcSystem

public final class SyntaxTree: SyntaxNode {
    public let root: [SyntaxNode]
    public let diagnostics = DiagnosticBag()

    public init(_ root: [SyntaxNode]) {
        self.root = root
        super.init()
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        fatalError("NotImplementedException")
    }
}
