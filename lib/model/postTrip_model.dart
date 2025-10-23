import 'dart:io';

class TripPostModel {
  int? id;
  String destination;
  int groupSize;
  String startDate;
  String endDate;
  String boardingPoint;
  String mode;
  String minBudget;
  String maxBudget;
  String details;
  String activities;
  String imagePath;
  int synced;

  TripPostModel({
    this.id,
    required this.destination,
    required this.groupSize,
    required this.startDate,
    required this.endDate,
    required this.boardingPoint,
    required this.mode,
    required this.minBudget,
    required this.maxBudget,
    required this.details,
    required this.activities,
    required this.imagePath,
    this.synced = 0,
  });

  // 🧠 Convert model to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination': destination,
      'groupSize': groupSize,
      'startDate': startDate,
      'endDate': endDate,
      'boardingPoint': boardingPoint,
      'mode': mode,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'details': details,
      'activities': activities,
      'imagePath': imagePath,
      'synced': synced,
    };
  }

  // 🧩 Create model from SQLite Map

  // 📷 Get list of File objects from imagePath
  List<File> getImageFiles() {
    return imagePath
        .split(',')
        .map((e) => e.trim())
        .where((path) => path.isNotEmpty)
        .map((path) => File(path))
        .toList();
  }
}
