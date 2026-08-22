import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
}

class AdminUserListItem {
  const AdminUserListItem({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    required this.hasBusiness,
    required this.businessName,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool hasBusiness;
  final String? businessName;
}

class AdminBusinessSummary {
  const AdminBusinessSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.currency,
    required this.startingYear,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final String? category;
  final String currency;
  final int startingYear;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.business,
    required this.transactionCount,
    required this.loanCount,
    required this.simulationCount,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final AdminBusinessSummary? business;
  final int transactionCount;
  final int loanCount;
  final int simulationCount;
}

class AdminDailyCount {
  const AdminDailyCount({required this.day, required this.count});
  final DateTime day;
  final int count;
}

class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.adminUsers,
    required this.totalBusinesses,
    required this.totalTransactions,
    required this.totalLoans,
    required this.totalSimulations,
    required this.usersLast7Days,
    required this.usersLast30Days,
    required this.loginsLast7Days,
    required this.loginsLast30Days,
    required this.registrationSeries,
    required this.loginSeries,
  });

  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int adminUsers;
  final int totalBusinesses;
  final int totalTransactions;
  final int totalLoans;
  final int totalSimulations;
  final int usersLast7Days;
  final int usersLast30Days;
  final int loginsLast7Days;
  final int loginsLast30Days;
  final List<AdminDailyCount> registrationSeries;
  final List<AdminDailyCount> loginSeries;
}

