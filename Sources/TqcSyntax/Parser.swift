import TqcDiagnostics
import TqcSystem

public final class Parser {
    private let diagnostics: DiagnosticBag

    private var lexer: Lexer! = nil
    private var peeked: TokenValue? = nil
    private var trivia: [TriviaNode] = []
    private var attributeNodes: [AttributeNode] = []

    public init(_ diagnostics: DiagnosticBag) {
        self.diagnostics = diagnostics
    }

    // MARK: Trivia Collections
    private let midDeclarationTrivia: [TokenKind] = [.comment, .lineFeed, .whitespace]
    private let midDeclarationConservativeTrivia: [TokenKind] = [.comment, .whitespace]
    private let midStatementTrivia: [TokenKind] = [.comment, .lineFeed, .whitespace]
    private let midExpressionTrivia: [TokenKind] = [.comment, .lineFeed, .whitespace]
    private let midExpressionConservativeTrivia: [TokenKind] = [.comment, .whitespace]

    public func parse(_ source: String) throws -> SyntaxTree {
        lexer = Lexer(source)
        peeked = nil
        return SyntaxTree(try parseRoot())
    }

    public func parseRoot() throws -> [SyntaxNode] {
        var declarations: [SyntaxNode] = []
        while true {
            try advanceTrivia(midDeclarationTrivia)
            if try atEnd() { break }
            declarations.append(try parseDeclaration([
                .import, .attributes, .field, .struct, .typedef,
            ]))
        }
        return declarations
    }

    private func parseDeclaration(_ allowedDeclarations: ScopeAllowedDeclarations) throws -> SyntaxNode {
        while allowedDeclarations.contains(.attributes) {
            if try check(.at) {
                let attribute = try parseAttribute()
                attributeNodes.append(attribute)
                try advanceTrivia(midDeclarationTrivia)
                continue
            }
            break
        }

        if allowedDeclarations.contains(.field), try checkKeyword("let") { return try parseFieldDeclaration() }
        if allowedDeclarations.contains(.field), try checkKeyword("const") { return try parseFieldDeclaration() }

        if allowedDeclarations.contains(.import), try checkKeyword("from") { return try parseImportDefinition() }
        if try checkKeyword("func") { return try parseFunctionDeclaration() }
        if allowedDeclarations.contains(.struct), try checkKeyword("struct") { return try parseStructDeclaration() }
        if allowedDeclarations.contains(.typedef), try checkKeyword("typedef") { return try parseTypedefDeclaration() }

        if allowedDeclarations.contains(.constructor), try checkKeyword("constructor") { return try parseConstructorDeclaration() }
        if allowedDeclarations.contains(.destructor), try checkKeyword("destructor") { return try parseDestructorDeclaration() }

        if allowedDeclarations.contains(.case), try checkKeyword("case") { return try parseCaseDeclaration() }

        let token = try advance()
        print("'\(token.value)' (\(token.kind))")
        throw NotImplementedException(token.value)
    }

    // MARK: declarations - entities
    private func parseImportDefinition() throws -> ImportDefinitionNode {
        let fromKeyword = try expectNode("from", "'from' keyword")
        try advanceTrivia([.whitespace])
        let namespaceIdentifier = try parseCompoundIdentifier()
        try advanceTrivia(midDeclarationTrivia)
        let importKeyword = try expectNode("import", "'import' keyword")
        try advanceTrivia([.whitespace])

        if try !check(.leftBrace) {
            return ImportDefinitionNode(fromKeyword, namespaceIdentifier, importKeyword, nil)
        }

        let leftBrace = try expectNode(.leftBrace, "open brace ('{')")
        try advanceTrivia(midExpressionTrivia)
        let importsList = try parseCommaSeparatedIdentifierCollection(.rightBrace)
        try advanceTrivia(midExpressionTrivia)
        let rightBrace = try expectNode(.rightBrace, "close brace ('}')")
        let imports = MembersCollectionNode(leftBrace, importsList, rightBrace)

        return ImportDefinitionNode(fromKeyword, namespaceIdentifier, importKeyword, imports)
    }

