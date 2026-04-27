# TODO - Geliştirme ve İyileştirme Önerileri

## Tespit Edilen Eksiklikler

1. **Test Eksikliği**
   - Birim testleri (Unit Tests) bulunmamaktadır
   - UI testleri yoktur
   - Spam filtreleme mantığı için otomatik testler gerekir

2. **CI/CD Pipeline Eksikliği**
   - Otomatik build ve test için GitHub Actions yapılandırılmamış
   - Kod kalitesi kontrolü (linting) otomatikleştirilmemiş

3. **Performans İzleme**
   - Uzantının performans metrikleri toplanmamaktadır
   - Bellek kullanımı ve CPU tüketimi izlenmemektedir

4. **Eksik Özellikler**
   - Spam istatistiklerinin detaylı görselleştirmesi
   - Yedekleme/geri yükleme fonksiyonu
   - Şifreli yedekleme seçeneği
   - Bildirim özelleştirme (spam engellendiğinde farklı sesler)

5. **Kullanıcı Deneyimi İyileştirmeleri**
   - Onboarding/tutorial ekranı
   - Boş durum görünümlerinde daha fazla bilgilendirme
   - Hızlı eylemler (quick actions) için 3D Touch/lengthy press desteği

6. **Gizlilik ve Güvenlik**
   - App Privacy etiketleri App Store Connect'te eksik
   - Veri koruma sınıfları (Data Protection) belirtilmemiş
   - Hassas veri (spam logları) için ek koruma gerekli

7. **Uluslararasılaştırma (i18n)**
   - Yerelleştirilmiş stringlerin tamamı kontrol edilmemiş
   - Bazı hardcoded stringler olabilir

8. **Belgeler**
   - API dokümantasyonu eksik
   - Geliştirici kılavuzu güncel değil
   - Katkıda bulunanlar için kodスタイル rehberi eksik

## Dokümantasyon Geliştirme Notları

Aşağıdaki bölümde DOCS klasöründeki dosyalardan tespit edilen geliştirme notları ve tamamlanmamış bölümler yer alacaktır.

- Docs/Phases/Phase2.md: Update this doc to match your final role logic.
