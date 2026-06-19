class Contact {
  String? id;
  String name;
  String phone;
  String email;
  String? photoPath;
  bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.photoPath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'photoPath': photoPath,
      'isFavorite': isFavorite,
    };
  }

  factory Contact.fromMap(String id, Map<String, dynamic> map) {
    return Contact(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      photoPath: map['photoPath'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
