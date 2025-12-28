import '../../core/database/database.service.dart';
import 'models/staff.model.dart';

class StaffService {
  final DatabaseService _dbService = DatabaseService();
  final String _table = 'staff';

  // Create or update staff
  Future<int> saveStaff(Staff staff) async {
    final db = await _dbService.database;
    if (staff.id != null) {
      return await db.update(
        _table,
        staff.toMap(),
        where: 'id = ?',
        whereArgs: [staff.id],
      );
    } else {
      return await db.insert(_table, staff.toMap());
    }
  }

  // Delete staff
  Future<int> deleteStaff(int id) async {
    final db = await _dbService.database;
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // Get all staff members
  Future<List<Staff>> getAllStaff() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(_table);
    return maps.map((item) => Staff.fromMap(item)).toList();
  }

  // THE GATEKEEPER: Check if we have at least one staff member
  Future<bool> isStaffEmpty() async {
    final db = await _dbService.database;
    final count = await db.rawQuery('SELECT COUNT(*) FROM $_table');
    int? total = firstIntValue(count);
    return total == 0;
  }

  // Helper to get first int value from rawQuery
  int? firstIntValue(List<Map<String, dynamic>> list) {
    if (list.isNotEmpty && list.first.values.isNotEmpty) {
      return list.first.values.first as int;
    }
    return null;
  }
}
