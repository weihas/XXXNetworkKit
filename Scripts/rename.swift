#!/usr/bin/env swift

import Foundation

struct Options {
    let oldPrefix: String
    let newPrefix: String
    let dryRun: Bool
}

enum RenameError: Error, CustomStringConvertible {
    case missingPrefix
    case invalidPrefix(String)
    case samePrefix
    case pathConflict(String)

    var description: String {
        switch self {
        case .missingPrefix:
            return """
            Usage: swift Scripts/rename.swift <NewPrefix> [--old XXX] [--dry-run]

            Examples:
              swift Scripts/rename.swift MyApp
              swift Scripts/rename.swift ABC --dry-run
              swift Scripts/rename.swift MyApp --old ABC
            """
        case .invalidPrefix(let prefix):
            return "'\(prefix)' is not a valid Swift-style prefix. Use letters, numbers, or '_', and start with a letter or '_'."
        case .samePrefix:
            return "The old and new prefixes are the same. Nothing to rename."
        case .pathConflict(let path):
            return "Cannot rename because destination already exists: \(path)"
        }
    }
}

let fileManager = FileManager.default
let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let scriptPath = URL(fileURLWithPath: CommandLine.arguments[0], relativeTo: rootURL)
    .standardizedFileURL
    .path

func parseOptions() throws -> Options {
    var oldPrefix = "X" + "XX"
    var newPrefix: String?
    var dryRun = false

    var index = 1
    while index < CommandLine.arguments.count {
        let argument = CommandLine.arguments[index]

        switch argument {
        case "--dry-run":
            dryRun = true
        case "--old":
            index += 1
            guard index < CommandLine.arguments.count else { throw RenameError.missingPrefix }
            oldPrefix = CommandLine.arguments[index]
        case "-h", "--help":
            throw RenameError.missingPrefix
        default:
            guard !argument.hasPrefix("-"), newPrefix == nil else {
                throw RenameError.missingPrefix
            }
            newPrefix = argument
        }

        index += 1
    }

    guard let newPrefix else { throw RenameError.missingPrefix }
    try validate(prefix: oldPrefix)
    try validate(prefix: newPrefix)
    guard oldPrefix != newPrefix else { throw RenameError.samePrefix }

    return Options(oldPrefix: oldPrefix, newPrefix: newPrefix, dryRun: dryRun)
}

func validate(prefix: String) throws {
    let pattern = #"^[A-Za-z_][A-Za-z0-9_]*$"#
    let range = NSRange(prefix.startIndex..<prefix.endIndex, in: prefix)
    let regex = try NSRegularExpression(pattern: pattern)
    guard regex.firstMatch(in: prefix, range: range) != nil else {
        throw RenameError.invalidPrefix(prefix)
    }
}

func shouldSkipDirectory(_ name: String) -> Bool {
    [".git", ".build", ".swiftpm", ".idea", ".vscode", "DerivedData"].contains(name)
}

func isLikelyTextFile(_ url: URL) -> Bool {
    if url.path == scriptPath { return false }

    let textExtensions: Set<String> = [
        "swift", "md", "txt", "yml", "yaml", "json", "plist", "xcconfig",
        "pbxproj", "xcscheme", "resolved", "gitignore"
    ]

    let ext = url.pathExtension.lowercased()
    if textExtensions.contains(ext) { return true }
    return url.lastPathComponent == "Package.resolved" || url.lastPathComponent == "Package.swift"
}

func collectItems(at root: URL, options: Options) throws -> (files: [URL], pathsToRename: [URL]) {
    guard let enumerator = fileManager.enumerator(
        at: root,
        includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey],
        options: [.skipsPackageDescendants]
    ) else {
        return ([], [])
    }

    var files: [URL] = []
    var pathsToRename: [URL] = []

    for case let url as URL in enumerator {
        let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isRegularFileKey])
        let name = url.lastPathComponent

        if values.isDirectory == true {
            if shouldSkipDirectory(name) {
                enumerator.skipDescendants()
                continue
            }
            if name.contains(options.oldPrefix) {
                pathsToRename.append(url)
            }
        } else if values.isRegularFile == true {
            if isLikelyTextFile(url) {
                files.append(url)
            }
            if url.path != scriptPath, name.contains(options.oldPrefix) {
                pathsToRename.append(url)
            }
        }
    }

    return (files, pathsToRename)
}

func replaceContents(in files: [URL], options: Options) throws -> Int {
    var changed = 0

    for file in files {
        let data = try Data(contentsOf: file)
        guard var contents = String(data: data, encoding: .utf8),
              contents.contains(options.oldPrefix)
        else { continue }

        contents = contents.replacingOccurrences(of: options.oldPrefix, with: options.newPrefix)
        changed += 1

        if options.dryRun {
            print("content: \(relativePath(for: file))")
        } else {
            try contents.write(to: file, atomically: true, encoding: .utf8)
        }
    }

    return changed
}

func renamePaths(_ paths: [URL], options: Options) throws -> Int {
    let deepestFirst = paths.sorted {
        $0.pathComponents.count > $1.pathComponents.count
    }

    var renamed = 0
    for source in deepestFirst {
        let destinationName = source.lastPathComponent
            .replacingOccurrences(of: options.oldPrefix, with: options.newPrefix)
        let destination = source.deletingLastPathComponent().appendingPathComponent(destinationName)

        guard source.path != destination.path else { continue }
        if fileManager.fileExists(atPath: destination.path) {
            throw RenameError.pathConflict(relativePath(for: destination))
        }

        renamed += 1
        if options.dryRun {
            print("path: \(relativePath(for: source)) -> \(relativePath(for: destination))")
        } else {
            try fileManager.moveItem(at: source, to: destination)
        }
    }

    return renamed
}

func relativePath(for url: URL) -> String {
    let path = url.standardizedFileURL.path
    let root = rootURL.standardizedFileURL.path

    guard path.hasPrefix(root) else { return path }
    let start = path.index(path.startIndex, offsetBy: root.count)
    return String(path[start...]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
}

do {
    let options = try parseOptions()
    let items = try collectItems(at: rootURL, options: options)
    let changedFiles = try replaceContents(in: items.files, options: options)
    let renamedPaths = try renamePaths(items.pathsToRename, options: options)

    if options.dryRun {
        print("Dry run complete: \(changedFiles) file(s) would change, \(renamedPaths) path(s) would be renamed.")
    } else {
        print("Renamed \(options.oldPrefix) to \(options.newPrefix): \(changedFiles) file(s) changed, \(renamedPaths) path(s) renamed.")
    }
} catch let error as RenameError {
    fputs(error.description + "\n", stderr)
    exit(1)
} catch {
    fputs("Rename failed: \(error)\n", stderr)
    exit(1)
}
