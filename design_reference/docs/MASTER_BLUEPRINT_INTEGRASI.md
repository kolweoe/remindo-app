# Master Blueprint & Panduan Integrasi Aplikasi **Remindo**

Dokumen ini adalah **spesifikasi induk (Master Blueprint)** untuk mengintegrasikan seluruh antarmuka, tombol, navigasi, basis data offline (**SQLite**), dan layanan latar belakang (**Android / Flutter**) pada aplikasi **Remindo**.

---

## 1. Gambaran Umum & Arsitektur Sistem

- **Nama Aplikasi**: Remindo (Gamified Reminder, Focus Timer & Student Finance App)
- **Platform Target**: Android (Flutter + Dart)
- **Mode Operasi**: **100% Offline-First** menggunakan **SQLite (`sqflite`)** lokal di perangkat. Tidak memerlukan server backend untuk operasional harian.
- **Koneksi Eksternal Opsional**:
  - **GitHub Releases API** (hanya saat pengguna menekan tombol *Cek & Update App dari GitHub* di Pengaturan Utama).
- **Tema & Sistem Desain**: Soft 2D Pixel-Art RPG (`DESIGN.md` & `tailwind.config.js`), font *Boogaloo* (headline), *Capriola* (UI/body), *Spline Sans Mono* (angka/timer/rupiah).

---

## 2. Daftar Lengkap Layar, Fungsi, & Aksi Tombol

### A. Lobi, Onboarding & Sistem Utama
1. **Onboarding — Buat Hero Awal** (`screens/onboarding/Onboarding.html`)
   - **Fungsi**: Layar pertama saat aplikasi baru dipasang (jika tabel `hero_profile` masih kosong).
   - **Penggunaan**: Pengguna memilih karakter awal, mengisi nama panggilan Hero, memilih peliharaan awal, lalu masuk ke Lobi.
   - **Tombol & Aksi**:
     - `Mulai Petualangan` -> Simpan `hero_profile` ke SQLite, arahkan ke `Home`.
     - `Sudah punya cadangan? Pulihkan Data` -> Arahkan ke `Settings` (bagian Backup SQLite).

2. **Home — Kamar Hero** (`screens/home/Home.html`)
   - **Fungsi**: Lobi utama yang menampilkan kamar pixel art sesuai level saat ini (`Lv.1` s/d `Lv.8`), karakter Hero, dan Pet aktif.
   - **Tombol & Aksi**:
     - Header HUD: Menampilkan `Level Hero`, `XP Bar`, dan `Total Coin` secara real-time dari SQLite.
     - Tombol Pengaturan (kiri atas, `#lobby-settings-btn`) -> Buka `Settings`.
     - Tombol `Upgrade Kamar` (kanan atas, `#upgrade-room-btn`) -> Buka `RoomUpgrade`.
     - Tap pada Hero / Pet -> Tampilkan toast interaksi / dialog penyemangat.
     - Quick Quest Banner -> Buka `Quests`.
     - **Navigasi Bawah (5 Slot)**: `Home` (`#home`), `Quests` (`#quests`), Tombol `+` Tengah (Quick Add Quest -> `AddQuest`), `Wallet` (`#wallet`), `Hero` (`#hero`).

3. **Upgrade Kamar (Lv.1–Lv.8)** (`screens/room-upgrade/RoomUpgrade.html`)
   - **Fungsi**: Progres visual kamar Hero dari Lv.1 (sederhana) hingga Lv.8 (kamar sultan/maksimal) menggunakan Coin hasil menyelesaikan Quest.
   - **Tombol & Aksi**:
     - Tombol Kembali (`<-`) -> Kembali ke `Home`.
     - Daftar Slot Lv.1–Lv.8: Menampilkan preview gambar kamar (bisa memakai aset bawaan atau file gambar kustom pengguna dari folder `/kamar`).
     - Tombol `Upgrade ke Lv.X` -> Cek kecukupan `coins`, kurangi `coins`, naikkan `room_level` di SQLite, perbarui gambar kamar di `Home`.

