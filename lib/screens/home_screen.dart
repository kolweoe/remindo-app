import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8B5CF6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Remindo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => Navigator.pushNamed(context, '#settings'),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: heroAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (hero) {
            final xpProgress = hero.xpNext > 0 ? (hero.xp / hero.xpNext).clamp(0.0, 1.0) : 0.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.px(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TOP STATUS BAR: Level, Streak, Coins ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Level Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Lv.${hero.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hero.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'XP: ${hero.xp} / ${hero.xpNext}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Coins & Streak
                            Row(
                              children: [
                                // Streak
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_fire_department, color: Color(0xFFEF4444), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hero.streakDays} Hari',
                                        style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Coins
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.monetization_on, color: Color(0xFFF59E0B), size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hero.coins}',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // XP Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: xpProgress,
                            backgroundColor: const Color(0xFF0F172A),
                            color: const Color(0xFF8B5CF6),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- HERO ROOM VIEW (Kamar Hero) ---
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4), width: 2),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2E1065), Color(0xFF0F172A)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Room Level Badge & Upgrade Button
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Kamar Hero Lv.${hero.roomLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 14,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '#room-upgrade'),
                            icon: const Icon(Icons.arrow_upward, size: 14),
                            label: const Text('Upgrade', style: TextStyle(fontSize: 12)),
                          ),
                        ),

                        // Center Character & Pet Representation
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFA78BFA), width: 2),
                                ),
                                child: const Icon(Icons.person, size: 48, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kostum: ${hero.activeCostumeId}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                'Pet: ${hero.activePetId}',
                                style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        // Kostum button bottom-left
                        Positioned(
                          bottom: 12,
                          left: 14,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black38,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '#customize'),
                            icon: const Icon(Icons.checkroom, size: 16),
                            label: const Text('Ganti Kostum', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- QUICK ACTION SHORTCUTS ---
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.checklist_rtl_rounded,
                          color: const Color(0xFF8B5CF6),
                          title: 'Papan Quest',
                          subtitle: 'Misi & XP',
                          onTap: () => Navigator.pushNamed(context, '#quests'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.timer_outlined,
                          color: const Color(0xFF3B82F6),
                          title: 'Mode Fokus',
                          subtitle: 'Timer Belajar',
                          onTap: () => Navigator.pushNamed(context, '#timed-quest'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF10B981),
                          title: 'Dompetku',
                          subtitle: 'Uang Saku',
                          onTap: () => Navigator.pushNamed(context, '#wallet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.savings_rounded,
                          color: const Color(0xFFF59E0B),
                          title: 'Peti Tabungan',
                          subtitle: 'Target Hemat',
                          onTap: () => Navigator.pushNamed(context, '#savings'),
                        ),
                      ),
                    ],
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

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
