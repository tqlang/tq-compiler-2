public final class DiagnosticBag: Sequence {
    private var _diagnostics: [Diagnostic] = []

    public init() {}

    public var diagnostics: [Diagnostic] { _diagnostics }
    public var count: Int { _diagnostics.count }

    public func reportErrorAndPanic(_ message: String, _ line: Int, _ column: Int) throws {
        _diagnostics.append(Diagnostic(message, line, column))
        throw ParseException()
    }

    public func reportError(_ message: String, _ line: Int, _ column: Int) {
        _diagnostics.append(Diagnostic(message, line, column))
    }

    public var hasErrors: Bool { _diagnostics.count > 0 }

    public func makeIterator() -> IndexingIterator<[Diagnostic]> { diagnostics.makeIterator() }
}
