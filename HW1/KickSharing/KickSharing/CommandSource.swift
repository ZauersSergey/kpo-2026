//
//  CommandSource.swift
//  KickSharing
//
//  Created by Сергей Зауэрс on 12.10.2026.
//

import Foundation

protocol CommandSource {
    /// Возвращает следующую непустую строку или nil, если ввод закончился.
    func nextLine() -> String?
}

/// Чтение из консоли.
final class ConsoleCommandSource: CommandSource {
    private let interactive: Bool

    init(interactive: Bool = isatty(STDIN_FILENO) == 1) {
        self.interactive = interactive
    }

    func nextLine() -> String? {
        if interactive {
            print("> ", terminator: "")
            fflush(stdout)
        }
        return readLine()
    }
}

/// Чтение команд из файла.
final class FileCommandSource: CommandSource {
    private let lines: [String]
    private var index = 0

    init(path: String) throws {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        self.lines = content
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
    }

    func nextLine() -> String? {
        while index < lines.count {
            let raw = lines[index]
            index += 1
            let trimmed = raw.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            return trimmed
        }
        return nil
    }
}
