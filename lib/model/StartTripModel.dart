class StartTripModel {
  int? id; // for SQLite local id
  String destination;
  int groupSize;
  String startDate;
  String endDate;
  String boardingPoint;
  List<String> mode;
  String minBudget;
  String maxBudget;
  String details;
  List<String> activities;
  List<String> photoPaths;
  String userId;
  String userEmail;

  StartTripModel({
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
    required this.photoPaths,
    required this.userId,
    required this.userEmail,
  });
}
