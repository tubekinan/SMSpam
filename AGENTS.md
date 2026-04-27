# Ajanlar Yapilandirmasi

Bu dosya, bu depoda calisan otomatik ajanlar (OpenCode gibi) icin talimatlar icerir.

## Genel Yonergeler

- Her zaman mevcut kod stilini ve kurallarini saygi gosterin
- Minimal, odakli degisiklikler yapin
- Yeni kodun duzgun sekilde test edildiginden emin olun
- Belgelemeyi ilgili oldugunda guncelleyin
- TODO.md dosyasini, belirtilen guncelleme sureci disinda degistirmeyin

## Gorev Tipleri

Sorunlar uzerinde calisirken lutfen bu kaliplari izleyin:

### Hata Duzeltmeleri
1. Sorunu yeniden olusturan bir test yazin
2. Hatayi duzeltin
3. Tum testlerin gectiginden emin olun
4. Ilgili belgelemeyi guncelleyin

### Ozellik Uygulamasi
1. Tasarim belgelerinin varligini kontrol edin
2. Mevcut kaliplari takip ederek ozelligi uygulayin
3. Yeni islevsellik icin testler ekleyin
4. Kullanici belgelerini guncelleyin
5. Uygulanabilirse API belgelerini guncelleyin

### Yeniden Yapilandirma
1. Yeniden yapilandirmadan once mevcut testlerin gectiginden emin olun
2. Kucuk, artimli degisiklikler yapin
3. Testleri sik sik calistirin
4. Arayuzler degisirse belgelemeyi guncelleyin

## Komutlar

Sik kullanilan komutlar:
- `swift test` - Birim testlerini calistirin
- `swift lint` - SwiftLint'i calistirin (yapilandirilmissa)
- `xcodebuild test` - Testleri xcodebuild uzerinden calistirin

## Belgeleme

Belgelemeyi guncellerken:
- Kisa ve dogru tutun
- Mevcut belgelerin tonunu kullanin
- Hem kod ici yorumlari hem de harici belgeleri guncelleyin
- UI degisiklikleri oldugunda ekran goruntulerini guncelleyin

## Kod Stili

Projedeki mevcut Swift stilini izleyin:
- Girinti icin 4 bosluk kullanin
- Okunurlugunu artirsa acik turleri tercih edin
- Erken cikislar icin guard sartlarini kullanin
- IBOutlets ve IBActions'i uygun sekilde isaretleyin
- Mumkun oldugunda satirlari 120 karakterin altinda tutun

## Commit Mesajlari

Acik ve aciklayici commit mesajlari yazin:
- Buyuk harfle baslayin
- Istek kipi kullanin ("Ekle ozellik" not "Eklendi ozellik")
- Konu satirini 72 karakterin altinda tutun
- Gerekirse vucutta kisa bir aciklama ekleyin
- Uygulanabilirse issue numaralarina referans verin: "Duzeltme #123"
