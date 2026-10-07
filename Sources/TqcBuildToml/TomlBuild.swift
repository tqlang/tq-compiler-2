import Foundation
import TOMLKit
import TqcBuild
import TqcSystem

public enum TomlBuild {
    public static func load(_ manifestPath: String) throws -> BuildManifest {
        let manifestContent = try File.readAllText(manifestPath)
        let document = try TOMLTable(string: manifestContent)
        return try parseManifest(manifestPath, document)
    }

    private static func parseManifest(_ directory: String, _ root: TOMLTable) throws -> BuildManifest {
        // root["out-dir"].ToString() — o indexador lança KeyNotFoundException se a chave não existe
        let outDir = try require(root, "out-dir").string ?? ".tq-out"
        let cacheDir = try require(root, "cache-dir").string ?? ".tq-cache"

        var project: ProjectDefinition? = nil
        if let projectTable = root["project"]?.table {
            project = try parseProject(projectTable)
        }

        let manifest = BuildManifest(directory)
        manifest.outDirectory = outDir
        manifest.cacheDirectory = cacheDir
        manifest.project = project

        if let moduleValue = root["module"] {
            guard let modules = moduleValue.array else {
                throw Exception("'module' must be an array of tables.")
            }
            for value in modules {
                guard let table = value.table else {
                    throw InvalidCastException("Unable to cast object to type 'Tomlyn.Model.TomlTable'.")
                }
                manifest.modules.append(try parseModule(table))
            }
        }
        return manifest
    }

    private static func parseProject(_ projectTable: TOMLTable) throws -> ProjectDefinition {
        let name = try require(projectTable, "name")
        let target = try require(projectTable, "target")
        let root = try require(projectTable, "root")

        return ProjectDefinition(
            name: toStringValue(name),
            target: toStringValue(target),
            root: toStringValue(root)
        )
    }

    private static func parseModule(_ table: TOMLTable) throws -> ModuleDefinition {
        let module = ModuleDefinition(
            name: try getRequiredString(table, "name"),
            type: try getOptionalString(table, "type")
        )

        for (key, value) in table {
            switch key {
            case "name", "type":
                break

            case "dependencies":
                try parseDependencies(value, &module.dependencies)

            default:
                module.extraFields.updateValue(try convertValue(value), forKey: key)
            }
        }

        return module
    }

    private static func parseDependencies(_ value: TOMLValueConvertible, _ output: inout [ModuleDependency]) throws {
        guard let array = value.array else { throw Exception("'dependencies' must be an array.") }
        for item in array {
            guard let text = item.string else { throw Exception("Module dependency must be a string.") }
            output.append(try parseDependency(text))
        }
    }

    private static func parseDependency(_ text: String) throws -> ModuleDependency {
        let parts = text
            .split(separator: ":", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if parts.count == 2 && parts[0] == "module" {
            return ModuleReference(parts[1])
        }

        if parts.count == 3 && parts[0] == "dotnet", let parsedVersion = Version.tryParse(parts[2]) {
            return DotnetAssemblyReference(parts[1], parsedVersion)
        }

        throw Exception("Invalid module dependency '\(text)'.")
    }

    private static func convertValue(_ value: TOMLValueConvertible?) throws -> Any? {
        guard let value else { return nil }

        if let s = value.string { return s }
        if let b = value.bool { return b }
        if let i = value.int { return i }
        if let d = value.double { return d }

        if let array = value.array {
            return try array.map { try convertValue($0) }
        }

        if let table = value.table {
            var dict: [String: Any?] = [:]
            for (k, v) in table { dict.updateValue(try convertValue(v), forKey: k) }
            return dict
        }

        throw Exception("Unsupported TOML value: \(type(of: value))")
    }

    private static func getRequiredString(_ table: TOMLTable, _ key: String) throws -> String {
        guard let value = table[key] else { throw Exception("Missing required property '\(key)'.") }
        guard let text = value.string else { throw Exception("Property '\(key)' must be a string.") }
        return text
    }

    private static func getOptionalString(_ table: TOMLTable, _ key: String) throws -> String? {
        guard let value = table[key] else { return nil }
        guard let text = value.string else { throw Exception("Property '\(key)' must be a string.") }
        return text
    }

    // table["key"] do Tomlyn (lança se ausente)
    private static func require(_ table: TOMLTable, _ key: String) throws -> TOMLValueConvertible {
        guard let value = table[key] else {
            throw KeyNotFoundException("The given key '\(key)' was not present in the dictionary.")
        }
        return value
    }

    // object.ToString()
    private static func toStringValue(_ value: TOMLValueConvertible) -> String {
        if let s = value.string { return s }
        if let b = value.bool { return b ? "True" : "False" }
        if let i = value.int { return String(i) }
        if let d = value.double { return String(d) }
        return String(describing: value)
    }
}
