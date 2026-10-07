import TqcSystem

final class Lexer {
    private let source: [UInt16] // string do C# = UTF-16
    private var cursorPosition = 0
    private var lastPosition = 0

    private var line = 0
    private var column = 0

    var mode: LexerMode = .normal
    enum LexerMode { case normal, string }

    init(_ source: String) {
        self.source = Array(source.utf16)
    }

    func isEof() -> Bool { cursorPosition >= source.count }

    func nextToken() throws -> TokenValue {
        switch mode {
        case .normal: return try nextGenericToken()
        case .string: return try nextStringToken()
        }
    }

    private func nextGenericToken() throws -> TokenValue {
        let c = try nextRune()
        if c == " " || c == "\t" { return getTokenValue(.whitespace) }

        // case '\n' when NextRuneIf('\r'): / case '\r' when NextRuneIf('\n'): / case '\n' or '\r':
        if c == "\n" {
            if try nextRuneIf("\r") { return getTokenValue(.lineFeed) }
        }
        if c == "\r" {
            if try nextRuneIf("\n") { return getTokenValue(.lineFeed) }
        }
        if c == "\n" || c == "\r" {
            return getTokenValue(.lineFeed)
        }

        switch c {
        case ";": return getTokenValue(.semicolon)

        case "(": return getTokenValue(.leftParenthesis)
        case ")": return getTokenValue(.rightParenthesis)
        case "{": return getTokenValue(.leftBrace)
        case "}": return getTokenValue(.rightBrace)
        case "[": return getTokenValue(.leftBracket)
        case "]": return getTokenValue(.rightBracket)

        case "?": return getTokenValue(.questionMark)
        case "@": return getTokenValue(.at)
        case ":": return getTokenValue(.colon)

        case "'": return getTokenValue(.quote)
        case "\"": return getTokenValue(.doubleQuote)

        case ".":
            if try nextRuneIf(".") { return getTokenValue(.dotDot) }
            return getTokenValue(.dot)
        case ",": return getTokenValue(.comma)

        case "<":
            if try nextRuneIf("=") { return getTokenValue(.lessEqual) }
            if try nextRuneIf("<") { return getTokenValue(.bitShiftLeft) }
            return getTokenValue(.leftAngle)

        case ">":
            if try nextRuneIf("=") { return getTokenValue(.greaterEqual) }
            if try nextRuneIf(">") { return getTokenValue(.bitShiftRight) }
            return getTokenValue(.rightAngle)

        case "+":
            if try nextRuneIf("=") { return getTokenValue(.addAssign) }
            if try nextRuneIf("+") { return getTokenValue(.increment) }
            if try nextRuneIf("%") { return getTokenValue(.addWrap) }
            if try nextRuneIf("|") { return getTokenValue(.addOnBounds) }
            return getTokenValue(.plus)

        case "-":
            if try nextRuneIf("=") { return getTokenValue(.subAssign) }
            if try nextRuneIf("-") { return getTokenValue(.decrement) }
            if try nextRuneIf("%") { return getTokenValue(.subWrap) }
            if try nextRuneIf("|") { return getTokenValue(.subOnBounds) }
            return getTokenValue(.plus) // (sic) o original retorna TokenKind.Plus aqui

        case "*":
            if try nextRuneIf("=") { return getTokenValue(.mulAssign) }
            if try nextRuneIf("%") { return getTokenValue(.mulWrap) }
            if try nextRuneIf("|") { return getTokenValue(.mulOnBounds) }
            return getTokenValue(.star)

        case "/":
            if try nextRuneIf("=") { return getTokenValue(.divAssign) }
            if try nextRuneIf("_") { return getTokenValue(.divFloor) }
            if try nextRuneIf("^") { return getTokenValue(.divCeil) }
            return getTokenValue(.slash)

        case "%":
            if try nextRuneIf("=") { return getTokenValue(.restAssign) }
            return getTokenValue(.rest)

        case "=":
            if try nextRuneIf("=") {
                return getTokenValue(try nextRuneIf("=") ? .exactEquals : .equalsEquals)
            }
            return getTokenValue(.equals)

        case "!":
            if try nextRuneIf("=") {
                return getTokenValue(try nextRuneIf("=") ? .notExactEquals : .notEqualsEquals)
            }
            return getTokenValue(.bang)

        case "\u{22CF}": return getTokenValue(.bitwiseAnd) // ⋏
        case "\u{22CE}": return getTokenValue(.bitwiseOr)  // ⋎
        case "\u{2295}": return getTokenValue(.bitwiseXor) // ⊕

        default: break
        }

        if c.isDecimalDigit() {
            var numBase = 10
            var isFloating = false

            if c == "0" && !isEof() { // verify different bases
                switch try peekRune().toLowerInvariant() {
                case "x":
                    numBase = 16
                    _ = try nextRune()

                // case 'o':
                // {
                //     numBase = 8;
                //     NextChar();
                // } break;

                case "b":
                    numBase = 2
                    _ = try nextRune()

                default: break
                }
            }

            while !isEof() {
                let cc = try peekRune()
                if cc == "." {
                    if numBase != 10 || isFloating { break }

                    isFloating = true
                    _ = try nextRune()
                    continue
                }

                let d = try peekRune()
                if d != "_" {
                    if numBase == 10 && !d.isDecimalDigit() { break }
                    if numBase == 16 && !d.isHexDigit() { break }
                    if numBase == 2 && !d.isBinaryDigit() { break }
                }

                _ = try nextRune()
            }

            return getTokenValue(isFloating ? .floatingNumberLiteral : .integerNumberLiteral)
        }

        // Build identifier token
        if c.isIdentifierStart() {
            while try peekRune().isIdentifierPart() { _ = try nextRune() }
            return getTokenValue(.identifier)
        }

        // Build comment
        if c == "#" {
            if !isEof(), try peekRune() == "#" {
                _ = try nextRune()

                while !isEof() {
                    if try peekRune() == "#" {
                        let _ = cursorPosition // savedPos (não utilizado no original)
                        _ = try nextRune()

                        if !isEof(), try peekRune() == "#" {
                            _ = try nextRune()
                            if !isEof(), try peekRune() == "#" {
                                _ = try nextRune()
                                break
                            }
                        }
                    }

                    else { _ = try nextRune() }
                }
            }
            else {
                while !isEof(), try peekRune() != "\n", try peekRune() != "\r" { _ = try nextRune() }
            }

            return getTokenValue(.comment)
        }

        // unrecognized character
        throw NotImplementedException("unknown token \(String(Character(c))) at \(line):\(column)")
        // FIXME implement error handlers
        // try { throw new UnrecognizedCharacterException(c, i); }
        // catch (SyntaxException e) { currentSrc.ThrowError(e); }
    }

