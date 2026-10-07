import Foundation
import TqcSystem

// Rune helpers (extension(Rune rune) { ... }) -> Unicode.Scalar
extension Unicode.Scalar {
    func isIdentifierStart() -> Bool {
        if value == 0x5F /* '_' */ { return true }
        switch properties.generalCategory {
        case .uppercaseLetter: return true
        case .lowercaseLetter: return true
        case .titlecaseLetter: return true
        case .modifierLetter:  return true
        case .otherLetter:     return true
        case .letterNumber:    return true
        default:               return false
        }
    }

    func isIdentifierPart() -> Bool {
        if isIdentifierStart() { return true }
        switch properties.generalCategory {
        case .decimalNumber:        return true
        case .nonspacingMark:       return true
        case .spacingMark:          return true
        case .connectorPunctuation: return true
        default:                    return false
        }
    }

    func isBinaryDigit() -> Bool {
        switch value {
        case 0x30, 0x31: return true // '0' '1'
        default:         return false
        }
    }

    func isOctalDigit() -> Bool {
        value >= 0x30 && value <= 0x37 // '0'...'7'
    }

    func isDecimalDigit() -> Bool {
        value >= 0x30 && value <= 0x39 // '0'...'9'
    }

    func isHexDigit() -> Bool {
        (value >= 0x30 && value <= 0x39)
            || (value >= 0x61 && value <= 0x66)
            || (value >= 0x41 && value <= 0x46)
    }

    /// Rune.ToLowerInvariant (mapeamento simples de caixa)
    func toLowerInvariant() -> Unicode.Scalar {
        let mapped = properties.lowercaseMapping.unicodeScalars
        if mapped.count == 1, let only = mapped.first { return only }
        return self
    }
}

// extension(StringBuilder sb) { ... }
extension StringBuilder {
    @discardableResult
    func appendAttributesSyntaxNode(_ attributeNodes: [AttributeNode]) -> StringBuilder {
        for attr in attributeNodes {
            appendSyntaxNode(attr)
        }
        return self
    }

    @discardableResult
    func appendSyntaxNode(_ node: SyntaxNode?) -> StringBuilder {
        guard let node else { return self }
        node.appendSyntaxToStringBuilder(self)
        return self
    }
}

extension Array {
    /// List<T>.Dump(): copia para array e limpa a lista.
    mutating func dump() -> [Element] {
        let array = self
        removeAll()
        return array
    }
}

extension Optional where Wrapped == String {
    func tabAll() -> String {
        guard let str = self else { return "<nil>" }
        let sb = StringBuilder()
        let lines = str.components(separatedBy: Environment.newLine)
        for l in lines {
            if l.isEmpty { sb.appendLine() }
            else { sb.appendLine("\t\(l)") }
        }

        if lines.count > 0 { sb.length -= Environment.newLine.utf16.count }
        return sb.toString()
    }
}
