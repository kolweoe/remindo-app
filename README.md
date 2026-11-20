# Remindo (Gamified Habit, Reminder, Focus Timer & Student Finance App)

Aplikasi produktivitas dan pencatatan keuangan saku siswa/mahasiswa bertema **Pixel Retro RPG**, dibangun dengan **Flutter** dan **100% Offline-First SQLite**.

---

## 🌟 Fitur Utama

1. **Kamar Hero & Gamifikasi RPG (Lv.1 - Lv.8)**
   - Sistem Level, XP, Koin, dan Streak harian.
   - Upgrade visual kamar hero dari Level 1 hingga Level 8.
   - Kustomisasi kostum hero dan peliharaan (Pet).
2. **Papan Misi & Quest Bertimer**
   - Kategori Misi: Harian, Mingguan, Epik, dan Bertimer (Mode Fokus).
   - Mode Fokus Pomodoro/Timer Belajar dengan musik ambient Lo-Fi.
   - Bonus +20% XP untuk streak >= 3 hari atau sesi fokus yang diselesaikan tepat waktu.
3. **Dompetku & Peti Tabungan**
   - Pencatatan uang saku (Pemasukan & Pengeluaran) secara instan.
   - Target Peti Tabungan dengan progres bar dan setoran atomik (otomatis memotong saldo dompet).
4. **Layanan Latar Belakang Android & Stiker Mengambang**
   - **3 Versi Stiker Mengambang (`SYSTEM_ALERT_WINDOW`)**:
     - Stiker Quest Bertimer
     - Stiker Quest Pengingat
     - Stiker Laporan Dompet
   - Notifikasi terjadwal harian dan bulanan untuk laporan keuangan.
   - Full Screen Alarm untuk pengingat misi penting.
5. **Cadangan & Pemulihan Database**
   - Ekspor dan impor file SQLite `remindo_local.db` langsung dari aplikasi.
6. **Arsitektur Semi-Online (GitHub Catalog)**
   - Sinkronisasi aset skin, pet, dan event terbatas melalui repositori GitHub publik (`catalog.json`) dengan sistem cache offline lokal.

---

## 📐 Kompatibilitas Layar & Responsivitas

- Seluruh 21 layar didesain berdasarkan viewport dasar **390px** (standar mobile modern).
- Menggunakan `ResponsiveWrapper`, `LayoutBuilder`, dan adaptif scaling (`Responsive.px(context, ...)`) sehingga layout tampil presisi, proporsional, dan bebas overflow di semua merk serta ukuran layar HP (Samsung, Xiaomi/Redmi, Oppo, Vivo, Infinix, Pixel, dsb).

---

## 🛠️ Stack Teknis

- **Framework**: Flutter (Dart)
- **Database**: SQLite (`sqflite`) -> file `remindo_local.db`
- **State Management**: Riverpod (`flutter_riverpod`)
- **Background Services**:
  - `flutter_local_notifications`
  - `android_alarm_manager_plus`
  - `flutter_overlay_window`
  - `audioplayers`
- **Utility**: `permission_handler`, `file_picker`, `share_plus`, `intl`, `http`

---

## 🚀 Panduan Build APK

### 1. Bersihkan & Unduh Dependensi
```bash
flutter clean
flutter pub get
```

### 2. Build APK Debug (Uji Coba di HP)
```bash
flutter build apk --debug
```
File APK: `build/app/outputs/flutter-apk/app-debug.apk`

### 3. Build APK Release (Siap Pakai & Ringan)
```bash
flutter build apk --release --split-per-abi
```
File APK:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (HP Android modern 64-bit)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (HP Android 32-bit)
