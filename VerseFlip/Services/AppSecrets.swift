//
//  AppSecrets.swift
//  VerseFlip
//
//  Created by Codex on 5/30/26.
//

import Foundation

enum AppSecrets {
    static var esvAPIKey: String {
        apiKey(named: "ESV_API_KEY", in: .main)
    }

    static var nivAPIKey: String {
        apiKey(named: "NIV_API_KEY", in: .main)
    }

    static var isESVAPIKeyConfigured: Bool {
        isESVAPIKeyConfigured(in: .main)
    }

    static var isNIVAPIKeyConfigured: Bool {
        isNIVAPIKeyConfigured(in: .main)
    }

    static func esvAPIKey(in bundle: Bundle) -> String {
        apiKey(named: "ESV_API_KEY", in: bundle)
    }

    static func nivAPIKey(in bundle: Bundle) -> String {
        apiKey(named: "NIV_API_KEY", in: bundle)
    }

    static func isESVAPIKeyConfigured(in bundle: Bundle) -> Bool {
        isESVAPIKeyConfigured(esvAPIKey(in: bundle))
    }

    static func isESVAPIKeyConfigured(_ key: String) -> Bool {
        isAPIKeyConfigured(key, placeholderNames: [
            "esv_api_key",
            "your_esv_api_key_here",
            "your_real_esv_api_key_here",
            "paste_your_esv_api_key_here"
        ])
    }

    static func isNIVAPIKeyConfigured(in bundle: Bundle) -> Bool {
        isNIVAPIKeyConfigured(nivAPIKey(in: bundle))
    }

    static func isNIVAPIKeyConfigured(_ key: String) -> Bool {
        isAPIKeyConfigured(key, placeholderNames: [
            "niv_api_key",
            "your_niv_api_key_here",
            "your_real_niv_api_key_here",
            "paste_your_niv_api_key_here"
        ])
    }

    private static func apiKey(named key: String, in bundle: Bundle) -> String {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
            return ""
        }

        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isAPIKeyConfigured(_ key: String, placeholderNames: Set<String>) -> Bool {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedKey = trimmedKey.lowercased()
        let unresolvedBuildSettingPattern = #"^\$\([a-z0-9_]+\)$"#

        return trimmedKey.isEmpty == false
            && lowercasedKey.range(of: unresolvedBuildSettingPattern, options: .regularExpression) == nil
            && placeholderNames.contains(lowercasedKey) == false
            && trimmedKey != "your_real_key_here"
            && lowercasedKey.contains("authorization") == false
            && lowercasedKey.contains("x-rapidapi-key") == false
            && lowercasedKey.hasPrefix("token ") == false
            && lowercasedKey.hasPrefix("bearer ") == false
            && lowercasedKey.hasPrefix("api-key") == false
    }
}
