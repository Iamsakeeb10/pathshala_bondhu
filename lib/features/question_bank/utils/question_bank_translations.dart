/// Question Bank Translations
/// Bilingual translations for English and Bangla

class QuestionBankTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Auth
      'qb_auth_title': 'Question Bank Login',
      'qb_auth_subtitle': 'Enter your credentials to access the Question Bank',
      'qb_auth_email': 'Email',
      'qb_auth_email_hint': 'Enter your email address',
      'qb_auth_password': 'Password',
      'qb_auth_password_hint': 'Enter your password',
      'qb_auth_login': 'Login',
      'qb_auth_logging_in': 'Logging in...',
      'qb_auth_error': 'Invalid credentials',
      'qb_auth_error_email': 'Please enter a valid email',
      'qb_auth_error_password': 'Password is required',

      // Home/List
      'qb_title': 'Question Bank',
      'qb_create': 'Create Question',
      'qb_search': 'Search questions...',
      'qb_filter': 'Filter',
      'qb_filters_active': 'filters active',
      'qb_empty': 'No questions yet!',
      'qb_empty_subtitle': 'Tap + to create your first question',
      'qb_loading': 'Loading questions...',
      'qb_load_more': 'Loading more...',
      'qb_results_found': 'results found',
      'qb_pull_refresh': 'Pull to refresh',

      // Question Types
      'qb_type_mcq': 'Multiple Choice',
      'qb_type_mcq_desc':
          'Questions with multiple options and one correct answer',
      'qb_type_true_false': 'True/False',
      'qb_type_true_false_desc': 'Simple true or false statements',
      'qb_type_short_answer': 'Short Answer',
      'qb_type_short_answer_desc': 'Brief text-based answers',
      'qb_type_essay': 'Essay',
      'qb_type_essay_desc': 'Long-form written responses',
      'qb_type_matching': 'Matching',
      'qb_type_matching_desc': 'Match items from two columns',
      'qb_type_fill_blank': 'Fill in the Blank',
      'qb_type_fill_blank_desc': 'Complete sentences with missing words',
      'qb_type_math': 'Math Problem',
      'qb_type_math_desc': 'Mathematical equations and calculations',
      'qb_type_creative': 'Creative Question',
      'qb_type_creative_desc': 'Structured questions with sub-parts (CQ)',

      // Form Labels
      'qb_step_type': 'Select Type',
      'qb_step_basic': 'Basic Info',
      'qb_step_details': 'Details',
      'qb_step_preview': 'Preview',
      'qb_class': 'Class',
      'qb_class_hint': 'Select a class',
      'qb_subject': 'Subject',
      'qb_subject_hint': 'Select a subject',
      'qb_marks': 'Marks',
      'qb_marks_hint': 'Enter marks',
      'qb_question_text': 'Question Text',
      'qb_question_text_hint': 'Enter your question here...',
      'qb_options': 'Options',
      'qb_option_hint': 'Enter option text',
      'qb_add_option': 'Add Option',
      'qb_correct_answer': 'Correct Answer',
      'qb_explanation': 'Explanation',
      'qb_explanation_hint': 'Add an explanation (optional)',
      'qb_expected_answer': 'Expected Answer',
      'qb_expected_answer_hint': 'Enter the expected answer',
      'qb_word_count': 'Expected Word Count',
      'qb_grading_guidelines': 'Grading Guidelines',
      'qb_grading_guidelines_hint': 'Enter grading guidelines (optional)',
      'qb_solution': 'Solution Steps',
      'qb_solution_hint': 'Enter solution steps',
      'qb_left_column': 'Left Column',
      'qb_right_column': 'Right Column',
      'qb_add_pair': 'Add Pair',
      'qb_add_subquestion': 'Add Sub-question',
      'qb_subquestion': 'Sub-question',
      'qb_blank_answer': 'Answer for Blank',
      'qb_shuffle_right': 'Shuffle right column',
      'qb_recent_types': 'Recently Used',

      // Actions
      'qb_next': 'Next',
      'qb_previous': 'Previous',
      'qb_save': 'Save Question',
      'qb_saving': 'Saving...',
      'qb_cancel': 'Cancel',
      'qb_edit': 'Edit',
      'qb_delete': 'Delete',
      'qb_duplicate': 'Duplicate',
      'qb_view': 'View',
      'qb_logout': 'Logout',
      'qb_try_again': 'Try Again',
      'qb_undo': 'Undo',
      'qb_apply': 'Apply',
      'qb_reset': 'Reset',
      'qb_clear_filters': 'Clear Filters',
      'qb_create_another': 'Create Another',
      'qb_view_question': 'View Question',
      'qb_edit_question': 'Edit Question',
      'qb_show_answers': 'Show Answers',
      'qb_hide_answers': 'Hide Answers',

      // Confirmations
      'qb_delete_title': 'Delete Question?',
      'qb_delete_confirm': 'Are you sure you want to delete this question?',
      'qb_delete_warning': 'This action cannot be undone.',
      'qb_logout_title': 'Logout from Question Bank?',
      'qb_logout_confirm':
          'You will need to login again to access Question Bank.',
      'qb_save_changes_title': 'Save Changes?',
      'qb_save_changes_confirm': 'Do you want to save your changes?',
      'qb_discard_title': 'Discard Changes?',
      'qb_discard_confirm': 'Your unsaved changes will be lost.',
      'qb_draft_found': 'Draft Found',
      'qb_draft_restore':
          'You have an unsaved draft. Would you like to restore it?',
      'qb_restore': 'Restore',
      'qb_discard': 'Discard',

      // Validation
      'qb_required': 'This field is required',
      'qb_min_marks': 'Minimum marks is 0.5',
      'qb_min_options': 'Add at least 2 options',
      'qb_max_options': 'Maximum 6 options allowed',
      'qb_select_correct': 'Select the correct answer',
      'qb_option_empty': 'Option text cannot be empty',
      'qb_min_pairs': 'Add at least 2 matching pairs',
      'qb_blank_required': 'Add blanks using [1], [2] or ___',

      // Messages
      'qb_created': 'Question created successfully!',
      'qb_updated': 'Question updated successfully!',
      'qb_deleted': 'Question deleted',
      'qb_restored': 'Question restored',
      'qb_draft_saved': 'Draft saved',
      'qb_error': 'Something went wrong',
      'qb_network_error': 'No internet connection',
      'qb_session_expired': 'Session expired, please login again',
      'qb_not_found': 'Question not found',
      'qb_forbidden': 'You don\'t have permission to perform this action',

      // Filter
      'qb_filter_class': 'Filter by Class',
      'qb_filter_subject': 'Filter by Subject',
      'qb_filter_type': 'Filter by Type',
      'qb_filter_marks': 'Marks Range',
      'qb_all': 'All',

      // Detail Screen
      'qb_question_details': 'Question Details',
      'qb_created_at': 'Created',
      'qb_updated_at': 'Last Updated',
      'qb_marks_label': 'marks',

      // Time
      'qb_just_now': 'Just now',
      'qb_minutes_ago': 'minutes ago',
      'qb_hours_ago': 'hours ago',
      'qb_days_ago': 'days ago',
      'qb_session_time': 'Session expires in',
    },
    'bn': {
      // Auth
      'qb_auth_title': 'প্রশ্ন ব্যাংক লগইন',
      'qb_auth_subtitle': 'প্রশ্ন ব্যাংকে প্রবেশের জন্য আপনার তথ্য দিন',
      'qb_auth_email': 'ইমেইল',
      'qb_auth_email_hint': 'আপনার ইমেইল ঠিকানা লিখুন',
      'qb_auth_password': 'পাসওয়ার্ড',
      'qb_auth_password_hint': 'আপনার পাসওয়ার্ড লিখুন',
      'qb_auth_login': 'লগইন করুন',
      'qb_auth_logging_in': 'লগইন হচ্ছে...',
      'qb_auth_error': 'ভুল লগইন তথ্য',
      'qb_auth_error_email': 'একটি সঠিক ইমেইল দিন',
      'qb_auth_error_password': 'পাসওয়ার্ড আবশ্যক',

      // Home/List
      'qb_title': 'প্রশ্ন ব্যাংক',
      'qb_create': 'প্রশ্ন তৈরি করুন',
      'qb_search': 'প্রশ্ন খুঁজুন...',
      'qb_filter': 'ফিল্টার',
      'qb_filters_active': 'ফিল্টার সক্রিয়',
      'qb_empty': 'এখনো কোনো প্রশ্ন নেই!',
      'qb_empty_subtitle': 'প্রথম প্রশ্ন তৈরি করতে + চাপুন',
      'qb_loading': 'প্রশ্ন লোড হচ্ছে...',
      'qb_load_more': 'আরো লোড হচ্ছে...',
      'qb_results_found': 'ফলাফল পাওয়া গেছে',
      'qb_pull_refresh': 'রিফ্রেশ করতে টানুন',

      // Question Types
      'qb_type_mcq': 'বহুনির্বাচনী',
      'qb_type_mcq_desc': 'একাধিক অপশন সহ প্রশ্ন এবং একটি সঠিক উত্তর',
      'qb_type_true_false': 'সত্য/মিথ্যা',
      'qb_type_true_false_desc': 'সরল সত্য বা মিথ্যা বিবৃতি',
      'qb_type_short_answer': 'সংক্ষিপ্ত উত্তর',
      'qb_type_short_answer_desc': 'সংক্ষিপ্ত লিখিত উত্তর',
      'qb_type_essay': 'রচনা',
      'qb_type_essay_desc': 'বিস্তারিত লিখিত উত্তর',
      'qb_type_matching': 'মিলকরণ',
      'qb_type_matching_desc': 'দুই কলাম থেকে আইটেম মেলান',
      'qb_type_fill_blank': 'শূন্যস্থান পূরণ',
      'qb_type_fill_blank_desc': 'অনুপস্থিত শব্দ দিয়ে বাক্য পূর্ণ করুন',
      'qb_type_math': 'গণিত সমস্যা',
      'qb_type_math_desc': 'গাণিতিক সমীকরণ এবং গণনা',
      'qb_type_creative': 'সৃজনশীল প্রশ্ন',
      'qb_type_creative_desc': 'উপ-অংশ সহ কাঠামোবদ্ধ প্রশ্ন (সৃজনশীল)',

      // Form Labels
      'qb_step_type': 'ধরন নির্বাচন',
      'qb_step_basic': 'মৌলিক তথ্য',
      'qb_step_details': 'বিস্তারিত',
      'qb_step_preview': 'প্রিভিউ',
      'qb_class': 'শ্রেণী',
      'qb_class_hint': 'একটি শ্রেণী নির্বাচন করুন',
      'qb_subject': 'বিষয়',
      'qb_subject_hint': 'একটি বিষয় নির্বাচন করুন',
      'qb_marks': 'নম্বর',
      'qb_marks_hint': 'নম্বর লিখুন',
      'qb_question_text': 'প্রশ্নের টেক্সট',
      'qb_question_text_hint': 'এখানে আপনার প্রশ্ন লিখুন...',
      'qb_options': 'অপশন',
      'qb_option_hint': 'অপশনের টেক্সট লিখুন',
      'qb_add_option': 'অপশন যোগ করুন',
      'qb_correct_answer': 'সঠিক উত্তর',
      'qb_explanation': 'ব্যাখ্যা',
      'qb_explanation_hint': 'একটি ব্যাখ্যা যোগ করুন (ঐচ্ছিক)',
      'qb_expected_answer': 'প্রত্যাশিত উত্তর',
      'qb_expected_answer_hint': 'প্রত্যাশিত উত্তর লিখুন',
      'qb_word_count': 'প্রত্যাশিত শব্দ সংখ্যা',
      'qb_grading_guidelines': 'মূল্যায়ন নির্দেশিকা',
      'qb_grading_guidelines_hint': 'মূল্যায়ন নির্দেশিকা লিখুন (ঐচ্ছিক)',
      'qb_solution': 'সমাধানের ধাপ',
      'qb_solution_hint': 'সমাধানের ধাপ লিখুন',
      'qb_left_column': 'বাম কলাম',
      'qb_right_column': 'ডান কলাম',
      'qb_add_pair': 'জোড়া যোগ করুন',
      'qb_add_subquestion': 'উপ-প্রশ্ন যোগ করুন',
      'qb_subquestion': 'উপ-প্রশ্ন',
      'qb_blank_answer': 'শূন্যস্থানের উত্তর',
      'qb_shuffle_right': 'ডান কলাম এলোমেলো করুন',
      'qb_recent_types': 'সম্প্রতি ব্যবহৃত',

      // Actions
      'qb_next': 'পরবর্তী',
      'qb_previous': 'পূর্ববর্তী',
      'qb_save': 'প্রশ্ন সংরক্ষণ করুন',
      'qb_saving': 'সংরক্ষণ হচ্ছে...',
      'qb_cancel': 'বাতিল',
      'qb_edit': 'সম্পাদনা',
      'qb_delete': 'মুছুন',
      'qb_duplicate': 'অনুলিপি',
      'qb_view': 'দেখুন',
      'qb_logout': 'লগআউট',
      'qb_try_again': 'আবার চেষ্টা করুন',
      'qb_undo': 'পূর্বাবস্থায় ফিরুন',
      'qb_apply': 'প্রয়োগ করুন',
      'qb_reset': 'রিসেট',
      'qb_clear_filters': 'ফিল্টার মুছুন',
      'qb_create_another': 'আরেকটি তৈরি করুন',
      'qb_view_question': 'প্রশ্ন দেখুন',
      'qb_edit_question': 'প্রশ্ন সম্পাদনা',
      'qb_show_answers': 'উত্তর দেখুন',
      'qb_hide_answers': 'উত্তর লুকান',

      // Confirmations
      'qb_delete_title': 'প্রশ্ন মুছবেন?',
      'qb_delete_confirm': 'আপনি কি নিশ্চিত এই প্রশ্নটি মুছতে চান?',
      'qb_delete_warning': 'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।',
      'qb_logout_title': 'প্রশ্ন ব্যাংক থেকে লগআউট?',
      'qb_logout_confirm': 'প্রশ্ন ব্যাংকে প্রবেশ করতে আবার লগইন করতে হবে।',
      'qb_save_changes_title': 'পরিবর্তন সংরক্ষণ করবেন?',
      'qb_save_changes_confirm': 'আপনি কি আপনার পরিবর্তনগুলি সংরক্ষণ করতে চান?',
      'qb_discard_title': 'পরিবর্তন বাতিল করবেন?',
      'qb_discard_confirm': 'আপনার অসংরক্ষিত পরিবর্তনগুলি হারিয়ে যাবে।',
      'qb_draft_found': 'খসড়া পাওয়া গেছে',
      'qb_draft_restore':
          'আপনার একটি অসংরক্ষিত খসড়া আছে। পুনরুদ্ধার করতে চান?',
      'qb_restore': 'পুনরুদ্ধার',
      'qb_discard': 'বাতিল করুন',

      // Validation
      'qb_required': 'এই ফিল্ডটি আবশ্যক',
      'qb_min_marks': 'সর্বনিম্ন নম্বর ০.৫',
      'qb_min_options': 'কমপক্ষে ২টি অপশন যোগ করুন',
      'qb_max_options': 'সর্বোচ্চ ৬টি অপশন অনুমোদিত',
      'qb_select_correct': 'সঠিক উত্তর নির্বাচন করুন',
      'qb_option_empty': 'অপশন টেক্সট খালি রাখা যাবে না',
      'qb_min_pairs': 'কমপক্ষে ২টি মিলকরণ জোড়া যোগ করুন',
      'qb_blank_required': '[1], [2] বা ___ ব্যবহার করে শূন্যস্থান যোগ করুন',

      // Messages
      'qb_created': 'প্রশ্ন সফলভাবে তৈরি হয়েছে!',
      'qb_updated': 'প্রশ্ন সফলভাবে আপডেট হয়েছে!',
      'qb_deleted': 'প্রশ্ন মুছে ফেলা হয়েছে',
      'qb_restored': 'প্রশ্ন পুনরুদ্ধার হয়েছে',
      'qb_draft_saved': 'খসড়া সংরক্ষিত',
      'qb_error': 'কিছু ভুল হয়েছে',
      'qb_network_error': 'ইন্টারনেট সংযোগ নেই',
      'qb_session_expired': 'সেশন শেষ, দয়া করে আবার লগইন করুন',
      'qb_not_found': 'প্রশ্ন পাওয়া যায়নি',
      'qb_forbidden': 'এই কাজ করার অনুমতি নেই',

      // Filter
      'qb_filter_class': 'শ্রেণী অনুযায়ী ফিল্টার',
      'qb_filter_subject': 'বিষয় অনুযায়ী ফিল্টার',
      'qb_filter_type': 'ধরন অনুযায়ী ফিল্টার',
      'qb_filter_marks': 'নম্বর সীমা',
      'qb_all': 'সব',

      // Detail Screen
      'qb_question_details': 'প্রশ্নের বিস্তারিত',
      'qb_created_at': 'তৈরি হয়েছে',
      'qb_updated_at': 'শেষ আপডেট',
      'qb_marks_label': 'নম্বর',

      // Time
      'qb_just_now': 'এইমাত্র',
      'qb_minutes_ago': 'মিনিট আগে',
      'qb_hours_ago': 'ঘন্টা আগে',
      'qb_days_ago': 'দিন আগে',
      'qb_session_time': 'সেশন শেষ হবে',
    },
  };

  /// Get translation for key
  static String translate(String key, {String languageCode = 'en'}) {
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  /// Get translation with context (uses app locale)
  static String t(String key, bool isBangla) {
    final langCode = isBangla ? 'bn' : 'en';
    return translate(key, languageCode: langCode);
  }
}
