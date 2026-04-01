import '../utils/constants.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;

  Transaction({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  String get displayAmount {
    String formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
    return '${isIncome ? '+' : '-'}Rp.$formatted';
  }

  Color get amountColor => isIncome ? AppColors.incomeGreen : AppColors.spendingRed;
}