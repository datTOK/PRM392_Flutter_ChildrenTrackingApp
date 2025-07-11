class GrowthAttributeResult {
  final double percentile;
  final String description;
  final int level;

  GrowthAttributeResult({
    required this.percentile,
    required this.description,
    required this.level,
  });

  factory GrowthAttributeResult.fromJson(Map<String, dynamic> json) {
    return GrowthAttributeResult(
      percentile: (json['percentile'] as num).toDouble(),
      description: json['description'],
      level: json['level'],
    );
  }
}

class GrowthResult {
  final GrowthAttributeResult weight;
  final GrowthAttributeResult height;
  final GrowthAttributeResult bmi;
  final GrowthAttributeResult headCircumference;
  final GrowthAttributeResult armCircumference;
  final GrowthAttributeResult weightForLength;
  final String? description; // Can be null
  final int level;

  GrowthResult({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.headCircumference,
    required this.armCircumference,
    required this.weightForLength,
    this.description,
    required this.level,
  });

  factory GrowthResult.fromJson(Map<String, dynamic> json) {
    return GrowthResult(
      weight: GrowthAttributeResult.fromJson(json['weight']),
      height: GrowthAttributeResult.fromJson(json['height']),
      bmi: GrowthAttributeResult.fromJson(json['bmi']),
      headCircumference: GrowthAttributeResult.fromJson(json['headCircumference']),
      armCircumference: GrowthAttributeResult.fromJson(json['armCircumference']),
      weightForLength: GrowthAttributeResult.fromJson(json['weightForLength']),
      description: json['description'],
      level: json['level'],
    );
  }
}

class GrowthData {
  final String id;
  final String childId;
  final DateTime inputDate;
  final double weight;
  final double height;
  final double? headCircumference;
  final double? armCircumference;
  final double? bmi; // BMI can be null or calculated
  final GrowthResult? growthResult; // Add this

  GrowthData({
    required this.id,
    required this.childId,
    required this.inputDate,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.armCircumference,
    this.bmi,
    this.growthResult, // Add this
  });

  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      id: json['id'],
      childId: json['childId'],
      inputDate: DateTime.parse(json['inputDate']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      headCircumference: (json['headCircumference'] as num?)?.toDouble(),
      armCircumference: (json['armCircumference'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      growthResult: json['growthResult'] != null
          ? GrowthResult.fromJson(json['growthResult'])
          : null, // Parse growthResult
    );
  }
}