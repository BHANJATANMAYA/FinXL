import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/subscription.dart';
import 'package:finxl/features/subscriptions/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({LocalDatabaseService? databaseService})
      : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final maps = await _databaseService.queryAll(
      LocalDatabaseService.subscriptionsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'next_renewal_date ASC',
    );
    return maps.map((map) => Subscription.fromMap(map)).toList();
  }

  @override
  Future<Subscription?> getSubscriptionById(int id) async {
    final map = await _databaseService.queryById(
      LocalDatabaseService.subscriptionsTable,
      id,
    );
    if (map == null || map['deleted_at'] != null) return null;
    return Subscription.fromMap(map);
  }

  @override
  Future<int> insertSubscription(Subscription subscription) async {
    return _databaseService.insert(
      LocalDatabaseService.subscriptionsTable,
      subscription.toMap(),
    );
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    if (subscription.id == null) return;
    await _databaseService.update(
      LocalDatabaseService.subscriptionsTable,
      subscription.toMap(),
      subscription.id!,
    );
  }

  @override
  Future<void> deleteSubscription(int id) async {
    // Soft delete for sync purposes
    final subscription = await getSubscriptionById(id);
    if (subscription != null) {
      await _databaseService.update(
        LocalDatabaseService.subscriptionsTable,
        {
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'sync_status': 'pending',
        },
        id,
      );
    }
  }
}
