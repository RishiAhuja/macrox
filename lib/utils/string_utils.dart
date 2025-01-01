class StringUtils {
  static String generateSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username);
  }
}