4. **Pengaturan Utama** (`screens/settings/Settings.html`)
   - **Fungsi**: Pusat kontrol aset kustom, pembaruan aplikasi, cadangan data, nada dering, mode fokus, dan izin overlay.
   - **Fitur & Tombol**:
     - **Input Gambar (4 Folder)**: Tab `1. Karakter`, `2. Kamar (1–8)`, `3. Pet`, `4. Popup Alarm`. Tombol `Pilih File` memanggil `file_picker` / galeri HP dan menyimpan path gambar lokal ke tabel `custom_assets`.
     - **Update App (GitHub)**: Input URL repository GitHub + tombol `Cek & Update App dari GitHub` (cek tag rilis terbaru & unduh APK).
     - **Backup Data Offline (SQLite)**: Tombol `Cadangkan` (ekspor file `.db` ke folder Download/Documents), `Pulihkan` (impor file `.db`), dan `Reset Data Lokal` (hapus seluruh tabel dengan dialog konfirmasi).
     - **Nada Dering Alarm**: Pilih `Pixel Chime`, `8-Bit Morning`, atau `Pilih Audio Lokal (MP3/OGG)` untuk alarm quest.
     - **Musik & Latar Mode Fokus**:
       - `Pilih Gambar` (Latar Pixel Fokus) -> Simpan path gambar latar untuk layar `TimedQuest`.
       - `Pilih Musik` (Musik Pengiring) -> Simpan path MP3/OGG lokal untuk diputar saat Mode Fokus.
       - `Buka Pratinjau Mode Fokus` -> Buka `TimedQuest`.
     - **Stiker Mengambang**: Sakelar ON/OFF (`SYSTEM_ALERT_WINDOW`) untuk mengizinkan stiker pengingat tampil di atas aplikasi lain, plus pintasan pratinjau ke 3 tipe popup (`Timer`, `Pengingat`, `Dompetku`).

---

### B. Quest, Mode Fokus, Alarm & Stiker Mengambang
5. **Quests — Quest Board** (`screens/quests/Quests.html`)
   - **Fungsi**: Papan misi harian, mingguan, epic, dan quest bertimer.
   - **Fitur & Tombol**:
     - Tab Kategori: `Daily`, `Weekly`, `Epic`, `Timed`.
     - **Quest Bertimer**: Tombol `Mulai Timer` / `Mulai Fokus` -> Buka `TimedQuest` dengan ID quest aktif. Tombol centang terkunci sampai timer selesai.
     - **Quest Pengingat (Tanpa Timer)**: Tombol centang langsung (`quest-check-btn`) -> Tandai selesai, tambah `XP` & `Coin` ke `hero_profile`, catat ke `quest_history`.
     - Banner Streak -> Menampilkan jumlah hari beruntun (`+20% XP`).
     - Tombol `Riwayat & Statistik Quest` -> Buka `QuestHistory`.
     - Tombol `+` (Navigasi Bawah) -> Buka `AddQuest`.

6. **Tambah Quest (Ber-Timer)** (`screens/add-quest/AddQuest.html`)
   - **Fungsi**: Membuat quest baru yang wajib dikerjakan dengan hitungan mundur (timer fokus).
   - **Input**: Nama Quest, Kategori (`Daily`/`Weekly`/`Epic`), Tingkat Kesulitan (`Easy`/`Normal`/`Hard`), Durasi Timer (menit), Jadwal Alarm (opsional), dan Tipe Pengulangan.
   - **Tombol**: `X` (kembali ke `Quests`), `Simpan Quest` (insert ke tabel `quests` dengan `is_timed = 1`, jadwalkan alarm jika aktif).

7. **Tambah Quest — Pengingat (Langsung Centang)** (`screens/add-quest-reminder/AddQuestReminder.html`)
   - **Fungsi**: Membuat quest pengingat ringan tanpa timer yang bisa langsung dicentang selesai.
   - **Input**: Nama Pengingat, Kategori, Tingkat Kesulitan, Jam Pengingat, dan Tipe Pengulangan.
   - **Tombol**: `X` (kembali ke `Quests`), `Simpan Pengingat` (insert ke tabel `quests` dengan `is_timed = 0`).

8. **Quest Timer — Fokus** (`screens/timed-quest/TimedQuest.html`)
   - **Fungsi**: Layar fokus yang rileks dan nyaman dengan latar pixel art (`cozy_focus_bg.jpg` atau gambar kustom dari Settings), mokup timer di tengah, dan pemutar musik pengiring.
   - **Fitur & Tombol**:
     - `Mulai` / `Jeda` / `Lanjut` -> Menjalankan countdown timer (tetap berjalan di Foreground Service Android jika layar dimatikan atau popup ditutup).
     - `Reset` -> Mengembalikan waktu ke durasi awal.
     - **Musik Fokus**: Sakelar ON/OFF, pilihan trek (`Lo-Fi Hujan`, `8-Bit Santai`, `Kafe Malam`, `File MP3`), dan slider `Volume` (0%–100%).
     - `Selesaikan Quest` -> Menyelesaikan quest, memberi bonus `+20% XP` jika selesai sebelum waktu habis, lalu kembali ke `Quests`.

9. **Riwayat Quest & Statistik** (`screens/quest-history/QuestHistory.html`)
   - **Fungsi**: Menampilkan catatan quest yang sudah diselesaikan, total XP, total jam fokus, dan grafik konsistensi mingguan.
   - **Tombol**: `<-` kembali ke `Quests`, filter periode (`Hari Ini`, `Minggu Ini`, `Bulan Ini`).

