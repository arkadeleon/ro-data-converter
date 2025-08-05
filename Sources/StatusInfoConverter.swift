//
//  StatusInfoConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation
import Lua

struct StatusInfo: Codable {
    var statusDescription: String
}

struct StatusInfoConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let stateiconinfoURL = input.appending(components: locale.path, "stateiconinfo.lub")
        guard FileManager.default.fileExists(atPath: stateiconinfoURL.path()) else {
            return
        }

        let context = LuaContext()
        context.loadJSONModule()

        let efstidsURL = input.appending(component: "efstids.lub")
        let stateiconimginfoURL = input.appending(component: "stateiconimginfo.lub")

        context.loadData(at: efstidsURL)
        context.loadData(at: stateiconimginfoURL)
        context.loadData(at: stateiconinfoURL)

        try context.parse("""
        function convert()
          local result = {}
          for statusID, value in pairs(StateIconList) do
            local key = string.format("%04d", statusID)
            result[key] = {
              statusDescription = value["descript"][1][1]
            }
          end
        
          return dkjson.encode(result, { indent = true })
        end
        """)

        let json = try context.call("convert", with: []) as! String

        let decoder = JSONDecoder()
        var statusInfos = try decoder.decode([String : StatusInfo].self, from: json.data(using: .utf8)!)
        for statusID in statusInfos.keys {
            statusInfos[statusID]?.statusDescription.transcode(from: .isoLatin1, to: locale.language.preferredEncoding)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(statusInfos)
        let jsonURL = output.appending(components: locale.path, "StatusInfo.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