    private func parseFunctionDeclaration() throws -> FunctionDeclarationNode {
        let funcKeyword = try expectNode("func", "'func' keyword")
        try advanceTrivia([.whitespace])
        let nameIdentifier = try parseSingleIdentifier()
        try advanceTrivia(midDeclarationTrivia)
        let parameters = try parseParameters()
        try advanceTrivia(midDeclarationTrivia)

        var returnType: ExpressionNode? = nil
        if try peekKind() != .leftBrace {
            returnType = try parseExpression()
            try advanceTrivia(midDeclarationTrivia)
        }

        let body = try parseScope()
        try advanceTrivia(midDeclarationTrivia)

        return FunctionDeclarationNode(
            attributeNodes.dump(),
            funcKeyword,
            nameIdentifier,
            parameters,
            returnType,
            body
        )
    }

    private func parseStructDeclaration() throws -> StructDeclarationNode {
        let structKeyword = try expectNode("struct", "'struct' keyword")
        try advanceTrivia([.whitespace])
        let nameIdentifier = try parseSingleIdentifier()
        try advanceTrivia(midDeclarationTrivia)

        var parameters: ParametersCollectionNode? = nil

        var extends: (extends: SyntaxNode, type: ExpressionNode)? = nil

        if try check(.leftParenthesis) {
            parameters = try parseParameters()
            try advanceTrivia(midDeclarationTrivia)
        }

        if try checkKeyword("extends") {
            let extendsKeyword = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let extendsType = try parseExpression()
            extends = (extends: extendsKeyword, type: extendsType)
            try advanceTrivia(midDeclarationTrivia)
        }

        let body = try parseStructContent()

        return StructDeclarationNode(
            attributeNodes.dump(),
            structKeyword,
            nameIdentifier,
            parameters,
            extends,
            body
        )
    }

    private func parseTypedefDeclaration() throws -> TypedefDeclaration {
        let structKeyword = try expectNode("typedef", "'typedef' keyword")
        try advanceTrivia([.whitespace])
        let nameIdentifier = try parseSingleIdentifier()
        try advanceTrivia(midDeclarationTrivia)

        let body = try parseTypedefContent()

        return TypedefDeclaration(
            attributeNodes.dump(),
            structKeyword,
            nameIdentifier,
            body
        )
    }

    private func parseFieldDeclaration() throws -> SyntaxNode {
        let letKeyword: TokenNode
        var firstExpression: ExpressionNode? = nil
        var secondExpression: IdentifierExpressionNode? = nil

        letKeyword = try expectNode("let", "'let' keyword")
        try advanceTrivia([.whitespace])

        firstExpression = try parseExpression()
        try advanceTrivia(midDeclarationTrivia)

        if try !check(.equals) && !check(.lineFeed) {
            secondExpression = try parseSingleIdentifier()
            try advanceTrivia(midDeclarationTrivia)
        }

        if try check(.equals) {
            let equals = try advanceNode()
            try advanceTrivia(midDeclarationTrivia)
            let value = try parseExpression()

            if secondExpression != nil && !(firstExpression is IdentifierExpressionNode) {
                throw NotImplementedException()
            }

            if secondExpression == nil {
                secondExpression = try castToIdentifier(firstExpression)
                firstExpression = nil
            }

            return FieldDeclarationNode(
                attributeNodes.dump(),
                letKeyword,
                firstExpression,
                secondExpression!,
                equals,
                value
            )
        }

        if try check(.leftBracket) {
            throw NotImplementedException("Properties")
        }

        if secondExpression == nil && !(firstExpression is IdentifierExpressionNode) {
            throw NotImplementedException()
        }

        if secondExpression == nil {
            secondExpression = try castToIdentifier(firstExpression)
            firstExpression = nil
        }

        return FieldDeclarationNode(
            attributeNodes.dump(),
            letKeyword,
            firstExpression,
            secondExpression!,
            nil,
            nil
        )
    }

