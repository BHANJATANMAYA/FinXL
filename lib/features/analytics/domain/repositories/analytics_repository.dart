import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsOverview> fetchOverview();
}
