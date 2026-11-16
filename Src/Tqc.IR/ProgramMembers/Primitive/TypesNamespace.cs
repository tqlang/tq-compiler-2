namespace Tqc.IR.ProgramMembers.Primitive;

public class TypesNamespace() : PrimitiveNamespace("Types") {
    
    public PrimitiveStruct Bool { get; init; }
    public PrimitiveStruct Char { get; init; }
    
    public PrimitiveStruct UInt8 { get; init; }
    public PrimitiveStruct UInt16 { get; init; }
    public PrimitiveStruct UInt32 { get; init; }
    public PrimitiveStruct UInt64 { get; init; }
    
    public PrimitiveStruct Int8 { get; init; }
    public PrimitiveStruct Int16 { get; init; }
    public PrimitiveStruct Int32 { get; init; }
    public PrimitiveStruct Int64 { get; init; }
    
    public PrimitiveStruct String { get; init; }
    
    public override INamespace? TryGetNamespace(string namespaceName) => throw new NotImplementedException();
    public override IMember? TryGetMember(string memberName) => throw new NotImplementedException();
    public override IMember[] GetAllMembers() => throw new NotImplementedException();
}
