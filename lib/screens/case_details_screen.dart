import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../providers/case_provider.dart';
import '../theme/app_theme.dart';

class CaseDetailsScreen extends StatelessWidget {
  final LegalCase legalCase;
  const CaseDetailsScreen({super.key, required this.legalCase});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy/MM/dd');
    return Scaffold(
      appBar: AppBar(
        title: Text(legalCase.displayId),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.charcoal,
                  title: const Text('تأكيد الحذف'),
                  content: const Text('هل تريد حذف هذه القضية نهائياً؟'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (confirm == true) {
                await context.read<CaseProvider>().deleteCase(legalCase);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard('بيانات القضية', [
            _row('رقم القضية', legalCase.caseNumber),
            _row('السنة', legalCase.year),
            _row('نوع القضية', legalCase.caseType),
            _row('المحكمة / الدائرة', legalCase.court),
          ]),
          _sectionCard('الخصوم والموكلين', [
            Text(legalCase.parties, style: const TextStyle(color: AppColors.textPrimary)),
          ]),
          _sectionCard('الموقف القانوني', [
            Chip(
              label: Text(legalCase.status.arabicLabel),
              backgroundColor: AppColors.gold.withOpacity(0.2),
              labelStyle: const TextStyle(color: AppColors.goldLight),
            ),
          ]),
          _sectionCard('الجلسات والمواعيد', [
            _row('الجلسة القادمة', legalCase.nextSessionDate != null
                ? dateFmt.format(legalCase.nextSessionDate!)
                : 'غير محدد'),
            if (legalCase.appealDeadlines.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('مواعيد الطعون/الإجرائية:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ...legalCase.appealDeadlines.map((d) => Text(
                  '• ${DateTime.tryParse(d) != null ? dateFmt.format(DateTime.parse(d)) : d}',
                  style: const TextStyle(color: AppColors.textPrimary))),
            ],
          ]),
          if (legalCase.notes.isNotEmpty)
            _sectionCard('ملاحظات', [
              Text(legalCase.notes, style: const TextStyle(color: AppColors.textPrimary)),
            ]),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
