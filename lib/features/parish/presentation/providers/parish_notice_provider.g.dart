// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parish_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the website-backed repository behind the abstract contract.

@ProviderFor(parishNoticeRepository)
final parishNoticeRepositoryProvider = ParishNoticeRepositoryProvider._();

/// Wires the website-backed repository behind the abstract contract.

final class ParishNoticeRepositoryProvider
    extends
        $FunctionalProvider<
          ParishNoticeRepository,
          ParishNoticeRepository,
          ParishNoticeRepository
        >
    with $Provider<ParishNoticeRepository> {
  /// Wires the website-backed repository behind the abstract contract.
  ParishNoticeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parishNoticeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parishNoticeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ParishNoticeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ParishNoticeRepository create(Ref ref) {
    return parishNoticeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParishNoticeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParishNoticeRepository>(value),
    );
  }
}

String _$parishNoticeRepositoryHash() =>
    r'9cf12ed338a89a35aa3fcde8c0e0b85ae18c8dd2';

/// The home page's current pop-up notice (`null` when there is none).
/// Auto-disposed, so it is read afresh each time Special Announcements
/// opens.

@ProviderFor(currentParishNotice)
final currentParishNoticeProvider = CurrentParishNoticeProvider._();

/// The home page's current pop-up notice (`null` when there is none).
/// Auto-disposed, so it is read afresh each time Special Announcements
/// opens.

final class CurrentParishNoticeProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParishNotice?>,
          ParishNotice?,
          FutureOr<ParishNotice?>
        >
    with $FutureModifier<ParishNotice?>, $FutureProvider<ParishNotice?> {
  /// The home page's current pop-up notice (`null` when there is none).
  /// Auto-disposed, so it is read afresh each time Special Announcements
  /// opens.
  CurrentParishNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentParishNoticeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentParishNoticeHash();

  @$internal
  @override
  $FutureProviderElement<ParishNotice?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ParishNotice?> create(Ref ref) {
    return currentParishNotice(ref);
  }
}

String _$currentParishNoticeHash() =>
    r'c37bb10d340a1082873863ef19d8ebb0651110bf';
