// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_base_uri_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Origin of the parish API (parish_app_service), e.g.
/// `https://parish-app-service.fly.dev`, or null when it isn't configured.
///
/// Read from `API_BASE_URL` in assets/app.env. Until that is set, falls back
/// to the origin of `BASE_URL`, which holds the full `/tokens` endpoint on
/// the same service. dotenv throws if assets/app.env never loaded (main.dart
/// logs and carries on), so that case is treated as both keys missing.

@ProviderFor(apiBaseUri)
final apiBaseUriProvider = ApiBaseUriProvider._();

/// Origin of the parish API (parish_app_service), e.g.
/// `https://parish-app-service.fly.dev`, or null when it isn't configured.
///
/// Read from `API_BASE_URL` in assets/app.env. Until that is set, falls back
/// to the origin of `BASE_URL`, which holds the full `/tokens` endpoint on
/// the same service. dotenv throws if assets/app.env never loaded (main.dart
/// logs and carries on), so that case is treated as both keys missing.

final class ApiBaseUriProvider extends $FunctionalProvider<Uri?, Uri?, Uri?>
    with $Provider<Uri?> {
  /// Origin of the parish API (parish_app_service), e.g.
  /// `https://parish-app-service.fly.dev`, or null when it isn't configured.
  ///
  /// Read from `API_BASE_URL` in assets/app.env. Until that is set, falls back
  /// to the origin of `BASE_URL`, which holds the full `/tokens` endpoint on
  /// the same service. dotenv throws if assets/app.env never loaded (main.dart
  /// logs and carries on), so that case is treated as both keys missing.
  ApiBaseUriProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiBaseUriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUriHash();

  @$internal
  @override
  $ProviderElement<Uri?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri? create(Ref ref) {
    return apiBaseUri(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$apiBaseUriHash() => r'7914176bb547c399fa42f366d2d09779f42bcf26';
