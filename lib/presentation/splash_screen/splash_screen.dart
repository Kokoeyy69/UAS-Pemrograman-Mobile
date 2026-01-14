import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_flags/country_flags.dart';
// 1. IMPORT WAJIB UNTUK GPS
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLocationFound = false; 
  String _initializationStatus = 'splash_initialization_status_default'.tr();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  // --- LOGIKA UTAMA ---
  Future<void> _initializeApp() async {
    try {
      // 1. Simulasi loading awal
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        setState(() {
          _initializationStatus = 'splash_detecting'.tr(); // "Mendeteksi lokasi..."
        });
      }

      // 2. JALANKAN DETEKSI GPS (Ini yang bikin bahasa berubah)
      await _detectLocationAndChangeLanguage();

      // 3. Setelah lokasi ketemu, Munculkan Bendera
      if (mounted) {
        setState(() {
          _isLocationFound = true;
        });
      }

      // 4. Tahan 2 detik biar user lihat benderanya
      await Future.delayed(const Duration(milliseconds: 2000));

      // 5. Pindah ke Dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.walletDashboard);
      }
    } catch (e) {
      print("Error GPS: $e");
      // Jika GPS error, tetap lanjut masuk dashboard dengan bahasa default
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.walletDashboard);
      }
    }
  }

  // --- FUNGSI DETEKSI GPS & GEOCIDING ---
  Future<void> _detectLocationAndChangeLanguage() async {
    // A. Cek Service GPS Nyala/Mati
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return; 

    // B. Cek Izin Lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // C. Ambil Koordinat (Latitude/Longitude)
    Position position = await Geolocator.getCurrentPosition();

    // D. Ubah Koordinat jadi Nama Negara (Reverse Geocoding)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        String? countryCode = placemarks.first.isoCountryCode; // Dapat "JP", "ID", dll
        
        if (countryCode != null && mounted) {
          // E. Ganti Bahasa Aplikasi
          _switchLanguageByCountry(countryCode);
        }
      }
    } catch (e) {
      print("Gagal mendapatkan negara: $e");
    }
  }

  // --- FUNGSI GANTI BAHASA OTOMATIS ---
  void _switchLanguageByCountry(String countryCode) {
    print("📍 Lokasi Terdeteksi: $countryCode"); // Cek di terminal
    switch (countryCode) {
      case 'ID': context.setLocale(Locale('id', 'ID')); break;
      case 'JP': context.setLocale(Locale('ja', 'JP')); break;
      case 'US': context.setLocale(Locale('en', 'US')); break;
      case 'MY': context.setLocale(Locale('ms', 'MY')); break;
      case 'CN': context.setLocale(Locale('zh', 'CN')); break;
      case 'KR': context.setLocale(Locale('ko', 'KR')); break;
      case 'SA': context.setLocale(Locale('ar', 'SA')); break;
      case 'ES': context.setLocale(Locale('es', 'ES')); break;
      case 'FR': context.setLocale(Locale('fr', 'FR')); break;
      case 'DE': context.setLocale(Locale('de', 'DE')); break;
      case 'IT': context.setLocale(Locale('it', 'IT')); break;
      case 'TH': context.setLocale(Locale('th', 'TH')); break;
      case 'TR': context.setLocale(Locale('tr', 'TR')); break;
      case 'IN': context.setLocale(Locale('hi', 'IN')); break;
      case 'RU': context.setLocale(Locale('ru', 'RU')); break;
      default: context.setLocale(Locale('en', 'US')); // Default Inggris
    }
  }

  String _getCountryName(String code) {
    switch (code) {
      case 'ID': return 'Indonesia';
      case 'US': return 'United States';
      case 'JP': return 'Japan';
      case 'CN': return 'China';
      case 'MY': return 'Malaysia';
      case 'KR': return 'Korea';
      case 'SA': return 'Saudi Arabia';
      case 'DE': return 'Germany';
      case 'FR': return 'France';
      case 'IT': return 'Italy';
      case 'ES': return 'Spain';
      case 'TH': return 'Thailand';
      case 'TR': return 'Turkey';
      case 'IN': return 'India';
      case 'RU': return 'Russia';
      default: return code;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final countryCode = context.locale.countryCode ?? 'US';

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondary.withValues(alpha: 0.3),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(opacity: _fadeAnimation.value, child: child),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Center(child: CustomIconWidget(iconName: 'account_balance_wallet', size: 64, color: theme.colorScheme.primary)),
                    ),
                    SizedBox(height: 24),
                    Text('splash_app_name'.tr(), style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('splash_tagline'.tr(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              SizedBox(
                height: 100,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: Offset(0.0, 0.2), end: Offset.zero).animate(animation), child: child));
                  },
                  child: _isLocationFound 
                      ? _buildGreetingWidget(theme, countryCode)
                      : _buildLoadingWidget(theme),
                ),
              ),

              SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.onPrimary.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(iconName: 'verified_user', size: 16, color: theme.colorScheme.onPrimary),
                    SizedBox(width: 8),
                    Text('splash_security_badge'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Column(
      key: ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary))),
        SizedBox(height: 16),
        Text(_initializationStatus, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.9)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildGreetingWidget(ThemeData theme, String countryCode) {
    return Column(
      key: ValueKey('greeting'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))]),
          padding: EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            // --- FIX SIZEDBOX UNTUK COUNTRYFLAG VERSI BARU ---
            child: SizedBox(
              width: 48,
              height: 32,
              child: CountryFlag.fromCountryCode(countryCode),
            ),
            // -------------------------------------------------
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${'splash_greeting'.tr()} ", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w500)),
            Text(_getCountryName(countryCode), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
            SizedBox(width: 6),
            Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18)
          ],
        ),
      ],
    );
  }
}