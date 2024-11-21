import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_helper.dart';
//import '../models/periodic_item.dart';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  final Function? onItemAdded; // コールバック関数を追加
  const AddItemScreen({super.key, this.onItemAdded});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _periodController = TextEditingController();
  final _memoController = TextEditingController();

  DateTime _lastPurchaseDate = DateTime.now();
  String _selectedCategoryId = '1'; // デフォルトカテゴリー

  // カテゴリーの選択肢（実際はDBから取得）
  final List<Map<String, String>> _categories = [
    {'id': '1', 'name': '食品'},
    {'id': '2', 'name': '日用品'},
    {'id': '3', 'name': '衣類'},
    {'id': '4', 'name': '趣味'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規アイテム登録'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品名入力
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '商品名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '商品名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 価格入力
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '価格',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_yen),
                  suffixText: '円',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '価格を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 購入周期入力
              TextFormField(
                controller: _periodController,
                decoration: const InputDecoration(
                  labelText: '購入周期',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixText: '日',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '購入周期を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // カテゴリー選択
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'カテゴリー',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['id'],
                    child: Text(category['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 最終購入日選択
              ListTile(
                title: const Text('最終購入日'),
                subtitle: Text(
                  DateFormat('yyyy年MM月dd日').format(_lastPurchaseDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _lastPurchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _lastPurchaseDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // メモ入力
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 保存ボタンが押されたときの処理
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // フォームデータを準備
      final newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'period_days': int.parse(_periodController.text),
        'last_purchase_date': _lastPurchaseDate.toIso8601String(),
        'category_id': _selectedCategoryId,
        'memo': _memoController.text,
      };

      try {
        // データベースに保存
        final success = await DatabaseHelper.instance.addItem(newItem);
        if (success) {
          if (mounted) {
            // 保存成功時にコールバックを実行
            widget.onItemAdded?.call();

            // 成功メッセージを表示して前の画面に戻る
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('アイテムを追加しました')),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('アイテムの追加に失敗しました')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('エラーが発生しました')),
          );
        }
        print('Error saving item: $e');
      }
    }
  }
  // // アイテムを保存
  // void _saveItem() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final item = {
  //         'id': DateTime.now().millisecondsSinceEpoch.toString(),
  //         'name': _nameController.text,
  //         'price': double.parse(_priceController.text),
  //         'period_days': int.parse(_periodController.text),
  //         'last_purchase_date': _lastPurchaseDate.toIso8601String(),
  //         'category_id': _selectedCategoryId,
  //         'memo': _memoController.text,
  //       };

  //       await DatabaseHelper.instance.insertItem(item);

  //       // 成功メッセージを表示
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('商品を登録しました'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );

  //       // 前の画面に戻る
  //       Navigator.pop(context);
  //     } catch (e) {
  //       // エラーメッセージを表示
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('エラーが発生しました'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _periodController.dispose();
    _memoController.dispose();
    super.dispose();
  }
}
