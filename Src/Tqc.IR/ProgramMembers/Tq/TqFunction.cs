using Tqc.Core;
using Tqc.IR.Nodes;

namespace Tqc.IR.ProgramMembers.Tq;

public class TqFunction(string name, SourceLocation location) : IFunction
{
    public SourceLocation SourceLocation => location;
    public string Name => name;
    public TqParameter[] Parameters { get; set; }
    public IrExpression? ReturnType { get; set; }

    public IrBody? Body { get; set; }
    
    public override string ToString() => $"func {Name}";
}
