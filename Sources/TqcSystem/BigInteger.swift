// System.Numerics.BigInteger: apenas o necessário (Parse + ToString).

public struct BigInteger: CustomStringConvertible, Equatable {
    private var negative: Bool
    private var limbs: [UInt32]

    private init(negative: Bool, limbs: [UInt32]) {
        self.negative = negative
        self.limbs = limbs
    }

    public static func parse(_ text: String) throws -> BigInteger {
        let scalars = Array(text.unicodeScalars)
        var i = 0
        var end = scalars.count
        while i < end && scalars[i].properties.isWhitespace { i += 1 }
        while end > i && scalars[end - 1].properties.isWhitespace { end -= 1 }

        var neg = false
        if i < end && (scalars[i] == "+" || scalars[i] == "-") {
            neg = scalars[i] == "-"
            i += 1
        }
        if i >= end { throw FormatException("The value could not be parsed.") }

        var limbs: [UInt32] = []
        while i < end {
            let s = scalars[i]
            guard s.value >= 0x30 && s.value <= 0x39 else {
                throw FormatException("The value could not be parsed.")
            }
            var carry = UInt64(s.value - 0x30)
            for k in 0..<limbs.count {
                let v = UInt64(limbs[k]) * 10 + carry
                limbs[k] = UInt32(truncatingIfNeeded: v)
                carry = v >> 32
            }
            if carry > 0 { limbs.append(UInt32(carry)) }
            i += 1
        }
        while let last = limbs.last, last == 0 { limbs.removeLast() }
        return BigInteger(negative: neg && !limbs.isEmpty, limbs: limbs)
    }

    public var description: String {
        if limbs.isEmpty { return "0" }
        var work = limbs
        var chunks: [UInt32] = []
        while !work.isEmpty {
            var rem: UInt64 = 0
            var k = work.count - 1
            while k >= 0 {
                let cur = (rem << 32) | UInt64(work[k])
                work[k] = UInt32(cur / 1_000_000_000)
                rem = cur % 1_000_000_000
                k -= 1
            }
            chunks.append(UInt32(rem))
            while let l = work.last, l == 0 { work.removeLast() }
        }
        var result = negative ? "-" : ""
        result += String(chunks.last!)
        for c in chunks.dropLast().reversed() {
            let p = String(c)
            result += String(repeating: "0", count: 9 - p.count) + p
        }
        return result
    }
}
