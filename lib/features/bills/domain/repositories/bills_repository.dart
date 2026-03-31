import 'package:finxl/core/models/bill.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';

abstract class BillsRepository {
  Future<BillsOverview> fetchOverview();
  Future<List<Bill>> getBills();
  Future<Bill?> getBillById(int id);
  Future<int> addBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> toggleBillActive(int id, bool isActive);
  Future<void> deleteBill(int id);
}
