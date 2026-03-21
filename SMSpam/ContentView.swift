//
//  ContentView.swift
//  SMSpam
//
//  Created by Inan Tubek on 19.03.2026.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var logs: [String] = []

    // Shared keys between the main app and the extension.
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"
    private let rulesConfigKey = "spam_rules_config"

    @State private var whitelistSenderContainsText: String = ""
    @State private var whitelistSenderRegexText: String = ""

    @State private var blockedSenderContainsText: String = ""
    @State private var senderRegexText: String = ""
    @State private var bodyRegexText: String = ""
    @State private var shortUrlRegexText: String = ""
    @State private var bodyKeywordsText: String = ""

    @State private var maxSpamLogs: Int = RulesConfig.defaultConfig.logging.maxSpamLogs

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

    private extension RulesConfig {
        static let defaultConfig: RulesConfig = {
            let blockedSenders = ["akbank", "isbank", "isbankasi", "finansbank", "fibabanka"]
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
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Spam Logları") {
                    if logs.isEmpty {
                        Text("Henüz spam kaydı yok.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(logs, id: \.self) { log in
                            Text(log)
                                .font(.caption)
                        }
                    }
                }

                Section("Whitelist (Asla Engelleme)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gönderici içerik (alt metin). Satır/virgül ile ayır.")
                            .font(.footnote)
                        TextEditor(text: $whitelistSenderContainsText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gönderici regex. Her satır bir regex.")
                            .font(.footnote)
                        TextEditor(text: $whitelistSenderRegexText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                Section("Kural Motoru (Engelleme)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Engellenen gönderici içerik. Satır/virgül ile ayır.")
                            .font(.footnote)
                        TextEditor(text: $blockedSenderContainsText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gönderici regex. Her satır bir regex.")
                            .font(.footnote)
                        TextEditor(text: $senderRegexText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body regex. (Örn: Türkçe karakter bozukluğu). Her satır bir regex.")
                            .font(.footnote)
                        TextEditor(text: $bodyRegexText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Body keyword (substring). Satır/virgül ile ayır.")
                            .font(.footnote)
                        TextEditor(text: $bodyKeywordsText)
                            .frame(height: 120)
                            .font(.system(.body, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kısa URL regex. Her satır bir regex.")
                            .font(.footnote)
                        TextEditor(text: $shortUrlRegexText)
                            .frame(height: 90)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                Section("Log Limiti") {
                    Stepper("Max spam log: \(maxSpamLogs)", value: $maxSpamLogs, in: 1...5000)
                }

                Section {
                    Button("Kuralları Kaydet") {
                        saveRulesConfig()
                    }
                    Button("Varsayılanlara Dön") {
                        resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("SMSpam")
            .toolbar {
                Button("Test") {
                    writeTestLog()
                }
            }
            .onAppear {
                loadRulesConfigForUI()
                loadLogs()
            }
        }
    }

    private func loadLogs() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        logs = defaults?.stringArray(forKey: spamLogsKey) ?? []
        if logs.count > maxSpamLogs {
            logs = Array(logs.prefix(maxSpamLogs))
        }
    }

    private func writeTestLog() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        var current = defaults?.stringArray(forKey: spamLogsKey) ?? []
        current.insert("[+90 (850) 435 09 20] Tebrikler HESABINIZA PARA GELDİ", at: 0)
        if current.count > maxSpamLogs {
            current = Array(current.prefix(maxSpamLogs))
        }
        defaults?.set(current, forKey: spamLogsKey)
        loadLogs()
    }

    private func loadRulesConfigForUI() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey) else {
            applyConfigToUI(RulesConfig.defaultConfig)
            return
        }

        do {
            let decoded = try JSONDecoder().decode(RulesConfig.self, from: data)
            applyConfigToUI(decoded.version == 1 ? decoded : RulesConfig.defaultConfig)
        } catch {
            applyConfigToUI(RulesConfig.defaultConfig)
        }
    }

    private func applyConfigToUI(_ config: RulesConfig) {
        maxSpamLogs = max(1, config.logging.maxSpamLogs)

        whitelistSenderContainsText = config.whitelist.senderContains.joined(separator: "\n")
        whitelistSenderRegexText = config.whitelist.senderRegex.joined(separator: "\n")

        blockedSenderContainsText = config.rules.blockedSenderContains.joined(separator: "\n")
        senderRegexText = config.rules.senderRegexes.joined(separator: "\n")
        bodyRegexText = config.rules.bodyRegexes.joined(separator: "\n")
        shortUrlRegexText = config.rules.shortUrlRegexes.joined(separator: "\n")
        bodyKeywordsText = config.rules.bodyKeywords.joined(separator: "\n")
    }

    private func saveRulesConfig() {
        let whitelistContains = splitCommaNewlineTokens(whitelistSenderContainsText)
        let whitelistRegexes = splitNewlineTokens(whitelistSenderRegexText)

        let blockedContains = splitCommaNewlineTokens(blockedSenderContainsText)
        let senderRegexes = splitNewlineTokens(senderRegexText)
        let bodyRegexes = splitNewlineTokens(bodyRegexText)
        let shortUrlRegexes = splitNewlineTokens(shortUrlRegexText)
        let bodyKeywords = splitCommaNewlineTokens(bodyKeywordsText)

        let config = RulesConfig(
            version: 1,
            whitelist: WhitelistConfig(senderContains: whitelistContains, senderRegex: whitelistRegexes),
            rules: RulesConfigBody(
                blockedSenderContains: blockedContains,
                senderRegexes: senderRegexes,
                bodyRegexes: bodyRegexes,
                bodyKeywords: bodyKeywords,
                shortUrlRegexes: shortUrlRegexes
            ),
            logging: LoggingConfig(maxSpamLogs: max(1, maxSpamLogs))
        )

        do {
            let data = try JSONEncoder().encode(config)
            let defaults = UserDefaults(suiteName: appGroupSuiteName)
            defaults?.set(data, forKey: rulesConfigKey)

            // Immediately cap existing logs to the new limit to avoid stale growth.
            var currentLogs = defaults?.stringArray(forKey: spamLogsKey) ?? []
            if currentLogs.count > max(1, maxSpamLogs) {
                currentLogs = Array(currentLogs.prefix(max(1, maxSpamLogs)))
                defaults?.set(currentLogs, forKey: spamLogsKey)
            }
            loadLogs()
        } catch {
            // Ignore save errors for now; extension will keep using previous/default config.
        }
    }

    private func resetToDefaults() {
        applyConfigToUI(RulesConfig.defaultConfig)
        saveRulesConfig()
    }

    private func splitCommaNewlineTokens(_ text: String) -> [String] {
        // For "contains"/keyword lists we allow both commas and newlines.
        let normalized = text.replacingOccurrences(of: "\r", with: "")
        let separators = CharacterSet(charactersIn: ",\n")
        return normalized
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func splitNewlineTokens(_ text: String) -> [String] {
        // For regex patterns we only split by newlines (commas can be part of regex).
        let normalized = text.replacingOccurrences(of: "\r", with: "")
        return normalized
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

#Preview {
    ContentView()
}
