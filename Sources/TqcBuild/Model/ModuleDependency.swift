import TqcSystem

public class ModuleDependency {
    fileprivate init() {}
}

public final class ModuleReference: ModuleDependency {
    public let name: String
    public let definition: ModuleDefinition!

    /// `Definition = null!` no original.
    public init(_ name: String, _ definition: ModuleDefinition? = nil) {
        self.name = name
        self.definition = definition
        super.init()
    }
}

public final class DotnetAssemblyReference: ModuleDependency {
    public let name: String
    public let version: Version

    public init(_ name: String, _ version: Version) {
        self.name = name
        self.version = version
        super.init()
    }
}
