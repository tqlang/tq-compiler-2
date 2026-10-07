public final class BuildManifest {
    public let directory: String

    public var outDirectory: String?
    public var cacheDirectory: String?

    public var project: ProjectDefinition?

    public var modules: [ModuleDefinition] = []

    public init(_ directory: String) {
        self.directory = directory
    }
}
