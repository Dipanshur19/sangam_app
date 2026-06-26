// =========================================================================
// PATCH: auth_service.dart
// =========================================================================
// ADD these two methods inside your AuthService class:
// =========================================================================

/*
  Future<AppUser?> loginWithInviteToken({
    required String staffId,
    required String shopId,
    required String token,
  }) async {
    final p = await SharedPreferences.getInstance();
    final storedToken = p.getString('invite_token_\$staffId');
    if (storedToken == null || storedToken != token) return null;
    final users = await getUsers();
    try { return users.firstWhere((u) => u.id == staffId); }
    catch (_) { return null; }
  }

  Future<String> generateInviteToken(String staffId) async {
    final token = const Uuid().v4().replaceAll('-', '').substring(0, 16);
    final p = await SharedPreferences.getInstance();
    await p.setString('invite_token_\$staffId', token);
    return token;
  }
*/
