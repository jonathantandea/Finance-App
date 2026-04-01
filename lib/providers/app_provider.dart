import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class AppProvider extends ChangeNotifier {
  double _balance = 0; // Mulai dari 0, jangan di-hardcode 1 juta
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalSpending => _transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

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
      // HANYA JIKA BENAR-BENAR KOSONG PERTAMA KALI, buat data dummy
      // Setelah user hapus semua, ini tidak akan muncul lagi karena key 'user_transactions' sudah pernah dibuat
      _transactions = [
        Transaction(title: 'Selamat Datang!', amount: 1000000, isIncome: true, date: DateTime.now()),
      ];
      _balance = 1000000;
      await _saveData(); // Langsung simpan data dummy ini agar next load tidak masuk sini lagi
    }

    _isLoading = false;
    notifyListeners();
  }

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

  Future<void> addTransaction({required String title, required double amount, required bool isIncome, required DateTime date}) async {
    final newTransaction = Transaction(title: title, amount: amount, isIncome: isIncome, date: date);
    _transactions.insert(0, newTransaction);

    if (isIncome) _balance += amount; else _balance -= amount;

    await _saveData();
    notifyListeners();
  }

  Future<void> deleteTransaction(int index) async {
    if (index >= 0 && index < _transactions.length) {
      final removed = _transactions[index];
      _transactions.removeAt(index);

      if (removed.isIncome) _balance -= removed.amount; else _balance += removed.amount;

      await _saveData();
      notifyListeners();
    }
  }
}