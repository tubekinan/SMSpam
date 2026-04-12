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
    var body: some View {
        HomeView()
    }
}

// MARK: - Home View

struct HomeView: View {
    @State private var logs: [String] = []
    @State private var showSettings = false
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    logoSection
                    statsSection
                    recentLogsSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                loadLogs()
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "shield.checkered")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }

            Text("SMSpam")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Spam Mesajları Engelle")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Toplam Spam",
                value: "\(logs.count)",
                icon: "envelope.badge.shield.half.filled",
                gradient: [Color.red.opacity(0.8), Color.red.opacity(0.5)]
            )

            StatCard(
                title: "Bugün",
                value: "0",
                icon: "calendar",
                gradient: [Color.blue.opacity(0.8), Color.blue.opacity(0.5)]
            )
        }
    }

    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Son Spam Logları")
                    .font(.title3.bold())
                Spacer()
                NavigationLink("Tümü") {
                    AllLogsView()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }

            if logs.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }

                    Text("Henüz spam tespit edilmedi")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Temiz bir mesaj kutusuna sahipsin!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
            } else {
                VStack(spacing: 0) {
                    ForEach(logs.prefix(5), id: \.self) { log in
                        LogRow(log: log)
                        if log != logs.prefix(5).last {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(16)
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
    let gradient: [Color]

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

struct LogRow: View {
    let log: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(log)
                    .font(.subheadline)
                    .lineLimit(2)

                Text(timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
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
        .listStyle(.insetGrouped)
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
    @Environment(\.dismiss) private var dismiss
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            List {
                logoHeader
                whitelistSection
                rulesSection
                logSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }

    private var logoHeader: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: "shield.checkered")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("SMSpam")
                        .font(.title2.bold())
                    Text("Versiyon 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var whitelistSection: some View {
        Section {
            NavigationLink {
                WhitelistEditorView()
            } label: {
                Label("Whitelist Yönetimi", systemImage: "checkmark.shield")
            }

            Text("Güvenilir göndericileri buradan ekleyin. Bu numaralar asla engellenmez.")
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Label("Whitelist", systemImage: "whitelist")
        }
    }

    private var rulesSection: some View {
        Section {
            NavigationLink {
                BlockedSendersView()
            } label: {
                Label("Engellenen Göndericiler", systemImage: "hand.raised.fill")
            }

            NavigationLink {
                SenderRegexView()
            } label: {
                Label("Gönderici Regex", systemImage: "number")
            }

            Text("Gönderici numarasına uygulanan regex kuralları.")
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                BodyRegexView()
            } label: {
                Label("İçerik Regex", systemImage: "text.alignleft")
            }

            Text("Mesaj içeriğine uygulanan regex kuralları. Örn: Türkçe karakter bozukluğu.")
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                BodyKeywordsView()
            } label: {
                Label("İçerik Anahtar Kelimeler", systemImage: "text.word.spacing")
            }

            Text("Spam içerebilecek anahtar kelimeler. Büyük/küçük harf duyarsız.")
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                ShortUrlRegexView()
            } label: {
                Label("Kısa URL Regex", systemImage: "link")
            }

            Text("Şüpheli kısa URL kalıpları. t2m.io, bit.ly gibi adresler.")
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Label("Kural Motoru", systemImage: "bolt.shield.fill")
        }
    }

    private var logSection: some View {
        Section {
            NavigationLink {
                LogSettingsView()
            } label: {
                Label("Log Ayarları", systemImage: "doc.text")
            }
        } header: {
            Label("Log", systemImage: "doc.text")
        }
    }

    private var aboutSection: some View {
        Section {
            Button {
                showAbout = true
            } label: {
                Label("Hakkında", systemImage: "info.circle")
            }

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Gizlilik Politikası", systemImage: "lock.shield")
            }

            NavigationLink {
                TermsView()
            } label: {
                Label("Kullanım Koşulları", systemImage: "doc.plaintext")
            }
        } header: {
            Label("Bilgi", systemImage: "info.circle")
        }
    }
}

// MARK: - List Editor Views

