import 'package:flutter/material.dart';

import '../models/font_settings.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_background.dart';
import '../widgets/skin_page_header.dart';

class SkinSettingsPage extends StatelessWidget {
  const SkinSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SkinFontSettings.instance;
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
              child: Column(
                children: [
                  const SkinPageHeader(
                    title: 'Settings',
                    backKey: Key('settings-back'),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: settings,
                      builder: (context, _) => ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        children: [
                          const Text('Tampilan tulisan',
                              style: SkinTokens.section),
                          const SizedBox(height: 5),
                          const Text(
                            'Pilih gaya font yang digunakan di seluruh aplikasi.',
                            style: SkinTokens.caption,
                          ),
                          const SizedBox(height: 18),
                          _FontOption(
                            key: const Key('font-roboto'),
                            title: 'Roboto',
                            preview: 'Rawat kulitmu, nikmati prosesnya.',
                            fontFamily: 'Roboto',
                            selected: settings.choice == SkinFontChoice.roboto,
                            onTap: () => settings.select(SkinFontChoice.roboto),
                          ),
                          const SizedBox(height: 11),
                          _FontOption(
                            key: const Key('font-handwritten'),
                            title: 'Handwritten',
                            preview: 'Rawat kulitmu, nikmati prosesnya.',
                            fontFamily: 'Kalam',
                            selected:
                                settings.choice == SkinFontChoice.handwritten,
                            onTap: () =>
                                settings.select(SkinFontChoice.handwritten),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption({
    super.key,
    required this.title,
    required this.preview,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String preview;
  final String fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SkinTokens.mint : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? SkinTokens.primary : SkinTokens.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: SkinTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preview,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14,
                        color: SkinTokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? SkinTokens.primary : SkinTokens.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
