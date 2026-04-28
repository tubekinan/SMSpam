//
//  MessageFilterExtension.swift
//  SpamFilterExtension
//
//  Created by Inan Tubek on 19.03.2026.
//

import IdentityLookup
import Foundation

final class MessageFilterExtension: ILMessageFilterExtension {
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"
    private let rulesConfigKey = "spam_rules_config"

}

extension MessageFilterExtension: ILMessageFilterQueryHandling, ILMessageFilterCapabilitiesQueryHandling {
    // Shared keys between the main app and this extension.

    private struct RulesConfig: Codable {
        var version: Int
        var whitelist: WhitelistConfig
        var rules: RulesConfigBody
        var logging: LoggingConfig
    }

    private struct WhitelistConfig: Codable {
        // If sender matches any of these, we must never block it.
        var senderContains: [String]
        var senderRegex: [String]
    }

    private struct RulesConfigBody: Codable {
        // If sender matches any of these, we block it.
        var blockedSenderContains: [String]
        var senderRegexes: [String]

        // Body regex checks (example: corrupted Turkish casing regex).
        var bodyRegexes: [String]

        // Body substring keyword checks.
        var bodyKeywords: [String]

        // Short URL regex checks.
        var shortUrlRegexes: [String]
    }

    private struct LoggingConfig: Codable {
        // Max number of log entries to keep in memory/shared storage.
        var maxSpamLogs: Int
    }

    private static let defaultRulesConfig: RulesConfig = {
        let blockedSenders = ["xbank", "ybank", "ybankasi", "", ""]
        let spamSenderPattern = "(\\+90[\\s\\-]?\\(?850\\)?|0850|90850)"
        let corruptTurkishPattern = "[A-Z]+i[A-Z]+"

        let gamblingKeywords = [
            "bonus", "freespin", "freebet", "jackpot", "slot",
            "çekim", "cekim", "cevrimli", "blokesiz", "sinirsiz",
            "deneme", "yatırım", "yatirim", "bahis", "oran",
            "nakit iade", "1 saniye", "kazanç", "kazanc"
        ]
        let spamKeywords = ["kampanya", "kazandınız", "tıklayın", "hesabınıza para"]

        let shortUrlPattern = "https?://(t2m\\.io|bit\\.ly|tinyurl\\.com|goo\\.gl|ow\\.ly|rb\\.gy|cutt\\.ly)"

        return RulesConfig(
            version: 1,
            whitelist: WhitelistConfig(senderContains: [], senderRegex: []),
            rules: RulesConfigBody(
                blockedSenderContains: blockedSenders,
                senderRegexes: [spamSenderPattern],
                bodyRegexes: [corruptTurkishPattern],
                bodyKeywords: gamblingKeywords + spamKeywords,
                shortUrlRegexes: [shortUrlPattern]
            ),
            logging: LoggingConfig(maxSpamLogs: 200)
        )
    }()

