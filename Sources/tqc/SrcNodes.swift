import TqcSystem

public final class SourceFile {
    public let filePath: String
    public let fileName: String

    public init(_ filePath: String) {
        self.filePath = filePath
        self.fileName = Path.getFileName(filePath)
    }
}

public final class NamespaceNode {
    public let name: String
    public let fullNamespace: String
    public var subNamespaces: [NamespaceNode] = []
    public var files: [SourceFile] = []

    public init(_ name: String, _ fullNamespace: String) {
        self.name = name
        self.fullNamespace = fullNamespace
    }
}