10. **Full Screen Popup Alarm** (`screens/popup-alarm/PopupAlarm.html`)
    - **Fungsi**: Alarm layar penuh yang muncul otomatis saat HP terkunci (`USE_FULL_SCREEN_INTENT`) ketika waktu quest mendesak tiba.
    - **Tombol**: `Done` (selesaikan quest + bonus +20% tanpa snooze), `Snooze 10 mnt` (jadwalkan ulang +10 menit).

11. **3 Versi Stiker Mengambang (Floating Overlay di Atas Aplikasi Lain)**:
    - **Popup Stiker — Quest Bertimer** (`screens/floating-popup-timed/FloatingPopupTimed.html`):
      - Tombol `Mulai Quest` -> Menutup popup stiker dan menjalankan timer di latar belakang (Foreground Service + notifikasi mini persisten yang bisa diketuk untuk membuka `TimedQuest`).
      - Tombol `Tunda 10m` -> Snooze 10 menit.
      - Tombol `Quest` -> Buka aplikasi langsung ke `Quests`.
    - **Popup Stiker — Quest Pengingat** (`screens/floating-popup-reminder/FloatingPopupReminder.html`):
      - Tombol `Centang Selesai (+30 XP)` -> Langsung menandai quest selesai di SQLite dan menutup stiker.
      - Tombol `Tunda 15m` -> Snooze 15 menit.
      - Tombol `Quest` -> Buka aplikasi langsung ke `Quests`.
    - **Popup Stiker — Laporan & Input Dompetku** (`screens/floating-popup-wallet/FloatingPopupWallet.html`):
      - Menampilkan ringkasan saldo, pemasukan, dan pengeluaran hari ini/bulan ini.
      - Tombol Catat Cepat Rutin (`Makan -20K`, `Saku +50K`) -> Langsung insert ke tabel `transactions`.
      - Pintasan `Catat Transaksi` (`#add-transaction`), `Dompetku` (`#wallet`), dan `Jadwal` (`#wallet-notification`).

---

### C. Dompetku (Keuangan Pelajar Offline)
12. **Wallet — Dompetku** (`screens/wallet/Wallet.html`)
    - **Fungsi**: Ringkasan saldo, pemasukan vs pengeluaran bulanan, progress anggaran, dan riwayat transaksi terbaru.
    - **Tombol & Aksi**:
      - Kartu pintasan `Notifikasi Laporan Keuangan` -> Buka `WalletNotification`.
      - Tombol `Tambah Transaksi` -> Buka `AddTransaction`.

13. **Transaksi Baru** (`screens/add-transaction/AddTransaction.html`)
    - **Fungsi**: Mencatat pemasukan atau pengeluaran baru ke SQLite.
    - **Input**: Jenis (`Pemasukan` / `Pengeluaran`), Nominal (Rp), Kategori, Catatan, Tanggal.
    - **Tombol**: `X` (kembali ke `Wallet`), `Simpan Transaksi` (insert ke `transactions` & perbarui saldo).

14. **Notifikasi Laporan Keuangan** (`screens/wallet-notification/WalletNotification.html`)
    - **Fungsi**: Mengatur pengiriman notifikasi laporan keuangan otomatis beserta isi pesannya.
    - **Fitur & Tombol**:
      - **Mode Tampilan Notifikasi**: Sakelar ON/OFF + pilihan 3 mode tampil (`Beranda` / Stiker Mengambang, `Layar Kunci` / Popup Penuh, atau `Otomatis` Keduanya).
      - **Laporan Harian Otomatis**: Sakelar ON/OFF, pilih hari satuan (`Sen`, `Sel`, `Rab`, `Kam`, `Jum`, `Sab`, `Min` — tanpa preset), dan jam kirim.
      - **Laporan Bulanan Otomatis**: Sakelar ON/OFF, pilih tanggal (`Tanggal 1`, `15`, `25`, `Akhir Bulan`), dan jam kirim.
      - **Input Isi Laporan**: Judul notifikasi, pesan/catatan kustom, dan chip data otomatis (`Pemasukan`, `Pengeluaran`, `Saldo`).
      - **Pratinjau Notifikasi Langsung**: Memperlihatkan hasil akhir notifikasi secara real-time sebelum disimpan.
      - `Simpan Pengaturan` -> Simpan konfigurasi ke tabel `notification_settings` & jadwalkan alarm berulang di Android.

---

### D. Hero, Kostum, Statistik & Pet
15. **Hero — Heroku** (`screens/hero/Hero.html`)
    - **Fungsi**: Profil karakter utama, perlengkapan aktif, dan akses ke Kostum, Statistik, serta Pet.
16. **Hero — Kostum** (`screens/hero-costume/HeroCostume.html`)
    - **Fungsi**: Membeli dan memakai kostum/outfit Hero menggunakan Coin.
