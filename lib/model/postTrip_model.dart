class TripModel {
  int? id; // For SQLite primary key
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
  String imagePath; // local file path
  int synced; // 0 = not synced, 1 = synced

  TripModel({
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

  // ✅ Convert Model → Map (for SQLite)
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

  // ✅ Convert Map → Model (for reading from SQLite)
  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      destination: map['destination'],
      groupSize: map['groupSize'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      boardingPoint: map['boardingPoint'],
      mode: map['mode'],
      minBudget: map['minBudget'],
      maxBudget: map['maxBudget'],
      details: map['details'],
      activities: map['activities'],
      imagePath: map['imagePath'] ?? '',
      synced: map['synced'] ?? 0,
    );
  }

  // ✅ Convert Model → Firestore Map
  Map<String, dynamic> toFirestore(String imageUrl) {
    return {
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
      'imageUrl': imageUrl,
      'createdAt': DateTime.now(),
    };
  }
}