    private func parseConstructorDeclaration() throws -> ConstructorDeclarationNode {
        let ctorKeyword = try expectNode("constructor", "'constructor' keyword")
        try advanceTrivia(midDeclarationTrivia)

        let parameters = try parseParameters()
        try advanceTrivia(midDeclarationTrivia)

        var returnType: ExpressionNode? = nil
        if try peekKind() != .leftBrace {
            returnType = try parseExpression()
            try advanceTrivia(midDeclarationTrivia)
        }

        let body = try parseScope()
        try advanceTrivia(midDeclarationTrivia)

        return ConstructorDeclarationNode(
            attributeNodes.dump(),
            ctorKeyword,
            parameters,
            returnType,
            body
        )
    }

    private func parseDestructorDeclaration() throws -> DestructorDeclarationNode {
        let dtorKeyword = try expectNode("destructor", "'destructor' keyword")
        try advanceTrivia(midDeclarationTrivia)

        let parameters = try parseParameters()
        try advanceTrivia(midDeclarationTrivia)

        var returnType: ExpressionNode? = nil
        if try peekKind() != .leftBrace {
            returnType = try parseExpression()
            try advanceTrivia(midDeclarationTrivia)
        }

        let body = try parseScope()
        try advanceTrivia(midDeclarationTrivia)

        return DestructorDeclarationNode(
            attributeNodes.dump(),
            dtorKeyword,
            parameters,
            returnType,
            body
        )
    }

    private func parseCaseDeclaration() throws -> TypedefCaseDeclaration {
        let caseKeyword = try expectNode("case", "'case' keyword")
        try advanceTrivia(midDeclarationConservativeTrivia)

        if try peekKind() == .integerNumberLiteral {
            var items: [(value: IntegerLiteralExpressionNode, comma: TokenNode?)] = []
            while try !atEnd() {
                if try !check(.integerNumberLiteral) {
                    throw error(try peekNonNull(), "Expected integer number literal")
                }
                let integer = try IntegerLiteralExpressionNode(try advanceNode())
                try advanceTrivia(midExpressionTrivia)

                var comma: TokenNode? = nil
                if try check(.comma) {
                    comma = try advanceNode()
                    try advanceTrivia(midExpressionTrivia)
                }

                items.append((value: integer, comma: comma))
                if comma == nil { break }
            }

            return TypedefNumberedCaseDeclaration(attributeNodes.dump(), caseKeyword, items)
        }

        _ = try parseSingleIdentifier() // identifier
        let cp = saveCheckpoint()
        try advanceTrivia(midDeclarationTrivia)

        try rollback(cp)
        throw NotImplementedException()
    }

    // MARK: declarations - misc

    private func parseAttribute() throws -> AttributeNode {
        let at = try expectNode(.at, "At ('@')")
        let name = try parseSingleIdentifier()
        var arguments: ArgumentsCollectionNode? = nil
        if try check(.leftParenthesis) { arguments = try parseArgumentCollection() }

        return AttributeNode(at, name, arguments)
    }

    private func parseParameters() throws -> ParametersCollectionNode {
        let leftParameters = try expectNode(.leftParenthesis, "open parenthesis ('(')")
        try advanceTrivia(midDeclarationTrivia)
        var parameters: [(node: ParameterNode, comma: TokenNode?)] = []

        while try !atEnd() {
            if try peekKind() == .rightParenthesis { break }

            let type = try parseExpression()
            try advanceTrivia(midDeclarationTrivia)
            let name = try parseSingleIdentifier()
            try advanceTrivia(midDeclarationTrivia)
            var comma: TokenNode? = nil

            if try peekKind() == .comma {
                comma = try advanceNode()
                try advanceTrivia(midDeclarationTrivia)
            }

            parameters.append((node: ParameterNode(type, name), comma: comma))
        }

        let rightParameters = try expectNode(.rightParenthesis, "close parenthesis (')')")

        return ParametersCollectionNode(leftParameters, parameters, rightParameters)
    }

