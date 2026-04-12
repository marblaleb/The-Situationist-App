class CreationLimitsModel {
  final int eventsToday;
  final int missionsToday;
  final int dailyLimit;

  const CreationLimitsModel({
    required this.eventsToday,
    required this.missionsToday,
    required this.dailyLimit,
  });

  factory CreationLimitsModel.fromJson(Map<String, dynamic> json) =>
      CreationLimitsModel(
        eventsToday: (json['eventsToday'] as num).toInt(),
        missionsToday: (json['missionsToday'] as num).toInt(),
        dailyLimit: (json['dailyLimit'] as num).toInt(),
      );
}
