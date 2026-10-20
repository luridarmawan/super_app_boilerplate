import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_interface/module_interface.dart' as modules;
import 'package:super_app/core/auth/auth_interface.dart';
import 'package:super_app/core/auth/token_refresh_service.dart' as core;
import 'package:super_app/core/config/app_config.dart';

/// Auth service palsu: login/logout cukup mengirim user baru ke stream.
class _FakeAuth implements BaseAuthService {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  void emit(AuthUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;
  @override
  AuthUser? get currentUser => _user;
  @override
  String? get accessToken => _user?.jwt;
  @override
  Future<String?> refreshAccessToken() async => _user?.jwt;
  @override
  void dispose() => _controller.close();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('sessionUserIdProvider follows sign-in, sign-out and switching accounts', () async {
    final auth = _FakeAuth();
    final container = ProviderContainer(
      overrides: [moduleSessionOverride, authServiceProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);

    // A module provider that caches per-user data, the way arrow_sense does.
    var loads = 0;
    final itemsProvider = FutureProvider<String>((ref) async {
      final uid = ref.watch(modules.sessionUserIdProvider);
      loads++;
      return 'items of $uid';
    });
    final sub = container.listen(itemsProvider, (_, _) {});
    addTearDown(sub.close);

    expect(container.read(modules.sessionUserIdProvider), isNull);

    auth.emit(AuthUser(uid: 'user-a', jwt: 'tok-a'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(modules.sessionUserIdProvider), 'user-a');
    expect(await container.read(itemsProvider.future), 'items of user-a');

    auth.emit(null);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(modules.sessionUserIdProvider), isNull);

    auth.emit(AuthUser(uid: 'user-b', jwt: 'tok-b'));
    await Future<void>.delayed(Duration.zero);
    expect(await container.read(itemsProvider.future), 'items of user-b');
    expect(loads, greaterThanOrEqualTo(3));
  });

  test('the app and modules share one TokenRefreshService with the provider handler', () async {
    expect(identical(core.TokenRefreshService.instance, modules.TokenRefreshService.instance), isTrue);
    modules.TokenRefreshService.instance.setRefreshHandler((jwt) async => '$jwt-fresh');
    addTearDown(() => modules.TokenRefreshService.instance.setRefreshHandler(null));
    // A module calls the module_interface instance; the app's provider registered the handler.
    expect(await modules.TokenRefreshService.instance.refreshToken(currentJwt: 'tok'), 'tok-fresh');
  });
}
