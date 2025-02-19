class UserSession {
  static int? userId;
  static String? userName;
  static String? userEmail;

  // SET USER
  static void setUser({required int id, required String name, required String email}) {
    userId = id;
    userName = name;
    userEmail = email;
  }

  // CLEAR USER
  static void clear() {
    userId = null;
    userName = null;
    userEmail = null;
  }
}