import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

enum TransactionType { revenue, expense }

extension TransactionTypeX on TransactionType {
  String get wire {
    switch (this) {
      case TransactionType.revenue:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  static TransactionType fromWire(String value) {
    final v = value.toLowerCase();
    if (v == 'income' || v == 'revenue') return TransactionType.revenue;
    return TransactionType.expense;
  }
}

class TransactionModel {
  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.description,
    required this.occurredAt,
    required this.createdAt,
  });

  final String id;
  final TransactionType type;
  final String category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime occurredAt;
  final DateTime createdAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionTypeX.fromWire((json['type'] as String?) ?? 'Expense'),
      category: (json['category'] as String?) ?? 'General',
      amount: _toDouble(json['amount']),
      currency: (json['currency'] as String?) ?? 'USD',
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.parse(json['occurredAt'] as String),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

String _isoUtc(DateTime dt) {
  final s = dt.toUtc().toIso8601String();
  return s.endsWith('Z') || s.contains('+') ? s : '${s}Z';
}

class TransactionPage {
  TransactionPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<TransactionModel> items;
  final int total;
  final int page;
  final int pageSize;
}

class TransactionRepository {
  TransactionRepository(this._api, this._ref);
  final ApiClient _api;
  final Ref _ref;

  Future<TransactionPage> list({
    TransactionType? type,
    String? category,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) async {
    final query = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (type != null) query['type'] = type.wire;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (from != null) query['from'] = _isoUtc(from);
    if (to != null) query['to'] = _isoUtc(to);

    final response = await _api.get('/api/v1/transactions', query: query);
    final map = response as Map<String, dynamic>;
    final rawItems = (map['items'] as List?) ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .map(TransactionModel.fromJson)
        .toList();
    return TransactionPage(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? page,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? pageSize,
    );
  }

  Future<TransactionModel> create({
    required TransactionType type,
    required String category,
    required double amount,
    String? description,
    DateTime? occurredAt,
  }) async {
    final response = await _api.post(
      '/api/v1/transactions',
      body: {
        'type': type.wire,
        'category': category,
        'amount': amount,
        if (description != null && description.isNotEmpty)
          'description': description,
        'occurredAt': (occurredAt ?? DateTime.now()).toUtc().toIso8601String(),
      },
    );
    final created = TransactionModel.fromJson(response as Map<String, dynamic>);
    // Cascade refresh so dashboards / health / recent lists update immediately.
    _ref.invalidate(transactionListInvalidationProvider);
    return created;
  }

  Future<void> delete(String id) async {
    await _api.delete('/api/v1/transactions/$id');
  }
}

final transactionListInvalidationProvider = Provider<void>((ref) {});

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(apiClientProvider), ref),
);
