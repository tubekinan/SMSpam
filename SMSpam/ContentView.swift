//
//  ContentView.swift
//  SMSpam
//
//  Created by Inan Tubek on 19.03.2026.
//

import SwiftUI
import Foundation

// MARK: - Models (file scope)

private struct RulesConfig: Codable {
    var version: Int
    var whitelist: WhitelistConfig
    var rules: RulesConfigBody
    var logging: LoggingConfig
}

private struct WhitelistConfig: Codable {
    var senderContains: [String]
    var senderRegex: [String]
}

private struct RulesConfigBody: Codable {
    var blockedSenderContains: [String]
    var senderRegexes: [String]
    var bodyRegexes: [String]
    var bodyKeywords: [String]
    var shortUrlRegexes: [String]
}

private struct LoggingConfig: Codable {
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

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(1)

            AboutView()
                .tabItem {
                    Label("Hakkında", systemImage: "info.circle.fill")
                }
                .tag(2)
        }
        .tint(Color.orange)
    }
}

// MARK: - Home View

struct HomeView: View {
    @State private var logs: [String] = []
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    logoSection
                    statsSection
                    recentLogsSection
                }
                .padding()
            }
            .navigationTitle("SMSpam")
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                loadLogs()
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("SMSpam")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Spam Mesajları Engelle")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Toplam Spam",
                value: "\(logs.count)",
                icon: "envelope.badge.shield.half.filled",
                color: .red
            )

            StatCard(
                title: "Bugün",
                value: "0",
                icon: "calendar",
                color: .blue
            )
        }
    }

    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Son Spam Logları")
                    .font(.headline)
                Spacer()
                NavigationLink("Tümü") {
                    AllLogsView()
                }
                .font(.subheadline)
            }

            if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Henüz spam tespit edilmedi")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    ForEach(logs.prefix(5), id: \.self) { log in
                        LogRow(log: log)
                        if log != logs.prefix(5).last {
                            Divider()
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
            }
        }
    }

    private func loadLogs() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        logs = defaults?.stringArray(forKey: spamLogsKey) ?? []
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct LogRow: View {
    let log: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(log)
                .font(.caption)
                .lineLimit(2)

            Spacer()

            Text(timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: Date(), relativeTo: Date())
    }
}

struct AllLogsView: View {
    @State private var logs: [String] = []
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"

    var body: some View {
        List {
            ForEach(logs, id: \.self) { log in
                LogRow(log: log)
            }
        }
        .navigationTitle("Tüm Loglar")
        .onAppear {
            loadLogs()
        }
    }

    private func loadLogs() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        logs = defaults?.stringArray(forKey: spamLogsKey) ?? []
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var whitelistSenderContainsText: String = ""
    @State private var whitelistSenderRegexText: String = ""
    @State private var blockedSenderContainsText: String = ""
    @State private var senderRegexText: String = ""
    @State private var bodyRegexText: String = ""
    @State private var shortUrlRegexText: String = ""
    @State private var bodyKeywordsText: String = ""
    @State private var maxSpamLogs: Int = 200
    @State private var showResetAlert = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        NavigationStack {
            Form {
                whitelistSection
                rulesSection
                logSection
                actionsSection
            }
            .navigationTitle("Ayarlar")
            .onAppear {
                loadRulesConfigForUI()
            }
        }
    }

    private var whitelistSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Gönderici içerik (virgül/satır ile ayır)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $whitelistSenderContainsText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Gönderici regex (her satır bir regex)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $whitelistSenderRegexText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }
        } header: {
            Label("Whitelist (Asla Engelleme)", systemImage: "checkmark.shield")
        }
    }

    private var rulesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Engellenen gönderici içerik")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $blockedSenderContainsText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Gönderici regex")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $senderRegexText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body regex (örn: Türkçe karakter bozukluğu)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $bodyRegexText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body keyword (substring)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $bodyKeywordsText)
                    .frame(height: 100)
                    .font(.system(.body, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Kısa URL regex")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $shortUrlRegexText)
                    .frame(height: 80)
                    .font(.system(.body, design: .monospaced))
            }
        } header: {
            Label("Kural Motoru", systemImage: "bolt.shield")
        }
    }

    private var logSection: some View {
        Section {
            Stepper("Max spam log: \(maxSpamLogs)", value: $maxSpamLogs, in: 1...5000)
        } header: {
            Label("Log Ayarları", systemImage: "doc.text")
        }
    }

    private var actionsSection: some View {
        Section {
            Button {
                saveRulesConfig()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Kuralları Kaydet")
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .listRowBackground(Color.orange)

            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Varsayılanlara Dön")
                }
            }
            .foregroundColor(.red)
        }
        .alert("Emin misin?", isPresented: $showResetAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                resetToDefaults()
            }
        } message: {
            Text("Tüm ayarlar varsayılanlara dönecek. Bu işlem geri alınamaz.")
        }
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
        } catch { }
    }

    private func resetToDefaults() {
        applyConfigToUI(RulesConfig.defaultConfig)
        saveRulesConfig()
    }

    private func splitCommaNewlineTokens(_ text: String) -> [String] {
        let normalized = text.replacingOccurrences(of: "\r", with: "")
        let separators = CharacterSet(charactersIn: ",\n")
        return normalized
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private func splitNewlineTokens(_ text: String) -> [String] {
        let normalized = text.replacingOccurrences(of: "\r", with: "")
        return normalized
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                appInfoSection
                featuresSection
                legalSection
            }
            .navigationTitle("Hakkında")
        }
    }

    private var appInfoSection: some View {
        Section {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .frame(width: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SMSpam")
                        .font(.title2.bold())
                    Text("Spam Mesaj Engelleyici")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Versiyon 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var featuresSection: some View {
        Section("Özellikler") {
            FeatureRow(icon: "bolt.shield", title: "Otomatik Spam Tespiti", desc: "SMS mesajlarınızı otomatik analiz eder")
            FeatureRow(icon: "text.badge.checkmark", title: "Özelleştirilebilir Kurallar", desc: "Kendi kurallarınızı oluşturun")
            FeatureRow(icon: "whitelist", title: "Whitelist Desteği", desc: "Güvenli numaraları listeye ekleyin")
            FeatureRow(icon: "bell.badge", title: "Anlık Bildirimler", desc: "Spam tespit edildiğinde bilgilendirin")
        }
    }

    private var legalSection: some View {
        Section("Yasal") {
            NavigationLink("Gizlilik Politikası") {
                PrivacyPolicyView()
            }
            NavigationLink("Kullanım Koşulları") {
                TermsView()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
            Gizlilik Politikası

            Bu uygulama, spam mesajları engellemek için tasarlanmıştır.

            Veri Kullanımı:
            - Tüm veriler cihazınızda yerel olarak işlenir
            - Hiçbir kişisel veri dışarı gönderilmez
            - SMS içerikleri sadece cihazınızda analiz edilir

            İzniniz olmadan hiçbir veri toplanmaz.
            """)
            .padding()
        }
        .navigationTitle("Gizlilik Politikası")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text("""
            Kullanım Koşulları

            Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:

            1. Uygulama 'olduğu gibi' sunulmaktadır.

            2. Geliştirici, spam engellemenin %100 başarılı olacağını garanti etmez.

            3. Yasadışı amaçlarla kullanım yasaktır.

            4. Uygulama sadece kişisel kullanım içindir.
            """)
            .padding()
        }
        .navigationTitle("Kullanım Koşulları")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
