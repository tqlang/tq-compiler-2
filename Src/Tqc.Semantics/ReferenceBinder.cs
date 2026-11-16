using Tqc.IR.Nodes;
using Tqc.IR.ProgramMembers;
using Tqc.IR.ProgramMembers.Tq;
using Tqc.IR.References;

namespace Tqc.Semantics;

internal static class ReferenceBinder
{
    public static void BindReferences(TqModule module, IModule[] dependencies)
    {
        var context = new ScopeContext();
        context.PushFrame();

        context.Add(module.RootNamespace);
        foreach (var i in dependencies) context.Add(i.RootNamespace);
        
        ExploreNamespace(context, module.RootNamespace);
        
        context.PopFrame();
    }

    private static void ExploreNamespace(ScopeContext ctx, TqNamespace namespaceNode)
    {
        foreach (var fs in namespaceNode.FileScopes) ExploreFileScope(ctx, fs);
        foreach (var (_, ns) in namespaceNode.Namespaces) ExploreNamespace(ctx, ns);
    }

    private static void ExploreFileScope(ScopeContext ctx, TqFileScope fileScope)
    {
        ctx.PushFrame();
        
        foreach (var i in fileScope.Imports) SearchImportedReferences(ctx, i);
        foreach (var (_, i) in fileScope.Members) ExploreMember(ctx, i);
        
        ctx.PopFrame();
    }

    private static void SearchImportedReferences(ScopeContext ctx, TqImportMember importMember)
    {
        var namespaceReference = importMember.NamespaceReference;
        
        var memberRef = ctx.TryGet(namespaceReference[0]);
        if (memberRef == null) throw new NotImplementedException($"No module named '{namespaceReference[0]}' ({importMember.Location})");
        if (memberRef is not NamespaceReference @namespaceMemberRef) throw new NotImplementedException($"'{namespaceReference[0]}' is not a namespace");
        var referredNamespace = namespaceMemberRef.Namespace;

        foreach (var i in namespaceReference[1..])
        {
            referredNamespace = referredNamespace.TryGetNamespace(i)
                ?? throw new NotImplementedException(
                    $"No namespace named '{i}' "
                    + $"at '{referredNamespace.Name}' ({importMember.Location})"
                );
        }

        if (importMember.Imports == null)
        {
            ctx.Add(referredNamespace.GetAllMembers());
            return;
        }

        foreach (var (alias, (_, reference)) in importMember.Imports)
        {
            var refe = referredNamespace.TryGetMember(reference);
            if (refe == null) throw new NotImplementedException($"'{reference}' is not a member of '{string.Join('.', namespaceReference)}'");
            ctx.AddWithAlias(refe, alias);
        }
    }

    private static void ExploreMember(ScopeContext ctx, IMember member)
    {
        switch (member)
        {
            case TqField field: ResolveField(ctx, field); break;
            case TqStruct @struct: ResolveStruct(ctx, @struct); break;
            case TqFunctionGroup @fng: ResolveFunctionGroup(ctx, @fng); break;
            case TqFunction @func: ResolveFunction(ctx, @func); break;
            default: throw new NotImplementedException();
        }
    }

    private static void ResolveField(ScopeContext ctx, TqField tqStruct)
    {
        //throw new NotImplementedException();
    }
    private static void ResolveStruct(ScopeContext ctx, TqStruct tqStruct)
    {
        //throw new NotImplementedException();
    }
    private static void ResolveFunctionGroup(ScopeContext ctx, TqFunctionGroup functionGroup)
    {
        foreach (var i in functionGroup) ResolveFunction(ctx, i);
    }
    private static void ResolveFunction(ScopeContext ctx, TqFunction function)
    {
        
        foreach (var p in function.Parameters)
        {
            //p.Type = Guard.Try(() => ResolveExpression(ctx, p.Type),); 
            if (p.DefaultValue != null) p.DefaultValue = ResolveExpression(ctx, p.DefaultValue);
        }
        
        if (function.ReturnType != null) function.ReturnType = ResolveExpression(ctx, function.ReturnType);
        if (function.Body != null) ResolveBody(ctx, function.Body);
    }

    private static void ResolveBody(ScopeContext ctx, IrBody body)
    {
        
    }
    
    private static IrExpression ResolveExpression(ScopeContext ctx, IrExpression expression)
    {
        throw new NotImplementedException();
    }

    private static Ref ResolveReference(ScopeContext ctx, string name)
    {
        throw new NotImplementedException();
    }
    
    private class ScopeContext
    {
        private List<(string name, Ref reference)> references = [];
        private Stack<int> frames = [];

        public void Add(IMember member) => references.Add((member.Name, member.GetReference()));
        public void Add(params IMember[] member)
        {
            foreach (var i in member) references.Add((i.Name, i.GetReference()));
        }
        public void AddWithAlias(IMember member, string alias) => references.Add((alias, member.GetReference()));

        public Ref? TryGet(string key)
        {
            for (var i = references.Count - 1; i >= 0; i--)
                if (references[i].name == key) return references[i].reference;
            return null;
        }
        
        public void PushFrame() => frames.Push(references.Count);
        public void PopFrame()
        {
            if (frames.Count == 0) throw new InvalidOperationException("No frame to pop");
            var start = frames.Pop();
            references.RemoveRange(start, references.Count - start);
        }
    }
}
