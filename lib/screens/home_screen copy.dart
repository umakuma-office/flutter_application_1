import 'package:flutter/material.dart';
// import '../services/database_helper.dart';
// import '../widgets/item_card.dart';
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
          // Expanded(
          //   child: FutureBuilder<List<Map<String, dynamic>>>(
          //     future: DatabaseHelper.instance.getAllItems(),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return Center(child: CircularProgressIndicator());
          //       }
          //       return ListView.builder(
          //         itemCount: snapshot.data!.length,
          //         itemBuilder: (context, index) {
          //           return ItemCard(item: snapshot.data![index]);
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => AddItemScreen()),
      //   ),
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
