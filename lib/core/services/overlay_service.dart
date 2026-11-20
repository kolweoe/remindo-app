import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../db/settings_dao.dart';

enum OverlayType { timedQuest, reminderQuest, walletReport }

class OverlayService {
  static final OverlayService instance = OverlayService._internal();
  OverlayService._internal();

  /// Check if overlay permission is granted
  Future<bool> isPermissionGranted() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// Request overlay permission
  Future<bool?> requestPermission() async {
    return await FlutterOverlayWindow.requestPermission();
  }

  /// Check if floating sticker is enabled in settings and permission granted
  Future<bool> canShowOverlay() async {
    final settingsDao = SettingsDao();
    final enabled = (await settingsDao.getSetting('floating_sticker_enabled', defaultValue: 'true')) == 'true';
    if (!enabled) return false;
    final granted = await isPermissionGranted();
    return granted;
  }

  /// Shows the floating sticker overlay with specific payload
  Future<void> showFloatingSticker({
    required OverlayType type,
    required Map<String, dynamic> data,
  }) async {
    final allowed = await canShowOverlay();
    if (!allowed) return;

    final isActive = await FlutterOverlayWindow.isActive();
    if (isActive) {
      await FlutterOverlayWindow.closeOverlay();
    }

    final payload = {
      'type': type.name,
      'data': data,
    };

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Remindo Stiker Mengambang",
      overlayContent: "Ketuk untuk membuka aksi cepat",
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: 380,
      width: 320,
    );

    // Share data with the overlay isolate
    await FlutterOverlayWindow.shareData(jsonEncode(payload));
  }

  /// Close the overlay window
  Future<void> closeOverlay() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }
}

/// Entry point for the Flutter Overlay Window isolate
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FloatingStickerWidget(),
  ));
}

class FloatingStickerWidget extends StatefulWidget {
  const FloatingStickerWidget({super.key});

  @override
  State<FloatingStickerWidget> createState() => _FloatingStickerWidgetState();
}

class _FloatingStickerWidgetState extends State<FloatingStickerWidget> {
  String _type = 'timedQuest';
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null) {
        try {
          final decoded = jsonDecode(event.toString()) as Map<String, dynamic>;
          setState(() {
            _type = decoded['type'] ?? 'timedQuest';
            _data = decoded['data'] ?? {};
          });
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFFBBF24),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getHeaderTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => FlutterOverlayWindow.closeOverlay(),
                    child: const Icon(Icons.close, color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content based on type
              _buildContent(),

              const SizedBox(height: 14),

              // Action Buttons
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    if (_type == 'reminderQuest') return 'Pengingat Quest';
    if (_type == 'walletReport') return 'Laporan Dompetku';
    return 'Quest Bertimer';
  }

  Widget _buildContent() {
    if (_type == 'walletReport') {
      final balance = _data['balance'] ?? 0;
      final income = _data['income'] ?? 0;
      final expense = _data['expense'] ?? 0;
      return Column(
        children: [
          Text(
            'Saldo: Rp $balance',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '+Rp $income  |  -Rp $expense',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      );
    }

    final title = _data['title'] ?? 'Belajar Mode Fokus';
    final duration = _data['duration_minutes'] ?? 25;
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _type == 'reminderQuest' ? 'Waktunya menyelesaikan misimu!' : 'Durasi: $duration Menit',
          style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (_type == 'walletReport') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                FlutterOverlayWindow.shareData(jsonEncode({'action': 'navigate', 'route': '#wallet'}));
                FlutterOverlayWindow.closeOverlay();
              },
              child: const Text('Buka Dompet', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                FlutterOverlayWindow.shareData(jsonEncode({'action': 'navigate', 'route': '#add-transaction'}));
                FlutterOverlayWindow.closeOverlay();
              },
              child: const Text('Catat Uang', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          if (_type == 'timedQuest') {
            FlutterOverlayWindow.shareData(jsonEncode({
              'action': 'start_timer',
              'quest_id': _data['quest_id'] ?? 1,
              'duration': _data['duration_minutes'] ?? 25,
              'title': _data['title'] ?? 'Fokus',
            }));
          } else {
            FlutterOverlayWindow.shareData(jsonEncode({'action': 'navigate', 'route': '#quests'}));
          }
          FlutterOverlayWindow.closeOverlay();
        },
        child: Text(
          _type == 'timedQuest' ? 'Mulai Quest Sekarang ⏱' : 'Buka Papan Quest 📜',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