struct WhitelistEditorView: View {
    @State private var senderContains: [String] = []
    @State private var senderRegex: [String] = []
    @State private var newSenderContains = ""
    @State private var newSenderRegex = ""
    @State private var showAddContains = false
    @State private var showAddRegex = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section("Gönderici İçerikleri") {
                ForEach(senderContains, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    senderContains.remove(atOffsets: indexSet)
                }

                Button {
                    showAddContains = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }

            Section("Gönderici Regex") {
                ForEach(senderRegex, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    senderRegex.remove(atOffsets: indexSet)
                }

                Button {
                    showAddRegex = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Whitelist")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Ekle", isPresented: $showAddContains) {
            TextField("Gönderici içeriği", text: $newSenderContains)
            Button("İptal", role: .cancel) { newSenderContains = "" }
            Button("Ekle") {
                if !newSenderContains.isEmpty {
                    senderContains.append(newSenderContains.lowercased())
                    newSenderContains = ""
                }
            }
        }
        .alert("Ekle", isPresented: $showAddRegex) {
            TextField("Regex pattern", text: $newSenderRegex)
            Button("İptal", role: .cancel) { newSenderRegex = "" }
            Button("Ekle") {
                if !newSenderRegex.isEmpty {
                    senderRegex.append(newSenderRegex)
                    newSenderRegex = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        senderContains = config.whitelist.senderContains
        senderRegex = config.whitelist.senderRegex
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.whitelist.senderContains = senderContains
        config.whitelist.senderRegex = senderRegex
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BlockedSendersView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }

                Button {
                    showAdd = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("Engellenen Gönderici İçerikleri")
            } footer: {
                Text("Bu içerikler gönderici adresinde geçiyorsa engellenir. Büyük/küçük harf duyarsız.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Engellenen Göndericiler")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Yeni Ekle", isPresented: $showAdd) {
            TextField("İçerik", text: $newItem)
            Button("İptal", role: .cancel) { newItem = "" }
            Button("Ekle") {
                if !newItem.isEmpty {
                    items.append(newItem.lowercased())
                    newItem = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        items = config.rules.blockedSenderContains
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.rules.blockedSenderContains = items
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct SenderRegexView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }

                Button {
                    showAdd = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("Gönderici Regex Kuralları")
            } footer: {
                Text("Gönderici numarasına uygulanan regex pattern'ları. Örn: \\+90[\\s\\-]?\\(?850\\)?")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Gönderici Regex")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Yeni Regex Ekle", isPresented: $showAdd) {
            TextField("Regex pattern", text: $newItem)
            Button("İptal", role: .cancel) { newItem = "" }
            Button("Ekle") {
                if !newItem.isEmpty {
                    items.append(newItem)
                    newItem = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        items = config.rules.senderRegexes
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.rules.senderRegexes = items
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BodyRegexView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }

                Button {
                    showAdd = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("İçerik Regex Kuralları")
            } footer: {
                Text("Mesaj içeriğine uygulanan regex. Örn: Türkçe karakter bozukluğu tespiti için [A-Z]+i[A-Z]+")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("İçerik Regex")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Yeni Regex Ekle", isPresented: $showAdd) {
            TextField("Regex pattern", text: $newItem)
            Button("İptal", role: .cancel) { newItem = "" }
            Button("Ekle") {
                if !newItem.isEmpty {
                    items.append(newItem)
                    newItem = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        items = config.rules.bodyRegexes
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.rules.bodyRegexes = items
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BodyKeywordsView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }

                Button {
                    showAdd = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("İçerik Anahtar Kelimeleri")
            } footer: {
                Text("Spam mesajlarda sık geçen kelimeler. Büyük/küçük harf duyarsız eşleşir.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Anahtar Kelimeler")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Yeni Kelime Ekle", isPresented: $showAdd) {
            TextField("Kelime", text: $newItem)
            Button("İptal", role: .cancel) { newItem = "" }
            Button("Ekle") {
                if !newItem.isEmpty {
                    items.append(newItem.lowercased())
                    newItem = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        items = config.rules.bodyKeywords
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.rules.bodyKeywords = items
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct ShortUrlRegexView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }

                Button {
                    showAdd = true
                } label: {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            } header: {
                Text("Kısa URL Regex Kalıpları")
            } footer: {
                Text("Şüpheli kısa URL adresleri. t2m.io, bit.ly, tinyurl.com gibi linkler.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Kısa URL")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert("Yeni Regex Ekle", isPresented: $showAdd) {
            TextField("Regex pattern", text: $newItem)
            Button("İptal", role: .cancel) { newItem = "" }
            Button("Ekle") {
                if !newItem.isEmpty {
                    items.append(newItem)
                    newItem = ""
                }
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        items = config.rules.shortUrlRegexes
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.rules.shortUrlRegexes = items
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct LogSettingsView: View {
    @State private var maxSpamLogs: Int = 200

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section {
                Stepper("Maksimum log sayısı: \(maxSpamLogs)", value: $maxSpamLogs, in: 10...5000)
            } footer: {
                Text("Kaydedilecek maksimum spam log sayısı. Daha eski loglar otomatik silinir.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Log Ayarları")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        maxSpamLogs = config.logging.maxSpamLogs
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.logging.maxSpamLogs = maxSpamLogs
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "shield.checkered")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("SMSpam")
                                .font(.title.bold())
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

                Section("Özellikler") {
                    FeatureRow(icon: "bolt.shield", title: "Otomatik Spam Tespiti", desc: "SMS mesajlarınızı otomatik analiz eder")
                    FeatureRow(icon: "text.badge.checkmark", title: "Özelleştirilebilir Kurallar", desc: "Kendi kurallarınızı oluşturun")
                    FeatureRow(icon: "whitelist", title: "Whitelist Desteği", desc: "Güvenli numaraları listeye ekleyin")
                    FeatureRow(icon: "doc.text", title: "Detaylı Loglar", desc: "Engellenen spamları takip edin")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Hakkında")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
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
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.orange)
            }

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
            VStack(alignment: .leading, spacing: 16) {
                Text("Gizlilik Politikası")
                    .font(.title.bold())

                Text("""
                Bu uygulama, spam mesajları engellemek için tasarlanmıştır.

                **Veri Kullanımı:**
                • Tüm veriler cihazınızda yerel olarak işlenir
                • Hiçbir kişisel veri dışarı gönderilmez
                • SMS içerikleri sadece cihazınızda analiz edilir

                **Veri Güvenliği:**
                İzniniz olmadan hiçbir veri toplanmaz. Tüm analiz işlemleri cihazınızın kendisinde gerçekleşir.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Gizlilik Politikası")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Kullanım Koşulları")
                    .font(.title.bold())

                Text("""
                Bu uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:

                **1. Sorumluluk Reddi**
                Uygulama 'olduğu gibi' sunulmaktadır. Geliştirici, spam engellemenin %100 başarılı olacağını garanti etmez.

                **2. Yasadışı Kullanım**
                Yasadışı amaçlarla kullanım yasaktır.

                **3. Kullanım Hakkı**
                Uygulama sadece kişisel kullanım içindir.
                """)
                .font(.body)
            }
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
