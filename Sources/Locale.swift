//
//  Locale.swift
//  ro-data-converter
//
//  Created by Leon Li on 2025/8/4.
//

import Foundation

let locales = [
    Locale(languageCode: .chinese, script: .hanSimplified),
    Locale(languageCode: .chinese, script: .hanTraditional),
    Locale(languageCode: .english),
    Locale(languageCode: .french),
    Locale(languageCode: .german),
    Locale(languageCode: .indonesian),
    Locale(languageCode: .italian),
    Locale(languageCode: .japanese),
    Locale(languageCode: .korean),
    Locale(languageCode: .portuguese, languageRegion: .brazil),
    Locale(languageCode: .russian),
    Locale(languageCode: .spanish),
    Locale(languageCode: .thai),
    Locale(languageCode: .turkish),
]

extension Locale {
    var path: String {
        identifier(.bcp47) + ".lproj"
    }
}

extension Locale.Language {
    var preferredEncoding: String.Encoding {
        let cfEncoding = switch languageCode {
        case .arabic:
            CFStringConvertWindowsCodepageToEncoding(1256)
        case .chinese where script == .hanSimplified:
            CFStringConvertWindowsCodepageToEncoding(936)
        case .chinese where script == .hanTraditional:
            CFStringConvertWindowsCodepageToEncoding(950)
        case .japanese:
            CFStringConvertWindowsCodepageToEncoding(932)
        case .korean:
            CFStringConvertWindowsCodepageToEncoding(949)
        case .russian:
            CFStringConvertWindowsCodepageToEncoding(1251)
        case .spanish where region == .latinAmerica:
            CFStringConvertWindowsCodepageToEncoding(1145)
        case .thai:
            CFStringConvertWindowsCodepageToEncoding(874)
        case .vietnamese:
            CFStringConvertWindowsCodepageToEncoding(1258)
        default:
            CFStringConvertWindowsCodepageToEncoding(1252)
        }

        let nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
        let encoding = String.Encoding(rawValue: nsEncoding)
        return encoding
    }
}

extension String {
    mutating func transcode(from: String.Encoding, to: String.Encoding) {
        let string = data(using: from).flatMap { data in
            String(data: data, encoding: to)
        }
        if let string {
            self = string
        }
    }

    func transcoding(from: String.Encoding, to: String.Encoding) -> String {
        let string = data(using: from).flatMap { data in
            String(data: data, encoding: to)
        }
        return string ?? self
    }
}
