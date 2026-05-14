import 'package:finxl/core/models/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<Subscription?> getSubscriptionById(int id);
  Future<int> insertSubscription(Subscription subscription);
  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(int id);
}
