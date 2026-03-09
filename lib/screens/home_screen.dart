import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import 'directory_screen.dart';
import 'my_listings_screen.dart';
import 'map_view_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  // App Theme Colors
  static const Color primaryColor = Color(0xFF1A237E);

  final List<Widget> _screens = [
    const DirectoryScreen(),
    const MyListingsScreen(),
    const MapViewScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().initializeListingsStream();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;

    // If switching to My Listings tab (index 1), refresh the listings
    if (index == 1) {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user != null) {
        // Force refresh when switching to My Listings tab
        context.read<ListingsProvider>().initializeMyListingsStream(user.uid, forceRefresh: true);
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.folder_outlined,
                  selectedIcon: Icons.folder,
                  label: 'Directory',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabSelected(0),
                ),
                _NavItem(
                  icon: Icons.list_alt_outlined,
                  selectedIcon: Icons.list_alt,
                  label: 'My Listings',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabSelected(1),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map,
                  label: 'Map',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabSelected(2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? primaryColor : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey.shade500,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}