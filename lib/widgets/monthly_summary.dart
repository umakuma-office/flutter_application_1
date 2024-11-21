import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/periodic_item.dart';
import 'package:intl/intl.dart';

class MonthlySummary extends StatelessWidget {
  MonthlySummary({super.key}); // keyパラメータを追加

  // 通貨フォーマット（日本円用）
  final formatCurrency = NumberFormat.currency(
    locale: 'ja_JP',
    symbol: '¥',
    decimalDigits: 0,
  );

  // 月間予測支出を計算
  Future<double> _calculateMonthlyExpense() async {
    final items = await DatabaseHelper.instance.getAllItems();
    double total = 0;

    for (var item in items) {
      final periodicItem = PeriodicItem.fromMap(item);
      // 月間換算（30日として計算）
      total += (periodicItem.price * 30) / periodicItem.periodDays;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の予測支出',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<double>(
              future: _calculateMonthlyExpense(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency.format(snapshot.data),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryBreakdown(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // カテゴリー別の内訳を表示
  Widget _buildCategoryBreakdown() {
    return FutureBuilder<Map<String, double>>(
      future: _getCategoryExpenses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリー別内訳',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ...snapshot.data!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      formatCurrency.format(entry.value),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // カテゴリー別支出を計算
  Future<Map<String, double>> _getCategoryExpenses() async {
    final items = await DatabaseHelper.instance.getAllItems();
    Map<String, double> categoryExpenses = {};

    for (var item in items) {
      final periodicItem = PeriodicItem.fromMap(item);
      final monthlyAmount = (periodicItem.price * 30) / periodicItem.periodDays;
      final category = periodicItem.categoryId; // カテゴリー名を取得

      categoryExpenses.update(
        category,
        (value) => value + monthlyAmount,
        ifAbsent: () => monthlyAmount,
      );
    }

    return categoryExpenses;
  }
}

// アニメーションありの進捗バーを追加する場合
class CategoryProgressBar extends StatelessWidget {
  final String category;
  final double amount;
  final double totalAmount;
  final Color color;

  const CategoryProgressBar({
    super.key,
    required this.category,
    required this.amount,
    required this.totalAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (amount / totalAmount).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category),
            Text('${(percentage * 100).toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