17. **Hero — Statistik** (`screens/hero-stats/HeroStats.html`)
    - **Fungsi**: Grafik statistik atribut Hero (Fokus, Konsistensi, Keuangan, Total Quest).
18. **Pilih Pet** (`screens/pet-select/PetSelect.html`)
    - **Fungsi**: Memilih, membuka kunci, dan mengganti peliharaan pendamping di Lobi `Home`.

---

## 3. Skema Basis Data SQLite Lokal (Master Schema)

Gunakan skema tabel berikut di SQLite (`remindo_local.db`):

1. `hero_profile`: `id`, `name`, `level`, `xp`, `xp_next`, `coins`, `streak_days`, `room_level` (1–8), `active_costume_id`, `active_pet_id`, `last_active_date`
2. `quests`: `id`, `title`, `category` (`daily`/`weekly`/`epic`/`timed`), `difficulty` (`easy`/`normal`/`hard`), `xp_reward`, `coin_reward`, `is_timed` (0/1), `duration_minutes`, `alarm_time`, `repeat_rule`, `is_completed` (0/1), `created_at`
3. `quest_history`: `id`, `quest_id`, `title`, `completed_at`, `xp_earned`, `coin_earned`, `focus_minutes`
4. `transactions`: `id`, `type` (`income`/`expense`), `amount`, `category`, `note`, `created_at`
5. `notification_settings`: `id`, `is_enabled` (0/1), `display_mode` (`home`/`lock`/`auto`), `daily_enabled` (0/1), `daily_days` (JSON array `["Sen","Rab","Jum"]`), `daily_time`, `monthly_enabled` (0/1), `monthly_day`, `monthly_time`, `title`, `message`, `include_income` (0/1), `include_expense` (0/1), `include_balance` (0/1)
6. `custom_assets`: `id`, `folder_type` (`karakter`/`kamar`/`pet`/`popup`/`focus_bg`/`focus_music`), `slot_key` (mis. `lv1`..`lv8`), `local_file_path`, `updated_at`
7. `app_settings`: `key`, `value` (untuk `ringtone_path`, `floating_sticker_enabled`, `focus_volume`, `github_repo_url`)

---

## 4. Izin Android & Layanan Latar Belakang (Wajib di `AndroidManifest.xml`)

Untuk mengaktifkan seluruh fitur notifikasi, alarm, dan stiker mengambang:
1. `SCHEDULE_EXACT_ALARM` & `USE_EXACT_ALARM` — Menjamin alarm quest dan laporan keuangan berbunyi tepat waktu meski HP dalam mode Doze.
2. `USE_FULL_SCREEN_INTENT` — Menampilkan `PopupAlarm` di layar kunci saat HP terkunci.
3. `SYSTEM_ALERT_WINDOW` — Menampilkan 3 versi **Stiker Mengambang** (`FloatingPopupTimed`, `FloatingPopupReminder`, `FloatingPopupWallet`) di atas aplikasi lain.
4. `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` — Menjalankan timer quest di latar belakang setelah tombol `Mulai Quest` ditekan dan memutar musik fokus.
5. `POST_NOTIFICATIONS` — Izin notifikasi standar Android 13+.
6. `READ_MEDIA_IMAGES` & `READ_MEDIA_AUDIO` — Memilih gambar pixel kustom dan file MP3/OGG lokal di `Settings`.

---

## 5. Peta Integrasi Alur untuk AI Developer

Jika dokumen ini diberikan ke AI pengembang aplikasi (Flutter / Android Studio / Google AI Studio), instruksikan urutan integrasi berikut:
1. **Inisialisasi SQLite & State Management** (Provider / Riverpod / Bloc) berdasarkan 7 tabel pada Bagian 3.
2. **Routing & Deep Link Notifikasi**: Pastikan setiap tombol pintasan di notifikasi/stiker mengambang (`#timed-quest`, `#quests`, `#add-transaction`, `#wallet`, `#wallet-notification`) membuka rute layar terkait secara langsung.
3. **Background Timer & Audio Service**: Hubungkan tombol `Mulai Quest` pada `FloatingPopupTimed` ke `ForegroundService` timer, tutup overlay stiker, dan tampilkan notifikasi persisten dengan hitungan mundur berjalan.
4. **Custom Asset Loader**: Baca `custom_assets` dari SQLite; jika kosong, gunakan aset bawaan di `images/` (`cozy_focus_bg.jpg`, `hero_alarm_popup.jpg`, `pet_cat_pixel.jpg`, `room_lv1_hero.jpg`, `room_lv2_preview.jpg`, `room_lv8_max.jpg`).
5. **Backup & Restore `.db`**: Implementasikan salin/timpa file `remindo_local.db` melalui `file_picker` dan `share_plus` / penyimpanan lokal.
