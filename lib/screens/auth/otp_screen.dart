import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../home_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import 'reset_password_screen.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String intent; // 'signup' or 'reset'
  final String? name;
  final String? password;
  final String? role;

  const OTPScreen({
    super.key,
    required this.email,
    required this.phone,
    required this.intent,
    this.name,
    this.password,
    this.role,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  
  // Timer attributes
  late Timer _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 59;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer.cancel();
        }
      });
    });
  }

  void _submit() async {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // OTP Code: for simplicity, accept any 4-digit numeric code
    setState(() {
      _isVerifying = true;
    });

    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (widget.intent == 'reset') {
      setState(() {
        _isVerifying = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } else {
      // Completed Signup Intent!
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      final success = await authProvider.signup(
        widget.name ?? 'New User',
        widget.email,
        widget.password ?? '',
        widget.role ?? 'buyer',
      );

      // Verify and set mobile phone inside the profile record
      authProvider.updateProfile(
        widget.name ?? 'New User',
        widget.email,
        widget.phone,
      );

      if (widget.role == 'seller') {
        storeProvider.registerSellerProfile(
          id: 's_${widget.email.split('@')[0]}',
          name: widget.name ?? 'New Seller',
          email: widget.email,
          phone: widget.phone,
        );
      }

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone & Email verified successfully!'), behavior: SnackBarBehavior.floating),
        );
        if (widget.role == 'seller') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.role == 'seller' ? const Color(0xFF7F5700) : const Color(0xFF000613);

    if (_isVerifying) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: themeColor),
              const SizedBox(height: 16),
              Text(
                'Verifying credentials...',
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
        title: const Text('Verify Code'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a 4-digit verification code to email ${widget.email} and mobile number ${widget.phone}. Please check your messages/inbox. (Hint: Enter any 4 numbers)',
                style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 40),

              // 4 numeric boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeColor),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC4C6CF))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeColor, width: 2)),
                      ),
                      onChanged: (val) {
                        if (val.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Countdown timer text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_canResend)
                    Text(
                      'Resend code in ${_secondsRemaining}s',
                      style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        _startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification code resent to email and mobile number!')));
                      },
                      child: Text(
                        'Resend Verification Code',
                        style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),

              // Submit trigger button
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
                  child: const Text('Verify Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
