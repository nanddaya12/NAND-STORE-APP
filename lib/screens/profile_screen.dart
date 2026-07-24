import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import 'orders_screen.dart';
import 'auth/role_selection_screen.dart';
import '../widgets/media_upload_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Preferences settings states
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  // Addresses list mock
  final List<String> _addresses = [
    '123 Tech Park Lane, Bangalore, 560001',
    '456 Greenfield Apartments, Tower C, Bangalore, 560103'
  ];

  void _logout(BuildContext context, AuthProvider authProvider) {
    authProvider.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final name = authProvider.currentUserName ?? 'Nand Kishore';
    final email = authProvider.currentUserEmail ?? 'nand@example.com';
    final phone = authProvider.currentUserPhone;

    // Get initials for Avatar
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF000613),
                    backgroundImage: authProvider.profileImageUrl != null && authProvider.profileImageUrl!.isNotEmpty
                        ? NetworkImage(authProvider.profileImageUrl!)
                        : null,
                    child: authProvider.profileImageUrl == null || authProvider.profileImageUrl!.isEmpty
                        ? Text(
                            initials.isNotEmpty ? initials : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF000613),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(color: Color(0xFF43474E), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x1A7F5700),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⭐ NAND VIP Member',
                            style: TextStyle(
                              color: Color(0xFF7F5700),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Loyalty points card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF000613), Color(0xFF2F486A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000613),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NAND LOYALTY POINTS',
                        style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB62C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LVL 2',
                          style: TextStyle(color: Color(0xFF000613), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${storeProvider.loyaltyPoints} Points',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Progress indicator to Level 3 (500 pts)
                  LinearProgressIndicator(
                    value: storeProvider.loyaltyPoints / 500,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFFFFB62C),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Earn 250 more points to reach Level 3.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Actions list
            _buildProfileHeading('My Account'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => _navigateToEditProfile(context, authProvider, name, email, phone),
            ),
            _buildMenuItem(
              icon: Icons.map_outlined,
              title: 'Address Book',
              onTap: () => _navigateToAddressBook(context),
            ),
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Order History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            _buildProfileHeading('App Preferences'),
            _buildToggleItem(
              icon: Icons.notifications_none,
              title: 'Push Notifications',
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Theme (Mock)',
              value: _darkModeEnabled,
              onChanged: (val) {
                setState(() {
                  _darkModeEnabled = val;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_darkModeEnabled ? 'Dark Theme layout simulation activated!' : 'Light Theme layout simulation active.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildLanguageItem(),
            const SizedBox(height: 20),

            _buildProfileHeading('Support & Legal'),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help FAQ Support',
              onTap: () => _showHelpSupportDialog(context),
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Privacy Policy',
              onTap: () => _showPrivacyPolicyDialog(context),
            ),
            const Divider(color: Color(0xFFC4C6CF), height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () => _logout(context, authProvider),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeading(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF43474E),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF000613)),
        title: Text(title, style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF43474E)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFF000613)),
        title: Text(title, style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.w600, fontSize: 14)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLanguageItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Color(0xFF000613)),
        title: const Text('Language', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: DropdownButton<String>(
          value: _selectedLanguage,
          underline: const SizedBox(),
          style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
          items: ['English', 'Spanish', 'Hindi', 'Kannada'].map((lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedLanguage = val;
              });
            }
          },
        ),
      ),
    );
  }

  // Navigation to sub screen Edit Profile
  void _navigateToEditProfile(BuildContext context, AuthProvider auth, String initialName, String initialEmail, String initialPhone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFFCF9F8),
          appBar: AppBar(title: const Text('Edit Profile')),
          body: StatefulBuilder(
            builder: (context, setModalState) {
              final formKey = GlobalKey<FormState>();
              final nameController = TextEditingController(text: initialName);
              final emailController = TextEditingController(text: initialEmail);
              final phoneController = TextEditingController(text: initialPhone);
              final imageController = TextEditingController(text: auth.profileImageUrl ?? '');

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: ListView( // Scrollable to prevent overflow
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (v) => v!.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Email Address'),
                        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        validator: (v) => v!.isEmpty ? 'Phone required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageController,
                        style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Profile Image URL',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF000613)),
                            tooltip: 'Upload Avatar',
                            onPressed: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) => const MediaUploadDialog(mediaType: 'avatar'),
                              );
                              if (result != null) {
                                imageController.text = result;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000613),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              auth.updateProfile(
                                nameController.text,
                                emailController.text,
                                phoneController.text,
                                image: imageController.text.trim(),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile details updated successfully!')),
                              );
                            }
                          },
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).then((_) => setState(() {})); // Re-render profile screen on return
  }

  // Navigation to sub screen Address Book
  void _navigateToAddressBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFFCF9F8),
          appBar: AppBar(title: const Text('Address Book')),
          body: StatefulBuilder(
            builder: (context, setModalState) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFC4C6CF))),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Color(0xFF000613)),
                      title: Text('Address #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text(_addresses[index], style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          setModalState(() {
                            _addresses.removeAt(index);
                          });
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF000613),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Add a default mock address to list
              setState(() {
                _addresses.add('789 Silicon Valley Residency, Indiranagar, Bangalore, 560038');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added new address mock to book!')),
              );
            },
          ),
        ),
      ),
    );
  }

  // Help FAQ dialog
  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help FAQ Support'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Q: How do I track my order?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613))),
              Text('A: Go to Order History on your profile tab to view processing logs and statuses.', style: TextStyle(fontSize: 11, height: 1.4)),
              SizedBox(height: 12),
              Text('Q: What is the coupon policy?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613))),
              Text('A: Type in promo coupon code NAND20 during checkout to get 20% flat discount.', style: TextStyle(fontSize: 11, height: 1.4)),
              SizedBox(height: 12),
              Text('Q: How do I earn loyalty points?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613))),
              Text('A: Earn 1 loyalty point for every \$10 spent on placing orders.', style: TextStyle(fontSize: 11, height: 1.4)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Privacy Policy dialog
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We value your privacy. NAND Store does not distribute or sell user data registries. All payment details are processed offline through secure mocked APIs. Device credentials and passwords verification remains fully protected under sound sound systems frameworks.',
            style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF43474E)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
