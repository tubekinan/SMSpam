# Ajanlar Yapılandırması

Bu dosya, bu depoda çalışan otomatik ajanlar (OpenCode gibi) için talimatlar içerir.

## Genel Yönergeler

- Her zaman mevcut kod stilini ve kurallarını saygı gösterin
- Minimal, odaklı değişiklikler yapın
- Yeni kodun düzgün şekilde test edildiğinden emin olun
- Belgelemeyi ilgili olduğunda güncelleyin
- TODO.md dosyasını, belirtilen güncelleme süreci dışında değiştirmeyin

## Görev Tipleri

Sorunlar üzerinde çalışırken lütfen bu kalıpları izleyin:

### Hata Düzeltmeleri
1. Sorunu yeniden oluşturan bir Unit test yazın
2. Hatayı düzeltin
3. Tüm testlerin geçtiğinden emin olun
4. İlgili belgelemeyi güncelleyin

### Özellik Uygulaması
1. Tasarım belgelerinin varlığını kontrol edin
2. Mevcut kalıpları takip ederek özelliği uygulayın
3. Yeni işlevsellik için Unit testler ekleyin
4. Kullanıcı belgelerini güncelleyin
5. Uygulanabilirse API belgelerini güncelleyin

### Yeniden Yapılandırma
1. Yeniden yapılandırmadan önce mevcut testlerin geçtiğinden emin olun
2. Küçük, artımlı değişiklikler yapın
3. Testleri sık sık çalıştırın
4. Arayüzler değişirse belgelemeyi güncelleyin

## Komutlar

Sık kullanılan komutlar:
- `swift test` - Unit testlerini çalıştırın
- `swift lint` - SwiftLint'i çalıştırın (yapılandırılmışsa)
- `xcodebuild test` - Testleri xcodebuild üzerinden çalıştırın

## Belgeleme

Belgelemeyi güncellerken:
- Kısa ve doğru tutun
- Mevcut belgelerin tonunu kullanın
- Hem kod içi yorumları hem de harici belgeleri güncelleyin
- UI değişiklikleri olduğunda ekran görüntülerini güncelleyin

## Kod Stili

Projedeki mevcut Swift style izleyin:
- Girinti için 4 boşluk kullanın
- Okunurluğunu artırsa açık türleri tercih edin
- Erken çıkışlar için guard şartlarını kullanın
- IBOutlets ve IBActions'i uygun şekilde işaretleyin
- Mümkün olduğunda satırları 120 karakterin altında tutun
