import 'student_model.dart';

class StudentUpdate {
  int? id;
  String? name;
  String? mobile;
  DateTime? dob;
  DateTime? joiningDate;

  // Constructor to initialize fields
  StudentUpdate({
    this.id,
    this.name,
    this.mobile,
    this.dob,
    this.joiningDate,
  });

  // Constructor to initialize fields from a Student object
  StudentUpdate.fromStudent(Student student) {
    id = student.id;
    name = student.name;
    mobile = student.mobile;
    dob = student.dob;
    joiningDate = student.joiningDate;
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobile != null) 'mobile': mobile,
      if (dob != null) 'dob': dob?.toIso8601String(),
      if (joiningDate != null) 'joiningDate': joiningDate?.toIso8601String(),
    };
  }
}
