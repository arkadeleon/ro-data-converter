//
//  ItemInfoConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/4.
//

import Foundation
import Lua

struct ItemInfo: Codable {
    var unidentifiedItemName: String?
    var unidentifiedItemDescription: String?
    var identifiedItemName: String?
    var identifiedItemDescription: String?
}

struct ItemInfoConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let itemInfoURL = input.appending(components: locale.path, "itemInfo.lub")
        var itemInfos = if FileManager.default.fileExists(atPath: itemInfoURL.path()) {
            try luaItemInfos(from: input, for: locale)
        } else {
            txtItemInfos(from: input, for: locale)
        }

        for itemID in itemInfos.keys {
            itemInfos[itemID]?.unidentifiedItemName?.transcode(from: .isoLatin1, to: locale.language.preferredEncoding)
            itemInfos[itemID]?.unidentifiedItemDescription?.transcode(from: .isoLatin1, to: locale.language.preferredEncoding)
            itemInfos[itemID]?.identifiedItemName?.transcode(from: .isoLatin1, to: locale.language.preferredEncoding)
            itemInfos[itemID]?.identifiedItemDescription?.transcode(from: .isoLatin1, to: locale.language.preferredEncoding)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(itemInfos)
        let jsonURL = output.appending(components: locale.path, "ItemInfo.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }

    private func luaItemInfos(from input: URL, for locale: Locale) throws -> [String : ItemInfo] {
        let context = LuaContext()
        context.loadJSONModule()

        let itemInfoURL = input.appending(components: locale.path, "itemInfo.lub")
        context.loadData(at: itemInfoURL)

        try context.parse("""
        function convert()
          local result = {}
          for itemID, value in pairs(tbl) do
            local key = string.format("%07d", itemID)
            result[key] = {
              unidentifiedItemName = value["unidentifiedDisplayName"],
              unidentifiedItemDescription = table.concat(value["unidentifiedDescriptionName"], "\\r\\n"),
              identifiedItemName = value["identifiedDisplayName"],
              identifiedItemDescription = table.concat(value["identifiedDescriptionName"], "\\r\\n")
            }
          end
        
          return dkjson.encode(result, { indent = true })
        end
        """)

        let json = try context.call("convert", with: []) as! String

        let decoder = JSONDecoder()
        let itemInfos = try decoder.decode([String : ItemInfo].self, from: json.data(using: .utf8)!)
        return itemInfos
    }

    private func txtItemInfos(from input: URL, for locale: Locale) -> [String : ItemInfo] {
        let identifiedItemNames: [String : String] = {
            let url = input.appending(components: locale.path, "idnum2itemdisplaynametable.txt")
            guard let string = try? String(contentsOf: url, encoding: .isoLatin1) else {
                return [:]
            }

            var identifiedItemNames: [String : String] = [:]

            let lines = string.split(separator: "\r\n")
            for line in lines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#").map(String.init)
                if columns.count >= 2,
                   let itemID = Int(columns[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                    let itemID = String(format: "%07d", itemID)
                    let itemDisplayName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    identifiedItemNames[itemID] = itemDisplayName
                }
            }

            return identifiedItemNames
        }()

        let identifiedItemDescriptions: [String : String] = {
            let url = input.appending(components: locale.path, "idnum2itemdesctable.txt")
            guard let string = try? String(contentsOf: url, encoding: .isoLatin1) else {
                return [:]
            }

            var identifiedItemDescriptions: [String : String] = [:]

            let lines = string.split(separator: "\r\n#\r\n")
            for line in lines {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#").map(String.init)
                if columns.count >= 2,
                   let itemID = Int(columns[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                    let itemID = String(format: "%07d", itemID)
                    let itemDescription = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    identifiedItemDescriptions[itemID] = itemDescription
                }
            }

            return identifiedItemDescriptions
        }()

        var itemInfos: [String : ItemInfo] = [:]

        for (itemID, itemName) in identifiedItemNames {
            if itemInfos[itemID] == nil {
                itemInfos[itemID] = ItemInfo()
            }
            itemInfos[itemID]?.identifiedItemName = itemName
        }

        for (itemID, itemDescription) in identifiedItemDescriptions {
            if itemInfos[itemID] == nil {
                itemInfos[itemID] = ItemInfo()
            }
            itemInfos[itemID]?.identifiedItemDescription = itemDescription
        }

        return itemInfos
    }
}
