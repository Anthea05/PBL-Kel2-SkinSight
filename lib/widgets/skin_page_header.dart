import 'package:flutter/material.dart';
import '../theme/skin_theme.dart';

class SkinPageHeader extends StatelessWidget {
  final String title;
  final Key? backKey;
  final Widget? trailing;
  const SkinPageHeader(
      {super.key, required this.title, this.backKey, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Row(children: [
          IconButton(
            key: backKey,
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).maybePop(),
            icon:
                const Icon(Icons.arrow_back_rounded, color: SkinTokens.primary),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: SkinTokens.section)),
          if (trailing != null) trailing!,
        ]),
      );
}
