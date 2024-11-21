import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_state.dart';
import '../widgets/monthly_summary.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

Future<void> _handleAddItem(BuildContext context) async {
  final navigationState = context.read<NavigationState>();

  // 遷移中フラグを設定
  navigationState.setTransitioning(true);

  // フラグを設定してPremiumScreenに切り替え
  navigationState.setShouldOpenAddItem(true);
  navigationState.setIndex(1);

  // 極短い遅延
  await Future.delayed(const Duration(milliseconds: 16));

  if (!context.mounted) return;

  // AddItemScreenを開く前にフラグをリセット
  navigationState.setTransitioning(false); // ここを追加

  // AddItemScreenを開く
  await Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddItemScreen(
        onItemAdded: () {
          // 必要な更新処理
        },
      ),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );

  // 遷移終了後にフラグをリセット
  if (!context.mounted) return;
  navigationState.setTransitioning(false);
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perio->Do Buy'),
      ),
      body: Column(
        children: [
          MonthlySummary(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddItem(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
