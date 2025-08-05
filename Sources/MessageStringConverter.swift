//
//  MessageStringConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/4.
//

import Foundation

struct MessageStringConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let url = input.appending(components: locale.path, "msgstringtable.txt")
        guard let data = try? Data(contentsOf: url),
              let string = String(data: data, encoding: .isoLatin1) else {
            return
        }

        var messageStrings: [Int : String] = [:]

        let lines = string.split(separator: "\r\n").map(String.init)
        for (lineNumber, line) in lines.enumerated() {
            var messageString = line.transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
            if messageString.hasSuffix("#") {
                messageString.removeLast()
            }
            messageStrings[lineNumber] = messageString
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(messageStrings)
        let jsonURL = output.appending(components: locale.path, "MessageString.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
