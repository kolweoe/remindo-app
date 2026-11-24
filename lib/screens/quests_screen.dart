import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../models/hero_profile.dart';
import '../models/quest.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  String _selectedTab = 'Daily'; // 'Daily', 'Weekly', 'Epic', 'Timed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyTabFilter(_selectedTab);
    });
  }

  void _applyTabFilter(String tab) {
    setState(() {
      _selectedTab = tab;
    });

    if (tab == 'Timed') {
      ref.read(questsProvider.notifier).loadQuests(isTimed: true);
    } else {
      ref.read(questsProvider.notifier).loadQuests(category: tab.toLowerCase());
    }
  }

  Future<void> _handleCompleteReminderQuest(Quest quest) async {
    if (quest.id == null || quest.isCompleted) return;

    await ref.read(questsProvider.notifier).completeQuest(
      quest.id!,
      focusMinutes: 0,
      hasTimerBonus: false,
    );

    // Refresh hero profile so HUD updates XP and Coins live
    await ref.read(heroProfileProvider.notifier).loadProfile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceNav,
          content: Text(
            'Quest selesai! +${quest.xpReward} XP & +${quest.coinReward} Coin diraih! 🎉',
            style: GoogleFonts.capriola(color: Colors.white, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroAsync = ref.watch(heroProfileProvider);
    final questsAsync = ref.watch(questsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // --- 1. TOP STATUS HUD ---
                heroAsync.maybeWhen(
                  data: (hero) => _buildTopStatusHud(hero),
                  orElse: () => const SizedBox(height: 50),
                ),

                // --- 2. MAIN SCROLLABLE QUEST BOARD ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ribbon Header
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.outline, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.outline,
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              'Buku Quest',
                              style: GoogleFonts.boogaloo(
                                fontSize: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Category Tabs: Daily | Weekly | Epic | Timed
                        Row(
                          children: [
                            _buildTabButton('Daily'),
                            const SizedBox(width: 6),
                            _buildTabButton('Weekly'),
                            const SizedBox(width: 6),
                            _buildTabButton('Epic'),
                            const SizedBox(width: 6),
                            _buildTabButton('Timed'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quest List Cards
                        questsAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                          error: (err, _) => Center(
                            child: Text('Gagal memuat quest: $err'),
                          ),
                          data: (quests) {
                            if (quests.isEmpty) {
                              return _buildEmptyQuestsView();
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: quests.length,
                              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                              itemBuilder: (ctx, index) {
                                final quest = quests[index];
                                return _buildQuestCard(quest);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Link ke Riwayat & Statistik
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.hashQuestHistory);
                          },
                          icon: const Icon(Icons.analytics, color: AppColors.primary, size: 20),
                          label: Text(
                            'Buka Riwayat & Statistik Quest',
                            style: GoogleFonts.capriola(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerLow,
                            side: const BorderSide(color: AppColors.outline, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // --- 3. BOTTOM NAVIGATION BAR (5 SLOTS) ---
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusHud(HeroProfile hero) {
    final xpRatio = (hero.xpNext > 0) ? (hero.xp / hero.xpNext).clamp(0.0, 1.0) : 0.0;

    return Container(
      color: AppColors.surfaceNav,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hero',
                  style: GoogleFonts.capriola(fontSize: 10, color: Colors.white, height: 1.0),
                ),
                Text(
                  'Lv.${hero.level}',
                  style: GoogleFonts.boogaloo(fontSize: 20, color: Colors.white, height: 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('XP Hero', style: GoogleFonts.capriola(fontSize: 11, color: Colors.white)),
                    Text(
                      '${hero.xp} / ${hero.xpNext}',
                      style: GoogleFonts.splineSansMono(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.accent, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${hero.coins}',
                  style: GoogleFonts.splineSansMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => _applyTabFilter(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline, width: 2),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.outline,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            tab,
            textAlign: TextAlign.center,
            style: GoogleFonts.capriola(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    final isCompleted = quest.isCompleted;
    final isTimed = quest.isTimed;

    Color diffColor;
    switch (quest.difficulty.toLowerCase()) {
      case 'easy':
        diffColor = AppColors.success;
        break;
      case 'hard':
        diffColor = AppColors.error;
        break;
      case 'normal':
      default:
        diffColor = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.accentContainer : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334E2F1B),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.surfaceContainerLow : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.standard),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Icon(
              isTimed ? Icons.timer : Icons.edit_note,
              color: isCompleted ? AppColors.success : AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Quest Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Difficulty Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        style: GoogleFonts.capriola(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: diffColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline, width: 1),
                      ),
                      child: Text(
                        quest.difficulty.toUpperCase(),
                        style: GoogleFonts.capriola(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Rewards & Mode Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.primary, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '+${quest.xpReward} XP',
                          style: GoogleFonts.splineSansMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.monetization_on, color: AppColors.accent, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '+${quest.coinReward}',
                          style: GoogleFonts.splineSansMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (isTimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline, width: 1),
                        ),
                        child: Text(
                          'Timer ${quest.durationMinutes}m',
                          style: GoogleFonts.capriola(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Area: Timed vs Reminder vs Completed
                if (isCompleted)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Selesai',
                              style: GoogleFonts.capriola(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (isTimed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, color: AppColors.outline, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Selesaikan timer',
                              style: GoogleFonts.capriola(fontSize: 10, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.timedQuest,
                            arguments: quest,
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                        label: Text(
                          'Mulai Timer',
                          style: GoogleFonts.capriola(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.outline, width: 2),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleCompleteReminderQuest(quest),
                        icon: const Icon(Icons.check_box_outline_blank, color: AppColors.primary, size: 18),
                        label: Text(
                          'Centang Selesai',
                          style: GoogleFonts.capriola(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainer,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: AppColors.outline, width: 2),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_esports, size: 48, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            'Belum ada quest di tab $_selectedTab!',
            textAlign: TextAlign.center,
            style: GoogleFonts.boogaloo(fontSize: 20, color: AppColors.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Tambah quest baru untuk mulai meraih XP dan Coin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.capriola(fontSize: 12, color: AppColors.onSurface),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.hashAddQuest);
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(
              'Tambah Quest',
              style: GoogleFonts.capriola(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.outline, width: 2),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: AppColors.surfaceNav,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, AppRouter.home),
          ),
          _buildNavItem(
            icon: Icons.assignment,
            label: 'Quests',
            isActive: true,
            onTap: () {},
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.hashAddQuest),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.outline,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _buildNavItem(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, AppRouter.wallet),
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Hero',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, AppRouter.customize),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outlineVariant, width: 2),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.capriola(
                fontSize: 10,
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
