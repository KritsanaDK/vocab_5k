import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider with ChangeNotifier {
  Database? _db;

  Future<void> openDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quiz_results.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE results (
            id TEXT PRIMARY KEY,
            right INTEGER,
            wrong INTEGER
          )
        ''');

        await db.execute('''
        CREATE TABLE config (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      },
    );
  }

  Future<void> insertOrUpdateResultAddValue(
    String date,
    int right,
    int wrong,
  ) async {
    if (_db == null) {
      throw Exception('Database not initialized. Call openDB() first.');
    }

    // 1. Try to find existing row
    final existing = await _db!.query(
      'results',
      where: 'id = ?',
      whereArgs: [date],
    );

    if (existing.isEmpty) {
      // 2a. No row exists → insert new
      await _db!.insert('results', {
        'id': date,
        'right': right,
        'wrong': wrong,
      });
      print('Inserted new result for $date → right=$right, wrong=$wrong');
    } else {
      // 2b. Row exists → update by adding new values
      final oldRight = existing.first['right'] as int;
      final oldWrong = existing.first['wrong'] as int;

      await _db!.update(
        'results',
        {'right': oldRight + right, 'wrong': oldWrong + wrong},
        where: 'id = ?',
        whereArgs: [date],
      );
      print(
        'Updated result for $date → right=${oldRight + right}, wrong=${oldWrong + wrong}',
      );
    }
  }

  Future<bool> insertOrUpdateResult(String date, int right, int wrong) async {
    if (_db == null) {
      throw Exception('Database not initialized. Call openDB() first.');
      return false;
    }

    try {
      // เช็คว่ามี row อยู่แล้วหรือไม่
      final existing = await _db!.query(
        'results',
        where: 'id = ?',
        whereArgs: [date],
        limit: 1,
      );

      if (existing.isEmpty) {
        // insert ใหม่
        await _db!.insert('results', {
          'id': date,
          'right': right,
          'wrong': wrong,
        });
        print('Inserted new result for $date → right=$right, wrong=$wrong');
        return true; // ✅ new insert
      } else {
        // update ทับค่าเดิม
        await _db!.update(
          'results',
          {'right': right, 'wrong': wrong},
          where: 'id = ?',
          whereArgs: [date],
        );
        print('Updated result for $date → right=$right, wrong=$wrong');
        return true; // ✅ updated
      }
    } catch (e) {
      return false; //
    }
  }

  Future<List<Map<String, dynamic>>> getResultsLast30Days() async {
    if (_db == null) {
      throw Exception('Database not initialized. Call openDB() first.');
    }

    // Calculate the date 30 days ago
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    final dateString =
        '${thirtyDaysAgo.year.toString().padLeft(4, '0')}-'
        '${thirtyDaysAgo.month.toString().padLeft(2, '0')}-'
        '${thirtyDaysAgo.day.toString().padLeft(2, '0')}';

    // Query results where id (date) >= 30 days ago
    final results = await _db!.query(
      'results',
      where: 'id >= ?',
      whereArgs: [dateString],
      orderBy: 'id DESC', // optional: newest first
    );

    return results;
  }

  Future<bool> deleteAllResults() async {
    try {
      if (_db == null) {
        throw Exception('Database not initialized. Call openDB() first.');
      }

      await _db!.delete('results');
      print('All results deleted');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteResultsLast30DaysAgo() async {
    if (_db == null) {
      throw Exception('Database not initialized. Call openDB() first.');
    }

    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    final dateString =
        '${thirtyDaysAgo.year.toString().padLeft(4, '0')}-'
        '${thirtyDaysAgo.month.toString().padLeft(2, '0')}-'
        '${thirtyDaysAgo.day.toString().padLeft(2, '0')}';

    await _db!.delete('results', where: 'id <= ?', whereArgs: [dateString]);

    print('Deleted results from last 30 days');
  }

  Future<void> insertOrUpdateConfig(String key, String value) async {
    await _db?.insert('config', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllConfig() async {
    final List<Map<String, dynamic>> result = await _db!.query('config');
    return result;
  }

  Future<String?> getConfigValue(String key) async {
    final List<Map<String, dynamic>> result = await _db!.query(
      'config',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String;
    } else {
      return null;
    }
  }
}
