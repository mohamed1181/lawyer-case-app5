import 'package:hive_flutter/hive_flutter.dart';
import '../models/legal_case.dart';

/// طبقة الوصول لقاعدة البيانات المحلية (Hive)
/// كل التطبيق يتعامل مع القضايا من خلال هذا الـ Repository فقط
/// (مما يسهّل تبديل قاعدة البيانات لاحقاً إن لزم، مثل SQLite)
class CaseRepository {
  static const String boxName = 'legal_cases_box';
  late Box<LegalCase> _box;

  /// يُهيّئ Hive ويفتح الـ Box - يُستدعى مرة واحدة عند بدء التطبيق
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LegalCaseAdapter());
    _box = await Hive.openBox<LegalCase>(boxName);
  }

  Box<LegalCase> get box => _box;

  List<LegalCase> getAll() => _box.values.toList();

  Future<void> addCase(LegalCase legalCase) async {
    await _box.add(legalCase);
  }

  Future<void> updateCase(LegalCase legalCase) async {
    legalCase.updatedAt = DateTime.now();
    await legalCase.save();
  }

  Future<void> deleteCase(LegalCase legalCase) async {
    await legalCase.delete();
  }

  /// بحث شامل وفوري عبر: رقم القضية، السنة، أسماء الخصوم، أو المحكمة
  /// مبني على فهرس نصي بسيط (searchIndex) لضمان سرعة الاستعلام حتى مع آلاف القضايا
  List<LegalCase> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.trim().toLowerCase();
    return _box.values.where((c) => c.searchIndex.contains(q)).toList();
  }

  /// فلترة متقدمة: حسب الموقف القانوني / نوع القضية / نطاق تاريخ الجلسة القادمة
  List<LegalCase> filter({
    CaseStatus? status,
    String? caseType,
    DateTime? sessionFrom,
    DateTime? sessionTo,
  }) {
    return _box.values.where((c) {
      if (status != null && c.status != status) return false;
      if (caseType != null && caseType.isNotEmpty && c.caseType != caseType) {
        return false;
      }
      if (sessionFrom != null &&
          (c.nextSessionDate == null || c.nextSessionDate!.isBefore(sessionFrom))) {
        return false;
      }
      if (sessionTo != null &&
          (c.nextSessionDate == null || c.nextSessionDate!.isAfter(sessionTo))) {
        return false;
      }
      return true;
    }).toList();
  }

  /// قضايا جلساتها اليوم - تُستخدم في الـ Dashboard
  List<LegalCase> todaysSessions() {
    final now = DateTime.now();
    return _box.values.where((c) {
      final d = c.nextSessionDate;
      if (d == null) return false;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  /// القضايا التي تحتوي مواعيد طعن/إجرائية حرجة خلال الأيام القادمة
  List<LegalCase> upcomingDeadlines({int withinDays = 7}) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: withinDays));
    return _box.values.where((c) {
      return c.appealDeadlines.any((iso) {
        final d = DateTime.tryParse(iso);
        if (d == null) return false;
        return d.isAfter(now) && d.isBefore(limit);
      });
    }).toList();
  }
}
