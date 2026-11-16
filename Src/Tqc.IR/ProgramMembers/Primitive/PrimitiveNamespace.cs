namespace Tqc.IR.ProgramMembers.Primitive;

public abstract class PrimitiveNamespace(string name) : INamespace
{
    public string Name => name;

    public abstract INamespace? TryGetNamespace(string namespaceName);
    public abstract IMember? TryGetMember(string memberName);
    public abstract IMember[] GetAllMembers();
}
