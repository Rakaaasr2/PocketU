class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String time;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.time,
    this.note,
  });
}

// Sample data
List<TransactionModel> sampleTransactions = [
  TransactionModel(
    id: '1',
    title: 'Makan Siang',
    category: 'Makanan',
    amount: 25000,
    isExpense: true,
    date: DateTime(2026, 5, 15),
    time: '12:30 WIB',
    note: 'Makan siang di wartegg, dapat nasi + ayam + es teh.',
  ),
  TransactionModel(
    id: '2',
    title: 'Kopi Kampus',
    category: 'Minuman',
    amount: 15000,
    isExpense: true,
    date: DateTime(2026, 5, 15),
    time: '09:00 WIB',
    note: 'Kopi pagi sebelum kuliah.',
  ),
  TransactionModel(
    id: '3',
    title: 'Uang Saku',
    category: 'Pemasukan',
    amount: 500000,
    isExpense: false,
    date: DateTime(2026, 5, 14),
    time: '08:00 WIB',
    note: 'Transfer dari orang tua.',
  ),
  TransactionModel(
    id: '4',
    title: 'Angkot ke Kampus',
    category: 'Transportasi',
    amount: 5000,
    isExpense: true,
    date: DateTime(2026, 5, 14),
    time: '07:30 WIB',
    note: null,
  ),
];
