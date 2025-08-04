//
//  SkillInfoConverter.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/1.
//

import Foundation
import Lua

struct SkillInfo: Codable {
    var skillName: String
    var skillDescription: String
}

struct SkillInfoConverter {
    func convert(from input: URL, to output: URL, for locale: Locale) throws {
        let localeEncoding = locale.language.preferredEncoding

        let context = LuaContext()
        context.loadJSONModule()

        let jobinheritlistURL = input.appending(components: "jobinheritlist.lub")
        context.loadData(at: jobinheritlistURL)

        let skillidURL = input.appending(components: "skillid.lub")
        context.loadData(at: skillidURL)

        let skillinfolistURL = input.appending(components: locale.path, "skillinfolist.lub")
        context.loadData(at: skillinfolistURL)

        let skilldescriptURL = input.appending(components: locale.path, "skilldescript.lub")
        context.loadData(at: skilldescriptURL)

        let skillinfofURL = input.appending(components: "skillinfo_f.lub")
        context.loadData(at: skillinfofURL)

        try context.parse("""
        function convert()
          result = {}
          for skillAegisName, skillID in pairs(SKID) do
            result[skillID] = {
              skillName = GetSkillName(skillID),
              skillDescription = table.concat(SKILL_DESCRIPT[skillID] or {}, "\\r\\n")
            }
          end
        
          return dkjson.encode(result, { indent = true })
        end
        """)

        let json = try context.call("convert", with: []) as! String

        let decoder = JSONDecoder()
        var skillInfos = try decoder.decode([String : SkillInfo].self, from: json.data(using: .utf8)!)
        for skillID in skillInfos.keys {
            skillInfos[skillID]?.skillName.transcode(from: .isoLatin1, to: localeEncoding)
            skillInfos[skillID]?.skillDescription.transcode(from: .isoLatin1, to: localeEncoding)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(skillInfos)
        let jsonURL = output.appending(components: locale.path, "SkillInfo.json")

        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: jsonURL)
    }
}
