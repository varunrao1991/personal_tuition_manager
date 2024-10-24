class ProfileUpdate {
  String? name;
  String? mobile;

  ProfileUpdate({this.name, this.mobile});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
    };
  }
}
