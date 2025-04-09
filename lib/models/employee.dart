class Employee {
  final String eid;
  final String name;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;

  Employee({
    required this.eid,
    required this.name,
    required this.role,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'eid': eid,
        'name': name,
        'role': role,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        eid: json['eid'],
        name: json['name'],
        role: json['role'],
        startDate: DateTime.parse(json['startDate']),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      );

  Employee copyWith({
    String? name,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Employee(
      eid: eid,
      name: name ?? this.name,
      role: role ?? this.role,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
