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
        let localeIdentifier = locale.identifier
        let localeEncoding = locale.language.preferredEncoding

        let context = LuaContext()

        let dkjsonURL = Bundle.module.url(forResource: "dkjson", withExtension: "lua")!
        let dkjson = try! String(contentsOf: dkjsonURL, encoding: .utf8)
        try context.parse("""
        function load_dkjson()
          \(dkjson)
        end
        
        dkjson = load_dkjson()
        """)

        let jobinheritlistURL = input.appending(path: "jobinheritlist.lub")
        if let data = try? Data(contentsOf: jobinheritlistURL) {
            try context.load(data)
        }

        let skillidURL = input.appending(path: "skillid.lub")
        if let data = try? Data(contentsOf: skillidURL) {
            try context.load(data)
        }

        let skillinfolistURL = input.appending(path: "\(localeIdentifier).lproj").appending(path: "skillinfolist.lub")
        if let data = try? Data(contentsOf: skillinfolistURL) {
            try context.load(data)
        }

        let skilldescriptURL = input.appending(path: "\(localeIdentifier).lproj").appending(path: "skilldescript.lub")
        if let data = try? Data(contentsOf: skilldescriptURL) {
            try context.load(data)
        }

        let skillinfofURL = input.appending(path: "skillinfo_f.lub")
        if let data = try? Data(contentsOf: skillinfofURL) {
            try context.load(data)
        }

        try context .parse("""
        function GetSkillDescript2(skillID)
          local descript = ""
          local obj = SKILL_DESCRIPT[skillID]
          if obj ~= nil then
            for i, v in pairs(obj) do
              descript = descript .. v
              descript = descript .. "\\r\\n"
            end
          end
          return descript
        end
        """)

        try context.parse("""
        function convert()
          result = {}
          for skillAegisName, skillID in pairs(SKID) do
            result[skillID] = {
              skillName = GetSkillName(skillID),
              skillDescription = GetSkillDescript2(skillID)
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
        let skillInfoData = try encoder.encode(skillInfos)
        let skillInfoURL = output.appending(path: "\(localeIdentifier).lproj").appending(path: "SkillInfo.json")

        try FileManager.default.createDirectory(at: skillInfoURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try skillInfoData.write(to: skillInfoURL)
    }
}
