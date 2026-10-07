public enum TokenKind: String, CustomStringConvertible {

    case lineFeed = "LineFeed"
    case semicolon = "Semicolon"
    case whitespace = "Whitespace"
    case comment = "Comment"

    case floatingNumberLiteral = "FloatingNumberLiteral"
    case integerNumberLiteral = "IntegerNumberLiteral"
    case stringLiteral = "StringLiteral"
    case identifier = "Identifier"

    case escapedLeftBracket = "EscapedLeftBracket" // \{
    case escapedCharacter = "EscapedCharacter"

    case leftParenthesis = "LeftParenthesis"; case rightParenthesis = "RightParenthesis" // ( )
    case leftBrace = "LeftBrace"; case rightBrace = "RightBrace" // { }
    case leftBracket = "LeftBracket"; case rightBracket = "RightBracket" // [ ]
    case leftAngle = "LeftAngle"; case rightAngle = "RightAngle" // < >

    case questionMark = "QuestionMark" // ?
    case bang = "Bang" // !
    case at = "At" // @
    case comma = "Comma" // ,
    case dot = "Dot" // .
    case dotDot = "DotDot" // ..
    case colon = "Colon" // :
    case tilde = "Tilde" // ~
    case pipe = "Pipe" // |
    case ampersand = "Ampersand" // &
    case equals = "Equals" // =
    case quote = "Quote" // '
    case doubleQuote = "DoubleQuote" // "

    case equalsEquals = "EqualsEquals" // ==
    case exactEquals = "ExactEquals" // ===
    case notEqualsEquals = "NotEqualsEquals" // !=
    case notExactEquals = "NotExactEquals" // !==
    case lessEqual = "LessEqual" // <=
    case greaterEqual = "GreaterEqual" // >=

    case bitShiftLeft = "BitShiftLeft" // <<
    case bitShiftRight = "BitShiftRight" // >>

    case bitwiseAnd = "BitwiseAnd" // ⋏
    case bitwiseOr = "BitwiseOr" // ⋎
    case bitwiseXor = "BitwiseXor" // ⊕

    case plus = "Plus" // +
    case increment = "Increment" // ++
    case addWrap = "AddWrap" // +%
    case addOnBounds = "AddOnBounds" // +|
    case addAssign = "AddAssign" // +=

    case minus = "Minus" // -
    case decrement = "Decrement" // --
    case subWrap = "SubWrap" // -%
    case subOnBounds = "SubOnBounds" // -|
    case subAssign = "SubAssign" // -=

    case star = "Star" // *
    case mulWrap = "MulWrap" // *%
    case mulOnBounds = "MulOnBounds" // *|
    case mulAssign = "MulAssign" // *=

    case slash = "Slash" // /
    case divFloor = "DivFloor" // /_
    case divCeil = "DivCeil" // /^
    case divAssign = "DivAssign" // /=

    case rest = "Rest" // %
    case restAssign = "RestAssign" // %=

    case eof = "Eof"

    public var description: String { rawValue }
}