    func handle(_ capabilitiesQueryRequest: ILMessageFilterCapabilitiesQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterCapabilitiesQueryResponse) -> Void) {
        let response = ILMessageFilterCapabilitiesQueryResponse()

        // TODO: Update subActions from ILMessageFilterSubAction enum
        // response.transactionalSubActions = [...]
        // response.promotionalSubActions   = [...]

        completion(response)
    }

    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {	
        // First, check whether to filter using offline data (if possible).
        let (offlineAction, offlineSubAction) = self.offlineAction(for: queryRequest)

        switch offlineAction {
        case .allow, .junk, .promotion, .transaction:
            // Based on offline data, we know this message should either be Allowed, Filtered as Junk, Promotional or Transactional. Send response immediately.
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            response.subAction = offlineSubAction

            completion(response)

        case .none:
            // Based on offline data, we do not know whether this message should be Allowed or Filtered. Defer to network.
            // Note: Deferring requests to network requires the extension target's Info.plist to contain a key with a URL to use. See documentation for details.
            context.deferQueryRequestToNetwork() { (networkResponse, error) in
                let response = ILMessageFilterQueryResponse()
                response.action = .none
                response.subAction = .none

                if let networkResponse = networkResponse {
                    // If we received a network response, parse it to determine an action to return in our response.
                    (response.action, response.subAction) = self.networkAction(for: networkResponse)
                } else {
                    NSLog("Error deferring query request to network: \(String(describing: error))")
                }

                completion(response)
            }

        @unknown default:
            break
        }
    }

    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> (ILMessageFilterAction, ILMessageFilterSubAction) {
        let messageBody = queryRequest.messageBody ?? ""
        let sender = queryRequest.sender ?? ""
        let bodyLower = messageBody.lowercased()
        let senderLower = sender.lowercased()

        let rulesConfig = loadRulesConfig()
        let maxLogs = max(1, rulesConfig.logging.maxSpamLogs)

        // 0. Whitelist (must always allow, highest priority).
        for token in normalizedContainsTokens(rulesConfig.whitelist.senderContains) {
            if senderLower.contains(token) {
                return (.allow, .none)
            }
        }
        for pattern in normalizedRegexPatterns(rulesConfig.whitelist.senderRegex) {
            if let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: sender, range: NSRange(sender.startIndex..., in: sender)) != nil {
                return (.allow, .none)
            }
        }

        // 1. Blocked sender substrings.
        for blocked in normalizedContainsTokens(rulesConfig.rules.blockedSenderContains) {
            if senderLower.contains(blocked) {
                logSpam("[\(sender)] \(messageBody)", maxLogs: maxLogs)
                return (.junk, .none)
            }
        }

        // 2. Blocked sender regexes (example: 850-type sender number).
        for pattern in normalizedRegexPatterns(rulesConfig.rules.senderRegexes) {
            if let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: sender, range: NSRange(sender.startIndex..., in: sender)) != nil {
                logSpam("[\(sender)] \(messageBody)", maxLogs: maxLogs)
                return (.junk, .none)
            }
        }

        // 3. Body regexes (example: corrupted Turkish casing).
        for pattern in normalizedRegexPatterns(rulesConfig.rules.bodyRegexes) {
            if let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: messageBody, range: NSRange(messageBody.startIndex..., in: messageBody)) != nil {
                logSpam("[\(sender)] \(messageBody)", maxLogs: maxLogs)
                return (.junk, .none)
            }
        }

        // 4. Body keyword substrings.
        for keyword in normalizedContainsTokens(rulesConfig.rules.bodyKeywords) {
            if bodyLower.contains(keyword) {
                logSpam("[\(sender)] \(messageBody)", maxLogs: maxLogs)
                return (.junk, .none)
            }
        }

        // 5. Short URL regexes.
        for pattern in normalizedRegexPatterns(rulesConfig.rules.shortUrlRegexes) {
            if let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: messageBody, range: NSRange(messageBody.startIndex..., in: messageBody)) != nil {
                logSpam("[\(sender)] \(messageBody)", maxLogs: maxLogs)
                return (.junk, .none)
            }
        }

        return (.none, .none)
    }

    private func networkAction(for networkResponse: ILNetworkResponse) -> (ILMessageFilterAction, ILMessageFilterSubAction) {
        // TODO: Replace with logic to parse the HTTP response and data payload of `networkResponse` to return an action.
        return (.none, .none)
    }
    
    private func loadRulesConfig() -> RulesConfig {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey) else {
            return Self.defaultRulesConfig
        }

        do {
            let decoded = try JSONDecoder().decode(RulesConfig.self, from: data)
            // If user config is malformed/incomplete, fall back to defaults for safety.
            return decoded.version == 1 ? decoded : Self.defaultRulesConfig
        } catch {
            return Self.defaultRulesConfig
        }
    }

    private func normalizedContainsTokens(_ tokens: [String]) -> [String] {
        tokens
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func normalizedRegexPatterns(_ patterns: [String]) -> [String] {
        // Regex patterns are case-sensitive by design (e.g. `[A-Z]`), so we must not lowercase them.
        patterns
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func logSpam(_ text: String, maxLogs: Int) {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        var logs = defaults?.stringArray(forKey: spamLogsKey) ?? []

        logs.insert(text, at: 0)
        if logs.count > maxLogs {
            logs = Array(logs.prefix(maxLogs))
        }

        defaults?.set(logs, forKey: spamLogsKey)
    }

}
