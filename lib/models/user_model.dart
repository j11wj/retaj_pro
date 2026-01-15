import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String userType;

  @HiveField(4)
  final String? gender;

  @HiveField(5)
  final int? age;

  @HiveField(6)
  final String? city;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final String? doctorId; // معرف الطبيب

  @HiveField(9)
  final String? doctorCode; // الرمز الخاص بالطبيب

  @HiveField(10)
  final String? clinicId; // معرف العيادة المرتبطة بالطبيب

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    this.gender,
    this.age,
    this.city,
    this.imageUrl,
    this.doctorId,
    this.doctorCode,
    this.clinicId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // دعم كلا التنسيقين: Backend API و Hive
    final role = json['role'] ?? json['userType'] ?? '';
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      userType: _mapRoleToUserType(role),
      gender: json['gender'],
      age: json['age'],
      city: json['city'],
      imageUrl: json['imageUrl'],
      doctorId: json['doctorId'],
      doctorCode: json['doctorCode'],
      clinicId: json['clinicId'],
    );
  }

  static String _mapRoleToUserType(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'patient';
      case 'doctor':
        return 'doctor';
      case 'receptionist':
        return 'receptionist';
      case 'photographer':
        return 'photographer';
      case 'admin':
        return 'admin';
      default:
        return role.isNotEmpty ? role : 'patient';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'gender': gender,
      'age': age,
      'city': city,
      'imageUrl': imageUrl,
      'doctorId': doctorId,
      'doctorCode': doctorCode,
      'clinicId': clinicId,
    };
  }

  // CopyWith method for updating user data
  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? userType,
    String? gender,
    int? age,
    String? city,
    String? imageUrl,
    String? doctorId,
    String? doctorCode,
    String? clinicId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      doctorId: doctorId ?? this.doctorId,
      doctorCode: doctorCode ?? this.doctorCode,
      clinicId: clinicId ?? this.clinicId,
    );
  }
}
