class User {
  final String id;
  final String phone;
  final String? name; // Optional, if needed

  User({
    required this.id,
    required this.phone,
    this.name,
  });
}
