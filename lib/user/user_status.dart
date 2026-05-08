enum UserStatus {
  pending('pending'),
  active('active'),
  suspended('suspended'),
  inactive('inactive');

  const UserStatus(this.value);

  final String value;

  static UserStatus fromValue(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse:
          () =>
              throw ArgumentError.value(value, 'value', 'Unknown user status'),
    );
  }
}
