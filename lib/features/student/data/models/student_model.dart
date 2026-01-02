class Student {
  final String id;
  final String name;
  final String email;
  final String grade;
  final String section;
  final String rollNumber;
  final String? avatarUrl;
  final String parentName;
  final String parentPhone;
  final String address;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    required this.section,
    required this.rollNumber,
    this.avatarUrl,
    required this.parentName,
    required this.parentPhone,
    required this.address,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      grade: json['grade'] as String,
      section: json['section'] as String,
      rollNumber: json['rollNumber'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      parentName: json['parentName'] as String,
      parentPhone: json['parentPhone'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'grade': grade,
      'section': section,
      'rollNumber': rollNumber,
      'avatarUrl': avatarUrl,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'address': address,
    };
  }

  static List<Student> getDummyStudents() {
    return [
      Student(
        id: '1',
        name: 'Alex Johnson',
        email: 'alex.j@school.com',
        grade: '10',
        section: 'A',
        rollNumber: '1001',
        parentName: 'Mr. Johnson',
        parentPhone: '+1 234 567 8900',
        address: '123 Main St, New York, NY 10001',
      ),
      Student(
        id: '2',
        name: 'Emily Davis',
        email: 'emily.d@school.com',
        grade: '10',
        section: 'A',
        rollNumber: '1002',
        parentName: 'Mrs. Davis',
        parentPhone: '+1 234 567 8901',
        address: '124 Main St, New York, NY 10001',
      ),
      Student(
        id: '3',
        name: 'Michael Brown',
        email: 'michael.b@school.com',
        grade: '10',
        section: 'B',
        rollNumber: '1003',
        parentName: 'Mr. Brown',
        parentPhone: '+1 234 567 8902',
        address: '125 Main St, New York, NY 10001',
      ),
      Student(
        id: '4',
        name: 'Sarah Wilson',
        email: 'sarah.w@school.com',
        grade: '9',
        section: 'A',
        rollNumber: '9001',
        parentName: 'Mrs. Wilson',
        parentPhone: '+1 234 567 8903',
        address: '126 Main St, New York, NY 10001',
      ),
      Student(
        id: '5',
        name: 'James Taylor',
        email: 'james.t@school.com',
        grade: '9',
        section: 'B',
        rollNumber: '9002',
        parentName: 'Mr. Taylor',
        parentPhone: '+1 234 567 8904',
        address: '127 Main St, New York, NY 10001',
      ),
    ];
  }
}
