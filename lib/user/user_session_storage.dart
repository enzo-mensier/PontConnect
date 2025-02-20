class UserSession {
  static int? userId;
  static String? userName;
  static String? userEmail;
  static int? typeUserId;


  // SET USER
  static void setUser({required int id, required String name, required String email,required int type}) {
    userId = id;
    userName = name;
    userEmail = email;
    typeUserId = type;
  }

  // CLEAR USER
  static void clear() {
    userId = null;
    userName = null;
    userEmail = null;
    typeUserId = null;
  }
}