class AdminActivityItem {
  const AdminActivityItem({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String? userEmail;
  final String? userFullName;
  final String action;
  final String? entity;
  final String? entityId;
  final String? metadata;
  final DateTime? createdAt;
}

class AdminActionResult {
  const AdminActionResult({required this.success, required this.message});
  final bool success;
  final String message;
}

DateTime? _parseDate(Object? v) {
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}

AdminDailyCount _parseDailyCount(Map<String, dynamic> json) {
  return AdminDailyCount(
    day: _parseDate(json['day']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

AdminUserListItem _parseUserListItem(Map<String, dynamic> json) {
  return AdminUserListItem(
    id: json['id']?.toString() ?? '',
    email: (json['email'] as String?) ?? '',
    fullName: (json['fullName'] as String?) ?? '',
    role: (json['role'] as String?) ?? 'User',
    isActive: json['isActive'] == true,
    createdAt: _parseDate(json['createdAt']),
    lastLoginAt: _parseDate(json['lastLoginAt']),
    hasBusiness: json['hasBusiness'] == true,
    businessName: json['businessName'] as String?,
  );
}

AdminBusinessSummary? _parseBusiness(Map<String, dynamic>? json) {
  if (json == null) return null;
  return AdminBusinessSummary(
    id: json['id']?.toString() ?? '',
    name: (json['name'] as String?) ?? '',
    type: (json['type'] as String?) ?? '',
    category: json['category'] as String?,
    currency: (json['currency'] as String?) ?? '',
    startingYear: (json['startingYear'] as num?)?.toInt() ?? 0,
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
  );
}

AdminUserDetail _parseUserDetail(Map<String, dynamic> json) {
  return AdminUserDetail(
    id: json['id']?.toString() ?? '',
    email: (json['email'] as String?) ?? '',
    fullName: (json['fullName'] as String?) ?? '',
    role: (json['role'] as String?) ?? 'User',
    isActive: json['isActive'] == true,
    createdAt: _parseDate(json['createdAt']),
    updatedAt: _parseDate(json['updatedAt']),
    lastLoginAt: _parseDate(json['lastLoginAt']),
    business: _parseBusiness(json['business'] as Map<String, dynamic>?),
    transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    loanCount: (json['loanCount'] as num?)?.toInt() ?? 0,
    simulationCount: (json['simulationCount'] as num?)?.toInt() ?? 0,
  );
}

AdminActivityItem _parseActivity(Map<String, dynamic> json) {
  return AdminActivityItem(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString(),
    userEmail: json['userEmail'] as String?,
    userFullName: json['userFullName'] as String?,
    action: (json['action'] as String?) ?? '',
    entity: json['entity'] as String?,
    entityId: json['entityId']?.toString(),
    metadata: json['metadataJson'] as String? ?? json['metadata'] as String?,
    createdAt: _parseDate(json['createdAt']),
  );
}

PagedResult<T> _parsePaged<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) parser,
) {
  final items = (json['items'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(parser)
      .toList();
  return PagedResult<T>(
    items: items,
    page: (json['page'] as num?)?.toInt() ?? 1,
    pageSize: (json['pageSize'] as num?)?.toInt() ?? items.length,
    totalItems: (json['totalItems'] as num?)?.toInt() ?? items.length,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
  );
}

class AdminRepository {
  AdminRepository(this._api);
  final ApiClient _api;

  Future<AdminStats> fetchStatistics() async {
    final raw = await _api.get('/api/v1/admin/statistics') as Map<String, dynamic>;
    final regSeries = (raw['registrationSeries30d'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseDailyCount)
        .toList();
    final loginSeries = (raw['loginSeries30d'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_parseDailyCount)
        .toList();
    return AdminStats(
      totalUsers: (raw['totalUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (raw['activeUsers'] as num?)?.toInt() ?? 0,
      inactiveUsers: (raw['inactiveUsers'] as num?)?.toInt() ?? 0,
      adminUsers: (raw['adminUsers'] as num?)?.toInt() ?? 0,
      totalBusinesses: (raw['totalBusinesses'] as num?)?.toInt() ?? 0,
      totalTransactions: (raw['totalTransactions'] as num?)?.toInt() ?? 0,
      totalLoans: (raw['totalLoans'] as num?)?.toInt() ?? 0,
      totalSimulations: (raw['totalSimulations'] as num?)?.toInt() ?? 0,
      usersLast7Days: (raw['usersLast7Days'] as num?)?.toInt() ?? 0,
      usersLast30Days: (raw['usersLast30Days'] as num?)?.toInt() ?? 0,
      loginsLast7Days: (raw['loginsLast7Days'] as num?)?.toInt() ?? 0,
      loginsLast30Days: (raw['loginsLast30Days'] as num?)?.toInt() ?? 0,
      registrationSeries: regSeries,
      loginSeries: loginSeries,
    );
  }

  Future<PagedResult<AdminUserListItem>> listUsers({
    String? search,
    bool? isActive,
    String? role,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (isActive != null) query['isActive'] = isActive.toString();
    if (role != null && role.isNotEmpty) query['role'] = role;
    final raw = await _api.get('/api/v1/admin/users', query: query)
        as Map<String, dynamic>;
    return _parsePaged<AdminUserListItem>(raw, _parseUserListItem);
  }

  Future<AdminUserDetail> getUser(String id) async {
    final raw = await _api.get('/api/v1/admin/users/$id') as Map<String, dynamic>;
    return _parseUserDetail(raw);
  }

  Future<AdminActionResult> setActive({
    required String userId,
    required bool active,
  }) async {
    final action = active ? 'activate' : 'deactivate';
    final raw = await _api.post(
      '/api/v1/admin/users/$userId/$action',
      body: <String, dynamic>{},
    ) as Map<String, dynamic>;
    return AdminActionResult(
      success: raw['success'] == true,
      message: (raw['message'] as String?) ?? 'Done',
    );
  }

  Future<AdminActionResult> deleteUser(String userId) async {
    final raw = await _api.delete('/api/v1/admin/users/$userId')
        as Map<String, dynamic>;
    return AdminActionResult(
      success: raw['success'] == true,
      message: (raw['message'] as String?) ?? 'Done',
    );
  }

  Future<PagedResult<AdminActivityItem>> userActivity(
    String userId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final raw = await _api.get(
      '/api/v1/admin/users/$userId/activity',
      query: {'page': page, 'pageSize': pageSize},
    ) as Map<String, dynamic>;
    return _parsePaged<AdminActivityItem>(raw, _parseActivity);
  }

  Future<PagedResult<AdminActivityItem>> globalActivity({
    String? search,
    String? action,
    int page = 1,
    int pageSize = 50,
  }) async {
    final query = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();
    if (action != null && action.isNotEmpty) query['action'] = action;
    final raw = await _api.get('/api/v1/admin/activity', query: query)
        as Map<String, dynamic>;
    return _parsePaged<AdminActivityItem>(raw, _parseActivity);
  }

  Future<List<AdminActivityItem>> recentActivity({int top = 20}) async {
    final raw = await _api.get(
      '/api/v1/admin/activity/recent',
      query: {'take': top},
    ) as List<dynamic>;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parseActivity)
        .toList();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);
