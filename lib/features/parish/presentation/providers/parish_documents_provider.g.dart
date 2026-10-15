// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parish_documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the website-backed repository behind the abstract contract.

@ProviderFor(parishDocumentsRepository)
final parishDocumentsRepositoryProvider = ParishDocumentsRepositoryProvider._();

/// Wires the website-backed repository behind the abstract contract.

final class ParishDocumentsRepositoryProvider
    extends
        $FunctionalProvider<
          ParishDocumentsRepository,
          ParishDocumentsRepository,
          ParishDocumentsRepository
        >
    with $Provider<ParishDocumentsRepository> {
  /// Wires the website-backed repository behind the abstract contract.
  ParishDocumentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parishDocumentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parishDocumentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParishDocumentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParishDocumentsRepository create(Ref ref) {
    return parishDocumentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParishDocumentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParishDocumentsRepository>(value),
    );
  }
}

String _$parishDocumentsRepositoryHash() =>
    r'8db8136bd12055d40e509eacaff7defac734442c';

/// The latest Pastoral Council minutes URL from the parish home page.
/// Auto-disposed, so it is read afresh each time the Pastoral Plan is
/// opened.

@ProviderFor(latestCouncilMinutesUrl)
final latestCouncilMinutesUrlProvider = LatestCouncilMinutesUrlProvider._();

/// The latest Pastoral Council minutes URL from the parish home page.
/// Auto-disposed, so it is read afresh each time the Pastoral Plan is
/// opened.

final class LatestCouncilMinutesUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The latest Pastoral Council minutes URL from the parish home page.
  /// Auto-disposed, so it is read afresh each time the Pastoral Plan is
  /// opened.
  LatestCouncilMinutesUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestCouncilMinutesUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestCouncilMinutesUrlHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return latestCouncilMinutesUrl(ref);
  }
}

String _$latestCouncilMinutesUrlHash() =>
    r'706f845073ec846ddb07b109f3449f71ec94165d';
