//
//  ContentView.swift
//  SMSpam
//
//  Created by Inan Tubek on 19.03.2026.
//

import SwiftUI
import Foundation

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
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            HomeView()
                .opacity(showSplash ? 0 : 1)
            
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash View

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.red.opacity(0.85), Color.red.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .red.opacity(0.4), radius: 25, x: 0, y: 10)
                    
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 55))
                        .foregroundColor(.white)
                }
                
                Text("SMSpam")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Spam Mesajları Engelle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @State private var logs: [String] = []
    @State private var showSettings = false
    @State private var selectedLog: String?
    @State private var scrollOffset: CGFloat = 0
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(spacing: 24) {
                        logoSection
                        statsSection
                        recentLogsSection
                    }
                    .padding()
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }

                if scrollOffset < -100 {
                    miniLogoView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
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
            .sheet(item: $selectedLog) { log in
                LogDetailView(log: log)
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
                            colors: [Color.red.opacity(0.85), Color.red.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .red.opacity(0.3), radius: 15, x: 0, y: 8)

                Image(systemName: "message.badge.filled.fill")
                    .font(.system(size: 45))
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
                icon: "xmark.app.fill",
                gradient: [Color.red.opacity(0.85), Color.red.opacity(0.5)]
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
                VStack(alignment: .leading, spacing: 2) {
                    Text("Son Spam Logları")
                        .font(.title3.bold())
                    if !logs.isEmpty {
                        Text("\(min(logs.count, 5)) spam")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if !logs.isEmpty {
                    NavigationLink {
                        AllLogsView()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Tümü")
                            Image(systemName: "arrow.right")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            if logs.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(logs.prefix(5)), id: \.self) { log in
                        SpamLogCard(log: log)
                            .onTapGesture {
                                selectedLog = log
                            }
                    }
                }
            }
        }
    }

    private var miniLogoView: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.85), Color.red.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: "message.badge.filled.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            Text("SMSpam")
                .font(.system(size: 17, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.leading, 16)
        .padding(.top, 8)
    }

    private func loadLogs() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        logs = defaults?.stringArray(forKey: spamLogsKey) ?? []
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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

struct SpamLogCard: View {
    let log: String
    
