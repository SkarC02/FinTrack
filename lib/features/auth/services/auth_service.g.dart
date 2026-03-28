part of 'auth_service.dart';

String _$authStateHash() => r'd8eb17123e8971f9b8086bb415a4b2bde52779e2';

@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'2120536e3f58e42755d64b11f413d5fa4dc1ffb7';

@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef CurrentUserRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$authServiceHash() => r'0dfa6cd7b3d2c42d27d44dbdbba6d3799e31f428';

@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
