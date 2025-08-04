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
            print("Converting item info for \(locale.path)")

            let converter = ItemInfoConverter()
            try converter.convert(from: input, to: output, for: locale)
        }

        for locale in locales {
            print("Converting map name for \(locale.path)")

            let converter = MapNameConverter()
            try converter.convert(from: input, to: output, for: locale)
        }

        for locale in locales {
            print("Converting skill info for \(locale.path)")

            let converter = SkillInfoConverter()
            try converter.convert(from: input, to: output, for: locale)
        }
    }
}
