import 'student_model.dart';

class StudentUpdate {
  int? id;
  String? name;
  String? mobile;

  StudentUpdate({
    this.id,
    this.name,
    this.mobile,
  });

  StudentUpdate.fromStudent(Student student) {
    id = student.id;
    name = student.name;
    mobile = student.mobile;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
    };
  }
}
