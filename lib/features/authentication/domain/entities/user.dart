class User {
  final String id;
  final String phone;
  final String? name;

  User({
    required this.id,
    required this.phone,
    this.name,
  });
}
