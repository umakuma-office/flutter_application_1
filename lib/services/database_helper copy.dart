import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'periodic_items.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE periodic_items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        period_days INTEGER NOT NULL,
        last_purchase_date TEXT NOT NULL,
        category_id TEXT,
        memo TEXT
      )
    ''');
  }

  // 全アイテムの取得
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    try {
      return await db.query('periodic_items');
    } catch (e) {
      print('Error getting all items: $e');
      rethrow;
    }
  }

  // アイテムの挿入
  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    try {
      await db.insert(
        'periodic_items',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting item: $e');
      rethrow;
    }
  }

  // アイテム追加の改善版
  Future<bool> addItem(Map<String, dynamic> item) async {
    final db = await database;

    try {
      // 入力データの検証
      if (!_validateItemData(item)) {
        throw Exception('Invalid item data format');
      }

      // IDが提供されていない場合は新しいUUIDを生成
      final itemToInsert = Map<String, dynamic>.from(item);
      if (!itemToInsert.containsKey('id') || itemToInsert['id'] == null) {
        itemToInsert['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // 必須フィールドの存在確認
      final requiredFields = [
        'name',
        'price',
        'period_days',
        'last_purchase_date'
      ];
      for (var field in requiredFields) {
        if (!itemToInsert.containsKey(field) || itemToInsert[field] == null) {
          throw Exception('Missing required field: $field');
        }
      }

      // データの挿入
      await db.insert(
        'periodic_items',
        itemToInsert,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return true;
    } catch (e) {
      print('Error in addItem: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // データ検証用のヘルパーメソッド - Null Safetyに対応
  bool _validateItemData(Map<String, dynamic> item) {
    // 価格が数値であることを確認
    if (item.containsKey('price')) {
      final price = item['price'];
      if (price != null && price is! num) return false;
    }

    // period_daysが整数であることを確認
    if (item.containsKey('period_days')) {
      final periodDays = item['period_days'];
      if (periodDays != null && periodDays is! int) return false;
    }

    // last_purchase_dateが有効な日付文字列であることを確認
    if (item.containsKey('last_purchase_date')) {
      final lastPurchaseDate = item['last_purchase_date'];
      if (lastPurchaseDate != null) {
        try {
          DateTime.parse(lastPurchaseDate);
        } catch (_) {
          return false;
        }
      }
    }

    return true;
  }

  // Future<void> addItem(Map<String, dynamic> item) async {
  //   try {
  //     final db = await database;

  //     // 入力データの確認
  //     print('Original item: $item');

  //     final itemWithoutId = Map<String, dynamic>.from(item)..remove('id');
  //     print('Processed item for insertion: $itemWithoutId');

  //     // テーブル存在確認
  //     final tables = await db.query('sqlite_master',
  //         where: 'type = ? AND name = ?', whereArgs: ['table', 'items']);
  //     print('Table exists: ${tables.isNotEmpty}');

  //     // if (tables.isEmpty) {
  //     //   print('Creating table...');
  //     //   await _onCreate(db, 1);
  //     // }

  //     await db.insert(
  //       'periodic_items',
  //       item,
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //     //final result = await db.insert('items', itemWithoutId);
  //     // print('Insert result: $result');
  //     // return result;
  //   } catch (e) {
  //     print('Error in addItem: $e');
  //     print('Stack trace: ${StackTrace.current}');
  //     rethrow;
  //   }
  // }

  // // アイテム追加
  // Future<void> addItem(Map<String, dynamic> item) async {
  //   final db = await database; // instance.database ではなく database を使用

  //   try {
  //     await db.insert(
  //       'periodic_items',
  //       item,
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   } catch (e) {
  //     print('Error inserting item: $e');
  //     rethrow;
  //   }
  //   // idを削除して新規追加（新しいidが自動生成される）
  //   //final itemWithoutId = Map<String, dynamic>.from(item)..remove('id');
  //   //return await db.insert('items', itemWithoutId);
  // }

  // // アイテム追加
  // Future<int> addItem(Map<String, dynamic> item) async {
  //   final db = await database; // instance.database ではなく database を使用

  //   try {
  //     await db.insert(
  //       'periodic_items',
  //       item,
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   } catch (e) {
  //     print('Error inserting item: $e');
  //     rethrow;
  //   }
  //   // idを削除して新規追加（新しいidが自動生成される）
  //   final itemWithoutId = Map<String, dynamic>.from(item)..remove('id');
  //   //return await db.insert('items', itemWithoutId);
  // }

  // 追加：アイテムの更新
  Future<void> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    try {
      await db.update(
        'periodic_items',
        item,
        where: 'id = ?',
        whereArgs: [item['id']],
      );
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  // 追加：アイテムの削除
  Future<void> deleteItem(String id) async {
    final db = await database;
    try {
      await db.delete(
        'periodic_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  // 追加：特定のアイテムを取得
  Future<Map<String, dynamic>?> getItem(String id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'periodic_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) {
        return null;
      }
      return results.first;
    } catch (e) {
      print('Error getting item: $e');
      rethrow;
    }
  }

  // データベースのクローズ
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
