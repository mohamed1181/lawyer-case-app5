import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/legal_case.dart';
import '../theme/app_theme.dart';

class CaseCard extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback onTap;

  const CaseCard({super.key, required this.legalCase, required this.onTap});

  Color _statusColor() {
    switch (legalCase.status) {
      case CaseStatus.active:
        return AppColors.success;
      case CaseStatus.adjourned:
        return AppColors.warning;
      case CaseStatus.appealed:
        return AppColors.gold;
      case CaseStatus.closedWon:
        return AppColors.success;
      case CaseStatus.closedLost:
        return AppColors.danger;
      case CaseStatus.archived:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy/MM/dd', 'ar');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 52,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          legalCase.displayId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldLight,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          legalCase.caseType,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      legalCase.parties,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      legalCase.court,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (legalCase.nextSessionDate != null)
                Column(
                  children: [
                    const Icon(Icons.event, color: AppColors.gold, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(legalCase.nextSessionDate!),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
