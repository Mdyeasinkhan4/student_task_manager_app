class AppConstants {
  AppConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // Priority values
  static const String priorityLow = 'Low';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh = 'High';

  static const List<String> priorities = [priorityLow, priorityMedium, priorityHigh];

  // Common subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Bengali',
    'History',
    'Geography',
    'Computer Science',
    'Other',
  ];

  // SharedPreferences keys
  static const String themeKey = 'isDarkMode';
}
