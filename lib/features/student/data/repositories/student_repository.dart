import '../models/student_model.dart';

class StudentRepository {
  Future<List<Student>> getStudents() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    return Student.getDummyStudents();
  }

  Future<Student?> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final students = Student.getDummyStudents();
    try {
      return students.firstWhere((student) => student.id == id);
    } catch (_) {
      return null;
    }
  }
}
