// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedTransactionsTable extends CachedTransactions
    with TableInfo<$CachedTransactionsTable, CachedTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    type,
    category,
    amount,
    currency,
    description,
    occurredAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $CachedTransactionsTable createAlias(String alias) {
    return $CachedTransactionsTable(attachedDatabase, alias);
  }
}

class CachedTransaction extends DataClass
    implements Insertable<CachedTransaction> {
  final String id;
  final String businessId;
  final String type;
  final String category;
  final double amount;
  final String currency;
  final String? description;
  final String occurredAt;
  final DateTime syncedAt;
  const CachedTransaction({
    required this.id,
    required this.businessId,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    this.description,
    required this.occurredAt,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['occurred_at'] = Variable<String>(occurredAt);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  CachedTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CachedTransactionsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      currency: Value(currency),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      occurredAt: Value(occurredAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory CachedTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTransaction(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      description: serializer.fromJson<String?>(json['description']),
      occurredAt: serializer.fromJson<String>(json['occurredAt']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'description': serializer.toJson<String?>(description),
      'occurredAt': serializer.toJson<String>(occurredAt),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  CachedTransaction copyWith({
    String? id,
    String? businessId,
    String? type,
    String? category,
    double? amount,
    String? currency,
    Value<String?> description = const Value.absent(),
    String? occurredAt,
    DateTime? syncedAt,
  }) => CachedTransaction(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    type: type ?? this.type,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    description: description.present ? description.value : this.description,
    occurredAt: occurredAt ?? this.occurredAt,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  CachedTransaction copyWithCompanion(CachedTransactionsCompanion data) {
    return CachedTransaction(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      description: data.description.present
          ? data.description.value
          : this.description,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTransaction(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    type,
    category,
    amount,
    currency,
    description,
    occurredAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTransaction &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.description == this.description &&
          other.occurredAt == this.occurredAt &&
          other.syncedAt == this.syncedAt);
}

class CachedTransactionsCompanion extends UpdateCompanion<CachedTransaction> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> type;
  final Value<String> category;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String?> description;
  final Value<String> occurredAt;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const CachedTransactionsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTransactionsCompanion.insert({
    required String id,
    required String businessId,
    required String type,
    required String category,
    required double amount,
    this.currency = const Value.absent(),
    this.description = const Value.absent(),
    required String occurredAt,
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       type = Value(type),
       category = Value(category),
       amount = Value(amount),
       occurredAt = Value(occurredAt),
       syncedAt = Value(syncedAt);
  static Insertable<CachedTransaction> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? description,
    Expression<String>? occurredAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (description != null) 'description': description,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? type,
    Value<String>? category,
    Value<double>? amount,
    Value<String>? currency,
    Value<String?>? description,
    Value<String>? occurredAt,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return CachedTransactionsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSnapshotsTable extends CachedSnapshots
    with TableInfo<$CachedSnapshotsTable, CachedSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    score,
    status,
    payloadJson,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $CachedSnapshotsTable createAlias(String alias) {
    return $CachedSnapshotsTable(attachedDatabase, alias);
  }
}

class CachedSnapshot extends DataClass implements Insertable<CachedSnapshot> {
  final String id;
  final String businessId;
  final double score;
  final String status;
  final String payloadJson;
  final DateTime generatedAt;
  const CachedSnapshot({
    required this.id,
    required this.businessId,
    required this.score,
    required this.status,
    required this.payloadJson,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['score'] = Variable<double>(score);
    map['status'] = Variable<String>(status);
    map['payload_json'] = Variable<String>(payloadJson);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  CachedSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return CachedSnapshotsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      score: Value(score),
      status: Value(status),
      payloadJson: Value(payloadJson),
      generatedAt: Value(generatedAt),
    );
  }

  factory CachedSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSnapshot(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      score: serializer.fromJson<double>(json['score']),
      status: serializer.fromJson<String>(json['status']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'score': serializer.toJson<double>(score),
      'status': serializer.toJson<String>(status),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  CachedSnapshot copyWith({
    String? id,
    String? businessId,
    double? score,
    String? status,
    String? payloadJson,
    DateTime? generatedAt,
  }) => CachedSnapshot(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    score: score ?? this.score,
    status: status ?? this.status,
    payloadJson: payloadJson ?? this.payloadJson,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  CachedSnapshot copyWithCompanion(CachedSnapshotsCompanion data) {
    return CachedSnapshot(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      score: data.score.present ? data.score.value : this.score,
      status: data.status.present ? data.status.value : this.status,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSnapshot(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, businessId, score, status, payloadJson, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSnapshot &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.score == this.score &&
          other.status == this.status &&
          other.payloadJson == this.payloadJson &&
          other.generatedAt == this.generatedAt);
}

class CachedSnapshotsCompanion extends UpdateCompanion<CachedSnapshot> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<double> score;
  final Value<String> status;
  final Value<String> payloadJson;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const CachedSnapshotsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.score = const Value.absent(),
    this.status = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSnapshotsCompanion.insert({
    required String id,
    required String businessId,
    required double score,
    required String status,
    required String payloadJson,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       score = Value(score),
       status = Value(status),
       payloadJson = Value(payloadJson),
       generatedAt = Value(generatedAt);
  static Insertable<CachedSnapshot> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<double>? score,
    Expression<String>? status,
    Expression<String>? payloadJson,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (score != null) 'score': score,
      if (status != null) 'status': status,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<double>? score,
    Value<String>? status,
    Value<String>? payloadJson,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return CachedSnapshotsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      score: score ?? this.score,
      status: status ?? this.status,
      payloadJson: payloadJson ?? this.payloadJson,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSimulationsTable extends CachedSimulations
    with TableInfo<$CachedSimulationsTable, CachedSimulation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSimulationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedAmountMeta = const VerificationMeta(
    'recommendedAmount',
  );
  @override
  late final GeneratedColumn<double> recommendedAmount =
      GeneratedColumn<double>(
        'recommended_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    recommendedAmount,
    currency,
    payloadJson,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_simulations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSimulation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('recommended_amount')) {
      context.handle(
        _recommendedAmountMeta,
        recommendedAmount.isAcceptableOrUnknown(
          data['recommended_amount']!,
          _recommendedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedAmountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSimulation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSimulation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      recommendedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommended_amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $CachedSimulationsTable createAlias(String alias) {
    return $CachedSimulationsTable(attachedDatabase, alias);
  }
}

class CachedSimulation extends DataClass
    implements Insertable<CachedSimulation> {
  final String id;
  final String businessId;
  final double recommendedAmount;
  final String currency;
  final String payloadJson;
  final DateTime generatedAt;
  const CachedSimulation({
    required this.id,
    required this.businessId,
    required this.recommendedAmount,
    required this.currency,
    required this.payloadJson,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['recommended_amount'] = Variable<double>(recommendedAmount);
    map['currency'] = Variable<String>(currency);
    map['payload_json'] = Variable<String>(payloadJson);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  CachedSimulationsCompanion toCompanion(bool nullToAbsent) {
    return CachedSimulationsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      recommendedAmount: Value(recommendedAmount),
      currency: Value(currency),
      payloadJson: Value(payloadJson),
      generatedAt: Value(generatedAt),
    );
  }

  factory CachedSimulation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSimulation(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      recommendedAmount: serializer.fromJson<double>(json['recommendedAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'recommendedAmount': serializer.toJson<double>(recommendedAmount),
      'currency': serializer.toJson<String>(currency),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  CachedSimulation copyWith({
    String? id,
    String? businessId,
    double? recommendedAmount,
    String? currency,
    String? payloadJson,
    DateTime? generatedAt,
  }) => CachedSimulation(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    recommendedAmount: recommendedAmount ?? this.recommendedAmount,
    currency: currency ?? this.currency,
    payloadJson: payloadJson ?? this.payloadJson,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  CachedSimulation copyWithCompanion(CachedSimulationsCompanion data) {
    return CachedSimulation(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      recommendedAmount: data.recommendedAmount.present
          ? data.recommendedAmount.value
          : this.recommendedAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSimulation(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('recommendedAmount: $recommendedAmount, ')
          ..write('currency: $currency, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    recommendedAmount,
    currency,
    payloadJson,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSimulation &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.recommendedAmount == this.recommendedAmount &&
          other.currency == this.currency &&
          other.payloadJson == this.payloadJson &&
          other.generatedAt == this.generatedAt);
}

class CachedSimulationsCompanion extends UpdateCompanion<CachedSimulation> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<double> recommendedAmount;
  final Value<String> currency;
  final Value<String> payloadJson;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const CachedSimulationsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.recommendedAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSimulationsCompanion.insert({
    required String id,
    required String businessId,
    required double recommendedAmount,
    required String currency,
    required String payloadJson,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       recommendedAmount = Value(recommendedAmount),
       currency = Value(currency),
       payloadJson = Value(payloadJson),
       generatedAt = Value(generatedAt);
  static Insertable<CachedSimulation> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<double>? recommendedAmount,
    Expression<String>? currency,
    Expression<String>? payloadJson,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (recommendedAmount != null) 'recommended_amount': recommendedAmount,
      if (currency != null) 'currency': currency,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSimulationsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<double>? recommendedAmount,
    Value<String>? currency,
    Value<String>? payloadJson,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return CachedSimulationsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      recommendedAmount: recommendedAmount ?? this.recommendedAmount,
      currency: currency ?? this.currency,
      payloadJson: payloadJson ?? this.payloadJson,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (recommendedAmount.present) {
      map['recommended_amount'] = Variable<double>(recommendedAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSimulationsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('recommendedAmount: $recommendedAmount, ')
          ..write('currency: $currency, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedChatMessagesTable extends CachedChatMessages
    with TableInfo<$CachedChatMessagesTable, CachedChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolCallsJsonMeta = const VerificationMeta(
    'toolCallsJson',
  );
  @override
  late final GeneratedColumn<String> toolCallsJson = GeneratedColumn<String>(
    'tool_calls_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    role,
    content,
    toolCallsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tool_calls_json')) {
      context.handle(
        _toolCallsJsonMeta,
        toolCallsJson.isAcceptableOrUnknown(
          data['tool_calls_json']!,
          _toolCallsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      toolCallsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_calls_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CachedChatMessagesTable createAlias(String alias) {
    return $CachedChatMessagesTable(attachedDatabase, alias);
  }
}

class CachedChatMessage extends DataClass
    implements Insertable<CachedChatMessage> {
  final String id;
  final String businessId;
  final String role;
  final String content;
  final String? toolCallsJson;
  final DateTime createdAt;
  const CachedChatMessage({
    required this.id,
    required this.businessId,
    required this.role,
    required this.content,
    this.toolCallsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || toolCallsJson != null) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return CachedChatMessagesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      role: Value(role),
      content: Value(content),
      toolCallsJson: toolCallsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCallsJson),
      createdAt: Value(createdAt),
    );
  }

  factory CachedChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedChatMessage(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      toolCallsJson: serializer.fromJson<String?>(json['toolCallsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'toolCallsJson': serializer.toJson<String?>(toolCallsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedChatMessage copyWith({
    String? id,
    String? businessId,
    String? role,
    String? content,
    Value<String?> toolCallsJson = const Value.absent(),
    DateTime? createdAt,
  }) => CachedChatMessage(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    role: role ?? this.role,
    content: content ?? this.content,
    toolCallsJson: toolCallsJson.present
        ? toolCallsJson.value
        : this.toolCallsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedChatMessage copyWithCompanion(CachedChatMessagesCompanion data) {
    return CachedChatMessage(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      toolCallsJson: data.toolCallsJson.present
          ? data.toolCallsJson.value
          : this.toolCallsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedChatMessage(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, businessId, role, content, toolCallsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedChatMessage &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.role == this.role &&
          other.content == this.content &&
          other.toolCallsJson == this.toolCallsJson &&
          other.createdAt == this.createdAt);
}

class CachedChatMessagesCompanion extends UpdateCompanion<CachedChatMessage> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> toolCallsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedChatMessagesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.toolCallsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChatMessagesCompanion.insert({
    required String id,
    required String businessId,
    required String role,
    required String content,
    this.toolCallsJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessId = Value(businessId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<CachedChatMessage> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? toolCallsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (toolCallsJson != null) 'tool_calls_json': toolCallsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? businessId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? toolCallsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CachedChatMessagesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCallsJson: toolCallsJson ?? this.toolCallsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (toolCallsJson.present) {
      map['tool_calls_json'] = Variable<String>(toolCallsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCallsJson: $toolCallsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedTransactionsTable cachedTransactions =
      $CachedTransactionsTable(this);
  late final $CachedSnapshotsTable cachedSnapshots = $CachedSnapshotsTable(
    this,
  );
  late final $CachedSimulationsTable cachedSimulations =
      $CachedSimulationsTable(this);
  late final $CachedChatMessagesTable cachedChatMessages =
      $CachedChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedTransactions,
    cachedSnapshots,
    cachedSimulations,
    cachedChatMessages,
  ];
}

typedef $$CachedTransactionsTableCreateCompanionBuilder =
    CachedTransactionsCompanion Function({
      required String id,
      required String businessId,
      required String type,
      required String category,
      required double amount,
      Value<String> currency,
      Value<String?> description,
      required String occurredAt,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$CachedTransactionsTableUpdateCompanionBuilder =
    CachedTransactionsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> type,
      Value<String> category,
      Value<double> amount,
      Value<String> currency,
      Value<String?> description,
      Value<String> occurredAt,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$CachedTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CachedTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedTransactionsTable,
          CachedTransaction,
          $$CachedTransactionsTableFilterComposer,
          $$CachedTransactionsTableOrderingComposer,
          $$CachedTransactionsTableAnnotationComposer,
          $$CachedTransactionsTableCreateCompanionBuilder,
          $$CachedTransactionsTableUpdateCompanionBuilder,
          (
            CachedTransaction,
            BaseReferences<
              _$AppDatabase,
              $CachedTransactionsTable,
              CachedTransaction
            >,
          ),
          CachedTransaction,
          PrefetchHooks Function()
        > {
  $$CachedTransactionsTableTableManager(
    _$AppDatabase db,
    $CachedTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> occurredAt = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTransactionsCompanion(
                id: id,
                businessId: businessId,
                type: type,
                category: category,
                amount: amount,
                currency: currency,
                description: description,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String type,
                required String category,
                required double amount,
                Value<String> currency = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String occurredAt,
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedTransactionsCompanion.insert(
                id: id,
                businessId: businessId,
                type: type,
                category: category,
                amount: amount,
                currency: currency,
                description: description,
                occurredAt: occurredAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedTransactionsTable,
      CachedTransaction,
      $$CachedTransactionsTableFilterComposer,
      $$CachedTransactionsTableOrderingComposer,
      $$CachedTransactionsTableAnnotationComposer,
      $$CachedTransactionsTableCreateCompanionBuilder,
      $$CachedTransactionsTableUpdateCompanionBuilder,
      (
        CachedTransaction,
        BaseReferences<
          _$AppDatabase,
          $CachedTransactionsTable,
          CachedTransaction
        >,
      ),
      CachedTransaction,
      PrefetchHooks Function()
    >;
typedef $$CachedSnapshotsTableCreateCompanionBuilder =
    CachedSnapshotsCompanion Function({
      required String id,
      required String businessId,
      required double score,
      required String status,
      required String payloadJson,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$CachedSnapshotsTableUpdateCompanionBuilder =
    CachedSnapshotsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<double> score,
      Value<String> status,
      Value<String> payloadJson,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$CachedSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSnapshotsTable> {
  $$CachedSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSnapshotsTable> {
  $$CachedSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSnapshotsTable> {
  $$CachedSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$CachedSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSnapshotsTable,
          CachedSnapshot,
          $$CachedSnapshotsTableFilterComposer,
          $$CachedSnapshotsTableOrderingComposer,
          $$CachedSnapshotsTableAnnotationComposer,
          $$CachedSnapshotsTableCreateCompanionBuilder,
          $$CachedSnapshotsTableUpdateCompanionBuilder,
          (
            CachedSnapshot,
            BaseReferences<
              _$AppDatabase,
              $CachedSnapshotsTable,
              CachedSnapshot
            >,
          ),
          CachedSnapshot,
          PrefetchHooks Function()
        > {
  $$CachedSnapshotsTableTableManager(
    _$AppDatabase db,
    $CachedSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSnapshotsCompanion(
                id: id,
                businessId: businessId,
                score: score,
                status: status,
                payloadJson: payloadJson,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required double score,
                required String status,
                required String payloadJson,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSnapshotsCompanion.insert(
                id: id,
                businessId: businessId,
                score: score,
                status: status,
                payloadJson: payloadJson,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSnapshotsTable,
      CachedSnapshot,
      $$CachedSnapshotsTableFilterComposer,
      $$CachedSnapshotsTableOrderingComposer,
      $$CachedSnapshotsTableAnnotationComposer,
      $$CachedSnapshotsTableCreateCompanionBuilder,
      $$CachedSnapshotsTableUpdateCompanionBuilder,
      (
        CachedSnapshot,
        BaseReferences<_$AppDatabase, $CachedSnapshotsTable, CachedSnapshot>,
      ),
      CachedSnapshot,
      PrefetchHooks Function()
    >;
typedef $$CachedSimulationsTableCreateCompanionBuilder =
    CachedSimulationsCompanion Function({
      required String id,
      required String businessId,
      required double recommendedAmount,
      required String currency,
      required String payloadJson,
      required DateTime generatedAt,
      Value<int> rowid,
    });
typedef $$CachedSimulationsTableUpdateCompanionBuilder =
    CachedSimulationsCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<double> recommendedAmount,
      Value<String> currency,
      Value<String> payloadJson,
      Value<DateTime> generatedAt,
      Value<int> rowid,
    });

class $$CachedSimulationsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSimulationsTable> {
  $$CachedSimulationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendedAmount => $composableBuilder(
    column: $table.recommendedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSimulationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSimulationsTable> {
  $$CachedSimulationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendedAmount => $composableBuilder(
    column: $table.recommendedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSimulationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSimulationsTable> {
  $$CachedSimulationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recommendedAmount => $composableBuilder(
    column: $table.recommendedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$CachedSimulationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSimulationsTable,
          CachedSimulation,
          $$CachedSimulationsTableFilterComposer,
          $$CachedSimulationsTableOrderingComposer,
          $$CachedSimulationsTableAnnotationComposer,
          $$CachedSimulationsTableCreateCompanionBuilder,
          $$CachedSimulationsTableUpdateCompanionBuilder,
          (
            CachedSimulation,
            BaseReferences<
              _$AppDatabase,
              $CachedSimulationsTable,
              CachedSimulation
            >,
          ),
          CachedSimulation,
          PrefetchHooks Function()
        > {
  $$CachedSimulationsTableTableManager(
    _$AppDatabase db,
    $CachedSimulationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSimulationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSimulationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSimulationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<double> recommendedAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSimulationsCompanion(
                id: id,
                businessId: businessId,
                recommendedAmount: recommendedAmount,
                currency: currency,
                payloadJson: payloadJson,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required double recommendedAmount,
                required String currency,
                required String payloadJson,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSimulationsCompanion.insert(
                id: id,
                businessId: businessId,
                recommendedAmount: recommendedAmount,
                currency: currency,
                payloadJson: payloadJson,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSimulationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSimulationsTable,
      CachedSimulation,
      $$CachedSimulationsTableFilterComposer,
      $$CachedSimulationsTableOrderingComposer,
      $$CachedSimulationsTableAnnotationComposer,
      $$CachedSimulationsTableCreateCompanionBuilder,
      $$CachedSimulationsTableUpdateCompanionBuilder,
      (
        CachedSimulation,
        BaseReferences<
          _$AppDatabase,
          $CachedSimulationsTable,
          CachedSimulation
        >,
      ),
      CachedSimulation,
      PrefetchHooks Function()
    >;
typedef $$CachedChatMessagesTableCreateCompanionBuilder =
    CachedChatMessagesCompanion Function({
      required String id,
      required String businessId,
      required String role,
      required String content,
      Value<String?> toolCallsJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CachedChatMessagesTableUpdateCompanionBuilder =
    CachedChatMessagesCompanion Function({
      Value<String> id,
      Value<String> businessId,
      Value<String> role,
      Value<String> content,
      Value<String?> toolCallsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CachedChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedChatMessagesTable> {
  $$CachedChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedChatMessagesTable> {
  $$CachedChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedChatMessagesTable> {
  $$CachedChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get toolCallsJson => $composableBuilder(
    column: $table.toolCallsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedChatMessagesTable,
          CachedChatMessage,
          $$CachedChatMessagesTableFilterComposer,
          $$CachedChatMessagesTableOrderingComposer,
          $$CachedChatMessagesTableAnnotationComposer,
          $$CachedChatMessagesTableCreateCompanionBuilder,
          $$CachedChatMessagesTableUpdateCompanionBuilder,
          (
            CachedChatMessage,
            BaseReferences<
              _$AppDatabase,
              $CachedChatMessagesTable,
              CachedChatMessage
            >,
          ),
          CachedChatMessage,
          PrefetchHooks Function()
        > {
  $$CachedChatMessagesTableTableManager(
    _$AppDatabase db,
    $CachedChatMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedChatMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> toolCallsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChatMessagesCompanion(
                id: id,
                businessId: businessId,
                role: role,
                content: content,
                toolCallsJson: toolCallsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessId,
                required String role,
                required String content,
                Value<String?> toolCallsJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedChatMessagesCompanion.insert(
                id: id,
                businessId: businessId,
                role: role,
                content: content,
                toolCallsJson: toolCallsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedChatMessagesTable,
      CachedChatMessage,
      $$CachedChatMessagesTableFilterComposer,
      $$CachedChatMessagesTableOrderingComposer,
      $$CachedChatMessagesTableAnnotationComposer,
      $$CachedChatMessagesTableCreateCompanionBuilder,
      $$CachedChatMessagesTableUpdateCompanionBuilder,
      (
        CachedChatMessage,
        BaseReferences<
          _$AppDatabase,
          $CachedChatMessagesTable,
          CachedChatMessage
        >,
      ),
      CachedChatMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedTransactionsTableTableManager get cachedTransactions =>
      $$CachedTransactionsTableTableManager(_db, _db.cachedTransactions);
  $$CachedSnapshotsTableTableManager get cachedSnapshots =>
      $$CachedSnapshotsTableTableManager(_db, _db.cachedSnapshots);
  $$CachedSimulationsTableTableManager get cachedSimulations =>
      $$CachedSimulationsTableTableManager(_db, _db.cachedSimulations);
  $$CachedChatMessagesTableTableManager get cachedChatMessages =>
      $$CachedChatMessagesTableTableManager(_db, _db.cachedChatMessages);
}
