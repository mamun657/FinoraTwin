import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

class FinancialHealth {
  FinancialHealth({
    required this.overallScore,
    required this.status,
    required this.cashFlowStabilityScore,
    required this.expenseControlScore,
    required this.debtBurdenScore,
    required this.cashBufferScore,
    required this.revenueStabilityScore,
    required this.cashBufferWeeks,
    required this.cashBufferMonths,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
    required this.monthlyNet,
    required this.outstandingDebt,
    required this.totalIncomeAllTime,
    required this.totalExpensesAllTime,
    required this.recommendations,
    required this.alerts,
  });

  final double overallScore;
  final String status;
  final double cashFlowStabilityScore;
  final double expenseControlScore;
  final double debtBurdenScore;
  final double cashBufferScore;
  final double revenueStabilityScore;
  final double cashBufferWeeks;
  final double cashBufferMonths;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final double monthlyNet;
  final double outstandingDebt;
  final double totalIncomeAllTime;
  final double totalExpensesAllTime;
  final List<String> recommendations;
  final List<String> alerts;

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    double d(dynamic value) => value == null ? 0 : (value as num).toDouble();
    return FinancialHealth(
      overallScore: d(json['overallScore']),
      status: (json['status'] as String?) ?? 'Fair',
      cashFlowStabilityScore: d(json['cashFlowStabilityScore']),
      expenseControlScore: d(json['expenseControlScore']),
      debtBurdenScore: d(json['debtBurdenScore']),
      cashBufferScore: d(json['cashBufferScore']),
      revenueStabilityScore: d(json['revenueStabilityScore']),
      cashBufferWeeks: d(json['cashBufferWeeks']),
      cashBufferMonths: d(json['cashBufferMonths']),
      monthlyRevenue: d(json['monthlyRevenue']),
      monthlyExpenses: d(json['monthlyExpenses']),
      monthlyNet: d(json['monthlyNet']),
      outstandingDebt: d(json['outstandingDebt']),
      totalIncomeAllTime: d(json['totalIncomeAllTime']),
      totalExpensesAllTime: d(json['totalExpensesAllTime']),
      recommendations: ((json['recommendations'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      alerts: ((json['alerts'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class CashFlowMetrics {
  CashFlowMetrics({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netCashFlow,
    required this.transactionsCount,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netCashFlow;
  final int transactionsCount;

  factory CashFlowMetrics.fromJson(Map<String, dynamic> json) {
    double d(dynamic value) => value == null ? 0 : (value as num).toDouble();
    return CashFlowMetrics(
      totalIncome: d(json['totalIncome']),
      totalExpenses: d(json['totalExpenses']),
      netCashFlow: d(json['netCashFlow']),
      transactionsCount: (json['transactionsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FinancialRepository {
  FinancialRepository(this._api);
  final ApiClient _api;

  Future<FinancialHealth> health() async {
    final response = await _api.get('/api/v1/financial/health');
    return FinancialHealth.fromJson(response as Map<String, dynamic>);
  }

  Future<CashFlowMetrics> cashflow({DateTime? from, DateTime? to}) async {
    final query = <String, dynamic>{};
    if (from != null) query['from'] = from.toIso8601String();
    if (to != null) query['to'] = to.toIso8601String();
    final response = await _api.get('/api/v1/financial/cashflow', query: query);
    return CashFlowMetrics.fromJson(response as Map<String, dynamic>);
  }
}

final financialRepositoryProvider = Provider<FinancialRepository>(
  (ref) => FinancialRepository(ref.watch(apiClientProvider)),
);
