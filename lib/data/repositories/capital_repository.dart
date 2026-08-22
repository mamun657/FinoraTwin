import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

class SimulationResult {
  SimulationResult({
    required this.requestedAmount,
    required this.recommendedAmount,
    required this.projectedRevenue,
    required this.projectedExpenses,
    required this.projectedCashFlow,
    required this.monthlyRepaymentEstimate,
    required this.maximumSustainableAmount,
    required this.projectedCashBuffer,
    required this.riskScore,
    required this.riskLevel,
    required this.currency,
    required this.notes,
    required this.scenarios,
    required this.stressTest,
    required this.generatedAt,
  });

  final double requestedAmount;
  final double recommendedAmount;
  final double projectedRevenue;
  final double projectedExpenses;
  final double projectedCashFlow;
  final double monthlyRepaymentEstimate;
  final double maximumSustainableAmount;
  final double projectedCashBuffer;
  final double riskScore;
  final String riskLevel;
  final String currency;
  final List<String> notes;
  final List<SimulationScenario> scenarios;
  final StressTestResult stressTest;
  final DateTime generatedAt;

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    double d(dynamic value) => value == null ? 0 : (value as num).toDouble();
    return SimulationResult(
      requestedAmount: d(json['requestedAmount']),
      recommendedAmount: d(json['recommendedAmount']),
      projectedRevenue: d(json['projectedRevenue']),
      projectedExpenses: d(json['projectedExpenses']),
      projectedCashFlow: d(json['projectedCashFlow']),
      monthlyRepaymentEstimate: d(json['monthlyRepaymentEstimate']),
      maximumSustainableAmount: d(json['maximumSustainableAmount']),
      projectedCashBuffer: d(json['projectedCashBuffer']),
      riskScore: d(json['riskScore']),
      riskLevel: (json['riskLevel'] as String?) ?? 'Moderate',
      currency: (json['currency'] as String?) ?? 'USD',
      notes: ((json['notes'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      scenarios: ((json['scenarios'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(SimulationScenario.fromJson)
          .toList(),
      stressTest: StressTestResult.fromJson(
        (json['stressTest'] as Map<String, dynamic>?) ?? const {},
      ),
      generatedAt:
          DateTime.tryParse((json['generatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class SimulationScenario {
  SimulationScenario({
    required this.label,
    required this.amount,
    required this.monthlyRepayment,
    required this.percentOfRevenue,
    required this.feasible,
  });

  final String label;
  final double amount;
  final double monthlyRepayment;
  final double percentOfRevenue;
  final bool feasible;

  factory SimulationScenario.fromJson(Map<String, dynamic> json) {
    return SimulationScenario(
      label: (json['label'] as String?) ?? '',
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      monthlyRepayment: ((json['monthlyRepayment'] as num?) ?? 0).toDouble(),
      percentOfRevenue: ((json['percentOfRevenue'] as num?) ?? 0).toDouble(),
      feasible: (json['feasible'] as bool?) ?? false,
    );
  }
}

class StressTestResult {
  StressTestResult({
    required this.adjustedRevenue,
    required this.adjustedExpenses,
    required this.adjustedNetCashFlow,
    required this.adjustedCashBufferWeeks,
    required this.riskLevel,
    required this.notes,
  });

  final double adjustedRevenue;
  final double adjustedExpenses;
  final double adjustedNetCashFlow;
  final double adjustedCashBufferWeeks;
  final String riskLevel;
  final List<String> notes;

  factory StressTestResult.fromJson(Map<String, dynamic> json) {
    double d(dynamic value) => value == null ? 0 : (value as num).toDouble();
    return StressTestResult(
      adjustedRevenue: d(json['adjustedRevenue']),
      adjustedExpenses: d(json['adjustedExpenses']),
      adjustedNetCashFlow: d(json['adjustedNetCashFlow']),
      adjustedCashBufferWeeks: d(json['adjustedCashBufferWeeks']),
      riskLevel: (json['riskLevel'] as String?) ?? 'Moderate',
      notes: ((json['notes'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class CapitalRepository {
  CapitalRepository(this._api);
  final ApiClient _api;

  Future<SimulationResult> simulate({
    required double requestedAmount,
    String? purpose,
    int termMonths = 12,
    double annualInterestRate = 12,
    double salesChangePercent = 0,
  }) async {
    final body = <String, dynamic>{
      'requestedAmount': requestedAmount,
      'purpose': (purpose == null || purpose.isEmpty)
          ? 'Working capital'
          : purpose,
      'termMonths': termMonths,
      'annualInterestRate': annualInterestRate,
      'salesChangePercent': salesChangePercent,
    };
    final response = await _api.post('/api/v1/capital/simulate', body: body);
    return SimulationResult.fromJson(response as Map<String, dynamic>);
  }

  Future<StressTestResult> stressTest({
    double salesChangePercent = -20,
    double expenseChangePercent = 0,
  }) async {
    final response = await _api.post(
      '/api/v1/capital/stress-test',
      body: {
        'salesChangePercent': salesChangePercent,
        'expenseChangePercent': expenseChangePercent,
      },
    );
    return StressTestResult.fromJson(response as Map<String, dynamic>);
  }
}

final capitalRepositoryProvider = Provider<CapitalRepository>(
  (ref) => CapitalRepository(ref.watch(apiClientProvider)),
);
