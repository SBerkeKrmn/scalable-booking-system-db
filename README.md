# 📅 Ölçeklenebilir Rezervasyon Sistemi Veritabanı Tasarımı

Merhaba, bu projede çok kiracılı (multi-tenant) bir rezervasyon sistemi senaryosu için **MySQL** üzerinde ilişkisel bir veritabanı mimarisi tasarladım.

Amacım; sadece veri saklayan bir yapı değil, **veri bütünlüğünü (data integrity)** garanti altına alan, finansal tutarlılığa sahip ve gerçek hayat senaryolarındaki "edge case"leri (fiyat değişimleri, mükerrer kayıtlar vb.) yönetebilen profesyonel bir şema oluşturmaktı.

## 🛠️ Kullanılan Teknolojiler & Yöntemler
* **Veritabanı:** MySQL (PostgreSQL uyumlu)
* **Tasarım Deseni:** İlişkisel Veritabanı (RDBMS) - 3. Normal Form (3NF)
* **Araçlar:** MySQL Workbench (EER Diyagramı ve Modelleme için)

## 🗂️ Veritabanı Mimarisi Hakkında
Sistem toplamda 9 ilişkisel tablodan oluşuyor ve şu temel modülleri kapsıyor:

1.  **Kimlik Yönetimi:** Kullanıcılar ve Hizmet Sağlayıcılar (Service Providers) için onay mekanizmalı (SMS/Belge onayı) ayrıştırılmış tablolar.
2.  **Mekan & Konum:** Enlem/Boylam (Geolocation) verileriyle desteklenen ve dinamik olarak çalışma saatleri engellenebilen (Blocked Hours) mekan yapısı.
3.  **Topluluk & Roller:** Mekanlara özel topluluk grupları ve bu gruplar içinde "Yönetici/Üye" gibi rol tanımlamaları (Many-to-Many ilişki).
4.  **Finansal İşlemler:** Rezervasyon ve kapora yönetimi.

## 🚀 Projede Çözdüğüm Kritik Problemler

Tasarım aşamasında özellikle şu mühendislik problemlerine odaklandım:

### 1. Fiyat Değişikliklerinde Veri Tutarlılığı (Snapshot Pattern)
Bir mekan sahibi saatlik ücretine zam yaptığında, geçmişteki rezervasyonların fiyat bilgisi bozulmamalıydı.
* **Çözüm:** `Bookings` tablosunda **Snapshot Pattern** uyguladım. Rezervasyon anındaki fiyatı ve kaporayı `price_at_booking` sütununa kopyalayarak, mekanın güncel fiyatından bağımsız, değişmez bir finansal kayıt oluşturdum.

### 2. İş Kuralları ve Kısıtlamalar (Constraints)
Yazılım tarafına bırakmadan, veritabanı seviyesinde hataları engelledim.
* **Composite Unique Key:** Aynı mekan isminin farklı şehirlerde kullanılabilmesi ama aynı şehirde/mekanda tekrar edememesi gibi kuralları `UNIQUE(venue_id, name)` gibi yapılarla sağladım.
* **On Delete Cascade:** Bir kullanıcı veya mekan silindiğinde, ona bağlı "öksüz veri" (orphan data) kalmaması için tüm ilişkileri zincirleme silinecek şekilde kurguladım.

### 3. Gerçekçi Yorum Sistemi
Sistemi manipüle etmeye açık sahte yorumların önüne geçmek istedim.
* **Çözüm:** Yorum tablosunu doğrudan rezervasyon tablosuna bağladım (`UNIQUE foreign key`). Böylece hizmet almamış birinin yorum yapmasını veya bir hizmet için birden fazla yorum yapılmasını veritabanı düzeyinde engelledim.

## 📄 Kurulum

Eğer bu yapıyı kendi lokalinizde incelemek isterseniz `.sql` dosyasını import etmeniz yeterli:

```sql
source schema.sql;
