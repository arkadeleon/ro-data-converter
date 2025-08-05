//
//  MonsterNameConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

struct MonsterNameConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let url = input.appending(components: locale.path, "mobname.txt")
        guard let string = try? String(contentsOf: url, encoding: .utf8) else {
            return
        }

        var monsterNames: [Int : String] = [:]

        let lines = string.split(separator: "\n")
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: ",")
            if columns.count >= 2 {
                if let monsterID = Int(String(columns[0])) {
                    let monsterName = String(columns[1])
                    monsterNames[monsterID] = monsterName
                }
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(monsterNames)
        let jsonURL = output.appending(components: locale.path, "MonsterName.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
