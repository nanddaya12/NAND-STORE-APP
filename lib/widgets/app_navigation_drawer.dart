import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/wishlist_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/auth/role_selection_screen.dart';

class AppNavigationDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppNavigationDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: const Color(0xFFFCF9F8),
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF000613), // Premium Indigo
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFFFFB62C), // Amber Accent
              backgroundImage: authProvider.profileImageUrl != null && authProvider.profileImageUrl!.isNotEmpty
                  ? NetworkImage(authProvider.profileImageUrl!)
                  : null,
              child: authProvider.profileImageUrl == null || authProvider.profileImageUrl!.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Color(0xFF000613),
                      size: 36,
                    )
                  : null,
            ),
            accountName: Text(
              authProvider.currentUserName ?? 'Guest User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authProvider.currentUserEmail ?? 'guest@example.com',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB62C).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB62C), width: 0.5),
                  ),
                  child: Text(
                    authProvider.userRole.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFB62C),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Menu List Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  title: 'Home Feed',
                  isActive: currentIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(0);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  title: 'Browse Categories',
                  isActive: currentIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(1);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  title: 'My Cart',
                  isActive: currentIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(2);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.favorite_border_outlined,
                  activeIcon: Icons.favorite,
                  title: 'My Wishlist',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  title: 'My Orders',
                  isActive: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'My Profile',
                  isActive: currentIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(3);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Color(0xFFC4C6CF), height: 32),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  activeIcon: Icons.logout,
                  title: 'Sign Out',
                  isActive: false,
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Drawer Footer branding
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'NAND STORE v1.0.0',
              style: TextStyle(
                color: Color(0xFF43474E),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFB62C).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive 
              ? const Color(0xFF7F5700) 
              : (iconColor ?? const Color(0xFF000613)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: isActive 
                ? const Color(0xFF7F5700) 
                : (textColor ?? const Color(0xFF1C1B1B)),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
