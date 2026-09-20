import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseDatabaseService {
  late final DatabaseReference _db;

  FirebaseDatabaseService() {
    // Explicitly using the URL for the europe-west1 region to fix the loading issue
    const String url = "https://smart-trade-manager-default-rtdb.europe-west1.firebasedatabase.app";
    _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: url,
    ).ref();
  }

  // =========================
  // PRODUCTS
  // =========================

  Future<void> addProduct(String id, Map<String, dynamic> data) async {
    await _db.child("products/$id").set(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.child("products/$id").update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.child("products/$id").remove();
  }

  Stream<DatabaseEvent> getProducts() {
    return _db.child("products").onValue;
  }

  // =========================
  // SUPPLIERS
  // =========================

  Future<void> addSupplier(String id, Map<String, dynamic> data) async {
    await _db.child("suppliers/$id").set(data);
  }

  Stream<DatabaseEvent> getSuppliers() {
    return _db.child("suppliers").onValue;
  }

  // =========================
  // SHIPMENTS
  // =========================

  Future<void> addShipment(String id, Map<String, dynamic> data) async {
    await _db.child("shipments/$id").set(data);
  }

  Stream<DatabaseEvent> getShipments() {
    return _db.child("shipments").onValue;
  }
}
