import 'package:flutter/material.dart';

/// Map-based localization class for the application
/// Provides translations without code generation
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('bn')];

  // Translation map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'account_actions': 'Account Actions',
      'messages': 'Messaages',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      // Auth
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'already_have_account': 'Already have an account?',
      'login': 'Login',
      'welcome_back': 'Welcome Back',
      'sign_in_to_continue': 'Sign in to continue',
      'forgot_password': 'Forgot Password?',
      'parent_id': 'Parent ID',
      'enter_parent_id': 'Enter your parent ID',
      'enter_email': 'Enter your email address',
      'enter_password': 'Enter your password',
      'sign_in': 'Sign In',
      'get_started': 'Get Started',
      'welcome_to_pathshala_bondhu': 'Welcome to Pathshala Bondhu',
      'your_school_companion': 'Your School Companion',
      'welcome_description':
          'আপনার সন্তানের শিক্ষা জীবনের সেরা সঙ্গী। বই, রুটিন, পরীক্ষা, উপস্থিতি এবং ফি সব এক জায়গায়।',
      'onboarding_feature_1_title': 'Digital Attendance',
      'onboarding_feature_1_desc':
          'Quick digital marking with SMS/Push notifications',
      'onboarding_feature_2_title': 'Exam & Results',
      'onboarding_feature_2_desc':
          'Multiple exams, auto GPA, marksheet & merit list',
      'onboarding_feature_3_title': 'Fee Management',
      'onboarding_feature_3_desc':
          'Auto monthly generation, payment tracking & receipts',
      'onboarding_feature_4_title': 'Parent App',
      'onboarding_feature_4_desc':
          'Attendance, results, fees, homework & messages',
      'onboarding_feature_5_title': 'Teacher Management',
      'onboarding_feature_5_desc':
          'Check-in/out, work hours, performance & salary data',
      'onboarding_feature_6_title': 'Real-time Chat',
      'onboarding_feature_6_desc': 'Parents & teachers can chat in real-time',
      'onboarding_pricing': 'Only 20 Taka per student',
      'onboarding_contact': 'Contact Us',
      'onboarding_phone': 'Phone & WhatsApp',
      'onboarding_phone_number': '01308831689 / 01305193510',
      'onboarding_150_features': '150+ Features',
      'onboarding_made_in_bd': 'Made in Bangladesh',

      // Profile & Settings
      'full_name': 'Full Name',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'about': 'About',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      'appearance': 'Appearance',
      'dark_theme_enabled': 'Dark theme enabled',
      'light_theme_enabled': 'Light theme enabled',
      'push_notifications': 'Push Notifications',
      'receive_push_notifications': 'Receive push notifications',
      'email_notifications': 'Email Notifications',
      'receive_email_updates': 'Receive email updates',
      'app_version': 'App Version',
      'delete_account': 'Delete Account',
      'permanently_delete_account': 'Permanently delete your account',
      'are_you_sure_delete':
          'Are you sure you want to delete your account? This action cannot be undone.',

      // Common
      'home': 'Home',
      'students': 'Students',
      'teachers': 'Teachers',
      'parents': 'Parents',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',

      // Home
      'quick_access': 'Quick Access',
      'explore_all_features': 'Explore all features',
      'books': 'Books',
      'diary': 'Diary',
      'class_routine': 'Class Routine',
      'exam_routine': 'Exam Routine',
      'attendance': 'Attendance',
      'fees': 'Fees',
      'result': 'Result',

      // Dashboard
      'dashboard': 'Dashboard',
      'my_routine': 'My Routine',
      'class_diary': 'Class Diary',
      'add_diary': 'Add Diary',
      'no_diaries_yet': 'No Diaries Yet',
      'start_creating_diaries':
          'Start creating class diaries by tapping\nthe "Add Diary" button below.',

      // Notifications
      'no_notifications_yet': 'No notifications yet',
      'we_will_notify_you': "We'll notify you when something arrives",
      'all_notifications_marked_read': 'All notifications marked as read',
      'mark_as_read': 'Mark as read',
      'read_more': 'Read more',
      'show_less': 'Show less',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      'earlier': 'Earlier',

      // Fees
      'academic_year': 'Academic Year',
      'no_fee_records': 'No fee records',
      'no_fee_records_year': 'No fee records for selected year.',
      'paid': 'Paid',
      'unpaid': 'Unpaid',

      // Teachers
      'no_teachers_found': 'No teachers found',
      'teachers_list_empty': 'Teachers list is empty.',

      // Routines
      'loading_routine': 'Loading routine...',
      'no_classes_today': 'No classes today',
      'no_classes_scheduled': 'No classes scheduled',
      'enjoy_free_day': 'Enjoy your free day!',
      'for_day': 'for',
      'ongoing': 'Ongoing',
      'sunday': 'Sunday',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',

      // Diary
      'diary_details': 'Diary Details',
      'delete_diary': 'Delete Diary',
      'are_you_sure_delete_diary':
          'Are you sure you want to delete this diary?',
      'diary_deleted_successfully': 'Diary deleted successfully',
      'loading_diary_details': 'Loading diary details...',
      'error_loading_details': 'Error Loading Details',
      'diary_not_found': 'Diary Not Found',
      'diary_not_found_message':
          'The diary you are looking for\ncould not be found.',
      'create_diary': 'Create Diary',
      'edit_diary': 'Edit Diary',
      'new_diary_entry': 'New Diary Entry',
      'edit_diary_entry': 'Edit Diary Entry',
      'update_diary_info': 'Update your class diary information below.',
      'create_new_diary': 'Fill in the details to create a new class diary.',
      'basic_information': 'Basic Information',
      'select_class': 'Select Class',
      'choose_class': 'Choose Class',
      'subject': 'Subject',
      'choose_subject': 'Choose Subject',
      'academic_session': 'Academic Session',
      'choose_session': 'Choose Session',
      'dates': 'Dates',
      'diary_date': 'Diary Date',
      'select_date': 'Select Date',
      'submission_date': 'Submission Date',
      'content': 'Content',
      'enter_topic_chapter': 'Enter topic or chapter name',
      'enter_detailed_description': 'Enter detailed description',
      'status': 'Status',
      'published': 'Published',
      'draft': 'Draft',
      'publish_diary': 'Publish Diary',
      'update_diary': 'Update Diary',
      'loading_form_data': 'Loading form data...',
      'please_select_class_session_subject':
          'Please select Class, Session and Subject',
      'diary_created_successfully': 'Diary created successfully!',
      'diary_updated_successfully': 'Diary updated successfully!',
      'error_loading_diaries': 'Error Loading Diaries',
      'loading_diaries': 'Loading diaries...',
      'unknown': 'Unknown',
      'description': 'Description',
      'details': 'Details',
      'submission_date_label': 'Submission Date',
      'no_description_provided': 'No description provided.',

      // Attendance
      'mark': 'Mark',
      'history': 'History',

      // Profile
      'personal_information': 'Personal Information',
      'view_edit_profile': 'View and edit profile details',
      'change_password': 'Change Password',
      'update_password': 'Update your password',
      'app_preferences': 'App preferences and configurations',
      'manage_notification_settings': 'Manage notification settings',
      'get_help_account': 'Get help with your account',
      'app_version_info': 'App version and information',
      'sign_out_account': 'Sign out of your account',
      'are_you_sure_logout': 'Are you sure you want to logout?',
      'version': 'Version',
      'account': 'Account',
      'preferences': 'Preferences',
      'support': 'Support',
      'help_support': 'Help & Support',
      'father_name': 'Father Name',
      'mother_name': 'Mother Name',
      'father_job': 'Father Job',
      'mother_job': 'Mother Job',
      'phone': 'Phone',
      'address': 'Address',
      'contact_details': 'Contact Details',
      'department': 'Department',
      'specialization': 'Specialization',
      'bio': 'Bio',
      'name': 'Name',
      'no_profile_data_found': 'No profile data found',
      'loading_profile': 'Loading profile...',
      'error_loading_profile': 'Error Loading Profile',

      // Common UI (only keys not already defined above)
      'try_again': 'Try Again',
      'oops_something_went_wrong': 'Oops! Something went wrong',
      "coming_soon": "Coming soon!",
      "no_students_found": "No students found. Please contact support.",
      "loading_student_information": "Loading student information...",
      "mark_all_read": "Mark all read",

      // Chat Background
      "chat_background": "Chat Background",
      "colors": "Colors",
      "gradients": "Gradients",
      "patterns": "Patterns",
      "custom": "Custom",
      "take_photo": "Take Photo",
      "choose_from_gallery": "Choose from Gallery",

      // Chat
      "search_conversations": "Search conversations...",
      "could_not_load_conversations": "We couldn't load your conversations",
      "no_messages_yet": "No Messages Yet",
      "start_conversation_with_teachers_parents":
          "Start a conversation with teachers\nand parents",
      "no_search_results": "No results found",
      "try_searching_different_name": "Try searching with a different name",
      "refresh": "Refresh",
      "no_messages_yet_chat": "No messages yet",
      "start_conversation_with": "Start the conversation with",
      "active_now": "Active now",
      "active_just_now": "Active just now",
      "active_minutes_ago": "Active {minutes}m ago",
      "active_hours_ago": "Active {hours}h ago",
      "active_yesterday": "Active yesterday",
      "active_days_ago": "Active {days}d ago",
      "offline": "Offline",
      // Result
      'student_result': 'Student Result',
      'exam_name': 'Exam Name',
      'total_marks': 'Total Marks',
      'obtained_marks': 'Obtained Marks',
      'grade': 'Grade',
      'position': 'Position',
      'no_results_found': 'No Results Found',
      'no_results_available': 'No exam results available for this student.',
      'download_pdf': 'Download PDF',
      'pdf_download_coming_soon': 'PDF download coming soon!',
      'loading_results': 'Loading results...',
      'error_loading_results': 'Error Loading Results',
      'subject_wise_results': 'Subject-wise Results',
      'exam_details': 'Exam Details',
      'percentage': 'Percentage',

      // Contact Us
      'contact_us': 'Contact Us',
      'get_in_touch': 'Get in Touch',
      'contact_us_subtitle': 'We\'re here to help! Reach out to us anytime.',
      'email_address': 'Email Address',
      'phone_number': 'Phone Number',
      'copy_email': 'Copy Email',
      'copy_phone': 'Copy Phone',
      'call': 'Call',
      'send_email': 'Send Email',
      'copied_to_clipboard': 'Copied to clipboard',
      'support_email': 'Support Email',
      'general_inquiries': 'General Inquiries',
      'contact_number': 'Contact Number',
      'whatsapp_number': 'WhatsApp Number',
      'office_hours': 'Office Hours',
      'sunday_thursday': 'Sunday - Thursday',
      'available_time': '9:00 AM - 6:00 PM',

      // Privacy Policy
      'privacy_policy_title': 'Privacy Policy',
      'last_updated': 'Last Updated',
      'privacy_intro':
          'Your privacy is important to us. This Privacy Policy explains how Pathshala Bondhu collects, uses, and protects your personal information.',
      'information_collection': 'Information Collection',
      'information_collection_desc':
          'We collect information you provide directly to us, including name, email, phone number, and educational data. We also collect usage data to improve our services.',
      'data_usage': 'How We Use Your Data',
      'data_usage_desc':
          'We use your information to provide educational services, communicate important updates, improve our platform, and ensure security of your account.',
      'data_protection': 'Data Protection',
      'data_protection_desc':
          'We implement industry-standard security measures to protect your data. Your information is encrypted and stored securely on our servers.',
      'third_party_sharing': 'Third-Party Sharing',
      'third_party_sharing_desc':
          'We do not sell your personal information. We may share data with service providers who help us operate our platform, but only to the extent necessary.',
      'your_rights': 'Your Rights',
      'your_rights_desc':
          'You have the right to access, update, or delete your personal information. Contact us if you wish to exercise these rights.',
      'policy_changes': 'Policy Changes',
      'policy_changes_desc':
          'We may update this policy from time to time. We will notify you of any significant changes via email or app notification.',

      // Terms & Conditions
      'terms_conditions_title': 'Terms & Conditions',
      'terms_intro':
          'By using Pathshala Bondhu, you agree to these terms and conditions. Please read them carefully.',
      'acceptance_terms': 'Acceptance of Terms',
      'acceptance_terms_desc':
          'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
      'user_responsibilities': 'User Responsibilities',
      'user_responsibilities_desc':
          'You are responsible for maintaining the confidentiality of your account credentials. You agree to use the platform only for lawful purposes.',
      'service_description': 'Service Description',
      'service_description_desc':
          'Pathshala Bondhu provides educational management services including attendance tracking, fee management, exam results, and parent-teacher communication.',
      'intellectual_property': 'Intellectual Property',
      'intellectual_property_desc':
          'All content, features, and functionality are owned by Pathshala Bondhu and protected by intellectual property laws.',
      'limitation_liability': 'Limitation of Liability',
      'limitation_liability_desc':
          'Pathshala Bondhu shall not be liable for any indirect, incidental, special, consequential damages arising from your use of the service.',
      'termination': 'Termination',
      'termination_desc':
          'We reserve the right to terminate or suspend your account at our discretion, without prior notice, for conduct that violates these terms.',
      'governing_law': 'Governing Law',
      'governing_law_desc':
          'These terms shall be governed by and construed in accordance with the laws of Bangladesh.',
      'contact_for_terms': 'Contact for Questions',
      'contact_for_terms_desc':
          'If you have any questions about these Terms & Conditions, please contact us using the information provided in the Contact Us section.',

      // Notification Permission
      'notification_settings': 'Notification Settings',
      'notification_settings_ios':
          'For iOS, please manage notification settings through your device settings.',
      'notifications_enabled': 'Notifications Enabled',
      'notifications_enabled_desc':
          'You will now receive important updates and alerts from Pathshala Bondhu.',
      'enable_notifications': 'Enable Notifications',
      'requesting_permission': 'Requesting...',
      'permission_denied': 'Permission Denied',
      'notification_permission_denied_desc':
          'Notifications have been denied. You can try again or enable them from settings.',
      'open_settings': 'Open Settings',
      'enable_notifications_in_settings':
          'Please enable notifications from your device settings to receive important updates.',
      'notifications_active': 'Notifications Active',
      'notifications_active_desc':
          'You are all set to receive notifications from Pathshala Bondhu.',
      'notifications_disabled': 'Notifications Disabled',
      'notifications_disabled_desc':
          'Enable notifications to stay updated with important information.',
      'notifications_blocked': 'Notifications Blocked',
      'notifications_blocked_desc':
          'Notifications are blocked. Please enable them from your device settings.',
      'notifications_setup': 'Set Up Notifications',
      'notifications_setup_desc':
          'Enable notifications to never miss important updates about your child\'s education.',
      'why_notifications': 'Why Enable Notifications?',
      'notifications_benefits':
          'Stay informed about attendance, exam results, fee reminders, homework updates, and important announcements from teachers.',
      'denial_count': 'Attempts',
      'notification_prompt_title': 'Stay Updated',
      'notification_prompt_message':
          'Enable notifications to receive important updates about attendance, results, and announcements.',
      'allow': 'Allow',
      'maybe_later': 'Maybe Later',

      // Teacher Attendance
      'teacher_attendance': 'Teacher Attendance',
      'my_attendance': 'My Attendance',
      'question_bank': 'Question Bank',
      'mark_attendance': 'Mark Attendance',
      'update_attendance': 'Update Attendance',
      'attendance_summary': 'Attendance Summary',
      'total_teachers': 'Total Teachers',
      'marked': 'Marked',
      'pending': 'Pending',
      'present': 'Present',
      'absent': 'Absent',
      'leave': 'Leave',
      'attendance_percentage': 'Attendance %',
      'past_record': 'Past Record',
      'past_record_warning': 'This is a past attendance record',
      'future_date_not_allowed': 'Cannot view future attendance',
      'search_teacher': 'Search teacher by name...',
      'all_status': 'All',
      'filter_by_department': 'Filter by Department',
      'check_in_time': 'Check-in Time',
      'check_out_time': 'Check-out Time',
      'check_in_required': 'Check-in time is required',
      'remarks': 'Remarks',
      'add_remarks': 'Add any notes...',
      'attendance_marked_successfully': 'Attendance marked successfully',
      'attendance_updated_successfully': 'Attendance updated successfully',
      'attendance_not_marked': 'Attendance not marked yet',
      'no_match_filter': 'No teachers match your filter',
      'updating_past_record': '⚠️ You are updating a past attendance record',
      'check_out_must_be_after_check_in':
          'Check-out time must be after check-in time',
      'attendance_already_marked': 'Attendance already marked for this teacher',
      'clear_filters': 'Clear Filters',
    },
    'bn': {
      'account_actions': 'অ্যাকাউন্ট সম্পর্কিত কার্যক্রম',
      'messages': 'বার্তা',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      // Auth
      'signup': 'নিবন্ধন করুন',
      'email': 'ইমেইল',
      'password': 'পাসওয়ার্ড',
      'confirm_password': 'পাসওয়ার্ড নিশ্চিত করুন',
      'already_have_account': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
      'login': 'লগইন',
      'welcome_back': 'আবার স্বাগতম',
      'sign_in_to_continue': 'চালিয়ে যেতে সাইন ইন করুন',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'parent_id': 'প্যারেন্ট আইডি',
      'enter_parent_id': 'আপনার প্যারেন্ট আইডি লিখুন',
      'enter_email': 'আপনার ইমেইল ঠিকানা লিখুন',
      'enter_password': 'আপনার পাসওয়ার্ড লিখুন',
      'sign_in': 'সাইন ইন',
      'get_started': 'শুরু করুন',
      'welcome_to_pathshala_bondhu': 'পাঠশালা বন্ধুতে স্বাগতম',
      'your_school_companion': 'আপনার স্কুল সঙ্গী',
      'welcome_description':
          'আপনার সন্তানের শিক্ষা জীবনের সেরা সঙ্গী। বই, রুটিন, পরীক্ষা, উপস্থিতি এবং ফি সব এক জায়গায়।',
      'onboarding_feature_1_title': 'ডিজিটাল উপস্থিতি',
      'onboarding_feature_1_desc': 'দ্রুত ডিজিটাল মার্কিং, SMS/পুশ নোটিফিকেশন',
      'onboarding_feature_2_title': 'পরীক্ষা ও ফলাফল',
      'onboarding_feature_2_desc':
          'একাধিক পরীক্ষা, অটো GPA, মার্কশিট, মেধা তালিকা',
      'onboarding_feature_3_title': 'ফি ব্যবস্থাপনা',
      'onboarding_feature_3_desc': 'মাসিক অটো তৈরি, পেমেন্ট ট্র্যাক, রসিদ',
      'onboarding_feature_4_title': 'অভিভাবক অ্যাপ',
      'onboarding_feature_4_desc': 'উপস্থিতি, ফলাফল, ফি, হোমওয়ার্ক, মেসেজ',
      'onboarding_feature_5_title': 'শিক্ষক ব্যবস্থাপনা',
      'onboarding_feature_5_desc':
          'চেক-ইন/আউট, কাজের ঘণ্টা, পারফরম্যান্স, বেতন',
      'onboarding_feature_6_title': 'রিয়েল-টাইম চ্যাট',
      'onboarding_feature_6_desc':
          'অভিভাবক ও শিক্ষক রিয়েল-টাইমে চ্যাট করতে পারবেন',
      'onboarding_pricing': 'শুধুমাত্র ২০ টাকা প্রতি শিক্ষার্থী',
      'onboarding_contact': 'যোগাযোগ করুন',
      'onboarding_phone': 'ফোন ও WhatsApp',
      'onboarding_phone_number': '০১৩০৮৮৩১৬৮৯ / ০১৩০৫১৯৩৫১০',
      'onboarding_150_features': '১৫০+ বৈশিষ্ট্য',
      'onboarding_made_in_bd': '🇧🇩 বাংলাদেশে তৈরি',

      // Profile & Settings
      'full_name': 'পুরো নাম',
      'profile': 'প্রোফাইল',
      'notifications': 'নোটিফিকেশন',
      'settings': 'সেটিংস',
      'about': 'সম্পর্কে',
      'logout': 'লগআউট',
      'cancel': 'বাতিল',
      'dark_mode': 'ডার্ক মোড',
      'language': 'ভাষা',
      'privacy_policy': 'গোপনীয়তা নীতি',
      'terms_conditions': 'শর্তাবলী',
      'appearance': 'চেহারা',
      'dark_theme_enabled': 'ডার্ক থিম সক্রিয়',
      'light_theme_enabled': 'লাইট থিম সক্রিয়',
      'push_notifications': 'পুশ নোটিফিকেশন',
      'receive_push_notifications': 'পুশ নোটিফিকেশন গ্রহণ করুন',
      'email_notifications': 'ইমেইল নোটিফিকেশন',
      'receive_email_updates': 'ইমেইল আপডেট গ্রহণ করুন',
      'app_version': 'অ্যাপ সংস্করণ',
      'delete_account': 'অ্যাকাউন্ট মুছুন',
      'permanently_delete_account': 'আপনার অ্যাকাউন্ট স্থায়ীভাবে মুছুন',
      'are_you_sure_delete':
          'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।',

      // Common
      'home': 'হোম',
      'students': 'ছাত্র',
      'teachers': 'শিক্ষক',
      'parents': 'পিতামাতা',
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'retry': 'পুনরায় চেষ্টা করুন',
      'save': 'সংরক্ষণ',
      'edit': 'সম্পাদনা',
      'result': 'ফলাফল',
      'delete': 'মুছুন',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'ok': 'ঠিক আছে',
      'close': 'বন্ধ',

      // Home
      'quick_access': 'দ্রুত অ্যাক্সেস',
      'explore_all_features': 'সমস্ত বৈশিষ্ট্য অন্বেষণ করুন',
      'books': 'বই',
      'diary': 'ডায়েরি',
      'class_routine': 'ক্লাস রুটিন',
      'exam_routine': 'পরীক্ষার রুটিন',
      'attendance': 'উপস্থিতি',
      'fees': 'ফি',

      // Dashboard
      'dashboard': 'ড্যাশবোর্ড',
      'my_routine': 'আমার রুটিন',
      'class_diary': 'ক্লাস ডায়েরি',
      'add_diary': 'ডায়েরি যোগ করুন',
      'no_diaries_yet': 'এখনও কোন ডায়েরি নেই',
      'start_creating_diaries':
          'নিচে "ডায়েরি যোগ করুন" বোতামে ট্যাপ করে\nক্লাস ডায়েরি তৈরি শুরু করুন।',

      // Notifications
      'no_notifications_yet': 'এখনও কোন নোটিফিকেশন নেই',
      'we_will_notify_you': 'কিছু আসলে আমরা আপনাকে জানাব',
      'all_notifications_marked_read': 'সমস্ত নোটিফিকেশন পড়া হিসাবে চিহ্নিত',
      'mark_as_read': 'পড়া হিসাবে চিহ্নিত',
      'read_more': 'আরও পড়ুন',
      'show_less': 'কম দেখান',
      'today': 'আজ',
      'yesterday': 'গতকাল',
      'this_week': 'এই সপ্তাহ',
      'earlier': 'আগে',

      // Fees
      'academic_year': 'শিক্ষাবর্ষ',
      'no_fee_records': 'কোন ফি রেকর্ড নেই',
      'no_fee_records_year': 'নির্বাচিত বছরের জন্য কোন ফি রেকর্ড নেই।',
      'paid': 'পেড',
      'unpaid': 'অপেড',

      // Teachers
      'no_teachers_found': 'কোন শিক্ষক পাওয়া যায়নি',
      'teachers_list_empty': 'শিক্ষক তালিকা খালি।',

      // Routines
      'loading_routine': 'রুটিন লোড হচ্ছে...',
      'no_classes_today': 'আজ কোন ক্লাস নেই',
      'no_classes_scheduled': 'কোন ক্লাস নির্ধারিত নেই',
      'enjoy_free_day': 'আপনার ফ্রি দিন উপভোগ করুন!',
      'for_day': 'জন্য',
      'ongoing': 'চলমান',
      'sunday': 'রবিবার',
      'monday': 'সোমবার',
      'tuesday': 'মঙ্গলবার',
      'wednesday': 'বুধবার',
      'thursday': 'বৃহস্পতিবার',
      'friday': 'শুক্রবার',
      'saturday': 'শনিবার',

      // Diary
      'diary_details': 'ডায়েরি বিবরণ',
      'delete_diary': 'ডায়েরি মুছুন',
      'are_you_sure_delete_diary':
          'আপনি কি নিশ্চিত যে আপনি এই ডায়েরি মুছতে চান?',
      'diary_deleted_successfully': 'ডায়েরি সফলভাবে মুছে ফেলা হয়েছে',
      'loading_diary_details': 'ডায়েরি বিবরণ লোড হচ্ছে...',
      'error_loading_details': 'বিবরণ লোড করতে ত্রুটি',
      'diary_not_found': 'ডায়েরি পাওয়া যায়নি',
      'diary_not_found_message': 'আপনি যে ডায়েরি খুঁজছেন\nতা পাওয়া যায়নি।',
      'create_diary': 'ডায়েরি তৈরি করুন',
      'edit_diary': 'ডায়েরি সম্পাদনা করুন',
      'new_diary_entry': 'নতুন ডায়েরি এন্ট্রি',
      'edit_diary_entry': 'ডায়েরি এন্ট্রি সম্পাদনা করুন',
      'update_diary_info': 'নিচে আপনার ক্লাস ডায়েরি তথ্য আপডেট করুন।',
      'create_new_diary': 'একটি নতুন ক্লাস ডায়েরি তৈরি করতে বিবরণ পূরণ করুন।',
      'basic_information': 'মৌলিক তথ্য',
      'select_class': 'ক্লাস নির্বাচন করুন',
      'choose_class': 'ক্লাস চয়ন করুন',
      'subject': 'বিষয়',
      'choose_subject': 'বিষয় চয়ন করুন',
      'academic_session': 'শিক্ষাবর্ষ',
      'choose_session': 'সেশন চয়ন করুন',
      'dates': 'তারিখ',
      'diary_date': 'ডায়েরি তারিখ',
      'select_date': 'তারিখ নির্বাচন করুন',
      'submission_date': 'জমা দেওয়ার তারিখ',
      'content': 'বিষয়বস্তু',
      'enter_topic_chapter': 'বিষয় বা অধ্যায়ের নাম লিখুন',
      'enter_detailed_description': 'বিস্তারিত বিবরণ লিখুন',
      'status': 'স্ট্যাটাস',
      'published': 'প্রকাশিত',
      'draft': 'খসড়া',
      'publish_diary': 'ডায়েরি প্রকাশ করুন',
      'update_diary': 'ডায়েরি আপডেট করুন',
      'loading_form_data': 'ফর্ম ডেটা লোড হচ্ছে...',
      'please_select_class_session_subject':
          'অনুগ্রহ করে ক্লাস, সেশন এবং বিষয় নির্বাচন করুন',
      'diary_created_successfully': 'ডায়েরি সফলভাবে তৈরি হয়েছে!',
      'diary_updated_successfully': 'ডায়েরি সফলভাবে আপডেট হয়েছে!',
      'error_loading_diaries': 'ডায়েরি লোড করতে ত্রুটি',
      'loading_diaries': 'ডায়েরি লোড হচ্ছে...',
      'unknown': 'অজানা',
      'description': 'বিবরণ',
      'details': 'বিবরণ',
      'submission_date_label': 'জমা দেওয়ার তারিখ',
      'no_description_provided': 'কোন বিবরণ প্রদান করা হয়নি।',

      // Attendance
      'mark': 'চিহ্নিত করুন',
      'history': 'ইতিহাস',

      // Profile
      'personal_information': 'ব্যক্তিগত তথ্য',
      'view_edit_profile': 'প্রোফাইল বিবরণ দেখুন এবং সম্পাদনা করুন',
      'change_password': 'পাসওয়ার্ড পরিবর্তন করুন',
      'update_password': 'আপনার পাসওয়ার্ড আপডেট করুন',
      'app_preferences': 'অ্যাপ পছন্দ এবং কনফিগারেশন',
      'manage_notification_settings': 'নোটিফিকেশন সেটিংস পরিচালনা করুন',
      'get_help_account': 'আপনার অ্যাকাউন্টে সাহায্য পান',
      'app_version_info': 'অ্যাপ সংস্করণ এবং তথ্য',
      'sign_out_account': 'আপনার অ্যাকাউন্ট থেকে সাইন আউট করুন',
      'are_you_sure_logout': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',
      'version': 'সংস্করণ',
      'account': 'অ্যাকাউন্ট',
      'preferences': 'পছন্দ',
      'support': 'সাহায্য',
      'help_support': 'সাহায্য ও সহায়তা',
      'father_name': 'পিতার নাম',
      'mother_name': 'মাতার নাম',
      'father_job': 'পিতার কাজ',
      'mother_job': 'মাতার কাজ',
      'phone': 'ফোন',
      'address': 'ঠিকানা',
      'contact_details': 'যোগাযোগের বিবরণ',
      'department': 'বিভাগ',
      'specialization': 'বিশেষীকরণ',
      'bio': 'জীবনী',
      'name': 'নাম',
      'no_profile_data_found': 'কোন প্রোফাইল ডেটা পাওয়া যায়নি',
      'loading_profile': 'প্রোফাইল লোড হচ্ছে...',
      'error_loading_profile': 'প্রোফাইল লোড করতে ত্রুটি',

      // Common UI (only keys not already defined above)
      'try_again': 'আবার চেষ্টা করুন',
      'oops_something_went_wrong': 'ওহো! কিছু ভুল হয়েছে',
      "coming_soon": "শীঘ্রই আসছে!",
      "no_students_found": "কোন ছাত্র পাওয়া যায়নি। অনুগ্রহ করে সহায়তা নিন।",
      "loading_student_information": "ছাত্র তথ্য লোড হচ্ছে...",
      "mark_all_read": "সব পড়া হিসাবে চিহ্নিত করুন",

      // Chat Background
      "chat_background": "চ্যাট ব্যাকগ্রাউন্ড",
      "colors": "রং",
      "gradients": "গ্রেডিয়েন্ট",
      "patterns": "প্যাটার্ন",
      "custom": "কাস্টম",
      "take_photo": "ছবি তুলুন",
      "choose_from_gallery": "গ্যালারি থেকে নির্বাচন করুন",

      // Chat
      "search_conversations": "কনভারসেশন খুঁজুন...",
      "could_not_load_conversations": "আমরা আপনার কথোপকথন লোড করতে পারিনি",
      "no_messages_yet": "এখনও কোন বার্তা নেই",
      "start_conversation_with_teachers_parents":
          "শিক্ষক এবং অভিভাবকদের সাথে\nকথোপকথন শুরু করুন",
      "no_search_results": "কোন ফলাফল পাওয়া যায়নি",
      "try_searching_different_name": "একটি ভিন্ন নাম দিয়ে অনুসন্ধান করুন",
      "refresh": "রিফ্রেশ",
      "no_messages_yet_chat": "এখনও কোন বার্তা নেই",
      "start_conversation_with": "এর সাথে কথোপকথন শুরু করুন",
      "active_now": "এখন সক্রিয়",
      "active_just_now": "এখনই সক্রিয়",
      "active_minutes_ago": "{minutes} মিনিট আগে সক্রিয়",
      "active_hours_ago": "{hours} ঘন্টা আগে সক্রিয়",
      "active_yesterday": "গতকাল সক্রিয়",
      "active_days_ago": "{days} দিন আগে সক্রিয়",
      "offline": "অফলাইন",

      // Result
      'student_result': 'শিক্ষার্থীর ফলাফল',
      'exam_name': 'পরীক্ষার নাম',
      'total_marks': 'মোট নম্বর',
      'obtained_marks': 'প্রাপ্ত নম্বর',
      'grade': 'গ্রেড',
      'position': 'অবস্থান',
      'no_results_found': 'কোন ফলাফল পাওয়া যায়নি',
      'no_results_available':
          'এই শিক্ষার্থীর জন্য কোন পরীক্ষার ফলাফল উপলব্ধ নেই।',
      'download_pdf': 'পিডিএফ ডাউনলোড করুন',
      'pdf_download_coming_soon': 'পিডিএফ ডাউনলোড শীঘ্রই আসছে!',
      'loading_results': 'ফলাফল লোড হচ্ছে...',
      'error_loading_results': 'ফলাফল লোড করতে ত্রুটি',
      'subject_wise_results': 'বিষয়ভিত্তিক ফলাফল',
      'exam_details': 'পরীক্ষার বিবরণ',
      'percentage': 'শতাংশ',

      // Contact Us
      'contact_us': 'যোগাযোগ করুন',
      'get_in_touch': 'যোগাযোগ করুন',
      'contact_us_subtitle':
          'আমরা সাহায্য করতে এখানে আছি! যেকোনো সময় আমাদের সাথে যোগাযোগ করুন।',
      'email_address': 'ইমেইল ঠিকানা',
      'phone_number': 'ফোন নম্বর',
      'copy_email': 'ইমেইল কপি করুন',
      'copy_phone': 'ফোন কপি করুন',
      'call': 'কল করুন',
      'send_email': 'ইমেইল পাঠান',
      'copied_to_clipboard': 'ক্লিপবোর্ডে কপি হয়েছে',
      'support_email': 'সাপোর্ট ইমেইল',
      'general_inquiries': 'সাধারণ জিজ্ঞাসা',
      'contact_number': 'যোগাযোগ নম্বর',
      'whatsapp_number': 'হোয়াটসঅ্যাপ নম্বর',
      'office_hours': 'অফিস সময়',
      'sunday_thursday': 'রবিবার - বৃহস্পতিবার',
      'available_time': 'সকাল ৯:০০ - সন্ধ্যা ৬:০০',

      // Privacy Policy
      'privacy_policy_title': 'গোপনীয়তা নীতি',
      'last_updated': 'সর্বশেষ আপডেট',
      'privacy_intro':
          'আপনার গোপনীয়তা আমাদের কাছে গুরুত্বপূর্ণ। এই গোপনীয়তা নীতি ব্যাখ্যা করে কিভাবে পাঠশালা বন্ধু আপনার ব্যক্তিগত তথ্য সংগ্রহ, ব্যবহার এবং সুরক্ষা করে।',
      'information_collection': 'তথ্য সংগ্রহ',
      'information_collection_desc':
          'আমরা আপনার প্রদত্ত তথ্য সংগ্রহ করি, যার মধ্যে নাম, ইমেইল, ফোন নম্বর এবং শিক্ষাগত তথ্য রয়েছে। আমরা আমাদের সেবা উন্নত করতে ব্যবহারের তথ্যও সংগ্রহ করি।',
      'data_usage': 'আমরা আপনার তথ্য কিভাবে ব্যবহার করি',
      'data_usage_desc':
          'আমরা আপনার তথ্য শিক্ষামূলক সেবা প্রদান, গুরুত্বপূর্ণ আপডেট জানাতে, আমাদের প্ল্যাটফর্ম উন্নত করতে এবং আপনার অ্যাকাউন্টের নিরাপত্তা নিশ্চিত করতে ব্যবহার করি।',
      'data_protection': 'তথ্য সুরক্ষা',
      'data_protection_desc':
          'আমরা আপনার তথ্য সুরক্ষার জন্য শিল্পমান নিরাপত্তা ব্যবস্থা প্রয়োগ করি। আপনার তথ্য এনক্রিপ্ট করা এবং আমাদের সার্ভারে নিরাপদে সংরক্ষিত।',
      'third_party_sharing': 'তৃতীয় পক্ষের সাথে শেয়ারিং',
      'third_party_sharing_desc':
          'আমরা আপনার ব্যক্তিগত তথ্য বিক্রি করি না। আমরা সেবা প্রদানকারীদের সাথে তথ্য শেয়ার করতে পারি যারা আমাদের প্ল্যাটফর্ম পরিচালনায় সহায়তা করে, তবে শুধুমাত্র প্রয়োজনীয় পরিমাণে।',
      'your_rights': 'আপনার অধিকার',
      'your_rights_desc':
          'আপনার ব্যক্তিগত তথ্য অ্যাক্সেস, আপডেট বা মুছে ফেলার অধিকার রয়েছে। এই অধিকারগুলি ব্যবহার করতে চাইলে আমাদের সাথে যোগাযোগ করুন।',
      'policy_changes': 'নীতি পরিবর্তন',
      'policy_changes_desc':
          'আমরা সময়ে সময়ে এই নীতি আপডেট করতে পারি। ইমেইল বা অ্যাপ নোটিফিকেশনের মাধ্যমে আমরা আপনাকে কোনো গুরুত্বপূর্ণ পরিবর্তন সম্পর্কে অবহিত করব।',

      // Terms & Conditions
      'terms_conditions_title': 'শর্তাবলী',
      'terms_intro':
          'পাঠশালা বন্ধু ব্যবহার করে, আপনি এই শর্তাবলীতে সম্মত হন। অনুগ্রহ করে সেগুলি সাবধানে পড়ুন।',
      'acceptance_terms': 'শর্তাবলীর গ্রহণযোগ্যতা',
      'acceptance_terms_desc':
          'এই অ্যাপ্লিকেশন অ্যাক্সেস এবং ব্যবহার করে, আপনি এই চুক্তির শর্তাবলী মেনে নিতে এবং তা মানতে সম্মত হন।',
      'user_responsibilities': 'ব্যবহারকারীর দায়িত্ব',
      'user_responsibilities_desc':
          'আপনার অ্যাকাউন্ট শংসাপত্রের গোপনীয়তা বজায় রাখার জন্য আপনি দায়ী। আপনি শুধুমাত্র আইনসম্মত উদ্দেশ্যে প্ল্যাটফর্ম ব্যবহার করতে সম্মত হন।',
      'service_description': 'সেবার বিবরণ',
      'service_description_desc':
          'পাঠশালা বন্ধু উপস্থিতি ট্র্যাকিং, ফি ব্যবস্থাপনা, পরীক্ষার ফলাফল এবং অভিভাবক-শিক্ষক যোগাযোগ সহ শিক্ষা ব্যবস্থাপনা সেবা প্রদান করে।',
      'intellectual_property': 'বৌদ্ধিক সম্পত্তি',
      'intellectual_property_desc':
          'সমস্ত বিষয়বস্তু, বৈশিষ্ট্য এবং কার্যকারিতা পাঠশালা বন্ধুর মালিকানাধীন এবং বৌদ্ধিক সম্পত্তি আইন দ্বারা সুরক্ষিত।',
      'limitation_liability': 'দায়বদ্ধতার সীমাবদ্ধতা',
      'limitation_liability_desc':
          'পাঠশালা বন্ধু আপনার সেবা ব্যবহার থেকে উদ্ভূত কোনো পরোক্ষ, আনুষঙ্গিক, বিশেষ, পরিণতিগত ক্ষতির জন্য দায়ী থাকবে না।',
      'termination': 'সমাপ্তি',
      'termination_desc':
          'এই শর্তাবলী লঙ্ঘন করে এমন আচরণের জন্য আমরা পূর্ব বিজ্ঞপ্তি ছাড়াই আপনার অ্যাকাউন্ট বাতিল বা স্থগিত করার অধিকার সংরক্ষণ করি।',
      'governing_law': 'প্রযোজ্য আইন',
      'governing_law_desc':
          'এই শর্তাবলী বাংলাদেশের আইন অনুযায়ী পরিচালিত এবং ব্যাখ্যা করা হবে।',
      'contact_for_terms': 'প্রশ্নের জন্য যোগাযোগ',
      'contact_for_terms_desc':
          'এই শর্তাবলী সম্পর্কে কোনো প্রশ্ন থাকলে, যোগাযোগ করুন বিভাগে প্রদত্ত তথ্য ব্যবহার করে আমাদের সাথে যোগাযোগ করুন।',

      // Notification Permission
      'notification_settings': 'নোটিফিকেশন সেটিংস',
      'notification_settings_ios':
          'iOS এর জন্য, অনুগ্রহ করে আপনার ডিভাইস সেটিংস থেকে নোটিফিকেশন সেটিংস পরিচালনা করুন।',
      'notifications_enabled': 'নোটিফিকেশন সক্রিয়',
      'notifications_enabled_desc':
          'আপনি এখন পাঠশালা বন্ধু থেকে গুরুত্বপূর্ণ আপডেট এবং সতর্কতা পাবেন।',
      'enable_notifications': 'নোটিফিকেশন সক্রিয় করুন',
      'requesting_permission': 'অনুরোধ করা হচ্ছে...',
      'permission_denied': 'অনুমতি প্রত্যাখ্যান',
      'notification_permission_denied_desc':
          'নোটিফিকেশন প্রত্যাখ্যান করা হয়েছে। আপনি আবার চেষ্টা করতে পারেন বা সেটিংস থেকে সক্রিয় করতে পারেন।',
      'open_settings': 'সেটিংস খুলুন',
      'enable_notifications_in_settings':
          'গুরুত্বপূর্ণ আপডেট পেতে অনুগ্রহ করে আপনার ডিভাইস সেটিংস থেকে নোটিফিকেশন সক্রিয় করুন।',
      'notifications_active': 'নোটিফিকেশন সক্রিয়',
      'notifications_active_desc':
          'আপনি পাঠশালা বন্ধু থেকে নোটিফিকেশন পেতে প্রস্তুত।',
      'notifications_disabled': 'নোটিফিকেশন নিষ্ক্রিয়',
      'notifications_disabled_desc':
          'গুরুত্বপূর্ণ তথ্য আপডেট থাকতে নোটিফিকেশন সক্রিয় করুন।',
      'notifications_blocked': 'নোটিফিকেশন ব্লক',
      'notifications_blocked_desc':
          'নোটিফিকেশন ব্লক করা আছে। অনুগ্রহ করে আপনার ডিভাইস সেটিংস থেকে সক্রিয় করুন।',
      'notifications_setup': 'নোটিফিকেশন সেটআপ',
      'notifications_setup_desc':
          'আপনার সন্তানের শিক্ষা সম্পর্কে গুরুত্বপূর্ণ আপডেট মিস না করতে নোটিফিকেশন সক্রিয় করুন।',
      'why_notifications': 'কেন নোটিফিকেশন সক্রিয় করবেন?',
      'notifications_benefits':
          'উপস্থিতি, পরীক্ষার ফলাফল, ফি রিমাইন্ডার, হোমওয়ার্ক আপডেট এবং শিক্ষকদের গুরুত্বপূর্ণ ঘোষণা সম্পর্কে অবগত থাকুন।',
      'denial_count': 'প্রচেষ্টা',
      'notification_prompt_title': 'আপডেট থাকুন',
      'notification_prompt_message':
          'উপস্থিতি, ফলাফল এবং ঘোষণা সম্পর্কে গুরুত্বপূর্ণ আপডেট পেতে নোটিফিকেশন সক্রিয় করুন।',
      'allow': 'অনুমতি দিন',
      'maybe_later': 'পরে হবে',

      // Teacher Attendance
      'teacher_attendance': 'শিক্ষক উপস্থিতি',
      'my_attendance': 'আমার উপস্থিতি',
      'question_bank': 'প্রশ্নব্যাংক',
      'mark_attendance': 'উপস্থিতি চিহ্নিত করুন',
      'update_attendance': 'উপস্থিতি আপডেট করুন',
      'attendance_summary': 'উপস্থিতির সারসংক্ষেপ',
      'total_teachers': 'মোট শিক্ষক',
      'marked': 'চিহ্নিত',
      'pending': 'মুলতুবি',
      'present': 'উপস্থিত',
      'absent': 'অনুপস্থিত',
      'leave': 'ছুটি',
      'attendance_percentage': 'উপস্থিতির শতাংশ',
      'past_record': 'পূর্ববর্তী রেকর্ড',
      'past_record_warning': 'এটি পূর্ববর্তী উপস্থিতি রেকর্ড',
      'future_date_not_allowed': 'ভবিষ্যতের তারিখের অনুমতি নেই',
      'search_teacher': 'নাম দিয়ে শিক্ষক খুঁজুন...',
      'all_status': 'সকল',
      'filter_by_department': 'বিভাগ অনুসারে ফিল্টার করুন',
      'check_in_time': 'প্রবেশের সময়',
      'check_out_time': 'প্রস্থানের সময়',
      'check_in_required': 'প্রবেশের সময় প্রয়োজন',
      'remarks': 'মন্তব্য',
      'add_remarks': 'মন্তব্য যোগ করুন...',
      'attendance_marked_successfully': 'উপস্থিতি সফলভাবে চিহ্নিত হয়েছে',
      'attendance_updated_successfully': 'উপস্থিতি সফলভাবে আপডেট হয়েছে',
      'attendance_not_marked': 'উপস্থিতি এখনো চিহ্নিত হয়নি',
      'no_match_filter': 'আপনার ফিল্টারের সাথে কোন শিক্ষক মিলেনি',
      'updating_past_record': '⚠️ আপনি পূর্ববর্তী উপস্থিতি রেকর্ড আপডেট করছেন',
      'check_out_must_be_after_check_in':
          'প্রস্থানের সময় প্রবেশের সময়ের পরে হতে হবে',
      'attendance_already_marked': 'এই শিক্ষকের উপস্থিতি ইতিমধ্যে চিহ্নিত',
      'clear_filters': 'ফিল্টার মুছুন',
    },
  };

  /// Get translation for a key
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  /// Get translation with fallback
  String translateWithFallback(String key, String fallback) {
    return _localizedValues[locale.languageCode]?[key] ?? fallback;
  }
}

/// Localizations delegate for AppLocalizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
