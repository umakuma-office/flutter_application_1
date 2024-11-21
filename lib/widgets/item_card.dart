import 'package:flutter/material.dart';
import '../models/periodic_item.dart';
import '../screens/edit_item_screen.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final periodicItem = PeriodicItem.fromMap(item);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(periodicItem.name),
        subtitle: Text('¥${periodicItem.price}'),
        trailing: Text('${periodicItem.periodDays}日周期'),
        onTap: () => _editItem(context, periodicItem),
      ),
    );
  }

  void _editItem(BuildContext context, PeriodicItem periodicItem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: periodicItem.toMap()),
      ),
    );

    // 更新または削除が行われた場合、親ウィジェットを更新
    if (result == true) {
      // HomeScreenのFutureBuilderが自動的に再構築される
    }
  }
}