    private func nextStringToken() throws -> TokenValue {
        let c = try nextRune()
        switch c {
        case "'": return getTokenValue(.quote)
        case "\"": return getTokenValue(.doubleQuote)

        case "\\":
            let c2 = try nextRune()
            return getTokenValue(c2 == "{" ? .escapedLeftBracket : .escapedCharacter)

        default:
            // (sic) `while (IsEof())` no original
            outLabel: while isEof() {
                let c2 = try peekRune()
                switch c2 {
                case "\\", "\"", "'":
                    break outLabel
                default:
                    break
                }
                _ = try nextRune()
            }
            return getTokenValue(.stringLiteral)
        }
    }

    private func nextRuneIf(_ expected: Unicode.Scalar) throws -> Bool {
        if isEof() { return false }

        let position = cursorPosition
        let actual = try nextRune()
        if actual == expected { return true }

        cursorPosition = position
        return false
    }

    private func nextRune() throws -> Unicode.Scalar {
        if isEof() { throw EndOfStreamException() }

        let (rune, consumed) = try decode(at: cursorPosition)
        cursorPosition += consumed
        return rune
    }

    private func peekRune() throws -> Unicode.Scalar {
        if isEof() { throw EndOfStreamException() }

        return try decode(at: cursorPosition).0
    }

    // Rune.DecodeFromUtf16: qualquer coisa diferente de OperationStatus.Done vira InvalidDataException
    private func decode(at position: Int) throws -> (Unicode.Scalar, Int) {
        let u = source[position]
        if u < 0xD800 || u > 0xDFFF {
            return (Unicode.Scalar(UInt32(u))!, 1)
        }
        if u <= 0xDBFF, position + 1 < source.count {
            let u2 = source[position + 1]
            if u2 >= 0xDC00 && u2 <= 0xDFFF {
                let v = 0x10000 + ((UInt32(u) - 0xD800) << 10) + (UInt32(u2) - 0xDC00)
                return (Unicode.Scalar(v)!, 2)
            }
        }
        throw InvalidDataException("Invalid UTF-16 sequence at \(position)")
    }

    private func getTokenValue(_ kind: TokenKind) -> TokenValue {
        let units = Array(source[lastPosition..<cursorPosition])
        let value = String(decoding: units, as: UTF16.self)

        let token = TokenValue(value: value, kind: kind, line: line, column: column)
        lastPosition = cursorPosition

        var i = 0
        while i < units.count {
            let c = units[i]
            switch c {
            case 0x0D: // '\r'
                line += 1
                column = 0
                if i + 1 < units.count && units[i + 1] == 0x0A { i += 1 }

            case 0x0A: // '\n'
                line += 1
                column = 0

            default:
                column += 1
            }
            i += 1
        }

        return token
    }

    struct State {
        let cursorPosition: Int
        let lastPosition: Int
        let line: Int
        let column: Int
        let mode: LexerMode
    }

    func saveCheckpoint() -> LexCheckpoint {
        LexCheckpoint(State(cursorPosition: cursorPosition, lastPosition: lastPosition,
                            line: line, column: column, mode: mode), self)
    }

    func restore(_ state: State) {
        cursorPosition = state.cursorPosition
        lastPosition = state.lastPosition
        line = state.line
        column = state.column
        mode = state.mode
    }
}

public struct LexCheckpoint {
    private let lexer: Lexer
    private let state: Lexer.State

    init(_ state: Lexer.State, _ lexer: Lexer) {
        self.lexer = lexer
        self.state = state
    }

    public func restore() {
        lexer.restore(state)
    }
}

struct TokenValue {
    var value: String
    var kind: TokenKind
    var line: Int
    var column: Int
}
