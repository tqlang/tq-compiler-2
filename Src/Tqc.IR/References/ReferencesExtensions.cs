using Tqc.IR.ProgramMembers;

namespace Tqc.IR.References;

public static class ReferencesExtensions
{
    extension(IMember member)
    {
        public Ref GetReference() => member switch
        {
            IType t => new TypeMetaReference(t),
            INamespace n => new NamespaceReference(n),
            IFunction f => new FunctionTypeReference(f),
            IFunctionGroup f => new FunctionGroupTypeReference(f),
            _       => throw new NotImplementedException(),
        };
    }
}
