import 'teacher_model.dart';

class TeacherUpdate {
  int? id;
  String? name;
  String? mobile;

  TeacherUpdate({
    this.id,
    this.name,
    this.mobile,
  });

  TeacherUpdate.fromTeacher(Teacher teacher) {
    id = teacher.id;
    name = teacher.name;
    mobile = teacher.mobile;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
    };
  }
}
