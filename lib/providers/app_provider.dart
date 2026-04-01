import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/user.dart'; // Pastikan model User lama masih ada atau hapus jika tidak dipakai

class AppProvider extends ChangeNotifier {
  // Data User (Kita pakai data statis dulu untuk saldo, nama diambil dari UserProfileProvider)
  double _balance = 1000000; 
  
  List<Transaction> _transactions = [
    Transaction(title: 'Motor', amount: 19000000, isIncome: false, date: DateTime.now()),
    Transaction(title: 'Gaji', amount: 19000000, isIncome: true, date: DateTime.now()),
    Transaction(title: 'Makan Siang', amount: 50000, isIncome: false, date: DateTime.now()),
  ];

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  
  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalSpending => _transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  // --- PERBAIKAN DI SINI ---
  // Ubah metode ini agar menerima parameter named langsung
  void addTransaction({
    required String title,
    required double amount,
    required bool isIncome,
    required DateTime date,
  }) {
    // Buat objek Transaction di dalam sini
    final newTransaction = Transaction(
      title: title,
      amount: amount,
      isIncome: isIncome,
      date: date,
    );

    _transactions.insert(0, newTransaction); // Tambah ke paling atas list

    // Update Saldo
    if (isIncome) {
      _balance += amount;
    } else {
      _balance -= amount;
    }

    notifyListeners(); // Beritahu UI untuk refresh
  }
}