import 'package:flutter/foundation.dart';
import '../models/legal_case.dart';
import '../services/case_repository.dart';

/// مزوّد الحالة الرئيسي للتطبيق (ChangeNotifier + Provider)
/// مسؤول عن: تحميل القضايا، البحث، الفلترة، والإشعار بالتغييرات لإعادة بناء الواجهة
class CaseProvider extends ChangeNotifier {
  final CaseRepository _repo;
  List<LegalCase> _allCases = [];
  List<LegalCase> _visibleCases = [];
  String _currentQuery = '';
  CaseStatus? _statusFilter;
  String? _typeFilter;

  CaseProvider(this._repo) {
    _refresh();
  }

  List<LegalCase> get cases => _visibleCases;
  List<LegalCase> get todaysSessions => _repo.todaysSessions();
  List<LegalCase> get upcomingDeadlines => _repo.upcomingDeadlines();
  CaseStatus? get statusFilter => _statusFilter;
  String? get typeFilter => _typeFilter;

  void _refresh() {
    _allCases = _repo.getAll();
    _applySearchAndFilters();
  }

  void _applySearchAndFilters() {
    List<LegalCase> result = _currentQuery.isEmpty
        ? List.of(_allCases)
        : _repo.search(_currentQuery);

    if (_statusFilter != null) {
      result = result.where((c) => c.status == _statusFilter).toList();
    }
    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      result = result.where((c) => c.caseType == _typeFilter).toList();
    }
    // ترتيب: الأقرب جلسة أولاً
    result.sort((a, b) {
      if (a.nextSessionDate == null) return 1;
      if (b.nextSessionDate == null) return -1;
      return a.nextSessionDate!.compareTo(b.nextSessionDate!);
    });
    _visibleCases = result;
    notifyListeners();
  }

  /// تُستدعى مباشرة من حقل البحث في الـ Dashboard (بحث فوري Real-time)
  void onSearchChanged(String query) {
    _currentQuery = query;
    _applySearchAndFilters();
  }

  void setStatusFilter(CaseStatus? status) {
    _statusFilter = status;
    _applySearchAndFilters();
  }

  void setTypeFilter(String? type) {
    _typeFilter = type;
    _applySearchAndFilters();
  }

  void clearFilters() {
    _statusFilter = null;
    _typeFilter = null;
    _currentQuery = '';
    _applySearchAndFilters();
  }

  Future<void> addCase(LegalCase legalCase) async {
    await _repo.addCase(legalCase);
    _refresh();
  }

  Future<void> updateCase(LegalCase legalCase) async {
    await _repo.updateCase(legalCase);
    _refresh();
  }

  Future<void> deleteCase(LegalCase legalCase) async {
    await _repo.deleteCase(legalCase);
    _refresh();
  }
}
