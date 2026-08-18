import 'package:flutter/material.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsDiagnosisSummary {
  const DsDiagnosisSummary({
    required this.title,
    required this.subtitle,
    required this.severityLabel,
    required this.confidencePercent,
    required this.summary,
    required this.matchedSymptoms,
    required this.recommendations,
  });

  final String title;
  final String subtitle;
  final String severityLabel;
  final int confidencePercent;
  final String summary;
  final List<String> matchedSymptoms;
  final List<String> recommendations;
}

class DsDiagnosisCard extends StatelessWidget {
  const DsDiagnosisCard({
    super.key,
    required this.data,
    this.onCaseStudy,
    this.onConnectDoctor,
    this.showActions = false,
  });

  final DsDiagnosisSummary data;
  final VoidCallback? onCaseStudy;
  final VoidCallback? onConnectDoctor;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final shape = AppRadius.superellipse(AppRadius.control);
    return Material(
      color: AppColor.canvas,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.accentVoice.withValues(alpha: 0.45),
          ),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: AppSpace.xs,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.headerTeal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.control),
                    topRight: Radius.circular(AppRadius.control),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.health_and_safety_outlined,
                      color: AppColor.iconOnAccent,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpace.xs),
                    Text(
                      'Kết quả phân tích AI',
                      style: AppTextStyle.label(color: AppColor.textOnAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: AppTextStyle.titleSm()),
                        const SizedBox(height: AppSpace.xxs),
                        Text(
                          data.subtitle,
                          style: AppTextStyle.caption(
                            color: AppColor.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  _SeverityTag(label: data.severityLabel),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text('Độ tin cậy', style: AppTextStyle.label()),
              const SizedBox(height: AppSpace.xxs),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: data.confidencePercent / 100,
                        minHeight: 8,
                        backgroundColor: AppColor.border,
                        color: AppColor.accentVoice,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    '${data.confidencePercent}%',
                    style: AppTextStyle.label(color: AppColor.accentVoice),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text(data.summary, style: AppTextStyle.bodySm()),
              if (data.matchedSymptoms.isNotEmpty) ...[
                const SizedBox(height: AppSpace.sm),
                Text('Triệu chứng phù hợp', style: AppTextStyle.label()),
                const SizedBox(height: AppSpace.xs),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xs,
                  children: [
                    for (final symptom in data.matchedSymptoms)
                      _SymptomChip(label: symptom),
                  ],
                ),
              ],
              if (data.recommendations.isNotEmpty) ...[
                const SizedBox(height: AppSpace.sm),
                Text('Khuyến nghị', style: AppTextStyle.label()),
                const SizedBox(height: AppSpace.xxs),
                for (var i = 0; i < data.recommendations.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.xxs),
                    child: Text(
                      '${i + 1}. ${data.recommendations[i]}',
                      style: AppTextStyle.bodySm(),
                    ),
                  ),
              ],
              if (showActions) ...[
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    TextButton(
                      onPressed: onCaseStudy,
                      child: const Text('Xem case study'),
                    ),
                    FilledButton(
                      onPressed: onConnectDoctor,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.headerTeal,
                        foregroundColor: AppColor.textOnAccent,
                      ),
                      child: const Text('Kết nối bác sĩ'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityTag extends StatelessWidget {
  const _SeverityTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColor.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.xxs,
        ),
        child: Text(
          label,
          style: AppTextStyle.caption(color: AppColor.warning),
        ),
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.canvas,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColor.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.xxs,
        ),
        child: Text(
          label,
          style: AppTextStyle.caption(color: AppColor.textMedium),
        ),
      ),
    );
  }
}
