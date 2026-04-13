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

struct AppLogo: View {
    let size: CGFloat
    
    var body: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
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
                AppLogo(size: 120)
                
                Text(L("app.name"))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(L("home.spam.blocker"))
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
            AppLogo(size: 100)

            Text(L("app.name"))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(L("home.spam.blocker"))
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
                title: L("home.total.spam"),
                value: "\(logs.count)",
                icon: "xmark.app.fill",
                gradient: [Color.red.opacity(0.85), Color.red.opacity(0.5)]
            )

            StatCard(
                title: L("home.today"),
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
                    Text(L("home.recent.logs"))
                        .font(.title3.bold())
                    if !logs.isEmpty {
                        Text(Lf("home.showing.results", min(logs.count, 5)))
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
                            Text(L("home.all.logs"))
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
            AppLogo(size: 32)

            Text(L("app.name"))
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
        case .banking: return L("spam.type.banking")
        case .gambling: return L("spam.type.gambling")
        case .suspiciousLink: return L("spam.type.suspicious.link")
        case .general: return L("spam.type.general")
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
                Text(L("home.no.spam"))
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text(L("home.no.spam.description"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                Text(L("home.messages.safe"))
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
                        Text(L("home.spam.message"))
                            .font(.title2.bold())

                        Text(L("home.spam.detected"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(L("home.message.content"))
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
            .navigationTitle(L("home.spam.detail"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("close")) {
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
        .navigationTitle(L("home.all.logs"))
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
    @StateObject private var languageManager = LanguageManager.shared

    var body: some View {
        NavigationStack {
            List {
                languageSection
                whitelistSection
                rulesSection
                logSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L("settings.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("save")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                }
            }
        }
    }

    private var languageSection: some View {
        Section {
            Picker(L("settings.language"), selection: $languageManager.currentLanguage) {
                ForEach(languageManager.supportedLanguages, id: \.code) { language in
                    Text(language.nativeName).tag(language.code)
                }
            }
            .onChange(of: languageManager.currentLanguage) { _, newValue in
                Localization.setLanguage(newValue)
            }
        } header: {
            Label(L("settings.language"), systemImage: "globe")
        }
    }

    private var whitelistSection: some View {
        Section {
            NavigationLink {
                WhitelistEditorView()
            } label: {
                Label(L("settings.whitelist.management"), systemImage: "checkmark.shield")
            }

            Text(L("settings.whitelist.description"))
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Label(L("settings.whitelist"), systemImage: "whitelist")
        }
    }

    private var rulesSection: some View {
        Section {
            NavigationLink {
                BlockedSendersView()
            } label: {
                Label(L("settings.blocked.senders"), systemImage: "hand.raised.fill")
            }

            NavigationLink {
                SenderRegexView()
            } label: {
                Label(L("settings.sender.regex"), systemImage: "number")
            }

            Text(L("settings.sender.regex.description"))
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                BodyRegexView()
            } label: {
                Label(L("settings.content.regex"), systemImage: "text.alignleft")
            }

            Text(L("settings.content.regex.description"))
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                BodyKeywordsView()
            } label: {
                Label(L("settings.content.keywords"), systemImage: "text.word.spacing")
            }

            Text(L("settings.content.keywords.description"))
                .font(.caption)
                .foregroundColor(.secondary)

            NavigationLink {
                ShortUrlRegexView()
            } label: {
                Label(L("settings.short.url.regex"), systemImage: "link")
            }

            Text(L("settings.short.url.regex.description"))
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Label(L("settings.rule.engine"), systemImage: "bolt.shield.fill")
        }
    }

    private var logSection: some View {
        Section {
            NavigationLink {
                LogSettingsView()
            } label: {
                Label(L("settings.log.settings"), systemImage: "doc.text")
            }
        } header: {
            Label(L("settings.log"), systemImage: "doc.text")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Label(L("settings.about"), systemImage: "info.circle")
            }

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label(L("settings.privacy.policy"), systemImage: "lock.shield")
            }

            NavigationLink {
                TermsView()
            } label: {
                Label(L("settings.terms.of.service"), systemImage: "doc.plaintext")
            }
        } header: {
            Label(L("settings.info"), systemImage: "info.circle")
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
            Section(L("whitelist.sender.contains")) {
                ForEach(senderContains, id: \.self) { item in
                    Text(item)
                        .font(.body.monospaced())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                senderContains.removeAll { $0 == item }
                            } label: {
                                Label(L("delete"), systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editingItem = item
                                editText = item
                            } label: {
                                Label(L("edit"), systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                }

                Button {
                    showAddContains = true
                } label: {
                    Label(L("whitelist.add.new"), systemImage: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("whitelist.sender.regex"))
                        .font(.headline)

                    Text(L("settings.sender.regex.description"))
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
                    Text(L("save"))
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
        .navigationTitle(L("whitelist.title"))
        .onAppear(perform: loadConfig)
        .alert(L("whitelist.add.new"), isPresented: $showAddContains) {
            TextField(L("whitelist.enter.value"), text: $newSenderContains)
            Button(L("cancel"), role: .cancel) { newSenderContains = "" }
            Button(L("add")) {
                if !newSenderContains.isEmpty {
                    senderContains.append(newSenderContains.lowercased())
                    newSenderContains = ""
                }
            }
        }
        .alert(L("edit"), isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField(L("whitelist.enter.value"), text: $editText)
            Button(L("cancel"), role: .cancel) { editingItem = nil }
            Button(L("save")) {
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
                            Label(L("delete"), systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingItem = item
                            editText = item
                        } label: {
                            Label(L("edit"), systemImage: "pencil")
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
                Label(L("whitelist.add.new"), systemImage: "plus.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L("blocked.senders.title"))
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert(L("whitelist.add.new"), isPresented: $showAdd) {
            TextField(L("whitelist.enter.value"), text: $newItem)
            Button(L("cancel"), role: .cancel) { newItem = "" }
            Button(L("add")) {
                if !newItem.isEmpty {
                    items.append(newItem.lowercased())
                    newItem = ""
                }
            }
        }
        .alert(L("edit"), isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField(L("whitelist.enter.value"), text: $editText)
            Button(L("cancel"), role: .cancel) { editingItem = nil }
            Button(L("save")) {
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
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("settings.sender.regex"))
                            .font(.headline)
                        Text(L("settings.sender.regex.description"))
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

            Button {
                saveConfig()
            } label: {
                Text(L("save"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
            }
        }
        .navigationTitle(L("settings.sender.regex"))
        .onAppear(perform: loadConfig)
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
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("settings.content.regex"))
                            .font(.headline)
                        Text(L("settings.content.regex.description"))
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

            Button {
                saveConfig()
            } label: {
                Text(L("save"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
            }
        }
        .navigationTitle(L("settings.content.regex"))
        .onAppear(perform: loadConfig)
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
                            Label(L("delete"), systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingItem = item
                            editText = item
                        } label: {
                            Label(L("edit"), systemImage: "pencil")
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
                Label(L("whitelist.add.new"), systemImage: "plus.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L("settings.content.keywords"))
        .onAppear(perform: loadConfig)
        .onDisappear(perform: saveConfig)
        .alert(L("whitelist.add.new"), isPresented: $showAdd) {
            TextField(L("whitelist.enter.value"), text: $newItem)
            Button(L("cancel"), role: .cancel) { newItem = "" }
            Button(L("add")) {
                if !newItem.isEmpty {
                    items.append(newItem.lowercased())
                    newItem = ""
                }
            }
        }
        .alert(L("edit"), isPresented: .init(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField(L("whitelist.enter.value"), text: $editText)
            Button(L("cancel"), role: .cancel) { editingItem = nil }
            Button(L("save")) {
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
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("settings.short.url.regex"))
                            .font(.headline)
                        Text(L("settings.short.url.regex.description"))
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

            Button {
                saveConfig()
            } label: {
                Text(L("save"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
            }
        }
        .navigationTitle(L("settings.short.url.regex"))
        .onAppear(perform: loadConfig)
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
                Stepper(Lf("settings.max.spam.logs", maxSpamLogs), value: $maxSpamLogs, in: 10...5000)
            } footer: {
                Text(L("settings.max.spam.logs.description"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L("settings.log.settings"))
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
                    AppLogo(size: 80)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("app.name"))
                            .font(.title.bold())
                        Text(L("about.spam.blocker"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(L("about.version"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section(L("about.features")) {
                FeatureRow(icon: "bolt.shield", title: L("about.feature.automatic"), desc: L("about.feature.automatic.desc"))
                FeatureRow(icon: "text.badge.checkmark", title: L("about.feature.customizable"), desc: L("about.feature.customizable.desc"))
                FeatureRow(icon: "whitelist", title: L("about.feature.whitelist"), desc: L("about.feature.whitelist.desc"))
                FeatureRow(icon: "doc.text", title: L("about.feature.logging"), desc: L("about.feature.logging.desc"))
            }

            Section(L("about.contact")) {
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
        .navigationTitle(L("about.title"))
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
                Text(L("about.privacy"))
                    .font(.title.bold())

                Text(L("about.privacy.content"))
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(L("about.privacy"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(L("about.terms"))
                    .font(.title.bold())

                Text(L("about.terms.content"))
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(L("about.terms"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
