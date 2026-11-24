# Remindo — Blueprint Lengkap, Arsitektur & Prompt Bertahap

Dokumen tunggal ini adalah **panduan induk resmi** untuk membangun aplikasi Android **Remindo** dari nol hingga menjadi file `.apk` siap pakai di HP, dengan tampilan yang **persis sama** dengan desain di kanvas dan seluruh fitur yang **100% hidup**.

---

## BAGIAN 1: Gambaran & Bentuk Aplikasi Remindo

### 1.1 Konsep & Gaya Visual
- **Apa itu Remindo?** Aplikasi Android pengingat tugas (*Quest*), timer fokus (*Pomodoro/Countdown*), dan pencatat keuangan pelajar (*Dompetku & Peti Tabungan*) yang dibalut menjadi **game RPG 2D Pixel Art** yang hangat dan nyaman.
- **Gaya Desain**: *Soft 2D Pixel-Art RPG* — sudut kartu membulat, garis tepi tegas (`border-2`), bayangan pixel solid, font judul **Boogaloo**, font isi **Capriola**, dan angka monospace **Spline Sans Mono** (seluruh warna & token ada di `DESIGN.md`).
- **Model Kerja (Offline-First + Semi-Online Gratis)**:
  - **100% Offline untuk Data Pribadi**: Setiap HP pengguna punya database lokal sendiri (`remindo_local.db`). Tidak butuh login, tidak butuh kuota, dan data tidak hilang saat offline.
  - **Semi-Online Gratis via GitHub**: Hanya dipakai untuk mengambil update **katalog skin, kostum, pet, kamar, dan event terbatas** dari repositori GitHub milik developer, lalu otomatis disimpan ke cache lokal HP.

### 1.2 Alur Penggunaan Harian
1. **Pertama kali buka (`Onboarding`)**: User memberi nama Hero dan memilih tampilan awal -> masuk ke **Lobi (`Home`)**.
2. **Aktivitas Harian (`Quests` & `TimedQuest`)**: User membuat Quest Pengingat (langsung centang) atau Quest Ber-Timer (fokus dengan musik latar). Setiap selesai, Hero mendapat **XP** (naik level), **Coin**, dan menjaga **Streak Harian**.
3. **Pengingat Latar Belakang (`PopupAlarm` & 3 `FloatingPopup`)**: Jika jadwal tiba saat HP terkunci, muncul alarm layar penuh; jika HP sedang dipakai, muncul **Stiker Mengambang** di atas aplikasi lain lengkap dengan tombol pintasan.
4. **Keuangan Pelajar (`Wallet` & `SavingsChest`)**: User mencatat pemasukan/pengeluaran, menabung ke target **Peti Tabungan**, dan menerima laporan keuangan harian/bulanan otomatis.
5. **Hadiah & Progres (`RoomUpgrade`, `HeroCostume`, `PetSelect`)**: Koin dari quest dipakai untuk meng-upgrade kamar (Lv.1–Lv.8), membeli kostum Hero, dan membuka Pet pendamping.

---

## BAGIAN 2: Penjelasan Lengkap Fitur & Fungsi Setiap Tombol (24 Layar)

### A. Awal & Lobi Utama
1. **`Onboarding` (`screens/onboarding/Onboarding.html`)**
   - Input nama Hero + pilih Hero awal -> Tombol `Mulai Petualangan` menyimpan profil ke SQLite (`id = 1`) dan membuka `Home`.
2. **`Home` (`screens/home/Home.html`)**
   - **Header Status HUD**: Menampilkan Level Kamar, progress bar XP Hero, dan total Coin secara langsung dari SQLite.
   - **Top Lobby Action Bar**:
     - Kiri (`Atur` / `#lobby-settings-btn`): Kapsul RPG ikon gear -> buka `Settings`.
     - Kanan (`Upgrade Kamar` / `#upgrade-room-btn`): Kapsul aksen emas berisi biaya koin level berikutnya -> buka `RoomUpgrade`.
   - **Bubble `X quest siap!`**: Buka `Quests`.
   - **Navigasi Bawah (5 Slot)**: `Home`, `Quests`, tombol tengah `+` (memunculkan pilihan cepat `Quest Ber-Timer` atau `Quest Pengingat`), `Wallet`, `Hero`.
3. **`RoomUpgrade` (`screens/room-upgrade/RoomUpgrade.html`)**
   - Menampilkan pratinjau kamar saat ini vs level berikutnya (`Lv.1`–`Lv.8`) dan tombol `Upgrade Kamar` (cek kecukupan Coin & Level Hero).

### B. Quest, Mode Fokus & Riwayat
4. **`Quests` (`screens/quests/Quests.html`)**
   - Tab filter `Daily`, `Weekly`, `Epic`, `Timed`.
   - **Quest Pengingat**: Tombol centang langsung menyelesaikan quest, menambah XP + Coin, dan mencatat ke riwayat.
   - **Quest Ber-Timer**: Tombol centang terkunci; tombol `Mulai Timer` / `Mulai Fokus` membuka `TimedQuest`.
   - Tombol `Riwayat & Statistik Quest` membuka `QuestHistory`.
