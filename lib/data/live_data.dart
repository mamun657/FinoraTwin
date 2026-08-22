import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/transaction_repository.dart';

final transactionVersionProvider = Provider<int>((ref) {
  ref.watch(transactionListInvalidationProvider);
  return DateTime.now().millisecondsSinceEpoch;
});

final addTransactionPulseProvider = Provider<int>((ref) {
  ref.watch(transactionListInvalidationProvider);
  return DateTime.now().microsecondsSinceEpoch;
});

final aiConversationVersionProvider = StateProvider<int>((ref) => 0);

final liveDataVersionProvider = Provider<int>((ref) {
  final tx = ref.watch(transactionVersionProvider);
  final ai = ref.watch(aiConversationVersionProvider);
  return tx ^ ai;
});
