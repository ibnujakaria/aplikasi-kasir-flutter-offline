import '../../core/database/database.service.dart';
import 'models/restaurant_info.model.dart';

class RestaurantService {
  final DatabaseService _dbService = DatabaseService();
  final String _table = 'restaurant_info';

  // Save or Update the single restaurant record
  Future<int> saveRestaurantInfo(RestaurantInfo info) async {
    final db = await _dbService.database;

    // Check if info already exists
    final List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = 1',
    );

    if (maps.isNotEmpty) {
      return await db.update(_table, info.toMap(), where: 'id = 1');
    } else {
      return await db.insert(_table, info.toMap());
    }
  }

  // Get the info
  Future<RestaurantInfo?> getRestaurantInfo() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = 1',
    );

    if (maps.isNotEmpty) {
      return RestaurantInfo.fromMap(maps.first);
    }
    return null;
  }
}
