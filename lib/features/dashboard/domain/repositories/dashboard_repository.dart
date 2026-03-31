import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> fetchSnapshot();
}
