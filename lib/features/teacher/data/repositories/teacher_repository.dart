import '../models/teacher_model.dart';

class TeacherRepository {
  Future<List<Teacher>> getTeachers() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return Teacher.getDummyTeachers();
  }

  Future<Teacher?> getTeacherById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final teachers = Teacher.getDummyTeachers();
    try {
      return teachers.firstWhere((teacher) => teacher.id == id);
    } catch (_) {
      return null;
    }
  }
}
