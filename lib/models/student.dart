class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.name,
  });

  final String id;
  final String classId;
  final String name;

  Student copyWith({String? id, String? classId, String? name}) {
    return Student(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'name': name,
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      classId: json['classId'] as String,
      name: json['name'] as String,
    );
  }
}
