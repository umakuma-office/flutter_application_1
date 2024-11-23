import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_state.dart';
import '../widgets/monthly_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
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
        onPressed: () {
          // AddItemScreenを開くフラグを立てる
          context.read<NavigationState>().setShouldOpenAddItem(true);
          // PremiumScreen に切り替え
          context.read<NavigationState>().setIndex(1);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
