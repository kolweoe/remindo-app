import 'package:flutter/material.dart';
import '../core/theme/pixel_theme.dart';
import '../models/hero_profile.dart';

/// Interactive Retro Pixel Room Stage representing the Hero's Room.
class PixelRoomView extends StatefulWidget {
  final HeroProfile hero;
  final VoidCallback onUpgradeTap;
  final VoidCallback onCustomizeTap;

  const PixelRoomView({
    super.key,
    required this.hero,
    required this.onUpgradeTap,
    required this.onCustomizeTap,
  });

  @override
  State<PixelRoomView> createState() => _PixelRoomViewState();
}

class _PixelRoomViewState extends State<PixelRoomView> with SingleTickerProviderStateMixin {
  late AnimationController _bobbingController;

  @override
  void initState() {
    super.initState();
    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bobbingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      decoration: BoxDecoration(
        color: const Color(0xFFDDD6FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PixelColors.deepPurple, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334A2E70),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // --- Custom Painted Pixel Room Background ---
            Positioned.fill(
              child: CustomPaint(
                painter: _PixelRoomPainter(roomLevel: widget.hero.roomLevel),
              ),
            ),

            // --- Top Info Badge: Room Name & Level ---
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PixelColors.cardParchment,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PixelColors.deepPurple, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bed_rounded, size: 14, color: PixelColors.deepPurple),
                    const SizedBox(width: 4),
                    Text(
                      'Kamar Lv.${widget.hero.roomLevel} (${_getRoomName(widget.hero.roomLevel)})',
                      style: const TextStyle(
                        color: PixelColors.textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Animated Hero Sprite & Pet in the Center Room ---
            Positioned(
              bottom: 45,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bobbingController,
                builder: (context, child) {
                  final bob = (_bobbingController.value * 4);
                  return Transform.translate(
                    offset: Offset(0, -bob),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Character Avatar Card
                    _buildCharacterSprite(),

                    const SizedBox(width: 14),

                    // Pet Avatar
                    _buildPetSprite(),
                  ],
                ),
              ),
            ),

            // --- Bottom Left: Ganti Kostum Button ---
            Positioned(
              bottom: 10,
              left: 12,
              child: InkWell(
                onTap: widget.onCustomizeTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: PixelColors.cardParchment,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checkroom_rounded, size: 14, color: PixelColors.deepPurple),
                      SizedBox(width: 4),
                      Text(
                        'Kostum',
                        style: TextStyle(
                          color: PixelColors.textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSprite() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 86,
          decoration: BoxDecoration(
            color: PixelColors.cardParchment,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PixelColors.deepPurple, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334A2E70),
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Character body silhouette / avatar
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7AA),
                      shape: BoxShape.circle,
                      border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('🙂', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 42,
                    height: 24,
                    decoration: BoxDecoration(
                      color: PixelColors.badgePurple,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: PixelColors.deepPurple, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_rounded, size: 14, color: PixelColors.coinGold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: PixelColors.badgePurple,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PixelColors.deepPurple, width: 1.5),
          ),
          child: Text(
            widget.hero.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetSprite() {
    String petEmoji = '🐱';
    String petName = 'Kucing';
    if (widget.hero.activePetId.contains('shiba')) {
      petEmoji = '🐶';
      petName = 'Shiba';
    } else if (widget.hero.activePetId.contains('burung')) {
      petEmoji = '🦉';
      petName = 'Hantu';
    } else if (widget.hero.activePetId.contains('naga')) {
      petEmoji = '🐲';
      petName = 'Naga';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: PixelColors.cardParchmentGold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PixelColors.deepPurple, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334A2E70),
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(petEmoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: PixelColors.coinGold,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PixelColors.deepPurple, width: 1),
          ),
          child: Text(
            petName,
            style: const TextStyle(
              color: PixelColors.textDark,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getRoomName(int level) {
    switch (level) {
      case 1:
        return 'Kos Polos';
      case 2:
        return 'Kos Rapi';
      case 3:
        return 'Meja Belajar LED';
      case 4:
        return 'Setup PC Impian';
      case 5:
        return 'Studio Mahasiswa';
      case 6:
        return 'Apartemen Minimalis';
      case 7:
        return 'Penthouse Produktif';
      case 8:
        return 'Istana Master RPG';
      default:
        return 'Kamar Hero';
    }
  }
}

/// Custom painter rendering a cozy pixel bedroom wallpaper, window, desk, and wooden floor.
class _PixelRoomPainter extends CustomPainter {
  final int roomLevel;

  _PixelRoomPainter({required this.roomLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height * 0.68;

    // 1. Wall Background (Warm Retro Pastel Lavender / Yellow)
    final wallPaint = Paint()..color = const Color(0xFFE9D5FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, floorY), wallPaint);

    // Wall stripes pattern
    final stripePaint = Paint()
      ..color = const Color(0xFFDDD6FE).withOpacity(0.5)
      ..strokeWidth = 2;
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, floorY), stripePaint);
    }

    // 2. Baseboard / skirting board
    final baseboardPaint = Paint()..color = const Color(0xFF6D3FA8);
    canvas.drawRect(Rect.fromLTWH(0, floorY - 6, size.width, 6), baseboardPaint);

    // 3. Wooden Floor
    final floorPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawRect(Rect.fromLTWH(0, floorY, size.width, size.height - floorY), floorPaint);

    // Floor planks
    final plankPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 1.5;
    for (double y = floorY; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankPaint);
    }

    // 4. Pixel Window on the wall
    final windowRect = Rect.fromLTWH(size.width * 0.1, 30, 80, 75);
    final windowFramePaint = Paint()..color = const Color(0xFF4A2E70);
    final windowGlassPaint = Paint()..color = const Color(0xFF93C5FD);
    canvas.drawRect(windowRect.inflate(3), windowFramePaint);
    canvas.drawRect(windowRect, windowGlassPaint);

    // Window sun/clouds
    final sunPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawCircle(Offset(windowRect.left + 24, windowRect.top + 26), 14, sunPaint);

    // Window crossbars
    final crossPaint = Paint()
      ..color = const Color(0xFF4A2E70)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(windowRect.left + 40, windowRect.top), Offset(windowRect.left + 40, windowRect.bottom), crossPaint);
    canvas.drawLine(Offset(windowRect.left, windowRect.top + 38), Offset(windowRect.right, windowRect.top + 38), crossPaint);

    // 5. Bookshelf / Computer Desk on the right
    final deskRect = Rect.fromLTWH(size.width * 0.65, floorY - 65, 95, 75);
    final deskPaint = Paint()..color = const Color(0xFFB45309);
    final borderPaint = Paint()
      ..color = const Color(0xFF4A2E70)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(deskRect, deskPaint);
    canvas.drawRect(deskRect, borderPaint);

    // Computer Monitor on the desk
    final monitorRect = Rect.fromLTWH(size.width * 0.72, floorY - 95, 36, 30);
    final monitorPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRect(monitorRect.inflate(2), windowFramePaint);
    canvas.drawRect(monitorRect, monitorPaint);

    // Computer Stand
    canvas.drawRect(Rect.fromLTWH(size.width * 0.76, floorY - 67, 8, 4), windowFramePaint);
  }

  @override
  bool shouldRepaint(covariant _PixelRoomPainter oldDelegate) => oldDelegate.roomLevel != roomLevel;
}
