class StudyClass {
  const StudyClass({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  StudyClass copyWith({String? id, String? name}) {
    return StudyClass(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory StudyClass.fromJson(Map<String, dynamic> json) {
    return StudyClass(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
