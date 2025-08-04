//
//  Convert.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/1.
//

import ArgumentParser
import Foundation

@main
struct Convert: ParsableCommand {
    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var input: URL

    @Argument(transform: { URL(filePath: $0, directoryHint: .isDirectory) })
    var output: URL

    func run() throws {
        for locale in locales {
            let skillInfoConverter = SkillInfoConverter()
            try? skillInfoConverter.convert(from: input, to: output, for: locale)
        }
    }
}
