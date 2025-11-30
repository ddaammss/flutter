class User {
  final String seq;
  final String name;

  User({this.seq = '', this.name = ''});

  User copyWith({String? seq, String? name}) {
    return User(seq: seq ?? this.seq, name: name ?? this.name);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(seq: json['seq']?.toString() ?? '', name: json['name']?.toString() ?? '');
  }
}
