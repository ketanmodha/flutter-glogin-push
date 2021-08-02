class User {
  final String uId;
  final String email;
  final String? displayName;
  final String? photoUrl;

  User({
    required this.uId,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
