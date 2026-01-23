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

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('bn'),
  ];

  // Translation map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
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
      'welcome_description': 'আপনার সন্তানের শিক্ষা জীবনের সেরা সঙ্গী। বই, রুটিন, পরীক্ষা, উপস্থিতি এবং ফি সব এক জায়গায়।',

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
      'are_you_sure_delete': 'Are you sure you want to delete your account? This action cannot be undone.',

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

      // Dashboard
      'dashboard': 'Dashboard',
      'my_routine': 'My Routine',
      'class_diary': 'Class Diary',
      'add_diary': 'Add Diary',
      'no_diaries_yet': 'No Diaries Yet',
      'start_creating_diaries': 'Start creating class diaries by tapping\nthe "Add Diary" button below.',

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
      'are_you_sure_delete_diary': 'Are you sure you want to delete this diary?',
      'diary_deleted_successfully': 'Diary deleted successfully',
      'loading_diary_details': 'Loading diary details...',
      'error_loading_details': 'Error Loading Details',
      'diary_not_found': 'Diary Not Found',
      'diary_not_found_message': 'The diary you are looking for\ncould not be found.',
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
      'please_select_class_session_subject': 'Please select Class, Session and Subject',
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
    },
    'bn': {
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
      'welcome_description': 'আপনার সন্তানের শিক্ষা জীবনের সেরা সঙ্গী। বই, রুটিন, পরীক্ষা, উপস্থিতি এবং ফি সব এক জায়গায়।',

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
      'are_you_sure_delete': 'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।',

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
      'start_creating_diaries': 'নিচে "ডায়েরি যোগ করুন" বোতামে ট্যাপ করে\nক্লাস ডায়েরি তৈরি শুরু করুন।',

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
      'are_you_sure_delete_diary': 'আপনি কি নিশ্চিত যে আপনি এই ডায়েরি মুছতে চান?',
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
      'please_select_class_session_subject': 'অনুগ্রহ করে ক্লাস, সেশন এবং বিষয় নির্বাচন করুন',
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
    return AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
