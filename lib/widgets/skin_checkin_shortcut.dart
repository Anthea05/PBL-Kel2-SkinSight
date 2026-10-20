import 'package:flutter/material.dart';

import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';

class SkinCheckinShortcut extends StatelessWidget {
  const SkinCheckinShortcut({
    required this.week,
    required this.dueDate,
    required this.status,
    required this.onPressed,
    required this.buttonKey,
    super.key,
  });

  final int week;
  final DateTime dueDate;
  final CheckinPromptStatus status;
  final VoidCallback onPressed;
  final Key buttonKey;

  String _date(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _title => switch (status) {
        CheckinPromptStatus.dueToday => 'Waktunya check-in kulitmu!',
        CheckinPromptStatus.lateThisWeek =>
          'Check-in minggu ini belum kamu isi.',
        CheckinPromptStatus.resumedAfterMissedWeek =>
          'Yuk, lanjutkan pemantauan kulitmu minggu ini.',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SkinTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: SkinTokens.mint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: SkinTokens.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        color: SkinTokens.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sudah masuk minggu ke-$week. Yuk, catat perubahan kondisi kulitmu minggu ini.',
                      style: SkinTokens.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;
              final date = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: SkinTokens.muted,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Jadwal: ${_date(dueDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkinTokens.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              );
              final button = FilledButton(
                key: buttonKey,
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Mulai Check-in →'),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    date,
                    const SizedBox(height: 10),
                    button,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: date),
                  const SizedBox(width: 10),
                  button,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
