public final class ProjectDefinition {
    public let name: String
    public let target: String
    public let root: String

    public init(name: String, target: String, root: String) {
        self.name = name
        self.target = target
        self.root = root
    }
}
