// Equivalentes das exceções da BCL usadas no projeto original.

public protocol SystemException: Error, CustomStringConvertible {
    var message: String { get }
}

public extension SystemException {
    var description: String { "\(String(describing: type(of: self))): \(message)" }
}

public struct Exception: SystemException {
    public let message: String
    public init(_ message: String = "Exception of type 'System.Exception' was thrown.") { self.message = message }
}

public struct NotImplementedException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "The method or operation is not implemented." }
}

public struct EndOfStreamException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Attempted to read past the end of the stream." }
}

public struct InvalidDataException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Invalid data." }
}

public struct InvalidOperationException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Operation is not valid due to the current state of the object." }
}

public struct InvalidCastException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Specified cast is not valid." }
}

public struct ArgumentException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Value does not fall within the expected range." }
}

public struct ArgumentOutOfRangeException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Specified argument was out of the range of valid values." }
}

public struct FormatException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "One of the identified items was in an invalid format." }
}

public struct KeyNotFoundException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "The given key was not present in the dictionary." }
}

public struct UnreachableException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "The program executed an instruction that was thought to be unreachable." }
}

public struct DirectoryNotFoundException: SystemException {
    public let message: String
    public init(_ message: String? = nil) { self.message = message ?? "Could not find a part of the path." }
}
