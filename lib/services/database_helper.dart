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
      version: 2, // バージョンを2に更新
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        memo TEXT,
        position INTEGER
      )
    ''');
  }

  // データベースのアップグレード処理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // position列を追加
      await db
          .execute('ALTER TABLE periodic_items ADD COLUMN position INTEGER');

      // 既存のデータに対して位置情報を設定
      final items = await db.query('periodic_items', orderBy: 'id ASC');
      for (int i = 0; i < items.length; i++) {
        await db.update(
          'periodic_items',
          {'position': i},
          where: 'id = ?',
          whereArgs: [items[i]['id']],
        );
      }
    }
  }

  // 次の利用可能なposition値を取得
  Future<int> getNextPosition() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT MAX(position) as maxPos FROM periodic_items');
    return (result.first['maxPos'] as int? ?? -1) + 1;
  }

  // 全アイテムの取得（位置でソート）
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    try {
      return await db.query('periodic_items', orderBy: 'position ASC');
    } catch (e) {
      print('Error getting all items: $e');
      rethrow;
    }
  }

  // アイテムの位置を更新
  Future<void> updateItemPosition(String id, int position) async {
    final db = await database;
    try {
      await db.update(
        'periodic_items',
        {'position': position},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating item position: $e');
      rethrow;
    }
  }

  // アイテム追加の改善版（位置情報を含む）
  Future<bool> addItem(Map<String, dynamic> item) async {
    final db = await database;

    try {
      if (!_validateItemData(item)) {
        throw Exception('Invalid item data format');
      }

      final itemToInsert = Map<String, dynamic>.from(item);
      if (!itemToInsert.containsKey('id') || itemToInsert['id'] == null) {
        itemToInsert['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // 位置情報が指定されていない場合は最後に追加
      if (!itemToInsert.containsKey('position') ||
          itemToInsert['position'] == null) {
        itemToInsert['position'] = await getNextPosition();
      }

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

  // 複数アイテムの位置を一括更新
  Future<void> updatePositions(List<Map<String, dynamic>> items) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in items) {
        await txn.update(
          'periodic_items',
          {'position': items.indexOf(item)},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    });
  }

  // 既存のメソッドはそのまま維持
  bool _validateItemData(Map<String, dynamic> item) {
    // 元のバリデーション
    if (item.containsKey('price')) {
      final price = item['price'];
      if (price != null && price is! num) return false;
    }

    if (item.containsKey('period_days')) {
      final periodDays = item['period_days'];
      if (periodDays != null && periodDays is! int) return false;
    }

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

    // position のバリデーションを追加
    if (item.containsKey('position')) {
      final position = item['position'];
      if (position != null && position is! int) return false;
    }

    return true;
  }

  // その他の既存メソッドはそのまま維持
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

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
