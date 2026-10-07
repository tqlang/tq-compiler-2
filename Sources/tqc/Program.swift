import Foundation
import TqcBuild
import TqcBuildToml
import TqcDiagnostics
import TqcSemantics
import TqcSyntax
import TqcSystem

@main
class Program {
    static func main() throws {
        let args = Array(CommandLine.arguments.dropFirst())

        if args.count == 0 {
            print("Usage: tqc <operation> <...>")
            exit(1)
        }

        switch args[0] {
        case "build_toml":
            try build(Array(args[1...]))
            exit(0)

        default:
            break
        }

        exit(1)
    }

    static func build(_ args: [String]) throws {
        let manifestFile = Path.getFullPath(args.count > 0 ? args[0] : "./build.toml")
        print(manifestFile)
        if !File.exists(manifestFile) {
            throw NotImplementedException(
                "File not found in path '\(manifestFile)'. "
                + "Default BuildManifest not implemented."
            )
        }

        let manifest = try parseManifest(manifestFile)
        let modulesDictionary = try toDictionary(manifest.modules) { $0.name }

        for (_, module) in modulesDictionary {
            for i in 0..<module.dependencies.count {
                guard let moduleReference = module.dependencies[i] as? ModuleReference else { continue }
                guard let dep = modulesDictionary[moduleReference.name] else {
                    throw Exception("Module '\(moduleReference.name)' not found.")
                }
                module.dependencies[i] = ModuleReference(moduleReference.name, dep)
            }
        }

        let buildPlanner = BuildPlanner()
        let order = buildPlanner.createOrder(modulesDictionary, manifest.project!.root)
        let diagnostics = DiagnosticBag()

        for i in order {
            switch i.type {

            case "tq", nil:
                try buildTqModule(i, diagnostics)

            default:
                throw Exception("Unknown module type: \(i.type!)")
            }
        }

    }

    static func buildTqModule(_ module: ModuleDefinition, _ diagnostics: DiagnosticBag) throws {
        print("COMPILING \(module.name)...")

        guard let pathobj = module.extraFields["path"], let path = pathobj as? String else {
            throw UnreachableException("Expected 'path' field with value string inside '\(module.name)' module")
        }

        let tree = try DirectoryParser.buildTree(path, module.name)
        let moduleRoot = try parseNamespaceRecursively(tree, diagnostics)
        let syntaxModuleContainer = SyntaxModuleContainer(module.name, moduleRoot)
        SemanticAnalyser.resolve(syntaxModuleContainer)

        print("COMPILED \(module.name)")
    }


    private enum DirectoryParser {
        private static let fileExtension = ".tq" // "*.tq"

        static func buildTree(_ rootPath: String, _ moduleName: String) throws -> NamespaceNode {
            let rootFullPath = Path.getFullPath(rootPath)
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: rootFullPath, isDirectory: &isDir), isDir.boolValue else {
                throw DirectoryNotFoundException("Directory in path '\(rootPath)' not found")
            }

            let rootNode = NamespaceNode(Path.getFileName(rootFullPath), moduleName)
            try populateNode(rootNode, rootFullPath, moduleName)
            return rootNode
        }

        private static func populateNode(_ node: NamespaceNode, _ dirPath: String, _ currentNamespace: String) throws {
            let entries = try FileManager.default.contentsOfDirectory(atPath: dirPath)

            func isDirectory(_ name: String) -> Bool {
                var isDir: ObjCBool = false
                return FileManager.default.fileExists(atPath: dirPath + "/" + name, isDirectory: &isDir) && isDir.boolValue
            }

            // dirInfo.GetFiles("*.tq")
            for name in entries where name.hasSuffix(fileExtension) && !isDirectory(name) {
                node.files.append(SourceFile(dirPath + "/" + name))
            }

            // dirInfo.GetDirectories()
            for name in entries where isDirectory(name) {
                if name.hasPrefix(".") || name == "bin" || name == "obj" {
                    continue
                }

                let nextNamespace = currentNamespace.isEmpty
                    ? name
                    : "\(currentNamespace).\(name)"

                let childNode = NamespaceNode(name, nextNamespace)
                node.subNamespaces.append(childNode)

                try populateNode(childNode, dirPath + "/" + name, nextNamespace)
            }
        }
    }

    static func parseNamespaceRecursively(_ node: NamespaceNode, _ diagnostics: DiagnosticBag) throws -> SyntaxNamespaceContainer {
        let container = SyntaxNamespaceContainer(node.name)

        for file in node.files {
            let parser = Parser(diagnostics)
            let sourceText = try File.readAllText(file.filePath)
            let syntaxTree = try parser.parse(sourceText)
            container.trees.append(syntaxTree)
        }

        for subNamespace in node.subNamespaces {
            container.namespaces.append(try parseNamespaceRecursively(subNamespace, diagnostics))
        }

        container.namespaces.trimExcess()
        container.trees.trimExcess()
        return container
    }

    static func parseManifest(_ manifestPath: String) throws -> BuildManifest { try TomlBuild.load(manifestPath) }
}
