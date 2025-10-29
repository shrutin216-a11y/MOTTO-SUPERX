import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TripDatabase {
  // Create Database
  Future<Database> createDB() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), "MottoDB.db"),
      version: 1,
      onCreate: (db, version) {
        db.execute('''CREATE TABLE start_trips (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          destination TEXT,
          groupSize INTEGER,
          startDate TEXT,
          endDate TEXT,
          boardingPoint TEXT,
          mode TEXT,
          minBudget TEXT,
          maxBudget TEXT,
          details TEXT,
          activities TEXT,
          photoPaths TEXT,
          userId TEXT,
          userEmail TEXT
        )''');
      },
    );
    return db;
  }

  // Insert Trip
  Future<void> insertTrip(Map<String, dynamic> trip) async {
    Database db = await createDB();
    await db.insert(
      "start_trips",
      trip,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get All Trips
  Future<List<Map>> getTrips() async {
    Database db = await createDB();
    List<Map> list = await db.query("start_trips");
    return list;
  }

  // Update Trip
  Future<void> updateTrip(Map<String, dynamic> trip) async {
    Database db = await createDB();
    await db.update(
      "start_trips",
      trip,
      where: "id = ?",
      whereArgs: [trip['id']],
    );
  }

  // Delete Trip
  Future<void> deleteTrip(int id) async {
    Database db = await createDB();
    await db.delete("start_trips", where: "id = ?", whereArgs: [id]);
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'status': 'cancelled',
      });

      log("✅ Trip cancelled successfully in Firestore");
    } catch (e) {
      log("❌ Error cancelling trip: $e");
    }
  }

  Future<void> cancelLocalTrip(int id) async {
    Database db = await createDB();
    await db.update(
      'trips',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [id],
    );
    log("✅ Trip cancelled locally in SQLite");
  }
}
