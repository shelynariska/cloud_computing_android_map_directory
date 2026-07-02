# ☕ CafeScope SBY

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white)

**Aplikasi direktori kafe Surabaya berbasis Flutter dengan fitur peta interaktif, GPS, dan routing.**

*Praktikum Cloud Computing — Kelompok 3*

</div>

---

## 📱 Tentang Aplikasi

**CafeScope SBY** adalah aplikasi mobile yang membantu pengguna menemukan kafe-kafe terbaik di Surabaya. Dilengkapi dengan peta interaktif berbasis OpenStreetMap, fitur GPS real-time, kalkulasi jarak, dan navigasi rute menuju kafe pilihan.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🗺️ **Peta Interaktif** | Menampilkan seluruh kafe Surabaya di peta OpenStreetMap |
| 📍 **GPS Real-time** | Mendeteksi lokasi pengguna secara real-time |
| 📏 **Kalkulasi Jarak** | Menghitung jarak dari lokasi pengguna ke setiap kafe |
| 🧭 **Routing** | Menampilkan rute mengemudi via OSRM langsung di peta |
| ❤️ **Favorit** | Menyimpan kafe favorit (memerlukan login) |
| 🔍 **Search & Filter** | Pencarian kafe dan filter berdasarkan wilayah |
| 🔐 **Autentikasi** | Login & Register via Supabase Auth |
| 👤 **Profil** | Halaman akun dengan info pengguna dan logout |
| 📊 **355+ Kafe** | Data lengkap kafe-kafe wilayah Surabaya |

---

## 🛠️ Teknologi yang Digunakan

### Frontend
- **Flutter** — Framework utama aplikasi mobile
- **Riverpod** — State management
- **Go Router** — Navigasi antar halaman
- **flutter_map** — Peta interaktif (OpenStreetMap)
- **geolocator** — Akses GPS perangkat

### Backend & Cloud
- **Supabase** — Database PostgreSQL cloud, REST API, dan Autentikasi
- **OSRM (Open Source Routing Machine)** — Kalkulasi rute gratis tanpa API key berbayar
- **OpenStreetMap** — Tile peta gratis

### Packages Utama
```yaml
dependencies:
  # UI & Design
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.0

  # Navigation & State Management
  go_router: ^14.2.0
  flutter_riverpod: ^2.5.1

  # Maps & Location
  flutter_map: ^6.1.0
  flutter_map_marker_popup: ^5.1.1
  geolocator: ^14.0.2
  location: ^5.0.1

  # API & Networking
  http: ^1.1.0
  url_launcher: ^6.2.0
  shared_preferences: ^2.2.0

  # Supabase & Backend
  supabase_flutter: ^2.3.0
  flutter_dotenv: ^5.1.0

  # Utils
  uuid: ^4.5.3
  flutter_native_splash: ^2.4.3
```

---

## 🗄️ Struktur Database (Supabase)
cafes          → Data utama kafe (nama, koordinat, fasilitas, rating)

categories     → Kategori kafe

favorites      → Kafe favorit per user

reviews        → Ulasan dan rating dari user

visit_stats    → Statistik kunjungan kafe

place_photos   → Foto kafe

issue_reports  → Laporan masalah kafe

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.7.2
- Dart SDK ≥ 3.7.2
- Akun Supabase (gratis)
- iOS 12+ atau Android 5.0+ untuk menjalankan di device

### Langkah Instalasi

