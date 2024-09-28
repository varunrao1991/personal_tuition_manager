enum UserRole {
  teacher,
  student,
  admin,
  manager,
}

UserRole getUserRole(String role) {
  switch (role.toLowerCase()) {
    case 'teacher':
      return UserRole.teacher;
    case 'student':
      return UserRole.student;
    case 'admin':
      return UserRole.admin;
    case 'manager':
      return UserRole.manager;
    default:
      throw Exception('Unknown role');
  }
}
