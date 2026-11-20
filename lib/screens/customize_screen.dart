import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/responsive.dart';

class CustomizeScreen extends ConsumerWidget {
  const CustomizeScreen({super.key});

  static const List<Map<String, String>> costumes = [
    {'id': 'hoodie_ungu', 'name': 'Hoodie Ungu Kasual', 'desc': 'Gaya santai untuk belajar sehari-hari.'},
    {'id': 'jaket_cyber', 'name': 'Jaket Cyber Neon', 'desc': 'Jaket retro masa depan penuh energi.'},
    {'id': 'jubah_sihir', 'name': 'Jubah Penyihir', 'desc': 'Kekuatan fokus setajam mantra.'},
    {'id': 'baju_olahraga', 'name': 'Jersey Atletik', 'desc': 'Semangat produktif tanpa lelah.'},
  ];

  static const List<Map<String, String>> pets = [
    {'id': 'cat_tuxedo', 'name': 'Kucing Tuxedo', 'desc': 'Teman setia yang selalu tenang.'},
    {'id': 'shiba_pixel', 'name': 'Shiba Pixel', 'desc': 'Anjing ceria yang menyemangatimu.'},
    {'id': 'burung_hantu', 'name': 'Burung Hantu', 'desc': 'Sahabat bijak untuk sesi belajar malam.'},
    {'id': 'naga_mini', 'name': 'Naga Mini', 'desc': 'Menjaga api semangatmu tetap menyala.'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroAsync = ref.watch(heroProfileProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          title: const Text(
            'Kustomisasi Hero & Pet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF8B5CF6),
            labelColor: Color(0xFF8B5CF6),
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.checkroom), text: 'Kostum Hero'),
              Tab(icon: Icon(Icons.pets), text: 'Peliharaan (Pet)'),
            ],
          ),
        ),
        body: ResponsiveWrapper(
          child: heroAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            data: (hero) {
              return TabBarView(
                children: [
                  // Tab 1: Costumes
                  ListView.separated(
                    padding: EdgeInsets.all(Responsive.px(context, 16)),
                    itemCount: costumes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = costumes[i];
                      final isSelected = hero.activeCostumeId == item['id'];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF334155),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.person, color: Color(0xFFA78BFA), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['desc']!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: isSelected
                                  ? null
                                  : () => ref.read(heroProfileProvider.notifier).setCostume(item['id']!),
                              child: Text(isSelected ? 'Dipakai' : 'Gunakan', style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tab 2: Pets
                  ListView.separated(
                    padding: EdgeInsets.all(Responsive.px(context, 16)),
                    itemCount: pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = pets[i];
                      final isSelected = hero.activePetId == item['id'];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF334155),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.pets, color: Color(0xFFFBBF24), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['desc']!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                                foregroundColor: isSelected ? Colors.white : Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: isSelected
                                  ? null
                                  : () => ref.read(heroProfileProvider.notifier).setPet(item['id']!),
                              child: Text(isSelected ? 'Aktif' : 'Pilih Pet', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