**1. Clone repository**
```bash
git clone https://github.com/shelynariska/cloud_computing_android_map_directory.git
cd cloud_computing_android_map_directory
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Konfigurasi environment**

Buat file `.env` di root project:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**4. Konfigurasi iOS (untuk GPS)**

Tambahkan ke `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi untuk menampilkan kafe terdekat</string>
```

**5. Jalankan aplikasi**
```bash
flutter run
```

---

## 📂 Struktur Project
lib/

├── app/

│   ├── router/         # Konfigurasi navigasi (Go Router)

│   └── theme/          # Warna dan tema aplikasi

├── data/               # Mock data fallback

├── models/             # Model data (Cafe, dll)

├── presentation/

│   ├── screens/        # Halaman aplikasi

│   │   ├── splash_screen.dart

│   │   ├── home_screen.dart

│   │   ├── map_page.dart

│   │   ├── cafe_detail_screen.dart

│   │   ├── favorites_screen.dart

│   │   ├── profile_screen.dart

│   │   ├── login_screen.dart

│   │   └── register_screen.dart

│   └── widgets/        # Widget reusable

├── providers/          # Riverpod providers

└── services/           # Supabase service & Navigation service

---

## 👥 Tim Pengembang

| Nama | NIM | Peran |
|---|---|---|
| Aryo Prabowo | 434231027 | Cloud Engineer & Backend (Supabase, REST API) |
| Shelyna Riska Amanatullah | 434231005 | Frontend Engineer (UI/UX Flutter) |
| Shendy Tria Amelyana | 434231003 | Maps & Location Engineer (OSM, GPS, Routing) |

---

## 📌 Pembagian Jobdesk

### 👩 Shelyna Riska — Flutter UI & Frontend

> Fokus utama: tampilan aplikasi dan alur pengguna 📱

**Tugas:**
- Membuat project Flutter
- Membuat tampilan: Splash Screen, Home Page, Detail Cafe, Filter Wilayah, Profile
- Membuat card/list cafe dan navigasi antar halaman
- Menampilkan data cafe dari Supabase ke UI
- Implementasi fitur Favorit dan Autentikasi (Login, Register, Logout)
- Menyesuaikan tampilan agar rapi dan user-friendly

**Output:**
- ✅ UI aplikasi berjalan
- ✅ List cafe tampil
- ✅ Filter wilayah tampil
- ✅ Detail cafe tampil
- ✅ Halaman Profile dengan kondisi login/guest
- ✅ Fitur Favorit tersimpan di Supabase

---

### 👨 Aryo Prabowo — Database & Supabase

> Fokus utama: cloud database dan data cafe ☁️

**Tugas:**
- Setup project Supabase dan membuat tabel database
- Menentukan struktur tabel cafe
- Input data cafe Surabaya (355+ kafe) dengan region: Barat, Timur, Selatan, Utara, Pusat
- Menyimpan: nama, alamat, latitude, longitude, rating, deskripsi
- Testing query/filter Supabase

**Output:**
- ✅ Database online
- ✅ Data cafe tersimpan
- ✅ Query filter region berjalan
- ✅ Supabase terhubung ke Flutter

---

### 👩 Shendy Tria — Maps, GPS & Routing

> Fokus utama: peta interaktif dan lokasi pengguna 🗺️📍

**Tugas:**
- Integrasi OpenStreetMap via `flutter_map` (solusi gratis tanpa API key berbayar)
- Menampilkan marker cafe di peta
- Mengambil lokasi pengguna (GPS) secara real-time
- Menghitung jarak user ke cafe (meter/km)
- Membuat fitur tampilkan rute via OSRM langsung di peta
- Filter marker berdasarkan radius (0.5/1/2/5 km)
- Testing GPS & routing

**Output:**
- ✅ Map tampil
- ✅ Marker cafe muncul
- ✅ Lokasi user terbaca
- ✅ Jarak cafe tampil
- ✅ Rute di peta berjalan

---

### 🌟 Kerja Bersama (Semua Anggota)

- Menentukan konsep aplikasi
- Menentukan desain sederhana
- Testing akhir
- Demo aplikasi
- Presentasi
- Dokumentasi & screenshots

---

## 📅 Alur Pengerjaan

| Minggu | Progress |
|---|---|
| 1 | Setup Supabase + desain UI |
| 2 | Flutter UI + input data cafe |
| 3 | Integrasi Supabase ke Flutter |
| 4 | Maps + GPS |
| 5 | Routing + testing |
| 6 | Dokumentasi + presentasi |

---

## 🎯 Target Minimum Project

- ✅ List cafe Surabaya
- ✅ Filter wilayah
- ✅ Database online (Supabase)
- ✅ Marker map
- ✅ GPS user
- ✅ Jarak user ke cafe
- ✅ Rute di peta
- ✅ Autentikasi pengguna (Login, Register, Logout)
- ✅ Fitur Favorit per pengguna

---

## ☁️ Cloud Services

| Layanan | Fungsi |
|---|---|
| **Supabase** | Database PostgreSQL, REST API, Authentication |
| **OpenStreetMap** | Tile peta interaktif (gratis) |
| **OSRM** | Routing & navigasi rute (gratis) |

---

## 📸 Screenshot

<table>
  <tr>
    <th>Registrasi</th>
    <th>Login</th>
    <th>Home</th>
    <th>Detail Cafe</th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/d94f92e6-c2a5-4e9d-83fb-a164178e700e" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/73140e5a-0865-4d9c-8da8-8c1bfe993ad7" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/badc87f3-e88b-4591-9b34-4791421f1113" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/a3accc77-7659-45d2-a1d6-773a30753c33" width="180"></td>
  </tr>
</table>

<table>
  <tr>
    <th>Peta</th>
    <th>Favorite</th>
    <th>Profil (Guest)</th>
    <th>Profil (Login)</th>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/67b6fad4-62a2-4636-a6b4-4959e7491ce5" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/00c96076-cce0-488d-bce3-c45ed1c480fe" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/a293375a-ec0f-4b87-9c92-8f686ce2a67c" width="180"></td>
    <td><img src="https://github.com/user-attachments/assets/fa2d29c6-4711-429b-bc9a-1dea7cc4d85e" width="180"></td>
  </tr>
</table>

---

## 📄 Lisensi

Project ini dibuat untuk keperluan **Praktikum Cloud Computing** — Informatika.

---

<div align="center">
Made with ☕ by Kelompok 3
</div>

---

## 🧪 Testing

Pengujian dilakukan secara manual langsung di perangkat/simulator dan diverifikasi melalui Supabase Dashboard.

### Hasil Testing Maps & GPS

| No | Skenario | Hasil |
|---|---|---|
| 1 | Buka halaman Peta | ✅ Peta OSM berhasil tampil |
| 2 | GPS aktif, lokasi user terbaca | ✅ Marker biru & lingkaran radius muncul |
| 3 | Marker 355 kafe tampil di peta | ✅ Semua marker muncul sesuai koordinat |
| 4 | Tap marker kafe → popup muncul | ✅ Popup tampil dengan nama, alamat, jarak |
| 5 | Jarak user ke kafe dihitung | ✅ Jarak tampil dalam meter/km (contoh: 544m) |
| 6 | Tap "Tampilkan Rute di Peta" | ✅ Garis rute oranye tampil via OSRM |
| 7 | Ganti radius filter (0.5/1/2/5 km) | ✅ Marker dan info bar terupdate otomatis |
| 8 | Info bar "X cafes found" | ✅ Jumlah kafe dalam radius tampil real-time |
| 9 | Tap tombol tutup rute (X) | ✅ Rute berhasil dihapus dari peta |
| 10 | Tap tombol lokasi saya | ✅ Kamera peta kembali ke posisi user |

### Hasil Testing Favorit

| No | Skenario | Hasil |
|---|---|---|
| 1 | Tap icon ❤️ tanpa login | ✅ Muncul pesan untuk login terlebih dahulu |
| 2 | Tap icon ❤️ setelah login | ✅ Kafe tersimpan di tabel `favorites` Supabase |
| 3 | Tap icon ❤️ kedua kali (hapus) | ✅ Kafe berhasil dihapus dari favorit |
| 4 | Buka halaman Favorit | ✅ Daftar kafe favorit tampil |

### Hasil Testing Autentikasi

| No | Skenario | Hasil |
|---|---|---|
| 1 | Register akun baru | ✅ Akun tersimpan di Supabase Auth |
| 2 | Login dengan akun terdaftar | ✅ Berhasil masuk ke halaman Home |
| 3 | Login dengan password salah | ✅ Muncul pesan error yang sesuai |
| 4 | Lanjut tanpa login | ✅ Bisa akses Home & Peta tanpa login |

### Hasil Testing Profil

| No | Skenario | Hasil |
|---|---|---|
| 1 | Buka tab Profil tanpa login | ✅ Tampil tombol Login & Register |
| 2 | Buka tab Profil setelah login | ✅ Tampil nama, email, dan tombol Logout |
| 3 | Tap Logout → dialog konfirmasi | ✅ Dialog konfirmasi muncul |
| 4 | Konfirmasi Logout | ✅ Tampilan kembali ke halaman guest otomatis |

---

## 📖 Dokumentasi Teknis

### Arsitektur Fitur Maps
MapPage (ConsumerStatefulWidget)

├── _initializeLocation()     → Request GPS permission & get position

├── _startPulseAnimation()    → Animasi lingkaran pulse di lokasi user

├── _getRouteFromOSRM()       → Fetch rute dari OSRM API

├── _calculateDistance()      → Haversine formula untuk hitung jarak (km)

├── _getCategoryMarkerColor() → Warna marker berdasarkan kategori kafe

└── _showCafePopup()          → Dialog info kafe + tombol rute & favorit

### Alur Pengguna (User Flow)

**Skenario 1 — Pengguna Tanpa Login:**
Buka aplikasi → izinkan akses GPS →

Lihat daftar kafe → filter wilayah →

Pilih kafe → lihat detail (jarak, fasilitas, review) →

Tap "Rute" → buka navigasi eksternal

**Skenario 2 — Pengguna Dengan Login:**
Tap Profil → Login/Register →

Tap ❤️ pada kafe → tersimpan ke Supabase →

Buka tab Favorit → lihat daftar kafe favorit →

Tap Profil → Logout → konfirmasi → kembali ke tampilan guest

### Cara Kerja GPS & Routing

**1. Inisialisasi GPS**
App start → Cek Location Service → Cek Permission →

Request Permission (jika denied) → Get Current Position →

Update UI & Move Camera ke posisi user

**2. Kalkulasi Jarak (Haversine Formula)**
```dart
double _calculateDistance(lat1, lon1, lat2, lon2) {
  // Haversine formula
  // Output: jarak dalam kilometer
  // Contoh: 0.544 km → ditampilkan sebagai "544m"
}
```

**3. Routing via OSRM**
User tap "Tampilkan Rute" →

Request ke router.project-osrm.org →

Parse GeoJSON coordinates →

Render Polyline oranye di flutter_map

**4. Filter Radius**
User pilih radius (0.5 / 1 / 2 / 5 km) →

Filter cafes where distance <= radiusKm →

Update MarkerLayer + CircleLayer + InfoBar secara real-time

### Keamanan Sistem

- API Key Supabase (anon key) hanya memiliki permission terbatas sesuai **Row Level Security (RLS)**
- Kredensial database tidak pernah disertakan dalam kode aplikasi
- Semua komunikasi menggunakan **HTTPS/TLS** secara default
- RLS dikonfigurasi agar pengguna hanya dapat mengakses data favorit dan review milik sendiri

### API Endpoint yang Digunakan

| Endpoint | Method | Fungsi |
|---|---|---|
| `/cafes` | GET | Fetch semua data kafe dari Supabase |
| `/cafes?id=eq.{id}` | GET | Fetch detail kafe by ID |
| `/categories` | GET | Fetch daftar kategori |
| `/favorites?user_id=eq.{uid}` | GET | Fetch favorit user |
| `/favorites` | POST | Tambah kafe ke favorit |
| `/favorites?id=eq.{id}` | DELETE | Hapus kafe dari favorit |
| `/reviews` | GET | Fetch daftar review |
| `/place_photos` | GET | Fetch foto kafe |
| `/visit_stats` | GET | Fetch statistik kunjungan |
| `router.project-osrm.org/route/v1/driving` | GET | Kalkulasi rute mengemudi |