    private func parseStructContent() throws -> BlockNode {
        var content: [SyntaxNode] = []

        let start = try expectNode(.leftBrace, "'{'")
        try advanceTrivia(midDeclarationTrivia)

        while try !atEnd() && !check(.rightBrace) {
            content.append(try parseDeclaration([
                .attributes, .field, .constructor, .destructor,
            ]))
        }
        try advanceTrivia(midDeclarationTrivia)

        let end = try expectNode(.rightBrace, "'}'")
        try advanceTrivia(midDeclarationTrivia)

        return BlockNode(start, content, end)
    }

    private func parseTypedefContent() throws -> BlockNode {
        var content: [SyntaxNode] = []

        let start = try expectNode(.leftBrace, "'{'")
        try advanceTrivia(midDeclarationTrivia)

        while try !atEnd() && !check(.rightBrace) {
            content.append(try parseDeclaration([
                .attributes, .field, .case,
            ]))
        }
        try advanceTrivia(midDeclarationTrivia)

        let end = try expectNode(.rightBrace, "'}'")
        try advanceTrivia(midDeclarationTrivia)

        return BlockNode(start, content, end)
    }

    // MARK: statements

    private func parseStatement() throws -> StatementNode {
        let statement: StatementNode
        try advanceTrivia(midStatementTrivia)

        // Conditionals
        if try checkKeyword("if") { statement = try parseIfStatement() }
        else if try checkKeyword("elif") { statement = try parseElifStatement() }
        else if try checkKeyword("else") { statement = try parseElseStatement() }

        // Misc
        else if try checkKeyword("return") { statement = try parseReturnStatement() }
        else if try check(.leftBrace) { statement = try parseScope() }

        else { statement = try parseExpressionStatement() }

        try advanceTrivia([.whitespace])
        if try check(.semicolon) || check(.lineFeed) { try advanceTrivia() }
        else if try !check(.rightBrace) { _ = try expect(.lineFeed, "Line feed after statement") }

        try advanceTrivia(midStatementTrivia)
        return statement
    }

    // statements - conditionals
    private func parseIfStatement() throws -> IfStatementNode {
        let ifKeyword = try expectNode("if", "'if' keyword")
        try advanceTrivia([.whitespace])
        let condition = try parseExpression()
        try advanceTrivia(midDeclarationTrivia)
        let thenBranch = try parseStatement()

        return IfStatementNode(ifKeyword, condition, thenBranch)
    }

    private func parseElifStatement() throws -> ElifStatementNode {
        let ifKeyword = try expectNode("elif", "'elif' keyword")
        try advanceTrivia([.whitespace])
        let condition = try parseExpression()
        try advanceTrivia(midDeclarationTrivia)
        let thenBranch = try parseStatement()

        return ElifStatementNode(ifKeyword, condition, thenBranch)
    }

    private func parseElseStatement() throws -> ElseStatementNode {
        let ifKeyword = try expectNode("else", "'else' keyword")
        try advanceTrivia(midDeclarationTrivia)
        let thenBranch = try parseStatement()

        return ElseStatementNode(ifKeyword, thenBranch)
    }

    // statements - misc
    private func parseReturnStatement() throws -> ReturnStatementNode {
        let start = try expectNode("return", "'return' keyword")
        try advanceTrivia([.whitespace])
        let value: ExpressionNode? = try check(.lineFeed) ? nil : try parseExpression()

        return ReturnStatementNode(start, value)
    }

    private func parseScope() throws -> ScopeNode {
        var content: [StatementNode] = []

        let start = try expectNode(.leftBrace, "'{'")
        while try !atEnd() && !check(.rightBrace) { content.append(try parseStatement()) }
        let end = try expectNode(.rightBrace, "'}'")

        return ScopeNode(start, content, end)
    }

    private func parseExpressionStatement() throws -> ExpressionStatementNode {
        return ExpressionStatementNode(try parseExpression())
    }

