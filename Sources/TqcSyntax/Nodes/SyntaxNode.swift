import TqcSystem

public class SyntaxNode: CustomStringConvertible {
    public init() {}

    // IFormattable.ToString(format, provider)
    public func toString(_ format: String?, _ formatProvider: Any?) -> String {
        switch format {
        default: return appendSyntaxToStringBuilder(StringBuilder()).toString()
        }
    }

    // override sealed string ToString()
    public final func toString() -> String { toString(nil, nil) }

    public final var description: String { toString() }

    // abstract internal
    @discardableResult
    func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        fatalError("abstract: appendSyntaxToStringBuilder")
    }
}
