import 'package:flutter/material.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role; // 'buyer' or 'seller'

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Direct registration to OTP verification page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPScreen(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          intent: 'signup',
          name: _nameController.text.trim(),
          password: _passwordController.text.trim(),
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSeller = widget.role == 'seller';
    final themeColor = isSeller ? const Color(0xFF7F5700) : const Color(0xFF000613);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: Text(isSeller ? 'Seller Sign Up' : 'Buyer Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSeller ? 'Register as Shop Owner' : 'Join NAND Store',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
                ),
                const SizedBox(height: 8),
                Text(
                  isSeller
                      ? 'Start setting up your store profile and launch your catalog listings today.'
                      : 'Create an account to browse high-end products and build your curated orders.',
                  style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 30),

                // Name field
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: Icon(Icons.person_outline, size: 18, color: themeColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: Icon(Icons.email_outlined, size: 18, color: themeColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Mobile field
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Mobile number is required' : null,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: Icon(Icons.phone_outlined, size: 18, color: themeColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 4 ? 'Password must be 4+ characters' : null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
                    prefixIcon: Icon(Icons.lock_outline, size: 18, color: themeColor),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms of service checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor: themeColor,
                      onChanged: (val) {
                        setState(() {
                          _acceptTerms = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I accept the NAND Store Terms of Service & Privacy Policies.',
                        style: TextStyle(fontSize: 11, color: themeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _submit,
                    child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 30),

                // Link back to Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: Color(0xFF43474E), fontSize: 13)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
