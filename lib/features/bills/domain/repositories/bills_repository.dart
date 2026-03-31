import 'package:finxl/features/bills/domain/entities/bills_overview.dart';

abstract class BillsRepository {
  Future<BillsOverview> fetchOverview();
}
