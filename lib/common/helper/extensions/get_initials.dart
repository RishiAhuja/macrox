extension GetInitials on String {
  String getInitials() {
    if (isEmpty) return '';

    List<String> names = this.trim().split(' ');
    String initials = names
        .where((name) => name.isNotEmpty)
        .map((name) => name[0].toUpperCase())
        .take(2)
        .join('');
    return initials;
  }
}
