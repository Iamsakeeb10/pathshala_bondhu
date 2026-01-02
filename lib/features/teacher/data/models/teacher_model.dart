class Teacher {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String department;
  final String? avatarUrl;
  final String phoneNumber;
  final int yearsOfExperience;
  final String qualification;
  final String address;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.department,
    this.avatarUrl,
    required this.phoneNumber,
    required this.yearsOfExperience,
    required this.qualification,
    required this.address,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      subject: json['subject'] as String,
      department: json['department'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
      qualification: json['qualification'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'subject': subject,
      'department': department,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'yearsOfExperience': yearsOfExperience,
      'qualification': qualification,
      'address': address,
    };
  }

  static List<Teacher> getDummyTeachers() {
    return [
      Teacher(
        id: '1',
        name: 'Dr. Sarah Anderson',
        email: 'sarah.a@school.com',
        subject: 'Mathematics',
        department: 'Science',
        phoneNumber: '+1 234 567 8800',
        yearsOfExperience: 15,
        qualification: 'PhD in Mathematics',
        address: '100 Faculty Ave, New York, NY 10001',
      ),
      Teacher(
        id: '2',
        name: 'Prof. Robert Miller',
        email: 'robert.m@school.com',
        subject: 'Physics',
        department: 'Science',
        phoneNumber: '+1 234 567 8801',
        yearsOfExperience: 12,
        qualification: 'MSc in Physics',
        address: '101 Faculty Ave, New York, NY 10001',
      ),
      Teacher(
        id: '3',
        name: 'Ms. Jennifer Lee',
        email: 'jennifer.l@school.com',
        subject: 'English Literature',
        department: 'Arts',
        phoneNumber: '+1 234 567 8802',
        yearsOfExperience: 8,
        qualification: 'MA in English',
        address: '102 Faculty Ave, New York, NY 10001',
      ),
      Teacher(
        id: '4',
        name: 'Mr. David Chen',
        email: 'david.c@school.com',
        subject: 'Computer Science',
        department: 'Technology',
        phoneNumber: '+1 234 567 8803',
        yearsOfExperience: 10,
        qualification: 'MSc in Computer Science',
        address: '103 Faculty Ave, New York, NY 10001',
      ),
      Teacher(
        id: '5',
        name: 'Mrs. Maria Garcia',
        email: 'maria.g@school.com',
        subject: 'Spanish',
        department: 'Languages',
        phoneNumber: '+1 234 567 8804',
        yearsOfExperience: 7,
        qualification: 'BA in Spanish Language',
        address: '104 Faculty Ave, New York, NY 10001',
      ),
    ];
  }
}
