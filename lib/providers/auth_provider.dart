import 'package:flutter/material.dart';
import '../core/storage/preferences_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String _currentUserPhone = '+91 99887 76655';
  String? _profileImageUrl;
  bool _rememberMe = false;
  String _userRole = 'buyer'; // 'buyer' or 'seller'

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String get currentUserPhone => _currentUserPhone;
  String? get profileImageUrl => _profileImageUrl;
  bool get rememberMe => _rememberMe;
  String get userRole => _userRole;

  AuthProvider() {
    loadAuthFromStorage();
  }

  // Restore authentication details from SharedPreferences
  void loadAuthFromStorage() {
    final prefs = PreferencesService.instance;
    _rememberMe = prefs.getBool('remember_me', defaultValue: false);
    _userRole = prefs.getString('user_role', defaultValue: 'buyer');
    _profileImageUrl = prefs.getString(
      'profile_image_url',
      defaultValue: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
    );

    if (_rememberMe) {
      _isLoggedIn = prefs.getBool('is_logged_in', defaultValue: false);
      if (_isLoggedIn) {
        _currentUserEmail = prefs.getString('user_email', defaultValue: 'nand@example.com');
        _currentUserName = prefs.getString('user_name', defaultValue: 'Nand Kishore');
        _currentUserPhone = prefs.getString('user_phone', defaultValue: '+91 99887 76655');
      }
    } else {
      _isLoggedIn = false;
      _currentUserEmail = null;
      _currentUserName = null;
    }
  }

  Future<bool> login(String email, String password, bool rememberMe, String role) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = email.split('@')[0].toUpperCase();
    _rememberMe = rememberMe;
    _userRole = role;
    _profileImageUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';

    // Save to SharedPreferences
    final prefs = PreferencesService.instance;
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('remember_me', rememberMe);
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', _currentUserName!);
    await prefs.setString('user_phone', _currentUserPhone);
    await prefs.setString('profile_image_url', _profileImageUrl!);

    notifyListeners();
    return true;
  }

  Future<bool> signup(String name, String email, String password, String role) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = name;
    _userRole = role;
    _rememberMe = true; // Auto login with remember me on registration
    _profileImageUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';

    // Save to SharedPreferences
    final prefs = PreferencesService.instance;
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('remember_me', true);
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', _currentUserPhone);
    await prefs.setString('profile_image_url', _profileImageUrl!);

    notifyListeners();
    return true;
  }

  void updateProfile(String name, String email, String phone, {String? image}) {
    _currentUserName = name;
    _currentUserEmail = email;
    _currentUserPhone = phone;
    if (image != null && image.isNotEmpty) {
      _profileImageUrl = image;
    }

    final prefs = PreferencesService.instance;
    prefs.setString('user_name', name);
    prefs.setString('user_email', email);
    prefs.setString('user_phone', phone);
    if (_profileImageUrl != null) {
      prefs.setString('profile_image_url', _profileImageUrl!);
    }

    notifyListeners();
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    _userRole = 'buyer';
    _rememberMe = false;
    _profileImageUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop';

    // Clear preferences
    final prefs = PreferencesService.instance;
    prefs.setBool('is_logged_in', false);
    prefs.setBool('remember_me', false);
    prefs.setString('user_role', 'buyer');
    prefs.setString('user_email', '');
    prefs.setString('user_name', '');
    prefs.setString('user_phone', '+91 99887 76655');
    prefs.setString('profile_image_url', _profileImageUrl!);

    notifyListeners();
  }
}
