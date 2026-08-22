import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

class BusinessModel {
  BusinessModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.startingYear,
    required this.currency,
    required this.monthlyOpEx,
    required this.currentCashBuffer,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final String category;
  final int startingYear;
  final String currency;
  final double monthlyOpEx;
  final double currentCashBuffer;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Business',
      type: (json['type'] as String?) ?? 'Other',
      category: (json['category'] as String?) ?? 'General',
      startingYear:
          (json['startingYear'] as num?)?.toInt() ?? DateTime.now().year,
      currency: (json['currency'] as String?) ?? 'USD',
      monthlyOpEx: _toDouble(json['monthlyOpEx']),
      currentCashBuffer: _toDouble(json['currentCashBuffer']),
      createdAt:
          DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

class BusinessRepository {
  BusinessRepository(this._api);
  final ApiClient _api;

  Future<BusinessModel> get() async {
    final response = await _api.get('/api/v1/business');
    return BusinessModel.fromJson(response as Map<String, dynamic>);
  }

  Future<BusinessModel> update({
    String? name,
    String? type,
    String? category,
    int? startingYear,
    String? currency,
    double? monthlyOpEx,
    double? currentCashBuffer,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = type;
    if (category != null) body['category'] = category;
    if (startingYear != null) body['startingYear'] = startingYear;
    if (currency != null) body['currency'] = currency;
    if (monthlyOpEx != null) body['monthlyOpEx'] = monthlyOpEx;
    if (currentCashBuffer != null) {
      body['currentCashBuffer'] = currentCashBuffer;
    }
    final response = await _api.put('/api/v1/business', body: body);
    return BusinessModel.fromJson(response as Map<String, dynamic>);
  }
}

final businessRepositoryProvider = Provider<BusinessRepository>(
  (ref) => BusinessRepository(ref.watch(apiClientProvider)),
);
