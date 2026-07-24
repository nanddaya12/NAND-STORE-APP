import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'buyer' or 'seller'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default pre-populated credentials for ease of testing
    if (widget.role == 'seller') {
      _emailController.text = 'seller@example.com';
      _passwordController.text = 'seller123';
    } else {
      _emailController.text = 'nand@example.com';
      _passwordController.text = 'nand123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
      _rememberMe,
      widget.role,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (widget.role == 'seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isSeller = widget.role == 'seller';
    final themeColor = isSeller ? const Color(0xFF7F5700) : const Color(0xFF000613);

    if (_isSubmitting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: themeColor),
              const SizedBox(height: 16),
              Text(
                isSeller ? 'Opening Seller Portal...' : 'Logging in...',
                style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isSeller ? 'Seller Login' : 'Buyer Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  isSeller ? 'Seller Portal' : 'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
                ),
                const SizedBox(height: 8),
                Text(
                  isSeller 
                      ? 'Access shop management dashboard to configure catalogs and check metrics.' 
                      : 'Enter credentials to access your NAND Store profile dashboard.',
                  style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 40),

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
                const SizedBox(height: 12),

                // Remember Me & Forgot Password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: themeColor,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                        Text('Remember Me', style: TextStyle(fontSize: 12, color: themeColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: isSeller ? const Color(0xFF7F5700) : const Color(0xFF000613), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign In Button
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
                    child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 16),


                // Separator Row
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFFC4C6CF))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CONTINUE WITH', style: TextStyle(color: Color(0xFF43474E), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFC4C6CF))),
                  ],
                ),
                const SizedBox(height: 20),

                // Google & Apple SSO buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated Google Authentication...')));
                        },
                        icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.redAccent),
                        label: Text('Google', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC4C6CF)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated Apple Authentication...')));
                        },
                        icon: const Icon(Icons.apple, size: 22, color: Colors.black),
                        label: Text('Apple', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC4C6CF)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Sign up redirection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?', style: TextStyle(color: Color(0xFF43474E), fontSize: 13)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen(role: widget.role)),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