5. **`AddQuest` (`screens/add-quest/AddQuest.html`)**
   - Form Quest Ber-Timer: Judul, Kategori, Tingkat Kesulitan (`Easy`/`Normal`/`Hard`), Durasi Timer (menit), Jam Alarm (opsional), Pengulangan -> `Simpan Quest`.
6. **`AddQuestReminder` (`screens/add-quest-reminder/AddQuestReminder.html`)**
   - Form Quest Pengingat (tanpa timer): Judul, Kategori, Tingkat Kesulitan, Jam Pengingat, Pengulangan -> `Simpan Pengingat`.
7. **`TimedQuest` (`screens/timed-quest/TimedQuest.html`)**
   - Latar pixel senja (`cozy_focus_bg.jpg` atau gambar kustom), countdown timer di tengah, tombol `Mulai` / `Jeda` / `Lanjut`, `Reset`, `Selesaikan Quest` (+20% bonus XP jika selesai sebelum waktu habis), serta kontrol **Musik Fokus** (sakelar ON/OFF, pilih trek / MP3 lokal, slider Volume).
8. **`QuestHistory` (`screens/quest-history/QuestHistory.html`)**
   - Filter `Hari Ini`, `Minggu Ini`, `Bulan Ini` + daftar riwayat quest selesai & total menit fokus.

### C. Alarm & 3 Versi Stiker Mengambang
9. **`PopupAlarm` (`screens/popup-alarm/PopupAlarm.html`)**
   - Muncul layar penuh saat HP terkunci (`USE_FULL_SCREEN_INTENT`).
   - Tombol `Done` (selesai + bonus `+20% XP`) dan `Snooze 10 mnt` (tunda 10 menit).
10. **3 Stiker Mengambang Minimalis (`SYSTEM_ALERT_WINDOW`)**:
    - **`FloatingPopupTimed` (`screens/floating-popup-timed/FloatingPopupTimed.html`)**: Tombol `Mulai Quest` (menutup stiker dan menjalankan timer di latar belakang dengan notifikasi persisten), `Tunda 10m`, dan pintasan `Quest`.
    - **`FloatingPopupReminder` (`screens/floating-popup-reminder/FloatingPopupReminder.html`)**: Tombol `Centang Selesai`, `Tunda 15m`, dan pintasan `Quest`.
    - **`FloatingPopupWallet` (`screens/floating-popup-wallet/FloatingPopupWallet.html`)**: Ringkasan saldo, tombol input cepat rutin (`Makan -20K`, `Saku +50K`), dan pintasan ke `AddTransaction`, `Wallet`, serta `WalletNotification`.

### D. Dompetku, Peti Tabungan & Notifikasi Keuangan
11. **`Wallet` (`screens/wallet/Wallet.html`)**
    - Ringkasan total saldo, pemasukan vs pengeluaran, kartu **Peti Tabungan** (tombol `Tabung` -> buka `SavingsChest`), pintasan `Notifikasi Laporan Keuangan`, tombol `Tambah Transaksi`, dan daftar riwayat transaksi.
12. **`SavingsChest` (`screens/savings-chest/SavingsChest.html`)**
    - Kartu target tabungan dengan progress bar, tombol nominal cepat (`+20rb`, `+50rb`, `+100rb`), input nominal bebas, `Simpan Setoran` (menambah tabungan & otomatis mencatat pengeluaran tabungan di `transactions`), tombol `Target Baru`, dan riwayat setoran.
13. **`AddTransaction` (`screens/add-transaction/AddTransaction.html`)**
    - Form catat `Pemasukan` / `Pengeluaran`, nominal, kategori, catatan, tanggal -> `Simpan Transaksi`.
14. **`WalletNotification` (`screens/wallet-notification/WalletNotification.html`)**
    - Sakelar & pilihan **Mode Tampilan Notifikasi** (`Beranda` / Stiker Mengambang, `Layar Kunci` / Popup Penuh, `Otomatis`).
    - **Laporan Harian**: Pemilih hari satuan (`Sen`–`Min`, tanpa preset) + jam kirim.
    - **Laporan Bulanan**: Pilih tanggal (`1`, `15`, `25`, `Akhir Bulan`) + jam kirim.
    - Input judul & pesan kustom, chip data otomatis (`Pemasukan`, `Pengeluaran`, `Saldo`), **Pratinjau Notifikasi Langsung**, dan tombol `Simpan Pengaturan`.

