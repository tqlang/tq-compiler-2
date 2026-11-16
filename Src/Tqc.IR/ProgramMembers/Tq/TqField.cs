using Tqc.Core;
using Tqc.IR.Nodes;
using Tqc.IR.References;

namespace Tqc.IR.ProgramMembers.Tq;

public class TqField(
    IrExpression? type,
    string name,
    IrExpression? value,
    SourceLocation location
) : IField
{
    public SourceLocation SourceLocation => location;
    public string Name => name;
    
    public Ref GetReference() => throw new NotImplementedException();
    public override string ToString() => $"field {Name}";
}
