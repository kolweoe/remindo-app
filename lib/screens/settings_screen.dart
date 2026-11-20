import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/db/settings_dao.dart';
import '../core/services/backup_service.dart';
import '../core/services/overlay_service.dart';
import '../core/services/asset_loader_service.dart';
import '../core/utils/responsive.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SettingsDao _settingsDao = SettingsDao();
  bool _floatingStickerEnabled = true;
  bool _focusMusicEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final stickerVal = await _settingsDao.getSetting('floating_sticker_enabled', defaultValue: 'true');
    final musicVal = await _settingsDao.getSetting('focus_music_enabled', defaultValue: 'true');
    setState(() {
      _floatingStickerEnabled = stickerVal == 'true';
      _focusMusicEnabled = musicVal == 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Pengaturan Utama',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.px(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- FITUR & LAYANAN LATAR BELAKANG ---
              const Text('Layanan & Tampilan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Stiker Mengambang (Floating Sticker)', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Menampilkan stiker tugas saat menggunakan HP', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _floatingStickerEnabled,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (val) async {
                        setState(() => _floatingStickerEnabled = val);
                        await _settingsDao.setSetting('floating_sticker_enabled', val.toString());
                        if (val) {
                          await OverlayService.instance.requestPermission();
                        }
                      },
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    SwitchListTile(
                      title: const Text('Musik Latar Mode Fokus', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Putar ambient sound Lo-Fi selama sesi timer', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      value: _focusMusicEnabled,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (val) async {
                        setState(() => _focusMusicEnabled = val);
                        await _settingsDao.setSetting('focus_music_enabled', val.toString());
                      },
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF8B5CF6)),
                      title: const Text('Jadwal & Notifikasi Dompet', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Atur jam alarm ringkasan uang jajan harian/bulanan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                      onTap: () => Navigator.pushNamed(context, '#wallet-notification'),
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    ListTile(
                      leading: const Icon(Icons.security, color: Color(0xFF10B981)),
                      title: const Text('Kelola Izin Android', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Alarm tepat waktu, Tampil di atas aplikasi lain', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 14),
                      onTap: () => openAppSettings(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- DATA & CADANGAN OFFLINE ---
              const Text('Cadangan & Pemulihan (SQLite)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_upload_outlined, color: Color(0xFF3B82F6)),
                      title: const Text('Ekspor Database Lokal (.db)', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Cadangkan remindo_local.db ke penyimpanan atau bagikan', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      onTap: () async {
                        final ok = await BackupService.instance.exportDatabase();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Ekspor database berhasil!' : 'Gagal mengekspor database.')),
                          );
                        }
                      },
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined, color: Color(0xFFF59E0B)),
                      title: const Text('Pulihkan Database (.db)', style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text('Pilih file backup SQLite untuk mengganti data lokal', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      onTap: () async {
                        final ok = await BackupService.instance.importDatabase();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Database berhasil dipulihkan!' : 'Gagal memulihkan database.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- SINKRONISASI KATALOG GITHUB ---
              const Text('Aset Pixel & Skin Remote (GitHub)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: Color(0xFFA78BFA)),
                  title: const Text('Cek Katalog Skin Terbaru', style: TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: const Text('Ambil catalog.json dari GitHub publik tanpa update APK', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, color: Colors.white54, size: 18),
                  onTap: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final ok = await AssetLoaderService.instance.syncCatalogWithRemote();
                          setState(() => _isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Katalog berhasil disinkronkan!'
                                    : 'Mode Offline: Memakai cache aset lokal.'),
                              ),
                            );
                          }
                        },
                ),
              ),

              const SizedBox(height: 24),

              // --- INFO APLIKASI ---
              Center(
                child: Column(
                  children: [
                    Text('Remindo v1.0.0 (Build 1)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('100% Offline-First SQLite • Gamified Habit & Finance', style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
