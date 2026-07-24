import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(widget.email, _newPasswordController.text);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Password Reset Successful'),
          content: const Text('Your profile password has been updated. Please sign in with your new credentials.'),
          actions: [
            TextButton(
              onPressed: () {
                // Return to Login screen, popping all reset steps
                final role = Provider.of<AuthProvider>(context, listen: false).userRole;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
                  (route) => false,
                );
              },
              child: const Text('Sign In', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Color(0xFF000613)),
              SizedBox(height: 16),
              Text('Updating Password...', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set New Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a strong secure password for your profile account. Avoid re-using old passwords.',
                  style: TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 40),

                // New Password field
                TextFormField(
                  controller: _newPasswordController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Password must be 6+ characters' : null,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF000613)),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF000613))),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Password must be 6+ characters' : null,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF000613)),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF000613))),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000613),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _submit,
                    child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
