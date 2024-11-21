import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditItemScreen({super.key, required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _periodController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    // コントローラーの初期化と初期値の設定
    _nameController = TextEditingController(text: widget.item['name']);
    _priceController =
        TextEditingController(text: widget.item['price'].toString());
    _periodController =
        TextEditingController(text: widget.item['period_days'].toString());
    _memoController = TextEditingController(text: widget.item['memo'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _periodController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アイテムの編集'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // 削除ボタン
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 商品名
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '商品名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 価格
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '価格',
                border: OutlineInputBorder(),
                suffixText: '円',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 周期
            TextField(
              controller: _periodController,
              decoration: const InputDecoration(
                labelText: '購入周期',
                border: OutlineInputBorder(),
                suffixText: '日',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // メモ
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 更新ボタン
            ElevatedButton(
              onPressed: _updateItem,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }

  // アイテムの更新
  void _updateItem() async {
    try {
      final updatedItem = {
        'id': widget.item['id'],
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'period_days': int.parse(_periodController.text),
        'memo': _memoController.text,
      };

      await DatabaseHelper.instance.updateItem(updatedItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新しました')),
      );

      Navigator.pop(context, true); // 更新成功を通知
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エラーが発生しました')),
      );
    }
  }

  // 削除確認ダイアログ
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('このアイテムを削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () => _deleteItem(context),
            ),
          ],
        );
      },
    );
  }

  // アイテムの削除
  void _deleteItem(BuildContext context) async {
    try {
      await DatabaseHelper.instance.deleteItem(widget.item['id']);
      Navigator.of(context).pop(); // ダイアログを閉じる
      Navigator.of(context).pop(true); // 編集画面を閉じる
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エラーが発生しました')),
      );
    }
  }
}
