class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.school,
    this.program,
    this.major,
    this.description,
  });

  final String id;
  final String name;
  final String? school;
  final String? program;
  final String? major;
  final String? description;
}
