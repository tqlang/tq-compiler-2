namespace Tqc.IR.ProgramMembers.Primitive;

public class PrimitiveModule(
    string name,
    TypesNamespace typesNamespace
) : IModule
{
    public readonly TypesNamespace TypesNamespace = typesNamespace;
    
    private PrimitiveModuleRootNamespace _rootNamespace = new (
        name, 
        typesNamespace
    );
    public INamespace RootNamespace => _rootNamespace;

    private class PrimitiveModuleRootNamespace(string name, params PrimitiveNamespace[] namespaces) : PrimitiveNamespace(name)
    {
        public override INamespace? TryGetNamespace(string namespaceName) => namespaces.Cast<INamespace>().FirstOrDefault(n => n.Name == namespaceName);
        public override IMember? TryGetMember(string memberName) => namespaces.Cast<IMember>().FirstOrDefault(m => m.Name == memberName);
        public override IMember[] GetAllMembers() => [.. namespaces.Cast<IMember>()];
    }
}
