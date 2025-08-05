//
//  ItemRandomOptionNameConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation
import Lua

struct ItemRandomOptionNameConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let addrandomoptionnametableURL = input.appending(components: locale.path, "addrandomoptionnametable.lub")
        guard FileManager.default.fileExists(atPath: addrandomoptionnametableURL.path()) else {
            return
        }

        let context = LuaContext()
        context.loadJSONModule()

        let enumvarURL = input.appending(component: "enumvar.lub")
        let addrandomoptionfURL = input.appending(component: "addrandomoption_f.lub")

        context.loadData(at: enumvarURL)
        context.loadData(at: addrandomoptionnametableURL)
        context.loadData(at: addrandomoptionfURL)

        try context.parse("""
        function convert()
          return dkjson.encode(NameTable_VAR, { indent = true })
        end
        """)

        let json = try context.call("convert", with: []) as! String

        let decoder = JSONDecoder()
        let names = try decoder.decode([String?].self, from: json.data(using: .utf8)!)

        let itemRandomOptionNames = Dictionary(
            names.enumerated().map({ (String(format: "%03d", $0.offset + 1), $0.element) }),
            uniquingKeysWith: { first, _ in first }
        ).compactMapValues { name in
            name?.transcoding(from: .isoLatin1, to: locale.language.preferredEncoding)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(itemRandomOptionNames)
        let jsonURL = output.appending(components: locale.path, "ItemRandomOptionName.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
