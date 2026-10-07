import TqcBuild
import TqcSystem

public final class BuildPlanner {
    public init() {}

    public func createOrder(
        _ graph: InsertionOrderedDictionary<String, ModuleDefinition>,
        _ rootName: String
    ) -> [ModuleDefinition] {
        var result: [ModuleDefinition] = []
        var visiting = Set<ModuleDefinition>()
        var visited = Set<ModuleDefinition>()

        for (_, node) in graph {
            BuildPlanner.visit(node, &visiting, &visited, &result)
        }

        return result
    }

    private static func visit(
        _ node: ModuleDefinition,
        _ visiting: inout Set<ModuleDefinition>,
        _ visited: inout Set<ModuleDefinition>,
        _ result: inout [ModuleDefinition]
    ) {
        if !visited.insert(node).inserted { return }

        for dependency in node.dependencies {
            guard let moduleReference = dependency as? ModuleReference else { continue }
            visit(moduleReference.definition, &visiting, &visited, &result)
        }

        result.append(node)
    }
}
