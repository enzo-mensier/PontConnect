class UserSession {
  static int? userId;
  static String? userName;
  static String? userEmail;

  static void setUser({required int id, required String name, required String email}) {
    userId = id;
    userName = name;
    userEmail = email;
  }

  static void clear() {
    userId = null;
    userName = null;
    userEmail = null;
  }
}