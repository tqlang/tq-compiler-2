public struct InsertionOrderedDictionary<Key: Hashable, Value>: Sequence {
    private var keysOrder: [Key] = []
    private var storage: [Key: Value] = [:]

    public init() {}

    public var count: Int { keysOrder.count }

    public subscript(key: Key) -> Value? {
        get { storage[key] }
        set {
            if let newValue {
                if storage.updateValue(newValue, forKey: key) == nil { keysOrder.append(key) }
            } else if storage.removeValue(forKey: key) != nil {
                keysOrder.removeAll { $0 == key }
            }
        }
    }

    public func makeIterator() -> AnyIterator<(key: Key, value: Value)> {
        var it = keysOrder.makeIterator()
        let st = storage
        return AnyIterator {
            guard let k = it.next() else { return nil }
            return (key: k, value: st[k]!)
        }
    }
}

public func toDictionary<S: Sequence, K: Hashable>(_ source: S, keySelector: (S.Element) -> K
) throws -> InsertionOrderedDictionary<K, S.Element> {
    var result = InsertionOrderedDictionary<K, S.Element>()
    for item in source {
        let key = keySelector(item)
        if result[key] != nil {
            throw ArgumentException("An item with the same key has already been added. Key: \(key)")
        }
        result[key] = item
    }
    return result
}

public extension Array {
    mutating func removeRange(_ index: Int, _ count: Int) throws {
        if index < 0 { throw ArgumentOutOfRangeException("Non-negative number required. (Parameter 'index')") }
        if count < 0 { throw ArgumentOutOfRangeException("Non-negative number required. (Parameter 'count')") }
        if self.count - index < count {
            throw ArgumentException(
                "Offset and length were out of bounds for the array or count is greater than the number of " +
                "elements from index to the end of the source collection."
            )
        }
        if count > 0 { removeSubrange(index..<(index + count)) }
    }

    mutating func trimExcess() {}
}
