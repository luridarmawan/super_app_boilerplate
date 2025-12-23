import 'package:flutter/material.dart';

/// Enum untuk menentukan strategi autentikasi
enum AuthStrategy { firebase, customApi }

/// Enum untuk posisi Sidebar
enum SidebarPosition { left, right }

class AppConfig extends ChangeNotifier {
  // 1. Auth Configuration
  AuthStrategy _authStrategy = AuthStrategy.firebase; // Default
  
  // 2. UI Configuration
  SidebarPosition _sidebarPosition = SidebarPosition.left; // Default
  Locale _selectedLocale = const Locale('id', 'ID'); // Default Bahasa Indonesia
  
  // 3. Template Configuration
  ThemeData _currentTheme = ThemeData.light(); 

  // Getters
  AuthStrategy get authStrategy => _authStrategy;
  SidebarPosition get sidebarPosition => _sidebarPosition;
  Locale get selectedLocale => _selectedLocale;
  ThemeData get currentTheme => _currentTheme;

  // Setters dengan NotifyListeners untuk re-build UI otomatis
  void setAuthStrategy(AuthStrategy strategy) {
    _authStrategy = strategy;
    notifyListeners();
  }

  void setSidebarPosition(SidebarPosition position) {
    _sidebarPosition = position;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _selectedLocale = locale;
    notifyListeners(); // Memicu perubahan bahasa di seluruh aplikasi
  }

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners(); // Memicu perubahan template/layout
  }
}