    // MARK: expressions

    private func parseExpression() throws -> ExpressionNode { try parseAssignment() }
    private func parseType() throws -> ExpressionNode { try parseAdditive() }

    private func parseAssignment() throws -> ExpressionNode {
        let left = try parseEquality()
        let cp = saveCheckpoint()
        try advanceTrivia(midExpressionTrivia)

        if let tok = try peek(), isAssignOp(tok.kind) {
            let op = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let right = try parseAssignment()
            return AssignmentExpressionNode(left, op, right)
        }
        try rollback(cp)

        return left
    }

    private func parseEquality() throws -> ExpressionNode {
        var left = try parseRelational()
        let cp = saveCheckpoint()
        try advanceTrivia(midExpressionTrivia)

        while try peekKindIsOneOf(.equalsEquals, .exactEquals, .notEqualsEquals, .notExactEquals) {
            let op = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let right = try parseEquality()
            left = BinaryExpressionNode(left, op, right)
        }

        try rollback(cp)
        return left
    }

    private func parseRelational() throws -> ExpressionNode {
        var left = try parseAdditive()
        let cp = saveCheckpoint()
        try advanceTrivia(midExpressionTrivia)

        while try peekKindIsOneOf(.leftAngle, .rightAngle, .lessEqual, .greaterEqual) {
            let op = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let right = try parseAdditive()
            left = BinaryExpressionNode(left, op, right)
        }

        try rollback(cp)
        return left
    }

    private func parseAdditive() throws -> ExpressionNode {
        var left = try parseMultiplicative()
        let cp = saveCheckpoint()
        try advanceTrivia(midExpressionTrivia)

        while try peekKindIsOneOf(.plus, .minus, .addWrap, .subWrap, .addOnBounds, .subOnBounds) {
            let op = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let right = try parseMultiplicative()
            left = BinaryExpressionNode(left, op, right)
        }

        try rollback(cp)
        return left
    }

    private func parseMultiplicative() throws -> ExpressionNode {
        var left = try parsePrefix()
        let cp = saveCheckpoint()
        try advanceTrivia(midExpressionTrivia)

        while try peekKindIsOneOf(.star, .slash, .rest, .mulWrap, .mulOnBounds, .divFloor, .divCeil) {
            let op = try advanceNode()
            try advanceTrivia(midExpressionTrivia)
            let right = try parsePrefix()
            left = BinaryExpressionNode(left, op, right)
        }

        try rollback(cp)
        return left
    }

    private func parsePrefix() throws -> ExpressionNode {
        switch try peekKind() {
        case .star:
            let starNode = try advanceNode()
            let type = try parsePrefix()
            return ReferenceTypeModifierNode(starNode, type)

        case .leftBracket:
            let leftBracket = try advanceNode()
            let rightBracket = try expectNode(.rightBracket, "Right bracket (']')")
            let type = try parsePrefix()
            return SliceTypeModifierNode(leftBracket, rightBracket, type)

        case .bang, .minus, .increment, .decrement:
            let op = try advanceNode()
            let operand = try parsePrefix()
            return UnaryPrefixExpressionNode(op, operand)

        default:
            break
        }

        return try parsePostfix()
    }