    private var spamType: SpamType {
        if log.lowercased().contains("akbank") || log.lowercased().contains("isbank") {
            return .banking
        } else if log.lowercased().contains("bonus") || log.lowercased().contains("slot") {
            return .gambling
        } else if log.lowercased().contains("t2m.io") || log.lowercased().contains("bit.ly") {
            return .suspiciousLink
        }
        return .general
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(spamType.color)
                .frame(width: 4)
            
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(spamType.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: spamType.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(spamType.color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(spamType.title)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(spamType.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(spamType.color.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text(timeAgo)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(log)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: Date(), relativeTo: Date())
    }
}

enum SpamType {
    case banking
    case gambling
    case suspiciousLink
    case general
    
    var title: String {
        switch self {
        case .banking: return "Banka"
        case .gambling: return "Bahis"
        case .suspiciousLink: return "Şüpheli Link"
        case .general: return "Spam"
        }
    }
    
    var icon: String {
        switch self {
        case .banking: return "building.columns.fill"
        case .gambling: return "dice.fill"
        case .suspiciousLink: return "link.badge.plus"
        case .general: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .banking: return .blue
        case .gambling: return .purple
        case .suspiciousLink: return .orange
        case .general: return .red
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("Spam Yok!")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Tebrikler! Henüz spam mesaj tespit edilmedi.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                Text("Mesaj kutunuz güvende")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
        )
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct LogDetailView: View {
    let log: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spam Mesaj")
                            .font(.title2.bold())

                        Text("Bu mesaj spam olarak tespit edildi")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mesaj İçeriği")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)

                        Text(log)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Spam Detay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct AllLogsView: View {
    @State private var logs: [String] = []
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let spamLogsKey = "spam_logs"

    var body: some View {
        List {
            ForEach(logs, id: \.self) { log in
                SpamLogCard(log: log)
                    .onTapGesture {
                    }
            }
        }
        .listStyle(.plain)
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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.85), Color.red.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)

                            Image(systemName: "message.badge.filled.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }

                        Text("SMSpam")
                            .font(.title3.bold())
                    }
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
                }
                .listRowBackground(Color.clear)

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
            NavigationLink {
                AboutView()
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

// MARK: - Whitelist Editor View

struct WhitelistEditorView: View {
    @State private var senderContains: [String] = []
    @State private var senderRegexText: String = ""
    @State private var newSenderContains = ""
    @State private var showAddContains = false
    @State private var editingItem: String?
    @State private var editText = ""

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            Section("Gönderici İçerikleri") {
                ForEach(senderContains, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                senderContains.removeAll { $0 == item }
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editingItem = item
                                editText = item
                            } label: {
                                Label("Düzenle", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                }

                Button {
                    showAddContains = true
                } label: {
                    Label("Yeni Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gönderici Regex")
                        .font(.headline)

                    Text("Gönderici numarasına uygulanan regex kuralları. Her satıra bir pattern yazın.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $senderRegexText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
                    .scrollContentBackground(.hidden)

                Button {
                    saveConfig()
                } label: {
                    Text("Kaydet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Whitelist")
        .onAppear(perform: loadConfig)
        .alert("Yeni Ekle", isPresented: $showAddContains) {
            TextField("Gönderici içeriği", text: $newSenderContains)
            Button("İptal", role: .cancel) { newSenderContains = "" }
            Button("Ekle") {
                if !newSenderContains.isEmpty {
                    senderContains.append(newSenderContains.lowercased())
                    newSenderContains = ""
                }
            }
        }
        .alert("Düzenle", isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField("Değer", text: $editText)
            Button("İptal", role: .cancel) { editingItem = nil }
            Button("Kaydet") {
                if let item = editingItem, let idx = senderContains.firstIndex(of: item) {
                    senderContains[idx] = editText.lowercased()
                }
                editingItem = nil
            }
        }
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        senderContains = config.whitelist.senderContains
        senderRegexText = config.whitelist.senderRegex.joined(separator: "\n")
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        config.whitelist.senderContains = senderContains
        let lines = senderRegexText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        config.whitelist.senderRegex = lines
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BlockedSendersView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false
    @State private var editingItem: String?
    @State private var editText = ""

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.body.monospaced())
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            items.removeAll { $0 == item }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingItem = item
                            editText = item
                        } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
            }
            .onDelete { indexSet in
                items.remove(atOffsets: indexSet)
            }

            Button {
                showAdd = true
            } label: {
                Label("Yeni Ekle", systemImage: "plus.circle.fill")
                    .foregroundColor(.orange)
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
        .alert("Düzenle", isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField("Değer", text: $editText)
            Button("İptal", role: .cancel) { editingItem = nil }
            Button("Kaydet") {
                if let item = editingItem, let idx = items.firstIndex(of: item) {
                    items[idx] = editText.lowercased()
                }
                editingItem = nil
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
    @State private var regexText: String = ""
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gönderici Regex")
                        .font(.headline)
                    Text("Gönderici numarasına uygulanan regex kuralları. Her satıra bir pattern yazın.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $regexText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .scrollContentBackground(.hidden)
            }
            .padding()
        }
        .navigationTitle("Gönderici Regex")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        regexText = config.rules.senderRegexes.joined(separator: "\n")
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        let lines = regexText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        config.rules.senderRegexes = lines
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BodyRegexView: View {
    @State private var regexText: String = ""
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("İçerik Regex")
                        .font(.headline)
                    Text("Mesaj içeriğine uygulanan regex kuralları. Örn: Türkçe karakter bozukluğu. Her satıra bir pattern yazın.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $regexText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .scrollContentBackground(.hidden)
            }
            .padding()
        }
        .navigationTitle("İçerik Regex")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        regexText = config.rules.bodyRegexes.joined(separator: "\n")
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        let lines = regexText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        config.rules.bodyRegexes = lines
        if let newData = try? JSONEncoder().encode(config) {
            defaults?.set(newData, forKey: rulesConfigKey)
        }
    }
}

struct BodyKeywordsView: View {
    @State private var items: [String] = []
    @State private var newItem = ""
    @State private var showAdd = false
    @State private var editingItem: String?
    @State private var editText = ""

    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.body.monospaced())
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            items.removeAll { $0 == item }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingItem = item
                            editText = item
                        } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
            }
            .onDelete { indexSet in
                items.remove(atOffsets: indexSet)
            }

            Button {
                showAdd = true
            } label: {
                Label("Yeni Ekle", systemImage: "plus.circle.fill")
                    .foregroundColor(.orange)
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
        .alert("Düzenle", isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField("Kelime", text: $editText)
            Button("İptal", role: .cancel) { editingItem = nil }
            Button("Kaydet") {
                if let item = editingItem, let idx = items.firstIndex(of: item) {
                    items[idx] = editText.lowercased()
                }
                editingItem = nil
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
    @State private var regexText: String = ""
    private let appGroupSuiteName = "group.com.inan.smspam"
    private let rulesConfigKey = "spam_rules_config"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kısa URL Regex")
                        .font(.headline)
                    Text("Şüpheli kısa URL kalıpları. t2m.io, bit.ly gibi adresler. Her satıra bir pattern yazın.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $regexText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .scrollContentBackground(.hidden)
            }
            .padding()
        }
        .navigationTitle("Kısa URL")
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
    }

    private func loadConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              let config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        regexText = config.rules.shortUrlRegexes.joined(separator: "\n")
    }

    private func saveConfig() {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        guard let data = defaults?.data(forKey: rulesConfigKey),
              var config = try? JSONDecoder().decode(RulesConfig.self, from: data) else { return }
        let lines = regexText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        config.rules.shortUrlRegexes = lines
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
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.85), Color.red.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "message.badge.filled.fill")
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

            Section("İletişim") {
                Button {
                    if let url = URL(string: "mailto:inantubek@icloud.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Label("inantubek@icloud.com", systemImage: "envelope.fill")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Hakkında")
        .navigationBarTitleDisplayMode(.inline)
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
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.red)
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
