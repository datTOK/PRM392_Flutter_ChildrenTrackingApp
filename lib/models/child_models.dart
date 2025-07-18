class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final String note;
  final int gender;
  final int feedingType;
  final List<int> allergies;
  final String guardianId;

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.note,
    required this.gender,
    required this.feedingType,
    required this.allergies,
    required this.guardianId,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      note: json['note'] ?? 'N/A', 
      gender: json['gender'],
      feedingType: json['feedingType'],
      allergies: List<int>.from(json['allergies'] ?? []),
      guardianId: json['guardianId'],
    );
  }
}