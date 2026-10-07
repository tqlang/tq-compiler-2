// System.Text.StringBuilder (semântica de referência + API fluente).

public enum Environment {
    public static let newLine = "\n"
}

public final class StringBuilder {
    private var storage: String = ""

    public init() {}

    public var length: Int {
        get { storage.utf16.count }
        set {
            let current = storage.utf16.count
            if newValue >= current { return }
            let idx = storage.utf16.index(storage.utf16.startIndex, offsetBy: newValue)
            storage = String(storage[..<idx])
        }
    }

    @discardableResult
    public func append(_ value: String?) -> StringBuilder {
        if let value { storage += value }
        return self
    }

    @discardableResult
    public func append(_ value: Character) -> StringBuilder {
        storage.append(value)
        return self
    }

    @discardableResult
    public func appendLine(_ value: String = "") -> StringBuilder {
        storage += value
        storage += Environment.newLine
        return self
    }

    @discardableResult
    public func clear() -> StringBuilder {
        storage = ""
        return self
    }

    public func toString() -> String { storage }
}
