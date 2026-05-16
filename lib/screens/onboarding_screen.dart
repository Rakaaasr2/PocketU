import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data konten tiap slide
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Catat Transaksi",
      "subtitle": "Pantau pemasukan dan pengeluaran harianmu dengan mudah, kapan saja dan di mana saja.",
      "icon": "wallet"
    },
    {
      "title": "Atur Anggaran",
      "subtitle": "Buat rencana keuangan bulananmu agar pengeluaran tidak membengkak di akhir bulan.",
      "icon": "pie_chart"
    },
    {
      "title": "Laporan Detail",
      "subtitle": "Dapatkan visualisasi grafik keuangan yang rapi untuk evaluasi kebiasaan belanjamu.",
      "icon": "bar_chart"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Bagian Atas: Slide Content
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() => _currentPage = value);
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) => _buildPageContent(index),
            ),
          ),

          // Bagian Bawah: Indicator & Button
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                        (index) => _buildDot(index),
                  ),
                ),
                Spacer(),
                // Tombol Lanjut / Mulai
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          // Jika sudah di slide terakhir, pindah ke Login
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        } else {
                          // Jika belum, geser ke slide berikutnya
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? "Mulai Sekarang" : "Lanjut",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                // Tombol Lewati
                if (_currentPage != _onboardingData.length - 1)
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                    child: Text("Lewati", style: TextStyle(color: Colors.grey)),
                  ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Isi Konten
  Widget _buildPageContent(int index) {
    IconData displayIcon;
    if (index == 0) displayIcon = Icons.account_balance_wallet_outlined;
    else if (index == 1) displayIcon = Icons.pie_chart_outline;
    else displayIcon = Icons.bar_chart_outlined;

    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200, width: 200,
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(displayIcon, size: 100, color: Color(0xFF6C63FF)),
          ),
          SizedBox(height: 40),
          Text(
            _onboardingData[index]["title"]!,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Text(
            _onboardingData[index]["subtitle"]!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }

  // Widget untuk Titik-titik (Dots)
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFF6C63FF) : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}