    private func parsePostfix() throws -> ExpressionNode {
        var expr = try parsePrimary()

        while true {
            let cp = saveCheckpoint()
            try advanceTrivia(midExpressionTrivia)

            if try check(.leftParenthesis) {
                let args = try parseArgumentCollection()
                expr = CallExpressionNode(expr, args)

                continue
            }

            if try check(.leftBracket) {
                // (sic) o original espera LeftParenthesis aqui
                let leftBracket = try expectNode(.leftParenthesis, "open bracket ('[')")
                try advanceTrivia(midExpressionTrivia)
                let args = try parseCommaSeparatedExpressionCollection()
                try advanceTrivia(midExpressionTrivia)
                let rightBracket = try expectNode(.leftParenthesis, "close bracket (']')")
                expr = IndexExpressionNode(expr, IndexCollectionNode(leftBracket, args, rightBracket))

                continue
            }

            if try check(.dot) {
                let dot = try advanceNode()
                try advanceTrivia(midExpressionTrivia)
                let member = try parseSingleIdentifier()
                expr = MemberAccessExpressionNode(expr, dot, member)

                continue
            }

            if let postOp = try peek(), postOp.kind == .increment || postOp.kind == .decrement {
                let op = try advanceNode()
                expr = UnaryPostfixExpressionNode(expr, op)

                break
            }

            if try checkKeyword("as") {
                let op = try advanceNode()
                try advanceTrivia(midExpressionTrivia)
                let operand = try parseExpression()
                expr = ConversionExpressionNode(expr, op, operand)

                break
            }

            try rollback(cp)
            break
        }

        return expr
    }

    private func parsePrimary() throws -> ExpressionNode {
        if try checkKeyword("let") {
            let letKeyword: TokenNode
            var firstExpression: ExpressionNode?
            var secondExpression: IdentifierExpressionNode? = nil

            letKeyword = try expectNode("let", "'let' keyword")
            try advanceTrivia([.whitespace])

            firstExpression = try parseType()
            try advanceTrivia(midDeclarationTrivia)

            if try !check(.equals) && !check(.lineFeed) {
                secondExpression = try parseSingleIdentifier()
                try advanceTrivia(midDeclarationTrivia)
            }

            if secondExpression == nil && !(firstExpression is IdentifierExpressionNode) {
                throw NotImplementedException()
            }

            if secondExpression == nil {
                secondExpression = try castToIdentifier(firstExpression)
                firstExpression = nil
            }

            return LocalExpressionNode(letKeyword, firstExpression, secondExpression!)
        }

        if try checkKeyword("new") {
            let keyword = try advanceNode()
            try advanceTrivia(midExpressionConservativeTrivia)

            let expr = try parseExpression()
            let cp = saveCheckpoint()

            if try check(.leftParenthesis) {
                return NewExpressionNode(keyword, expr, try parseArgumentCollection())
            }

            if let callExpr = expr as? CallExpressionNode {
                try rollback(cp)
                return NewExpressionNode(keyword, callExpr.callee, callExpr.arguments)
            }

            throw NotImplementedException()
        }

        if try peekKind() == .integerNumberLiteral {
            return try IntegerLiteralExpressionNode(try advanceNode())
        }

        if try peekKind() == .floatingNumberLiteral {
            return try DecimalLiteralExpressionNode(try advanceNode())
        }

        if try check(.identifier) {
            return try parseSingleIdentifier()
        }

        if try check(.leftParenthesis) {
            let open = try expectNode(.leftParenthesis, "open parenthesis ('(')")
            try advanceTrivia(midExpressionTrivia)
            let expr = try parseExpression()
            try advanceTrivia(midExpressionTrivia)
            let close = try expectNode(.rightParenthesis, "close parenthesis (')')")
            return ParenthesisExpressionNode(open, expr, close)
        }

        if try check(.doubleQuote) { return try parseStringExpression() }

        if let bad = try peek() { throw error(bad, "Invalid expression") }
        throw EndOfStreamException("Expected expression, found End of Stream")
    }

    private func parseStringExpression() throws -> StringExpressionNode {
        let oldMode = lexer.mode
        lexer.mode = .string

        var content: [StringContentNode] = []

        let open = try expectNode(.doubleQuote, "double quotes ('\"')")
        while try !atEnd() && !check(.doubleQuote) {
            if try check(.stringLiteral) { content.append(StringLiteralNode(try advanceNode())) }
            if try check(.escapedCharacter) { content.append(StringCharacterLiteralNode(try advanceNode())) }
        }
        let close = try expectNode(.doubleQuote, "double quotes ('\"')")

        lexer.mode = oldMode
        return StringExpressionNode(open, content, close)
    }

