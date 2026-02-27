import 'package:flutter/material.dart';
import '../app.dart';
import '../app_theme.dart';

class BottomNav extends StatelessWidget {
  final AppScreen currentScreen;
  final int alertCount;
  final ValueChanged<AppScreen> onNavigate;

  const BottomNav({
    super.key,
    required this.currentScreen,
    required this.alertCount,
    required this.onNavigate,
  });

  void _openMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundMid],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navItem(context, Icons.settings, 'Settings', AppScreen.settings),
              _navItem(context, Icons.wifi, 'IoT Status', AppScreen.iotStatus),
              _navItem(context, Icons.help_outline, 'Help', AppScreen.help),
              const Divider(color: Colors.white24, height: 24),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.white70),
                title: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {});
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    AppScreen screen,
  ) {
    final isActive = currentScreen == screen;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.white : Colors.white70,
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.white : Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onNavigate(screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundMid],
        ),
        border: Border(
          top: BorderSide(color: AppColors.white.withValues(alpha: 0.1)),
        ),
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tab(Icons.home, 'Home', AppScreen.home),
          _tab(Icons.directions_car, 'Vehicle', AppScreen.vehicle),
          _tabWithBadge(
            Icons.notifications,
            'Alerts',
            AppScreen.alerts,
            alertCount,
          ),
          _tab(Icons.history, 'History', AppScreen.history),
          _moreTab(context),
        ],
      ),
    );
  }

  Widget _tab(IconData icon, String label, AppScreen screen) {
    final isActive = currentScreen == screen;
    return GestureDetector(
      onTap: () => onNavigate(screen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.4) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.white : Colors.white60,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabWithBadge(
    IconData icon,
    String label,
    AppScreen screen,
    int count,
  ) {
    final isActive = currentScreen == screen;
    return GestureDetector(
      onTap: () => onNavigate(screen),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.4) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.white : Colors.white60,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.white : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _moreTab(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMoreMenu(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu, size: 24, color: Colors.white60),
          const SizedBox(height: 4),
          Text(
            'More',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
