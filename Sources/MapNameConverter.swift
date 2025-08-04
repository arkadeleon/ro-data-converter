//
//  MapNameConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/4.
//

import Foundation

struct MapNameConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let mapnametableURL = input.appending(components: locale.path, "mapnametable.txt")

        guard let data = try? Data(contentsOf: mapnametableURL),
              let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        var mapNamesByRSW: [String : String] = [:]

        let lines = string.split(separator: "\r\n")
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                continue
            }

            let columns = line.split(separator: "#")
            if columns.count >= 2 {
                let rsw = columns[0]
                    .replacingOccurrences(of: ".rsw", with: "")
                let mapName = columns[1]
                    .trimmingCharacters(in: .whitespaces)
                    .transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
                mapNamesByRSW[rsw] = mapName
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(mapNamesByRSW)
        let jsonURL = output.appending(components: locale.path, "MapName.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
