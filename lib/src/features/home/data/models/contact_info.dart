class ContactInfo {
  final String email;
  final String phone1;
  final String phone2;

  ContactInfo({this.email = '', this.phone1 = '', this.phone2 = ''});

  ContactInfo copyWith({String? email, String? phone1, String? phone2}) {
    return ContactInfo(
      email: email ?? this.email,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'phone1': phone1, 'phone2': phone2};
  }

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      email: map['email'] as String? ?? '',
      phone1: map['phone1'] as String? ?? '',
      phone2: map['phone2'] as String? ?? '',
    );
  }
}
