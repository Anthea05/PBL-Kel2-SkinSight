import 'package:flutter/material.dart';
import '../theme/skin_theme.dart';

class SkinBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onSelected;

  const SkinBottomNav({
    super.key,
    required this.currentIndex,
    this.onSelected,
  });

  static const _teal = SkinTokens.primary;
  static const _inactive = SkinTokens.muted;
  static const _routes = ['/home', '/education', '/profile'];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 350;
    // Kept outside the tab IndexedStack: shimmer/content changes never replace
    // this navigation bar. A repaint boundary also isolates its paint work.
    return RepaintBoundary(
      child: ColoredBox(
        color: SkinTokens.surface,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                height: compact ? 68 : 74,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: SkinTokens.border),
                  ),
                ),
                child: Row(
                  children: [
                    _NavItem(
                      key: const Key('bottom-home'),
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: currentIndex == 0,
                      compact: compact,
                      onTap: () => _open(context, 0),
                    ),
                    _NavItem(
                      key: const Key('open-education'),
                      icon: Icons.school_outlined,
                      label: 'Edukasi',
                      selected: currentIndex == 1,
                      compact: compact,
                      onTap: () => _open(context, 1),
                    ),
                    _NavItem(
                      key: const Key('bottom-profile'),
                      icon: Icons.person_outline_rounded,
                      label: 'Profil',
                      selected: currentIndex == 2,
                      compact: compact,
                      onTap: () => _open(context, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (onSelected != null) {
      onSelected!(index);
      return;
    }
    final navigator = Navigator.of(context);

    if (index == 0) {
      var foundHome = false;
      navigator.popUntil((route) {
        foundHome = route.settings.name == '/home';
        return foundHome || route.isFirst;
      });
      if (!foundHome) navigator.pushReplacementNamed('/home');
      return;
    }

    if (currentIndex == 0) {
      navigator.pushNamed(_routes[index]);
    } else {
      navigator.pushReplacementNamed(_routes[index]);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? SkinBottomNav._teal : SkinBottomNav._inactive;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: compact ? 22 : 24),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: selected ? 18 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: SkinBottomNav._teal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
