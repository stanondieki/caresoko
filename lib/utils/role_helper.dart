// Centralised access to the logged-in user's role.
//
// The role is stored on the user record returned by `u_reg_user.php` and
// `u_login_user.php` and persisted under the `UserLogin` key in GetStorage.
// Any screen that needs to branch behaviour by role should call these helpers
// instead of touching `UserLogin["user_type"]` directly.

import 'package:gotocarefinder/Api/data_store.dart';

/// Returns the current user's role string ("provider" or "recipient").
/// Defaults to "recipient" when the user is logged out or the field is absent,
/// matching the backend default and keeping legacy users on the recipient flow.
String currentUserType() {
  final user = getData.read("UserLogin");
  if (user == null) return "recipient";
  final raw = user["user_type"];
  if (raw == null || raw.toString().isEmpty) return "recipient";
  return raw.toString();
}

bool isProvider() => currentUserType() == "provider";
bool isRecipient() => currentUserType() == "recipient";
