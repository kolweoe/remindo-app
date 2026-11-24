import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../widgets/pixel_room_view.dart';
import '../widgets/pixel_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);
    final questsAsync = ref.watch(questsProvider);

    return PixelScaffold(
      currentTabIndex: 0,
      body: heroAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: PixelColors.badgePurple),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
        ),
        data: (hero) {
          final readyQuestsCount = questsAsync.maybeWhen(
            data: (quests) => quests.where((q) => !q.isCompleted).length,
            orElse: () => 3,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.px(context, 14),
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================================================
                // 1. TOP LOBBY ACTION BAR (Pengaturan & Upgrade Kamar)
                // ========================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Buka Pengaturan ("Atur")
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRouter.settings),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: PixelDecorations.button(
                          color: PixelColors.cardParchment,
                          radius: 24,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: PixelColors.badgePurple,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.settings,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Atur',
                              style: TextStyle(
                                color: PixelColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right: Upgrade Kamar Button (Gold with 200 Coin Badge)
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRouter.roomUpgrade),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        decoration: PixelDecorations.button(
                          color: PixelColors.coinGold,
                          radius: 24,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Upgrade Kamar',
                              style: TextStyle(
                                color: PixelColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: PixelColors.deepPurple,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🪙', style: TextStyle(fontSize: 10)),
                                  SizedBox(width: 3),
                                  Text(
                                    '200',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ========================================================
                // 2. MAIN ROOM STAGE (Pixel Room Hero View)
                // ========================================================
                PixelRoomView(
                  hero: hero,
                  onUpgradeTap: () => Navigator.pushNamed(context, AppRouter.roomUpgrade),
                  onCustomizeTap: () => Navigator.pushNamed(context, AppRouter.customize),
                ),

                const SizedBox(height: 12),

                // ========================================================
                // 3. BOTTOM OVERLAY: QUEST READY NOTIFICATION BUBBLE
                // ========================================================
                InkWell(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRouter.quests),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: PixelDecorations.card(
                      color: PixelColors.cardParchment,
                      radius: 18,
                    ),
                    child: Row(
                      children: [
                        // Exclamation Badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: PixelColors.badgePurple,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Message Text
                        Expanded(
                          child: Text(
                            '$readyQuestsCount quest siap dijalankan!',
                            style: const TextStyle(
                              color: PixelColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        // Chevron Action
                        const Row(
                          children: [
                            Text(
                              'Buka',
                              style: TextStyle(
                                color: PixelColors.badgePurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PixelColors.coinGold),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ========================================================
                // 4. STREAK BANNER
                // ========================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: PixelColors.badgePurple,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PixelColors.deepPurple, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x334A2E70),
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak: ${hero.streakDays} Hari Berturut-turut!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              'Selesaikan misi hari ini untuk bonus +20% XP & Koin!',
                              style: TextStyle(
                                color: Color(0xFFE9D5FF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================================
                // 5. QUICK MENU CARDS
                // ========================================================
                const Text(
                  'Fitur Utama Remindo',
                  style: TextStyle(
                    color: PixelColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _PixelMenuCard(
                        icon: Icons.checklist_rounded,
                        color: PixelColors.badgePurple,
                        title: 'Papan Quest',
                        subtitle: 'Misi & Pengingat',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRouter.quests),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PixelMenuCard(
                        icon: Icons.timer_outlined,
                        color: PixelColors.blueFocus,
                        title: 'Mode Fokus',
                        subtitle: 'Timer Belajar Mahasiswa',
                        onTap: () => Navigator.pushNamed(context, AppRouter.timedQuest),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PixelMenuCard(
                        icon: Icons.account_balance_wallet_rounded,
                        color: PixelColors.greenSuccess,
                        title: 'Dompetku',
                        subtitle: 'Catatan Keuangan Saku',
                        onTap: () => Navigator.pushReplacementNamed(context, AppRouter.wallet),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PixelMenuCard(
                        icon: Icons.savings_rounded,
                        color: PixelColors.coinGold,
                        title: 'Peti Tabungan',
                        subtitle: 'Target Menabung',
                        onTap: () => Navigator.pushNamed(context, AppRouter.savings),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PixelMenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PixelMenuCard({
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: PixelDecorations.card(
          color: PixelColors.cardParchment,
          radius: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: PixelColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: PixelColors.textMuted,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
