import Foundation

// System.Version
public struct Version: CustomStringConvertible, Hashable {
    public let major: Int
    public let minor: Int
    public let build: Int     // -1 = indefinido
    public let revision: Int  // -1 = indefinido

    public init(_ major: Int, _ minor: Int, _ build: Int = -1, _ revision: Int = -1) {
        self.major = major
        self.minor = minor
        self.build = build
        self.revision = revision
    }

    public static func tryParse(_ input: String) -> Version? {
        let parts = input.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count >= 2 && parts.count <= 4 else { return nil }
        var nums: [Int] = []
        for p in parts {
            guard let n = Int(p.trimmingCharacters(in: .whitespaces)), n >= 0 else { return nil }
            nums.append(n)
        }
        return Version(nums[0], nums[1], nums.count > 2 ? nums[2] : -1, nums.count > 3 ? nums[3] : -1)
    }

    public var description: String {
        var s = "\(major).\(minor)"
        if build >= 0 {
            s += ".\(build)"
            if revision >= 0 { s += ".\(revision)" }
        }
        return s
    }
}
