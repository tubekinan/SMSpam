	Dil: Swift
	IDE: Xcode
	API: IdentityLookup
	Mimari:
		App (UI)
		Message Filter Extension
		App Group (shared data)

 

[Prompt Gereksinimleri]

- Checkpoint (CP) sistemiyle; güncel prompt olutur. Mulak ve gevek olmamal. Yeni oturumda gerçek anlamda kalnan yerden devam etmeli. 
- Her 
CP sistemi [Prompt çerii] bölümündeki 4 adm karlamal.
- Her promptu: Bu noktadan itibaren devam et dedirtecek kadar açk olacak.

[Prompt çerii]

1.  Proje Tanm (sabit)

		App ne yapyor
		Teknik stack

2.  Mevcut Durum (state)

		Neleri yaptk
		Hangi dosyalar / modüller hazr

3.  Son Yaplan  (delta)

		Bu checkpointe kadar ne eklendi

4.  Sonraki Hedef (next step)

		Bir sonraki oturumda ne yaplacak

[Projenin parçalar]

Phase 1  Foundation

		Xcode project
		SMS Filter Extension
		App Group

Phase 2  Filtering Engine

		Keyword system
		Regex support
		Rule engine

Phase 3  Logging & Monitoring

		Shared storage
		Engellenen mesaj listesi UI

Phase 4  UX + Control

		Rule management UI
		Whitelist / blacklist

Phase 5  Advanced (opsiyonel ama gerçek güç burada)
		Backend API
		ML spam detection

- Current status: whitelist (never-block) implemented (highest priority).- Current status: dynamic rule engine loads patterns from shared App Group JSON config (no hardcoded per-keyword rebuild).- Current status: spam logs capped to max limit to avoid unbounded growth.