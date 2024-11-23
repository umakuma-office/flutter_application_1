import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import '../services/database_helper.dart';
import '../widgets/item_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

// 削除されたアイテムの情報を保持する構造体
class DeletedItemInfo {
  final Map<String, dynamic> item;
  final int position;

  DeletedItemInfo(this.item, this.position);
}

class _PremiumScreenState extends State<PremiumScreen> {
  DeletedItemInfo? _lastDeletedItemInfo;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DatabaseHelper.instance.getAllItems();
      if (!mounted) return;

      setState(() {
        _items = List<Map<String, dynamic>>.from(items);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('データの読み込みに失敗しました')),
      );
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item, int index) async {
    // 削除前のアイテムと位置を保存
    final deletedItem = Map<String, dynamic>.from(item);
    _lastDeletedItemInfo = DeletedItemInfo(deletedItem, index);

    setState(() {
      final newItems = List<Map<String, dynamic>>.from(_items);
      newItems.removeAt(index);
      _items = newItems;
    });

    try {
      await DatabaseHelper.instance.deleteItem(item['id']);
      _showUndoSnackBar(context);
    } catch (e) {
      print('Error deleting item: $e');

      // 削除に失敗した場合、UIを元に戻す
      setState(() {
        final newItems = List<Map<String, dynamic>>.from(_items);
        newItems.insert(index, deletedItem);
        _items = newItems;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除に失敗しました')),
        );
      }
    }
  }

  void _showUndoSnackBar(BuildContext context) {
    if (_lastDeletedItemInfo == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('アイテムを削除しました'),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () async {
            try {
              final success = await DatabaseHelper.instance
                  .addItem(_lastDeletedItemInfo!.item);
              if (success) {
                // 元の位置に復元
                setState(() {
                  final newItems = List<Map<String, dynamic>>.from(_items);
                  // リストの長さをチェックして、適切な位置に挿入
                  final insertIndex =
                      _lastDeletedItemInfo!.position < newItems.length
                          ? _lastDeletedItemInfo!.position
                          : newItems.length;
                  newItems.insert(insertIndex, _lastDeletedItemInfo!.item);
                  _items = newItems;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('アイテムを復元しました')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('アイテムの復元に失敗しました')),
                  );
                }
              }
            } catch (e) {
              print('Error restoring item: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('エラーが発生しました')),
                );
              }
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品リスト'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _items.isEmpty
                      ? const Center(child: Text('アイテムがありません'))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Dismissible(
                              key: Key(item['id'].toString()),
                              background: Container(
                                color: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (direction) {
                                _deleteItem(item, index);
                              },
                              child: ItemCard(item: item),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(
                onItemAdded: () {
                  _loadItems();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
