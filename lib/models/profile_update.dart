// profile_update.dart

class ProfileUpdate {
  String? name;
  String? mobile;
  String? dob;

  ProfileUpdate({this.name, this.mobile, this.dob});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (dob != null) 'dob': dob,
    };
  }
}
