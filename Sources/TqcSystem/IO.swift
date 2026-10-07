import Foundation

public enum Path {
    public static func getFullPath(_ path: String) -> String {
        let absolute = path.hasPrefix("/") ? path : FileManager.default.currentDirectoryPath + "/" + path
        return URL(fileURLWithPath: absolute).standardized.path
    }

    public static func getFileName(_ path: String) -> String {
        guard let idx = path.lastIndex(of: "/") else { return path }
        return String(path[path.index(after: idx)...])
    }
}

public enum File {
    public static func exists(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && !isDir.boolValue
    }

    public static func readAllText(_ path: String) throws -> String {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw Exception("Could not find file '\(path)'.")
        }
        var bytes = [UInt8](data)
        if bytes.count >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF {
            bytes.removeFirst(3)
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}
