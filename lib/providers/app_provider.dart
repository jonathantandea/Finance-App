import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class AppProvider extends ChangeNotifier {
  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  // Getters
  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalSpending => _transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  // --- FUNGSI LOAD DATA (Dipanggil saat awal) ---
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Load Saldo
    _balance = prefs.getDouble('user_balance') ?? 0;

    // 2. Load Transaksi
    String? transactionsString = prefs.getString('user_transactions');
    if (transactionsString != null) {
      List<dynamic> decodedList = json.decode(transactionsString);
      _transactions = decodedList.map((item) {
        return Transaction(
          title: item['title'],
          amount: (item['amount'] as num).toDouble(),
          isIncome: item['isIncome'],
          date: DateTime.parse(item['date']),
        );
      }).toList();
    } else {
      // Data Dummy jika pertama kali install
      _transactions = [
        Transaction(title: 'Gaji Bulanan', amount: 19000000, isIncome: true, date: DateTime.now().subtract(const Duration(days: 2))),
        Transaction(title: 'Beli Motor', amount: 19000000, isIncome: false, date: DateTime.now().subtract(const Duration(days: 1))),
      ];
      _balance = 1000000; // Saldo awal dummy
      await _saveData(); // Simpan dummy data
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- FUNGSI SIMPAN DATA (Internal) ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_balance', _balance);
    
    List<Map<String, dynamic>> transactionsMap = _transactions.map((t) => {
      'title': t.title,
      'amount': t.amount,
      'isIncome': t.isIncome,
      'date': t.date.toIso8601String(),
    }).toList();
    
    await prefs.setString('user_transactions', json.encode(transactionsMap));
  }

  // --- FUNGSI TAMBAH TRANSAKSI ---
  Future<void> addTransaction({
    required String title,
    required double amount,
    required bool isIncome,
    required DateTime date,
  }) async {
    final newTransaction = Transaction(title: title, amount: amount, isIncome: isIncome, date: date);
    _transactions.insert(0, newTransaction);

    if (isIncome) {
      _balance += amount;
    } else {
      _balance -= amount;
    }

    await _saveData(); // Simpan ke lokal
    notifyListeners();
  }

  // --- FUNGSI HAPUS TRANSAKSI ---
  Future<void> deleteTransaction(int index) async {
    if (index >= 0 && index < _transactions.length) {
      final removed = _transactions[index];
      _transactions.removeAt(index);

      // Reverse saldo
      if (removed.isIncome) {
        _balance -= removed.amount;
      } else {
        _balance += removed.amount;
      }

      await _saveData(); // Update lokal (data terhapus permanen)
      notifyListeners();
    }
  }
}