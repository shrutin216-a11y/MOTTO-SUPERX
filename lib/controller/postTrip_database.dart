import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:motto_app/view/signup_screen.dart';

class TripPostDatabase {
  // CREATE DATABASE
  Future<Database> createDB() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), "MottoDB.db"),
      version: 1,
      onCreate: (db, version) {
        db.execute('''
CREATE TABLE postedtrip (
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
      imagePath TEXT,
      synced INTEGER DEFAULT 0
    )
''');
      },
    );
    return db;
  }

  // GET DATA
  Future<List<Map>> getPostedTrip() async {
    final db = await createDB();
    return await db.query("postedtrip");
  }

  // ADD DATA
  Future<void> insertPostedTrip(Map<String, dynamic> obj) async {
    final db = await createDB();
    await db.insert(
      "postedtrip",
      obj,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // UPDATE DATA
  Future<void> updatePostedTrip(Map<String, dynamic> obj) async {
    final db = await createDB();
    await db.update("postedtrip", obj, where: "id=?", whereArgs: [obj['id']]);
  }

  // DELETE DATA
  Future<void> deletePostedTrip(int id) async {
    final db = await createDB();
    await db.delete("postedtrip", where: "id=?", whereArgs: [id]);
  }

  // 🔄 SYNC TO FIREBASE (with multiple image upload fix)
  Future<void> syncToFirebase(String userEmail) async {
    final db = await createDB();
    List<Map> unsyncedTrips = await db.query(
      "postedtrip",
      where: "synced = ?",
      whereArgs: [0],
    );

    for (var trip in unsyncedTrips) {
      // ✅ Properly split and clean image paths
      List<String> imagePaths = (trip['imagePath'] ?? '')
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> imageUrls = [];

      // ✅ Upload all images sequentially
      for (var path in imagePaths) {
        File file = File(path);

        if (!file.existsSync()) continue; // skip missing files

        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';
        var snapshot = await FirebaseStorage.instance
            .ref('tripImages/$fileName')
            .putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // ✅ Destination key formatting (safe Firestore subcollection name)
      String destinationKey = trip['destination']
          .toString()
          .trim()
          .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
          .toLowerCase();

      // ✅ Save all images in one Firestore document
      await FirebaseFirestore.instance
          .collection('postedTrips')
          .doc(userEmail)
          .collection(destinationKey)
          .add({
            'destination': trip['destination'],
            'groupSize': trip['groupSize'],
            'startDate': trip['startDate'],
            'endDate': trip['endDate'],
            'boardingPoint': trip['boardingPoint'],
            'mode': trip['mode'],
            'minBudget': trip['minBudget'],
            'maxBudget': trip['maxBudget'],
            'details': trip['details'],
            'activities': trip['activities'],
            'images': imageUrls, // ✅ all uploaded images now stored
            'createdAt': FieldValue.serverTimestamp(),
          });

      // ✅ Mark trip as synced
      await db.update(
        "postedtrip",
        {'synced': 1},
        where: "id = ?",
        whereArgs: [trip['id']],
      );
    }
  }
}
