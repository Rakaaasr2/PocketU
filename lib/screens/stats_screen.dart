import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:ui' as ui;

class StatsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> riwayatTransaksi;
  final Map<String, double> limitAnggaran;
  final Map<String, double> terpakaiPerKategori;

  StatsScreen({
    required this.riwayatTransaksi,
    required this.limitAnggaran,
    required this.terpakaiPerKategori,
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedFilter = "Bulan Ini";
  Map<String, double> _filteredData = {};
  double _totalFiltered = 0;

  final Map<String, Color> warnaKategori = {
    "Makanan": const Color(0xFF2196F3),
    "Belanja": const Color(0xFF9C27B0),
    "Hiburan": const Color(0xFF009688),
    "Tagihan": const Color(0xFFF44336),
    "Transport": Colors.orange,
    "Kesehatan": Colors.pink,
  };

  final Map<String, IconData> iconAnggaran = {
    "Makanan": Icons.fastfood,
    "Transport": Icons.directions_car,
    "Belanja": Icons.shopping_bag,
    "Hiburan": Icons.movie,
    "Tagihan": Icons.receipt_long,
    "Kesehatan": Icons.medical_services,
  };

  @override
  void initState() {
    super.initState();
    _filterData();
  }

  void _filterData() {
    Map<String, double> tempMap = {for (var k in widget.limitAnggaran.keys) k: 0.0};
    double total = 0;
    DateTime now = DateTime.now();
    DateFormat inputFormat = DateFormat("dd MMM yyyy");

    for (var item in widget.riwayatTransaksi) {
      try {
        DateTime tglTx = inputFormat.parse(item['tgl']);
        bool isIncluded = false;

        if (_selectedFilter == "Bulan Ini") {
          if (tglTx.month == now.month && tglTx.year == now.year) isIncluded = true;
        } else if (_selectedFilter == "1 Bulan Lalu") {
          DateTime lastM = DateTime(now.year, now.month - 1);
          if (tglTx.month == lastM.month && tglTx.year == lastM.year) isIncluded = true;
        } else if (_selectedFilter == "3 Bulan Lalu") {
          DateTime startRange = DateTime(now.year, now.month - 3, 1);
          DateTime endRange = DateTime(now.year, now.month, 0);
          if (tglTx.isAfter(startRange.subtract(const Duration(days: 1))) &&
              tglTx.isBefore(endRange.add(const Duration(days: 1)))) isIncluded = true;
        } else if (_selectedFilter == "1 Tahun Lalu") {
          if (tglTx.year == 2025) isIncluded = true;
        }

        if (isIncluded) {
          double nominal = item['nominal'].toDouble();
          if (nominal < 0) {
            tempMap[item['kategori']] = (tempMap[item['kategori']] ?? 0) + nominal.abs();
            total += nominal.abs();
          }
        }
      } catch (e) { /* skip */ }
    }
    setState(() { _filteredData = tempMap; _totalFiltered = total; });
  }

  String _getDateRangeLabel(String filter) {
    DateTime now = DateTime.now();
    if (filter == "Bulan Ini") return DateFormat('MMMM yyyy').format(now);
    if (filter == "1 Bulan Lalu") return DateFormat('MMMM yyyy').format(DateTime(now.year, now.month - 1));
    if (filter == "3 Bulan Lalu") return "Feb 2026 - Apr 2026";
    if (filter == "1 Tahun Lalu") return "Jan - Des 2025";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    // BUNGKUS DENGAN CONTAINER GRADASI DI SINI
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F2FF), Color(0xFFEDECFF), Color(0xFFE5E2FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        // UBAH JADI TRANSPARAN BIAR GRADASI TEMBUS KELUAR
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Analisis Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0, centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, left: 25, right: 25),
              decoration: const BoxDecoration(color: Color(0xFF6C63FF), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    dropdownColor: const Color(0xFF6C63FF),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    isExpanded: true,
                    items: ["Bulan Ini", "1 Bulan Lalu", "3 Bulan Lalu", "1 Tahun Lalu"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(_getDateRangeLabel(value), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) { setState(() { _selectedFilter = v!; _filterData(); }); },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const Text("Proporsi Kategori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 340, width: 340,
                            child: CustomPaint(
                              painter: FinalPiePainter(_filteredData, _totalFiltered, widget.limitAnggaran.keys.toList(), iconAnggaran, warnaKategori),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Total Pengeluaran", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text("Rp ${NumberFormat.decimalPattern('id').format(_totalFiltered)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(alignment: Alignment.centerLeft, child: const Text("Detail Kategori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      // WARNA BACKGROUND KARTU TETAP PUTIH SOLID DAN BERSIH DI ATAS GRADASI
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]),
                      child: Column(
                        children: widget.limitAnggaran.keys.map((kat) {
                          double val = _filteredData[kat] ?? 0;
                          if (val == 0) return const SizedBox();
                          double p = (_totalFiltered > 0) ? (val / _totalFiltered) * 100 : 0;
                          return ListTile(
                            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (warnaKategori[kat] ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(iconAnggaran[kat], color: warnaKategori[kat], size: 20)),
                            title: Text(kat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Rp ${NumberFormat.decimalPattern('id').format(val)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text("${p.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinalPiePainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final List<String> allKeys;
  final Map<String, IconData> icons;
  final Map<String, Color> categoryColors;

  FinalPiePainter(this.data, this.total, this.allKeys, this.icons, this.categoryColors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 100.0;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 45..strokeCap = StrokeCap.butt;

    if (total == 0) return;

    double startAngle = -pi / 2;
    for (String key in allKeys) {
      double value = data[key] ?? 0;
      if (value > 0) {
        double sweepAngle = (value / total) * 2 * pi;
        paint.color = categoryColors[key] ?? Colors.grey;
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
        double labelAngle = startAngle + (sweepAngle / 2);
        int pVal = (value / total * 100).toInt();

        if (pVal > 5) {
          _drawText(canvas, center.dx + radius * cos(labelAngle), center.dy + radius * sin(labelAngle), "$pVal%", Colors.white, 10);
        }

        double outerRadius = radius + 42;
        _drawIconOuter(canvas, center.dx + outerRadius * cos(labelAngle), center.dy + outerRadius * sin(labelAngle), icons[key]!, pVal, paint.color);

        startAngle += sweepAngle;
      }
    }
  }

  void _drawText(Canvas canvas, double x, double y, String text, Color color, double size) {
    TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold)), textDirection: ui.TextDirection.ltr)..layout()..paint(canvas, Offset(x - 12, y - 6));
  }

  void _drawIconOuter(Canvas canvas, double x, double y, IconData icon, int p, Color color) {
    TextPainter(text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: 20, fontFamily: icon.fontFamily, package: icon.fontPackage, color: color)), textDirection: ui.TextDirection.ltr)..layout()..paint(canvas, Offset(x - 10, y - 15));
    TextPainter(text: TextSpan(text: "$p%", style: const TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.bold)), textDirection: ui.TextDirection.ltr)..layout()..paint(canvas, Offset(x - 8, y + 6));
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}