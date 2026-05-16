import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_transaction_screen.dart';
import 'target_screen.dart';
import 'stats_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  double totalSaldo = 0;
  double pengeluaranBulanIni = 0;
  double pemasukanBulanIni = 0;
  bool _isSaldoHidden = false;
  List<Map<String, dynamic>> riwayatTransaksi = [];

  // Warna Tema Utama PocketU
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color darkColor = const Color(0xFF2D2D2D);

  // Kombinasi Warna Gradasi Latar Belakang (Modern Pastel Gradient)
  final List<Color> bgGradient = [
    const Color(0xFFF3F2FF),
    const Color(0xFFEDECFF),
    const Color(0xFFE5E2FF),
  ];

  Map<String, double> limitAnggaran = {
    "Makanan": 1000000,
    "Transport": 500000,
    "Belanja": 1000000,
    "Hiburan": 500000,
    "Tagihan": 2000000,
    "Kesehatan": 1000000,
  };

  final Map<String, IconData> iconAnggaran = {
    "Makanan": Icons.fastfood,
    "Transport": Icons.directions_car,
    "Belanja": Icons.shopping_bag,
    "Hiburan": Icons.movie,
    "Tagihan": Icons.receipt_long,
    "Kesehatan": Icons.medical_services,
  };

  Map<String, double> terpakaiPerKategori = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalSaldo = prefs.getDouble('total_saldo') ?? 0;
      _isSaldoHidden = prefs.getBool('is_saldo_hidden') ?? false;

      String? res = prefs.getString('riwayat_data');
      if (res != null) {
        riwayatTransaksi = List<Map<String, dynamic>>.from(json.decode(res));
      }

      String? budgetRes = prefs.getString('custom_limits');
      if (budgetRes != null) {
        Map<String, dynamic> decoded = json.decode(budgetRes);
        limitAnggaran = decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }

      _hitungSemuaStatistik();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total_saldo', totalSaldo);
    await prefs.setBool('is_saldo_hidden', _isSaldoHidden);
    await prefs.setString('riwayat_data', json.encode(riwayatTransaksi));
    await prefs.setString('custom_limits', json.encode(limitAnggaran));
  }

  void _hitungSemuaStatistik() {
    double keluar = 0;
    double masuk = 0;
    terpakaiPerKategori = {for (var k in limitAnggaran.keys) k: 0.0};
    String bulanSekarang = DateFormat('MMM yyyy').format(DateTime.now());

    for (var item in riwayatTransaksi) {
      if (item['tgl'].contains(bulanSekarang)) {
        double nominal = item['nominal'].toDouble();
        if (nominal < 0) {
          keluar += nominal.abs();
          if (terpakaiPerKategori.containsKey(item['kategori'])) {
            terpakaiPerKategori[item['kategori']] = (terpakaiPerKategori[item['kategori']] ?? 0) + nominal.abs();
          }
        } else {
          masuk += nominal;
        }
      }
    }
    setState(() {
      pengeluaranBulanIni = keluar;
      pemasukanBulanIni = masuk;
    });
  }

  int _getNotifCount() {
    int count = 0;
    limitAnggaran.forEach((kategori, limit) {
      double spent = terpakaiPerKategori[kategori] ?? 0;
      if (spent >= limit * 0.9) count++;
    });
    if (riwayatTransaksi.isNotEmpty) count++;
    return count;
  }

  void _showNotifications() {
    List<Widget> notifWidgets = [];
    limitAnggaran.forEach((kategori, limit) {
      double spent = terpakaiPerKategori[kategori] ?? 0;
      if (spent >= limit * 0.9) {
        notifWidgets.add(_buildNotifItem(
            "Limit $kategori Hampir Habis!",
            "Kamu sudah pakai Rp ${formatRupiah(spent, false)}",
            Icons.warning_amber_rounded,
            Colors.orange
        ));
      }
    });

    if (riwayatTransaksi.isNotEmpty) {
      var last = riwayatTransaksi.first;
      notifWidgets.add(_buildNotifItem(
          "Transaksi Berhasil",
          "Terakhir: ${last['kategori']} (Rp ${formatRupiah(last['nominal'].abs().toDouble(), false)})",
          Icons.check_circle_outline,
          Colors.green
      ));
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text("Notifikasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(child: ListView(children: notifWidgets)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(String title, String desc, IconData icon, Color col) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(backgroundColor: col.withOpacity(0.1), child: Icon(icon, color: col, size: 20)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
  );

  void _showEditLimitDialog(String kategori) {
    TextEditingController _limitController = TextEditingController(text: limitAnggaran[kategori]!.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Atur Limit $kategori"),
        content: TextField(
          controller: _limitController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(prefixText: "Rp ", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () {
              setState(() => limitAnggaran[kategori] = double.tryParse(_limitController.text) ?? 0);
              _saveData();
              _hitungSemuaStatistik();
              Navigator.pop(context);
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  void _keHalamanTambah() async {
    final result = await Navigator.push(context, _createRoute(AddTransactionScreen()));
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        totalSaldo += result['nominal'];

        String tglFix = result['tgl'];
        if (!tglFix.contains("•")) {
          tglFix = "$tglFix • ${DateFormat("HH:mm").format(DateTime.now())}";
        }

        riwayatTransaksi.insert(0, {
          "kategori": result['kategori'],
          "nominal": result['nominal'],
          "catatan": result['catatan'] ?? "",
          "icon_name": result['kategori'],
          "color_value": result['color'].value,
          "tgl": tglFix,
        });
        _hitungSemuaStatistik();
      });
      _saveData();

      _showSuccessTransactionDialog(
          context,
          result['kategori'],
          result['nominal'].toDouble(),
          result['catatan'] ?? ""
      );
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutQuart));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  String formatRupiah(double value, bool allowHide) {
    if (allowHide && _isSaldoHidden) return "••••••••";
    return NumberFormat.decimalPattern('id').format(value);
  }

  IconData _getConstantIcon(String kategori) {
    switch (kategori) {
      case "Makanan": return Icons.fastfood;
      case "Transport": return Icons.directions_car;
      case "Belanja": return Icons.shopping_bag;
      case "Hiburan": return Icons.movie;
      case "Tagihan": return Icons.receipt_long;
      case "Kesehatan": return Icons.medical_services;
      default: return Icons.monetization_on;
    }
  }

  void _showSuccessTransactionDialog(BuildContext context, String kategori, double nominal, String catatan) {
    bool isPengeluaran = nominal < 0;
    Color statusColor = isPengeluaran ? Colors.redAccent : Colors.green;
    String jenisTransaksi = isPengeluaran ? "Pengeluaran" : "Pemasukan";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
                ),
                const SizedBox(height: 20),

                Text(
                  "Catatan Tersimpan!",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor),
                ),
                const SizedBox(height: 6),
                Text(
                  "$jenisTransaksi kamu berhasil ditambahkan",
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${isPengeluaran ? '-' : '+'} Rp ${formatRupiah(nominal.abs(), false)}",
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                      const Divider(height: 20, color: Color(0xFFEBEBEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kategori", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                          Text(kategori, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: darkColor)),
                        ],
                      ),
                      if (catatan.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Catatan", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                            Expanded(
                              child: Text(
                                catatan,
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: darkColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Selesai",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeatureNotAvailableDialog(BuildContext context, String namaFitur) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.construction_rounded, color: primaryColor, size: 45),
                ),
                const SizedBox(height: 20),
                Text("Fitur Belum Tersedia", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 12),
                Text("Fitur '$namaFitur' masih dalam tahap pengembangan di PocketU!", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Oke, Paham", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 40),
                ),
                const SizedBox(height: 20),
                Text("Keluar Akun", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 12),
                Text("Apakah kamu yakin ingin keluar dari PocketU?", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          onPressed: () => Navigator.pop(context),
                          child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                          },
                          child: Text("Keluar", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (textColor == Colors.redAccent) ? Colors.redAccent.withOpacity(0.1) : primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor ?? primaryColor, size: 20),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: textColor ?? darkColor)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            _buildHomeContent(),
            _buildRiwayatFull(),
            _buildAnggaranContent(),
            _buildProfileContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _keHalamanTambah,
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: const Color(0xFFE5E2FF),
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home, color: _currentIndex == 0 ? primaryColor : Colors.grey[600]), onPressed: () => _onTabTapped(0)),
            IconButton(icon: Icon(Icons.history, color: _currentIndex == 1 ? primaryColor : Colors.grey[600]), onPressed: () => _onTabTapped(1)),
            const SizedBox(width: 40),
            IconButton(icon: Icon(Icons.account_balance_wallet, color: _currentIndex == 2 ? primaryColor : Colors.grey[600]), onPressed: () => _onTabTapped(2)),
            IconButton(icon: Icon(Icons.person, color: _currentIndex == 3 ? primaryColor : Colors.grey[600]), onPressed: () => _onTabTapped(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildDashboardHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text("Aksi Cepat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: darkColor)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _quickButton(Icons.add, "Tambah", Colors.blue, onTap: _keHalamanTambah),
                  _quickButton(Icons.bar_chart, "Statistik", Colors.teal, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen(
                      riwayatTransaksi: riwayatTransaksi,
                      terpakaiPerKategori: terpakaiPerKategori,
                      limitAnggaran: limitAnggaran,
                    )));
                  }),
                  _quickButton(Icons.track_changes, "Target", Colors.orange, onTap: () => Navigator.push(context, _createRoute(TargetScreen(currentSaldo: totalSaldo)))),
                  _quickButton(Icons.description, "Laporan", Colors.red, onTap: () => _showFeatureNotAvailableDialog(context, "Laporan Finansial")),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Transaksi Terbaru", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: darkColor)),
                  if (riwayatTransaksi.length > 4)
                    TextButton(onPressed: () => _onTabTapped(1), child: Text("Lihat Semua", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w600))),
                ],
              ),
              riwayatTransaksi.isEmpty
                  ? Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text("Belum ada transaksi", style: GoogleFonts.poppins(color: Colors.grey))))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayatTransaksi.length > 4 ? 4 : riwayatTransaksi.length,
                itemBuilder: (context, index) => _itemTransaksi(riwayatTransaksi[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardHeader() {
    int notifCount = _getNotifCount();
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, const Color(0xFF8A84FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Selamat pagi 👋", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)), Text("Halo, ${widget.userName}!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
              GestureDetector(
                onTap: _showNotifications,
                child: Stack(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    if (notifCount > 0)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('$notifCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Total Saldo Anda", style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)), const SizedBox(width: 8), GestureDetector(onTap: () { setState(() => _isSaldoHidden = !_isSaldoHidden); _saveData(); }, child: Icon(_isSaldoHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white, size: 18))]),
                const SizedBox(height: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(_isSaldoHidden),
                    children: [
                      Text("Rp ${formatRupiah(totalSaldo, true)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildMiniStatPlain("Pemasukan", pemasukanBulanIni, Icons.arrow_downward, Colors.greenAccent),
                          Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2)),
                          _buildMiniStatPlain("Pengeluaran", pengeluaranBulanIni, Icons.arrow_upward, Colors.redAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStatPlain(String label, double value, IconData icon, Color color) => Expanded(child: Row(children: [const SizedBox(width: 5), Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)), Text("Rp ${formatRupiah(value, true)}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)]))]));

  Widget _itemTransaksi(Map<String, dynamic> item) {
    bool isMinus = item['nominal'] < 0;
    String tglTampil = item['tgl'];

    if (!tglTampil.contains("•")) {
      tglTampil = "$tglTampil • ${DateFormat("HH:mm").format(DateTime.now())}";
    }

    IconData kategoriIcon = _getConstantIcon(item['kategori']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          leading: CircleAvatar(
              backgroundColor: Color(item['color_value']).withOpacity(0.1),
              child: Icon(kategoriIcon, color: Color(item['color_value']), size: 18)
          ),
          title: Text(item['kategori'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: darkColor)),
          subtitle: Text(tglTampil, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11)),
          trailing: Text("${isMinus ? '-' : '+'}Rp ${formatRupiah(item['nominal'].abs().toDouble(), false)}", style: GoogleFonts.poppins(color: isMinus ? Colors.redAccent : Colors.green, fontWeight: FontWeight.bold, fontSize: 14))
      ),
    );
  }

  Widget _quickButton(IconData icon, String label, Color color, {VoidCallback? onTap}) => GestureDetector(
      onTap: onTap,
      child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
                ),
                child: Icon(icon, color: color, size: 22)
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: darkColor))
          ]
      )
  );

  Widget _buildRiwayatFull() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Semua Riwayat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: riwayatTransaksi.isEmpty
          ? Center(child: Text("Belum ada riwayat transaksi", style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: riwayatTransaksi.length,
        itemBuilder: (context, index) => _itemTransaksi(riwayatTransaksi[index]),
      ),
    );
  }

  Widget _buildAnggaranContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Batas Anggaran", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: limitAnggaran.keys.map((kategori) {
          double limit = limitAnggaran[kategori] ?? 0;
          double spent = terpakaiPerKategori[kategori] ?? 0;
          double progress = limit > 0 ? (spent / limit) : 0;
          if (progress > 1.0) progress = 1.0;

          IconData iconData = _getConstantIcon(kategori);

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(iconData, color: primaryColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(kategori, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: darkColor)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onPressed: () => _showEditLimitDialog(kategori),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: progress >= 0.9 ? Colors.redAccent : primaryColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Terpakai: Rp ${formatRupiah(spent, false)}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                    Text("Limit: Rp ${formatRupiah(limit, false)}", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: darkColor)),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Profil Saya", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          const SizedBox(height: 10),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "U",
                    style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.stars, color: Colors.orange[400], size: 22),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(child: Text(widget.userName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: darkColor))),
          Center(child: Text("Siswa Kelas 1 SD • Pengguna Pintar", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))),
          const SizedBox(height: 35),

          Text("Pengaturan Game Finansial", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildProfileMenu(Icons.person_outline, "Ubah Nama Karakter", () => _showFeatureNotAvailableDialog(context, "Ubah Nama")),
          _buildProfileMenu(Icons.palette_outlined, "Tema Warna Aplikasi", () => _showFeatureNotAvailableDialog(context, "Kustomisasi Tema")),
          _buildProfileMenu(Icons.volume_up_outlined, "Efek Suara & Musik", () => _showFeatureNotAvailableDialog(context, "Suara & Musik")),

          const SizedBox(height: 20),
          Text("Akun", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _buildProfileMenu(Icons.logout_rounded, "Keluar Aplikasi", () => _showLogoutDialog(context), textColor: Colors.redAccent),
        ],
      ),
    );
  }
}