    private func parseCompoundIdentifier() throws -> CompoundIdentifierExpressionNode {
        var arguments: [(token: TokenNode, dot: TokenNode?)] = []
        while try !atEnd() {
            let identifier = try expectNode(.identifier, "identifier")
            try advanceTrivia(midExpressionTrivia)
            var dot: TokenNode? = nil
            if try check(.dot) { dot = try advanceNode() }

            arguments.append((token: identifier, dot: dot))
            if dot == nil { break }
        }
        return CompoundIdentifierExpressionNode(arguments)
    }

    private func parseSingleIdentifier() throws -> IdentifierExpressionNode {
        let tok = try expect(.identifier, "identifier")
        return IdentifierExpressionNode(TokenNode(trivia.dump(), tok))
    }

    private func parseCommaSeparatedExpressionCollection(
        _ alsoBreaksAt: TokenKind...
    ) throws -> [(node: ExpressionNode, comma: TokenNode?)] {
        var arguments: [(node: ExpressionNode, comma: TokenNode?)] = []

        while try !atEnd() {
            if try peekKind() == .rightParenthesis { break }

            let exp = try parseExpression()
            try advanceTrivia(midExpressionTrivia)
            var comma: TokenNode? = nil

            if try peekKind() == .comma {
                comma = try advanceNode()
                try advanceTrivia(midExpressionTrivia)
            }

            arguments.append((node: exp, comma: comma))
            if try alsoBreaksAt.contains(peekKind()) { break }
        }

        return arguments
    }

    private func parseCommaSeparatedIdentifierCollection(
        _ alsoBreaksAt: TokenKind...
    ) throws -> [(node: IdentifierExpressionNode, comma: TokenNode?)] {
        var identifiers: [(node: IdentifierExpressionNode, comma: TokenNode?)] = []

        while try !atEnd() {
            if try peekKind() == .leftParenthesis { break }

            let identifier = try parseSingleIdentifier()
            try advanceTrivia(midExpressionTrivia)
            var comma: TokenNode? = nil

            if try check(.comma) {
                comma = try advanceNode()
                try advanceTrivia(midExpressionTrivia)
            }

            identifiers.append((node: identifier, comma: comma))
            if try alsoBreaksAt.contains(peekKind()) { break }
        }

        return identifiers
    }

    private func parseArgumentCollection() throws -> ArgumentsCollectionNode {
        let leftParenthesis = try expectNode(.leftParenthesis, "open parenthesis ('(')")
        try advanceTrivia(midExpressionTrivia)
        let args = try parseCommaSeparatedExpressionCollection()
        try advanceTrivia(midExpressionTrivia)
        let rightParenthesis = try expectNode(.rightParenthesis, "close parenthesis (')')")
        return ArgumentsCollectionNode(leftParenthesis, args, rightParenthesis)
    }

    private func isAssignOp(_ kind: TokenKind) -> Bool {
        switch kind {
        case .equals, .addAssign, .subAssign, .mulAssign, .divAssign, .restAssign: return true
        default: return false
        }
    }

    // MARK: Helpers

    private func peek() throws -> TokenValue? {
        do {
            if peeked == nil { peeked = try lexer.nextToken() }
            return peeked
        } catch is EndOfStreamException {
            peeked = nil
            return nil
        }
    }

    private func peekKind() throws -> TokenKind {
        if peeked == nil { peeked = try lexer.nextToken() }
        return peeked?.kind ?? .eof
    }

    private func peekKindIsOneOf(_ kinds: TokenKind...) throws -> Bool {
        return try kinds.contains(peekKind())
    }

    // `Peek()!.Value` — Nullable<T>.Value lança InvalidOperationException se nulo
    private func peekNonNull() throws -> TokenValue {
        guard let t = try peek() else {
            throw InvalidOperationException("Nullable object must have a value.")
        }
        return t
    }

    private func atEnd() throws -> Bool { try peek() == nil }

