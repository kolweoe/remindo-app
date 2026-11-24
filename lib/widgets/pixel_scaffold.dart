import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';

/// Standard Shell Widget implementing the Penpot Top Status HUD (57px) and Bottom Nav (64px).
class PixelScaffold extends ConsumerWidget {
  final Widget body;
  final int currentTabIndex; // 0: Kamar, 1: Misi, 2: Center (+), 3: Dompet, 4: Hero, -1: Non-tab screen
  final String? title;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const PixelScaffold({
    super.key,
    required this.body,
    this.currentTabIndex = 0,
    this.title,
    this.showBackButton = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);

    return Scaffold(
      backgroundColor: PixelColors.bgLavender,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // TOP STATUS HUD (57px parity with Penpot)
            // ==========================================
            _buildTopStatusHud(context, heroAsync),

            // ==========================================
            // MAIN CONTENT (Responsive to all screens)
            // ==========================================
            Expanded(
              child: ResponsiveWrapper(
                backgroundColor: PixelColors.bgLavender,
                child: body,
              ),
            ),

            // ==========================================
            // BOTTOM NAVIGATION BAR (64px parity with Penpot)
            // ==========================================
            if (currentTabIndex >= 0)
              _buildBottomNavigationBar(context),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTopStatusHud(BuildContext context, AsyncValue heroAsync) {
    return Container(
      height: 57,
      decoration: const BoxDecoration(
        color: PixelColors.deepPurple,
        border: Border(
          bottom: BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: heroAsync.when(
        loading: () => const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: PixelColors.coinGold, strokeWidth: 2),
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (hero) {
          final xpProgress = hero.xpNext > 0 ? (hero.xp / hero.xpNext).clamp(0.0, 1.0) : 0.0;

          return Row(
            children: [
              // --- LEFT: Room Level Badge or Back Button ---
              if (showBackButton)
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 41,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: PixelColors.badgePurple,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: PixelColors.deepPurple, width: 2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  height: 41,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: PixelColors.badgePurple,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PixelColors.deepPurple, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Lv.${hero.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // --- MIDDLE: XP Progress Bar ---
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1B4E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'XP',
                            style: TextStyle(
                              color: Color(0xFFD8B4FE),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            '${hero.xp}/${hero.xpNext}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(PixelColors.badgePurple),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // --- RIGHT: Coin Counter Badge ---
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: PixelColors.badgePurple,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: PixelColors.deepPurple, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '${hero.coins}',
                      style: const TextStyle(
                        color: PixelColors.coinGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: PixelColors.deepPurple,
        border: Border(
          top: BorderSide(color: PixelColors.deepPurple, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Kamar (Home)
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.meeting_room_rounded,
            label: 'Kamar',
            route: AppRouter.home,
          ),

          // 2. Misi (Quests)
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.checklist_rounded,
            label: 'Misi',
            route: AppRouter.quests,
          ),

          // 3. Center (+) Quick Add Button
          _buildCenterAddButton(context),

          // 4. Dompet (Wallet)
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Dompet',
            route: AppRouter.wallet,
          ),

          // 5. Hero (Profile / Kostum)
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.shield_rounded,
            label: 'Hero',
            route: AppRouter.customize,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentTabIndex == index;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isActive ? PixelColors.badgePurple : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: PixelColors.activeBorder, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFFD8B4FE),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFFD8B4FE),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return InkWell(
      onTap: () => _showQuickActionModal(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: PixelColors.coinGold,
          shape: BoxShape.circle,
          border: Border.all(color: PixelColors.deepPurple, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: PixelColors.deepPurple,
          size: 28,
        ),
      ),
    );
  }

  void _showQuickActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PixelColors.cardParchment,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: PixelColors.deepPurple, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚡ Menu Cepat',
                    style: TextStyle(
                      color: PixelColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: PixelColors.deepPurple),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action 1: Tambah Quest Baru
              _buildModalAction(
                ctx,
                icon: Icons.checklist_rounded,
                title: 'Tambah Quest Baru',
                subtitle: 'Buat misi harian atau belajar baru',
                color: PixelColors.badgePurple,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRouter.quests);
                },
              ),
              const SizedBox(height: 10),

              // Action 2: Catat Transaksi Baru
              _buildModalAction(
                ctx,
                icon: Icons.receipt_long_rounded,
                title: 'Catat Transaksi Dompet',
                subtitle: 'Tambah uang masuk atau pengeluaran',
                color: PixelColors.coinGold,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRouter.addTransaction);
                },
              ),
              const SizedBox(height: 10),

              // Action 3: Mode Fokus Bertimer
              _buildModalAction(
                ctx,
                icon: Icons.timer_outlined,
                title: 'Mulai Mode Fokus Bertimer',
                subtitle: 'Belajar dengan countdown & floating sticker',
                color: PixelColors.blueFocus,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRouter.timedQuest);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalAction(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PixelColors.deepPurple, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: PixelColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: PixelColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PixelColors.deepPurple),
          ],
        ),
      ),
    );
  }
}
