namespace Tqc.IR.ProgramMembers.Primitive;

public class PrimitiveStruct(
    string name
) : IStruct
{
    public string Name => name;
}