### E. Hero, Kostum, Pet & Statistik
15. **`Hero` (`screens/hero/Hero.html`)**: Profil Hero, atribut aktif, navigasi ke `HeroCostume`, `HeroStats`, `PetSelect`.
16. **`HeroCostume` (`screens/hero-costume/HeroCostume.html`)**: Beli & pakai kostum dengan Coin (mendukung katalog lokal + GitHub).
17. **`HeroStats` (`screens/hero-stats/HeroStats.html`)**: Statistik total fokus, quest selesai, streak terpanjang, dan keuangan.
18. **`PetSelect` (`screens/pet-select/PetSelect.html`)**: Beli & ganti Pet pendamping di kamar.

### F. Pengaturan, Backup & Aset Kustom
19. **`Settings` (`screens/settings/Settings.html`)** (+ sub-halaman `AlarmSettings` & `BackupSettings`):
    - Sakelar izin **Stiker Mengambang** + 3 tombol pratinjau stiker.
    - Ganti gambar kustom (Kamar, Karakter, Pet, Latar Fokus) & musik fokus / nada dering lokal.
    - **Ekspor & Impor `.db`** untuk backup/pindah HP tanpa server.

---

## BAGIAN 3: Aturan Angka Permainan (Game Rules)

1. **Hadiah 3 Tingkat Kesulitan Quest**:
   - **Easy**: Pengingat (`+15 XP`, `+10 Coin`) | Ber-Timer (`+25 XP`, `+15 Coin`)
   - **Normal**: Pengingat (`+30 XP`, `+20 Coin`) | Ber-Timer (`+50 XP`, `+35 Coin`)
   - **Hard**: Pengingat (`+60 XP`, `+40 Coin`) | Ber-Timer (`+100 XP`, `+70 Coin`)
2. **Bonus Pengali XP**:
   - Streak `>= 3 hari`: `+20% XP`
   - Selesai sebelum timer habis / tekan `Done` tanpa snooze: `+20% XP`
   - Event aktif dari GitHub: dikali `xp_multiplier` (misal `2.0x`)
3. **Kurva Level Hero**: Lv.1 butuh `100 XP`. Setiap naik level, target XP naik `25%` (`xp_next = (xp_next * 1.25).round()`).
4. **Biaya Upgrade Kamar (`Lv.1` – `Lv.8`)**:
   - Lv.2: `200 Coin` (Hero Lv.2) | Lv.3: `400 Coin` (Lv.3) | Lv.4: `700 Coin` (Lv.4) | Lv.5: `1.100 Coin` (Lv.5) | Lv.6: `1.600 Coin` (Lv.6) | Lv.7: `2.200 Coin` (Lv.7) | Lv.8: `3.000 Coin` (Lv.8).

---

## BAGIAN 4: Rekomendasi Tech Stack & Arsitektur Backend

### 4.1 Saran Stack Terbaik (Kenapa Tidak Pakai Server JS/Node.js?)
- **Jangan pakai backend server JS (Node.js/Express)** karena aplikasi ini dirancang **offline di HP masing-masing user** tanpa biaya sewa server/hosting bulanan.
- **Stack Terbaik & Gratis Selamanya**:
  1. **Frontend & Logika Aplikasi**: **Flutter (Dart)** — tampilan pixel art rapi di semua ukuran HP Android dan bisa langsung dikompilasi ke `.apk`.
  2. **Database Lokal (Backend Offline)**: **SQLite (`sqflite`)** — menyimpan 8 tabel (`hero_profile`, `quests`, `quest_history`, `transactions`, `savings_goals`, `notification_settings`, `custom_assets`, `app_settings`) di file `remindo_local.db` per HP pengguna. Semua operasi multi-tabel wajib memakai `db.transaction(...)`.
  3. **Layanan Latar Belakang Android**: **Kotlin Native Bridge + Paket Flutter** (`flutter_local_notifications`, `android_alarm_manager_plus`, `flutter_overlay_window`, `audioplayers`, `permission_handler`, `file_picker`, `share_plus`).
  4. **Katalog Skin & Event Semi-Online (Gratis)**: **GitHub Public Repo (`remindo-assets`) + `catalog.json` via jsDelivr CDN** + paket `http`. Gambar yang sudah diunduh disimpan ke folder cache lokal HP sehingga tetap jalan saat offline.

### 4.2 Struktur Folder Proyek Flutter
```text
remindo_app/
├── design_reference/          # Salinan hasil Export ZIP dari Stitch (HTML, DESIGN.md, images)
├── assets/images/             # Aset pixel bawaan APK
├── android/app/src/main/      # AndroidManifest.xml (izin Alarm, Overlay, ForegroundService)
├── lib/
│   ├── core/
│   │   ├── theme/app_theme.dart
│   │   ├── db/                # database_helper.dart + DAO (hero, quest, wallet, settings)
│   │   ├── services/          # alarm, focus_timer, overlay, backup, github_catalog
│   │   └── router/app_router.dart
│   ├── features/              # Layar & controller per modul (home, quests, wallet, hero, settings)
│   └── main.dart
└── .github/workflows/build-apk.yml  # Build APK otomatis gratis di GitHub Actions
```

