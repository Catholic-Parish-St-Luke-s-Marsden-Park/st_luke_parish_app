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

/// The current Pastoral Plan and Pastoral Council minutes links from the
/// parish home page. Auto-disposed, so they are read afresh each time the
/// Pastoral Plan is opened.

@ProviderFor(parishDocumentLinks)
final parishDocumentLinksProvider = ParishDocumentLinksProvider._();

/// The current Pastoral Plan and Pastoral Council minutes links from the
/// parish home page. Auto-disposed, so they are read afresh each time the
/// Pastoral Plan is opened.

final class ParishDocumentLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParishDocumentLinks>,
          ParishDocumentLinks,
          FutureOr<ParishDocumentLinks>
        >
    with
        $FutureModifier<ParishDocumentLinks>,
        $FutureProvider<ParishDocumentLinks> {
  /// The current Pastoral Plan and Pastoral Council minutes links from the
  /// parish home page. Auto-disposed, so they are read afresh each time the
  /// Pastoral Plan is opened.
  ParishDocumentLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parishDocumentLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parishDocumentLinksHash();

  @$internal
  @override
  $FutureProviderElement<ParishDocumentLinks> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ParishDocumentLinks> create(Ref ref) {
    return parishDocumentLinks(ref);
  }
}

String _$parishDocumentLinksHash() =>
    r'59d1d93c6779b4a5007bf84a508c1c104bd95a29';
