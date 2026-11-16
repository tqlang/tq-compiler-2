using System.Reflection;
using Tqc.IR.ProgramMembers;
using Tqc.IR.ProgramMembers.Primitive;

namespace Tqc.Semantics;

public class Primitives
{
    public static readonly IModule PrimitivesModule = BuildPrimitives();
    
    private static IModule BuildPrimitives()
    {
        return new PrimitiveModule("Builtin",
            BuildTypesNamespace()
        );
    }

    private static TypesNamespace BuildTypesNamespace()
    {
        var nmsp = new TypesNamespace
        {
            Bool = new PrimitiveStruct("bool"),
            Char = new PrimitiveStruct("char"),
            
            UInt8 = new PrimitiveStruct("UInt8"),
            UInt16 = new PrimitiveStruct("UInt16"),
            UInt32 = new PrimitiveStruct("UInt32"),   
            UInt64 = new PrimitiveStruct("UInt64"),
            
            Int8  = new PrimitiveStruct("Int8"),
            Int16 = new PrimitiveStruct("Int16"),
            Int32 = new PrimitiveStruct("Int32"),   
            Int64 = new PrimitiveStruct("Int64"),
            
            String = new PrimitiveStruct("String"),
        };
        
        return nmsp;
    }
}
