public final class ModuleDefinition: Hashable {
    public let name: String
    public let type: String?

    public var extraFields: [String: Any?] = [:]
    public var dependencies: [ModuleDependency] = []

    public init(name: String, type: String?) {
        self.name = name
        self.type = type
    }

    public static func == (lhs: ModuleDefinition, rhs: ModuleDefinition) -> Bool { lhs === rhs }
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
}
