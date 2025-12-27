import '../restaurant/restaurant.service.dart';
import '../staff/staff.service.dart';

class SetupService {
  final RestaurantService _restaurantService = RestaurantService();
  final StaffService _staffService = StaffService();

  // This is the function main.dart calls
  Future<bool> isAppInitialized() async {
    try {
      // 1. Check if restaurant info exists
      final restaurant = await _restaurantService.getRestaurantInfo();

      // 2. Check if there is at least one staff member
      // we use ! (not) because isStaffEmpty returns true if empty
      final hasStaff = !(await _staffService.isStaffEmpty());

      // The app is ready only if BOTH are true
      return restaurant != null && hasStaff;
    } catch (e) {
      // If there's a database error, assume not initialized
      return false;
    }
  }
}
