import TqcSystem

public final class TypedefDeclaration: DeclarationNode {
    public let typedefKeyword: TokenNode
    public let name: IdentifierExpressionNode
    public let body: BlockNode

    public init(_ attributes: [AttributeNode], _ typedefKeyword: TokenNode, _ name: IdentifierExpressionNode, _ body: BlockNode) {
        self.typedefKeyword = typedefKeyword
        self.name = name
        self.body = body
        super.init(attributes)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendAttributesSyntaxNode(attributes)
            .appendSyntaxNode(typedefKeyword)
            .appendSyntaxNode(name)
            .appendSyntaxNode(body)
    }
}

public class TypedefCaseDeclaration: DeclarationNode {
    public let caseKeyword: TokenNode

    public init(_ attributes: [AttributeNode], _ caseKeyword: TokenNode) {
        self.caseKeyword = caseKeyword
        super.init(attributes)
    }
}

public final class TypedefNumberedCaseDeclaration: TypedefCaseDeclaration {
    public let integerLiterals: [(value: IntegerLiteralExpressionNode, comma: TokenNode?)]

    public init(
        _ attributes: [AttributeNode],
        _ caseKeyword: TokenNode,
        _ integerLiterals: [(value: IntegerLiteralExpressionNode, comma: TokenNode?)]
    ) {
        self.integerLiterals = integerLiterals
        super.init(attributes, caseKeyword)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        sb
            .appendAttributesSyntaxNode(attributes)
            .appendSyntaxNode(caseKeyword)

        for (v, c) in integerLiterals {
            sb.appendSyntaxNode(v).appendSyntaxNode(c)
        }

        return sb
    }
}

public class TypedefNamedCaseDeclaration: TypedefCaseDeclaration {
    public let name: IdentifierExpressionNode

    public init(_ attributes: [AttributeNode], _ caseKeyword: TokenNode, _ name: IdentifierExpressionNode) {
        self.name = name
        super.init(attributes, caseKeyword)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        return sb
            .appendAttributesSyntaxNode(attributes)
            .appendSyntaxNode(caseKeyword)
            .appendSyntaxNode(name)
    }
}

public final class TypedefNamedCaseWithValueDeclaration: TypedefNamedCaseDeclaration {
    public let equalsToken: TokenNode
    public let value: ExpressionNode

    public init(
        _ attributes: [AttributeNode],
        _ caseKeyword: TokenNode,
        _ name: IdentifierExpressionNode,
        _ equalsToken: TokenNode,
        _ value: ExpressionNode
    ) {
        self.equalsToken = equalsToken
        self.value = value
        super.init(attributes, caseKeyword, name)
    }

    @discardableResult
    override func appendSyntaxToStringBuilder(_ sb: StringBuilder) -> StringBuilder {
        // (sic) o original anexa Value antes de EqualsToken
        return sb
            .appendAttributesSyntaxNode(attributes)
            .appendSyntaxNode(caseKeyword)
            .appendSyntaxNode(name)
            .appendSyntaxNode(value)
            .appendSyntaxNode(equalsToken)
    }
}
