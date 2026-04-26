import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationDestination> destinations;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations, // 🔥 tambahan
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: destinations, // 🔥 pakai dari luar
    );
  }
}
