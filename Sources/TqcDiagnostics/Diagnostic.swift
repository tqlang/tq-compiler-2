import TqcSystem

public struct Diagnostic: Equatable {
    public let message: String
    public let line: Int
    public let column: Int

    public init(_ message: String, _ line: Int, _ column: Int) {
        self.message = message
        self.line = line
        self.column = column
    }
}

public struct ParseException: SystemException {
    public let message: String
    public init() { self.message = "Exception of type 'Tqc.Diagnostics.ParseException' was thrown." }
}