    private func advance() throws -> TokenValue {
        guard let tok = try peek() else { throw EndOfStreamException("Reached End Of File") }
        peeked = nil
        return tok
    }

    private func advanceNode() throws -> TokenNode {
        guard let tok = try peek() else { throw EndOfStreamException("Reached End Of File") }
        peeked = nil
        return TokenNode(trivia.dump(), tok)
    }

    private func advanceTrivia() throws {
        guard let tok = try peek() else { return }
        peeked = nil
        trivia.append(TriviaNode(tok))
    }

    private func advanceTrivia(_ kinds: [TokenKind]) throws {
        while try !atEnd() {
            let node = try peekKind()
            if !kinds.contains(node) { break }
            try advanceTrivia()
        }
    }

    private func check(_ kind: TokenKind) throws -> Bool {
        if let t = try peek() { return t.kind == kind }
        return false
    }

    private func checkKeyword(_ word: String) throws -> Bool {
        if let t = try peek() { return t.kind == .identifier && t.value == word }
        return false
    }

    private func expect(_ kind: TokenKind, _ expected: String) throws -> TokenValue {
        if try check(kind) { return try advance() }
        if let t = try peek() { throw error(t, "Expected '\(expected)', found '\(t.value)'") }
        throw EndOfStreamException("Expected '\(expected)', found End Of File")
    }

    private func expectNode(_ keyword: String, _ expected: String) throws -> TokenNode {
        if try checkKeyword(keyword) { return TokenNode(trivia.dump(), try advance()) }
        if let t = try peek() { throw error(t, "Expected '\(expected)', found '\(t.value)'") }
        throw EndOfStreamException("Expected '\(expected)', found End Of File")
    }

    private func expectNode(_ kind: TokenKind, _ expected: String) throws -> TokenNode {
        if try check(kind) { return TokenNode(trivia.dump(), try advance()) }
        if let t = try peek() { throw error(t, "Expected '\(expected)', found '\(t.value)'") }
        throw EndOfStreamException("Expected '\(expected)', found End Of File")
    }

    private typealias Checkpoint = (Int, TokenValue?, LexCheckpoint)

    private func saveCheckpoint() -> Checkpoint { (trivia.count, peeked, lexer.saveCheckpoint()) }

    private func rollback(_ cp: Checkpoint) throws {
        try trivia.removeRange(cp.0, trivia.count - cp.0)
        peeked = cp.1
        cp.2.restore()
    }

    private func error(_ tok: TokenValue, _ message: String) -> Error {
        return ParseException(message, tok.line, tok.column)
    }

    // (IdentifierExpressionNode)expr — ParseExpression nunca retorna null, então o ramo nil é inalcançável
    private func castToIdentifier(_ expr: ExpressionNode?) throws -> IdentifierExpressionNode {
        guard let expr, let id = expr as? IdentifierExpressionNode else {
            throw InvalidCastException("Specified cast is not valid.")
        }
        return id
    }

    private struct ScopeAllowedDeclarations: OptionSet {
        let rawValue: Int

        static let `import`     = ScopeAllowedDeclarations(rawValue: 1 << 0)
        static let `struct`     = ScopeAllowedDeclarations(rawValue: 1 << 1)
        static let typedef      = ScopeAllowedDeclarations(rawValue: 1 << 2)
        static let field        = ScopeAllowedDeclarations(rawValue: 1 << 3)
        static let `case`       = ScopeAllowedDeclarations(rawValue: 1 << 4)
        static let attributes   = ScopeAllowedDeclarations(rawValue: 1 << 5)
        static let constructor  = ScopeAllowedDeclarations(rawValue: 1 << 6)
        static let destructor   = ScopeAllowedDeclarations(rawValue: 1 << 7)
    }
}

public struct ParseException: SystemException {
    public let message: String
    public let line: Int
    public let column: Int

    public init(_ message: String, _ line: Int, _ column: Int) {
        self.message = "[\(line):\(column)] \(message)"
        self.line = line
        self.column = column
    }
}
