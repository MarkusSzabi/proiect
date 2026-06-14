class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String vehicles = 'vehicles';
  static const String trips = 'trips';
  static const String maintenanceItems = 'maintenance_items';

  static String userVehicles(String uid) => 'users/$uid/vehicles';
  static String userTrips(String uid) => 'users/$uid/trips';
  static String userMaintenance(String uid) => 'users/$uid/maintenance_items';
}