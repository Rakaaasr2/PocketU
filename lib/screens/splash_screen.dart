import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart'; // Pastikan path onboarding kamu sudah sesuai

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Kontroler untuk semua animasi di halaman ini
  late AnimationController _animationController;

  // Animasi untuk Logo (Hanya Fade In)
  late Animation<double> _logoFadeAnimation;

  // Animasi untuk Teks PocketU & Deskripsi (Fade In + Slide Kiri)
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Kontroler untuk animasi 3 Titik Kedip di bawah
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Kontroler Animasi Utama (Durasi 2 detik biar pergerakannya halus)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // --- ANIMASI LOGO (Muncul duluan di detik awal) ---
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn), // Selesai di 60% durasi
      ),
    );

    // --- ANIMASI TEKS SLIDE KIRI + FADE (Muncul menyusul secara sinematik) ---
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeIn), // Mulai dari 30% durasi
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Mulai agak ke kanan (X = 0.5)
      end: Offset.zero,             // Berakhir pas di tengah (X = 0.0)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic), // Efek ngerem halus pas di tengah
      ),
    );

    // Mulai jalankan semua animasi splash
    _animationController.forward();

    // 2. Inisialisasi Animasi 3 Titik Kedip (Loop terus)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // 3. Pindah ke Halaman Onboarding setelah 4.5 detik (dilebihkan dikit biar animasi kelihatan puas)
    Timer(const Duration(milliseconds: 4500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF), // Warna ungu tema PocketU
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- LOGO: HANYA FADE IN ---
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 110,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),

            // --- TEKS: FADE IN + SLIDE GESER KE KIRI ---
            FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Column(
                  children: [
                    const Text(
                      "PocketU",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kelola keuanganmu dengan bijak",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // --- ANIMASI 3 TITIK PUTIH KEDIP BERGANTIAN ---
            AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    double delay = index * 0.33;
                    double progress = (_dotController.value - delay);
                    if (progress < 0) progress += 1.0;

                    double opacity = (1.0 - (progress - 0.5).abs() * 2).clamp(0.2, 1.0);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(opacity),
                        boxShadow: [
                          if (opacity > 0.7)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}