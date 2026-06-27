import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../providers/case_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/case_card.dart';
import 'case_details_screen.dart';
import 'quick_add_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> caseTypes = [
    'جنائي',
    'مدني',
    'أحوال شخصية',
    'تجاري',
    'عمالي',
    'إداري',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة القضايا')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة قضية'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuickAddScreen()),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => provider.onSearchChanged(_searchController.text),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            _buildSearchBar(provider),
            _buildSummaryRow(provider),
            if (provider.todaysSessions.isNotEmpty) _buildTodaysSessions(provider),
            if (provider.upcomingDeadlines.isNotEmpty) _buildDeadlinesAlert(provider),
            _buildFilterChips(provider),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('جميع القضايا',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
            ...provider.cases.map((c) => CaseCard(
                  legalCase: c,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CaseDetailsScreen(legalCase: c)),
                  ),
                )),
            if (provider.cases.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('لا توجد قضايا مطابقة',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// شريط البحث الشامل الفوري: رقم القضية / السنة / اسم الخصم أو الموكل / المحكمة
  Widget _buildSearchBar(CaseProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: provider.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'بحث برقم القضية، السنة، اسم الخصم، أو المحكمة...',
          prefixIcon: const Icon(Icons.search, color: AppColors.gold),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    provider.onSearchChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(CaseProvider provider) {
    final total = provider.cases.length;
    final today = provider.todaysSessions.length;
    final deadlines = provider.upcomingDeadlines.length;
    Widget stat(String label, String value, Color color) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          stat('إجمالي القضايا', '$total', AppColors.gold),
          stat('جلسات اليوم', '$today', AppColors.success),
          stat('مواعيد حرجة', '$deadlines', AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildTodaysSessions(CaseProvider provider) {
    return _alertSection(
      title: 'جلسات اليوم',
      icon: Icons.gavel,
      color: AppColors.success,
      cases: provider.todaysSessions,
    );
  }

  Widget _buildDeadlinesAlert(CaseProvider provider) {
    return _alertSection(
      title: 'مواعيد طعن/إجرائية حرجة (٧ أيام)',
      icon: Icons.warning_amber_rounded,
      color: AppColors.danger,
      cases: provider.upcomingDeadlines,
    );
  }

  Widget _alertSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<LegalCase> cases,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ...cases.take(3).map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${c.displayId} — ${c.parties}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              )),
        ],
      ),
    );
  }

  /// فلاتر سريعة: الموقف القانوني + نوع القضية
  Widget _buildFilterChips(CaseProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...CaseStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text(s.arabicLabel, style: const TextStyle(fontSize: 12)),
                  selected: provider.statusFilter == s,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.charcoal,
                  onSelected: (selected) =>
                      provider.setStatusFilter(selected ? s : null),
                ),
              )),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(width: 8),
          ...caseTypes.map((t) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text(t, style: const TextStyle(fontSize: 12)),
                  selected: provider.typeFilter == t,
                  selectedColor: AppColors.goldLight,
                  backgroundColor: AppColors.charcoal,
                  onSelected: (selected) =>
                      provider.setTypeFilter(selected ? t : null),
                ),
              )),
        ],
      ),
    );
  }
}
