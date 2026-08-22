import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/business_repository.dart';

class ActiveBusinessState {
  const ActiveBusinessState({
    this.business,
    this.loading = false,
    this.error,
    this.notFound = false,
  });

  final BusinessModel? business;
  final bool loading;
  final String? error;
  final bool notFound;

  ActiveBusinessState copyWith({
    BusinessModel? business,
    bool? loading,
    String? error,
    bool? notFound,
    bool clearError = false,
    bool clearBusiness = false,
  }) {
    return ActiveBusinessState(
      business: clearBusiness ? null : business ?? this.business,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      notFound: notFound ?? this.notFound,
    );
  }

  bool get hasBusiness => business != null;
}

/// Resolved currency for the active business. Falls back to USD when the
/// business hasn't loaded yet so callers can format safely.
final activeBusinessCurrencyProvider = Provider<String>((ref) {
  final state = ref.watch(activeBusinessControllerProvider);
  final code = state.business?.currency;
  if (code == null || code.isEmpty) return 'USD';
  return code;
});

class ActiveBusinessController extends StateNotifier<ActiveBusinessState> {
  ActiveBusinessController(this._ref)
    : super(const ActiveBusinessState(loading: true)) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = _ref.read(businessRepositoryProvider);
      final business = await repo.get();
      state = ActiveBusinessState(business: business, loading: false);
    } catch (e) {
      final is404 =
          e.toString().contains('404') || e.toString().contains('not_found');
      state = state.copyWith(
        loading: false,
        error: e.toString(),
        notFound: is404,
      );
    }
  }

  Future<void> update({
    String? name,
    String? type,
    String? category,
    int? startingYear,
    String? currency,
    double? monthlyOpEx,
    double? currentCashBuffer,
  }) async {
    final repo = _ref.read(businessRepositoryProvider);
    final updated = await repo.update(
      name: name,
      type: type,
      category: category,
      startingYear: startingYear,
      currency: currency,
      monthlyOpEx: monthlyOpEx,
      currentCashBuffer: currentCashBuffer,
    );
    state = state.copyWith(business: updated);
  }

  void clear() {
    state = const ActiveBusinessState();
  }
}

final activeBusinessControllerProvider =
    StateNotifierProvider<ActiveBusinessController, ActiveBusinessState>(
      (ref) => ActiveBusinessController(ref),
    );
