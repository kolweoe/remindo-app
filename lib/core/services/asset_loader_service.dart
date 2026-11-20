import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/settings_dao.dart';

class AssetCatalogItem {
  final String id;
  final String name;
  final int priceCoins;
  final String imageUrl;

  AssetCatalogItem({
    required this.id,
    required this.name,
    required this.priceCoins,
    required this.imageUrl,
  });

  factory AssetCatalogItem.fromJson(Map<String, dynamic> json) {
    return AssetCatalogItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceCoins: json['price_coins'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}

class CatalogEvent {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final String startDate;
  final String endDate;
  final double xpMultiplier;
  final String rewardSkinId;

  CatalogEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    this.xpMultiplier = 1.0,
    required this.rewardSkinId,
  });

  factory CatalogEvent.fromJson(Map<String, dynamic> json) {
    return CatalogEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerUrl: json['banner_url'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      xpMultiplier: (json['xp_multiplier'] as num?)?.toDouble() ?? 1.0,
      rewardSkinId: json['reward_skin_id'] as String? ?? '',
    );
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null) return false;
    return now.isAfter(start) && now.isBefore(end.add(const Duration(days: 1)));
  }
}

class AssetLoaderService {
  static final AssetLoaderService instance = AssetLoaderService._internal();
  AssetLoaderService._internal();

  final SettingsDao _settingsDao = SettingsDao();

  static const String _defaultCatalogUrl =
      'https://raw.githubusercontent.com/kolweoe/remindo-assets/main/catalog.json';

  /// Syncs catalog from remote GitHub repository if connected to internet
  Future<bool> syncCatalogWithRemote({String? customUrl}) async {
    try {
      final url = customUrl ??
          await _settingsDao.getSetting('remote_catalog_url', defaultValue: _defaultCatalogUrl);

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final int newVersion = data['version'] as int? ?? 1;
      final int currentVersion = int.tryParse(
            await _settingsDao.getSetting('remote_catalog_version', defaultValue: '0'),
          ) ?? 0;

      // Save catalog json locally for offline access
      await _settingsDao.setSetting('cached_catalog_json', response.body);

      if (newVersion > currentVersion) {
        await _downloadAndCacheAssets(data);
        await _settingsDao.setSetting('remote_catalog_version', newVersion.toString());
      }

      return true;
    } catch (_) {
      // Offline fallback: graceful return, no crashes
      return false;
    }
  }

  Future<void> _downloadAndCacheAssets(Map<String, dynamic> data) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final assetsDir = Directory(p.join(docsDir.path, 'cached_assets'));
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    // Process costumes
    final costumes = data['costumes'] as List<dynamic>? ?? [];
    for (final item in costumes) {
      if (item is Map<String, dynamic>) {
        await _cacheSingleAsset('karakter', item['id'], item['image_url'], assetsDir);
      }
    }

    // Process pets
    final pets = data['pets'] as List<dynamic>? ?? [];
    for (final item in pets) {
      if (item is Map<String, dynamic>) {
        await _cacheSingleAsset('pet', item['id'], item['image_url'], assetsDir);
      }
    }

    // Process rooms
    final rooms = data['rooms'] as List<dynamic>? ?? [];
    for (final item in rooms) {
      if (item is Map<String, dynamic>) {
        await _cacheSingleAsset('kamar', item['id'], item['image_url'], assetsDir);
      }
    }
  }

  Future<void> _cacheSingleAsset(
    String folderType,
    String? slotKey,
    String? imageUrl,
    Directory targetDir,
  ) async {
    if (slotKey == null || imageUrl == null || imageUrl.isEmpty) return;

    try {
      final ext = p.extension(imageUrl).split('?').first;
      final localFileName = '${folderType}_$slotKey${ext.isEmpty ? ".png" : ext}';
      final localFilePath = p.join(targetDir.path, localFileName);
      final localFile = File(localFilePath);

      final resp = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        await localFile.writeAsBytes(resp.bodyBytes);
        await _settingsDao.upsertCustomAsset(folderType, slotKey, localFilePath);
      }
    } catch (_) {}
  }

  /// Resolve path to asset: checks custom cached SQLite entry first, then fallback
  Future<String?> resolveAssetPath(String folderType, String slotKey) async {
    final cached = await _settingsDao.getCustomAsset(folderType, slotKey);
    if (cached != null && await File(cached).exists()) {
      return cached;
    }
    return null;
  }

  /// Get active events from cached catalog
  Future<List<CatalogEvent>> getActiveEvents() async {
    final cachedJson = await _settingsDao.getSetting('cached_catalog_json');
    if (cachedJson.isEmpty) return [];

    try {
      final data = jsonDecode(cachedJson) as Map<String, dynamic>;
      final events = data['events'] as List<dynamic>? ?? [];
      final List<CatalogEvent> activeList = [];

      for (final ev in events) {
        if (ev is Map<String, dynamic>) {
          final event = CatalogEvent.fromJson(ev);
          if (event.isCurrentlyActive) {
            activeList.add(event);
          }
        }
      }
      return activeList;
    } catch (_) {
      return [];
    }
  }
}
