import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/db/hero_dao.dart';
import '../core/utils/responsive.dart';

class RoomUpgradeScreen extends ConsumerWidget {
  const RoomUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Upgrade Kamar Hero',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ResponsiveWrapper(
        child: heroAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (hero) {
            final currentLevel = hero.roomLevel;
            final isMaxLevel = currentLevel >= 8;
            final nextLevel = currentLevel + 1;
            final cost = HeroDao.roomUpgradeCosts[nextLevel] ?? 200;
            final canAfford = hero.coins >= cost;

            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.px(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Coins Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Koin Tersedia:', style: TextStyle(color: Colors.white70)),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Color(0xFFFBBF24), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${hero.coins}',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Visual Room Level Preview
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF8B5CF6)),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1065), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_rounded, size: 64, color: const Color(0xFFA78BFA)),
                          const SizedBox(height: 10),
                          Text(
                            'Tingkat Kamar Saat Ini: Lv.$currentLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isMaxLevel)
                            Text(
                              'Upgrade ke Lv.$nextLevel untuk membuka dekorasi baru',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Room Levels Grid / Progression
                  const Text(
                    'Daftar Tingkat Kamar',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: List.generate(8, (i) {
                      final lvl = i + 1;
                      final isUnlocked = lvl <= currentLevel;
                      final isNext = lvl == nextLevel;
                      final upgradeCost = HeroDao.roomUpgradeCosts[lvl] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? const Color(0xFF8B5CF6).withOpacity(0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isNext
                                ? const Color(0xFFFBBF24)
                                : (isUnlocked ? const Color(0xFF8B5CF6) : const Color(0xFF334155)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isUnlocked ? Icons.check_circle : (isNext ? Icons.lock_open : Icons.lock),
                                  color: isUnlocked
                                      ? const Color(0xFF10B981)
                                      : (isNext ? const Color(0xFFFBBF24) : Colors.white38),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Kamar Hero Lv.$lvl',
                                  style: TextStyle(
                                    color: isUnlocked || isNext ? Colors.white : Colors.white54,
                                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (isUnlocked)
                              const Text('Terbuka', style: TextStyle(color: Color(0xFF10B981), fontSize: 11))
                            else
                              Text(
                                '$upgradeCost Koin',
                                style: TextStyle(
                                  color: isNext ? const Color(0xFFFBBF24) : Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Upgrade Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMaxLevel
                          ? Colors.grey
                          : (canAfford ? const Color(0xFF8B5CF6) : Colors.grey.shade700),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isMaxLevel || !canAfford
                        ? null
                        : () async {
                            final success = await ref.read(heroProfileProvider.notifier).upgradeRoom();
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Kamar berhasil di-upgrade ke Lv.$nextLevel! 🎉')),
                              );
                            }
                          },
                    child: Text(
                      isMaxLevel
                          ? 'Tingkat Maksimum Tercapai'
                          : (canAfford ? 'Upgrade Sekarang ($cost Koin)' : 'Koin Belum Cukup ($cost Koin)'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
