//
//  LuaContext.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/4.
//

import Lua

extension LuaContext {
    func loadJSONModule() {
        let dkjsonURL = Bundle.module.url(forResource: "dkjson", withExtension: "lua")!
        let dkjson = try! String(contentsOf: dkjsonURL, encoding: .utf8)

        try! parse("""
        function load_dkjson()
          \(dkjson)
        end
        
        dkjson = load_dkjson()
        """)
    }

    func loadData(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            try load(data)
        } catch {
            print(error)
        }
    }
}
