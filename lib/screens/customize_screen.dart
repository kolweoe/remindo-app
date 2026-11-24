import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/theme/pixel_theme.dart';
import '../core/utils/responsive.dart';
import '../widgets/pixel_scaffold.dart';

class CustomizeScreen extends ConsumerStatefulWidget {
  const CustomizeScreen({super.key});

  static const List<Map<String, String>> costumes = [
    {'id': 'hoodie_ungu', 'name': 'Hoodie Ungu Kasual', 'desc': 'Gaya santai untuk belajar sehari-hari.', 'icon': '🥼'},
    {'id': 'jaket_cyber', 'name': 'Jaket Cyber Neon', 'desc': 'Jaket retro masa depan penuh energi.', 'icon': '🧥'},
    {'id': 'jubah_sihir', 'name': 'Jubah Penyihir', 'desc': 'Kekuatan fokus setajam mantra.', 'icon': '🧙‍♂️'},
    {'id': 'baju_olahraga', 'name': 'Jersey Atletik', 'desc': 'Semangat produktif tanpa lelah.', 'icon': '🥋'},
  ];

  static const List<Map<String, String>> pets = [
    {'id': 'cat_tuxedo', 'name': 'Kucing Tuxedo', 'desc': 'Teman setia yang selalu tenang.', 'icon': '🐱'},
    {'id': 'shiba_pixel', 'name': 'Shiba Pixel', 'desc': 'Anjing ceria yang menyemangatimu.', 'icon': '🐶'},
    {'id': 'burung_hantu', 'name': 'Burung Hantu', 'desc': 'Sahabat bijak untuk sesi belajar malam.', 'icon': '🦉'},
    {'id': 'naga_mini', 'name': 'Naga Mini', 'desc': 'Menjaga api semangatmu tetap menyala.', 'icon': '🐲'},
  ];

  @override
  ConsumerState<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends ConsumerState<CustomizeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroAsync = ref.watch(heroProfileProvider);

    return PixelScaffold(
      currentTabIndex: 4,
      body: Column(
        children: [
          // ==========================================
          // 1. RIBBON BANNER HEADER ("HEROKU")
          // ==========================================
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.px(context, 14),
              12,
              Responsive.px(context, 14),
              8,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: PixelColors.badgePurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PixelColors.deepPurple, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334A2E70),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛡️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'HEROKU — KOSTUM & PELIHARAAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. RETRO TAB SELECTOR
          // ==========================================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.px(context, 14), vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: PixelColors.cardParchment,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PixelColors.deepPurple, width: 1.5),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: PixelColors.badgePurple,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: PixelColors.textDark,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: '🥼 Kostum Hero'),
                  Tab(text: '🐾 Peliharaan (Pet)'),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. TAB CONTENT
          // ==========================================
          Expanded(
            child: heroAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PixelColors.badgePurple),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: PixelColors.redExpense)),
              ),
              data: (hero) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Costumes
                    ListView.separated(
                      padding: EdgeInsets.all(Responsive.px(context, 14)),
                      itemCount: CustomizeScreen.costumes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = CustomizeScreen.costumes[i];
                        final isSelected = hero.activeCostumeId == item['id'];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: PixelDecorations.card(
                            color: isSelected ? PixelColors.cardParchmentGold : PixelColors.cardParchment,
                            radius: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(item['icon']!, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: const TextStyle(
                                        color: PixelColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc']!,
                                      style: const TextStyle(
                                        color: PixelColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: isSelected
                                    ? null
                                    : () => ref.read(heroProfileProvider.notifier).setCostume(item['id']!),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? PixelColors.greenSuccess : PixelColors.badgePurple,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                                  ),
                                  child: Text(
                                    isSelected ? 'Dipakai ✓' : 'Gunakan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tab 2: Pets
                    ListView.separated(
                      padding: EdgeInsets.all(Responsive.px(context, 14)),
                      itemCount: CustomizeScreen.pets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = CustomizeScreen.pets[i];
                        final isSelected = hero.activePetId == item['id'];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: PixelDecorations.card(
                            color: isSelected ? PixelColors.cardParchmentGold : PixelColors.cardParchment,
                            radius: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(item['icon']!, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name']!,
                                      style: const TextStyle(
                                        color: PixelColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc']!,
                                      style: const TextStyle(
                                        color: PixelColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: isSelected
                                    ? null
                                    : () => ref.read(heroProfileProvider.notifier).setPet(item['id']!),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? PixelColors.greenSuccess : PixelColors.coinGold,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                                  ),
                                  child: Text(
                                    isSelected ? 'Aktif ✓' : 'Pilih Pet',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : PixelColors.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
