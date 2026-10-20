import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import '../models/auth_session.dart';
import '../widgets/skin_page_header.dart';
import '../widgets/skin_page_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/auth_service.dart';
import '../models/profile_data.dart';
import '../widgets/skin_bottom_nav.dart';

class SkinProfilePage extends StatelessWidget {
  const SkinProfilePage({super.key});

  static const _teal = SkinTokens.primary;
  static const _deepTeal = SkinTokens.primaryDark;
  static const _navy = SkinTokens.ink;
  static const _cream = SkinTokens.background;
  static const _coral = SkinTokens.coral;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
          child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 350;
                  return Column(
                    children: [
                      _ProfileHeader(compact: compact),
                      Expanded(
                        child: SingleChildScrollView(
                          key: const Key('profile-scroll'),
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            compact ? 14 : 20,
                            8,
                            compact ? 14 : 20,
                            28,
                          ),
                          child: Column(
                            children: [
                              _IdentitySection(compact: compact),
                              SizedBox(height: compact ? 22 : 28),
                              const _ProfileFields(),
                              SizedBox(height: compact ? 26 : 34),
                              const _LogoutButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      )),
      bottomNavigationBar: const SkinBottomNav(currentIndex: -1),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool compact;

  const _ProfileHeader({required this.compact});
  @override
  Widget build(BuildContext context) => SkinPageHeader(
        title: 'Profil Saya',
        backKey: const Key('profile-back'),
      );
}

class _IdentitySection extends StatelessWidget {
  final bool compact;

  const _IdentitySection({required this.compact});

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!context.mounted) return;
    context.read<ProfileData>().updatePhoto(bytes);
  }

  void _showPhotoSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: SkinProfilePage._cream,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah foto profil',
                style: TextStyle(
                  color: SkinProfilePage._navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                key: const Key('profile-photo-camera'),
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                key: const Key('profile-photo-gallery'),
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPhoto(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileData>();
    final initials = _initials(profile.name);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: SkinTokens.mint,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: SkinTokens.shadows,
              ),
              child: ClipOval(
                child: profile.photoBytes == null
                    ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: SkinProfilePage._deepTeal,
                            fontSize: compact ? 31 : 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Image.memory(
                        profile.photoBytes!,
                        key: const Key('profile-photo'),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
              ),
            ),
            Positioned(
              right: -3,
              bottom: 4,
              child: Material(
                color: SkinProfilePage._teal,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  key: const Key('edit-profile-photo'),
                  onTap: () => _showPhotoSource(context),
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          profile.name,
          key: const Key('profile-name-heading'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: SkinProfilePage._navy,
            fontSize: compact ? 23 : 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Akun SkinSight',
          style: TextStyle(color: SkinTokens.muted, fontSize: 13),
        ),
      ],
    );
  }
}

class _ProfileFields extends StatelessWidget {
  const _ProfileFields();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileData>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SkinTokens.radius),
      ),
      child: Column(
        children: [
          _ProfileField(
            editKey: const Key('edit-profile-name'),
            icon: Icons.person_outline_rounded,
            label: 'Nama',
            value: profile.name,
            onEdit: () => _editValue(
              context,
              title: 'Ubah nama',
              label: 'Nama lengkap',
              initialValue: profile.name,
              onSaved: context.read<ProfileData>().updateName,
            ),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-password'),
            icon: Icons.lock_outline_rounded,
            label: 'Password',
            value: '••••••••••••',
            onEdit: () => _editPassword(context),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-phone'),
            icon: Icons.phone_outlined,
            label: 'Nomor telepon',
            value: profile.phone,
            onEdit: () => _editValue(
              context,
              title: 'Ubah nomor telepon',
              label: 'Nomor telepon',
              initialValue: profile.phone,
              keyboardType: TextInputType.phone,
              onSaved: context.read<ProfileData>().updatePhone,
            ),
          ),
          const _FieldDivider(),
          _ProfileField(
            editKey: const Key('edit-profile-email'),
            icon: Icons.mail_outline_rounded,
            label: 'Alamat email',
            value: profile.email,
            onEdit: () => _editValue(
              context,
              title: 'Ubah alamat email',
              label: 'Alamat email',
              initialValue: profile.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: context.read<ProfileData>().updateEmail,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editValue(
  BuildContext context, {
  required String title,
  required String label,
  required String initialValue,
  required ValueChanged<String> onSaved,
  TextInputType? keyboardType,
}) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => _EditValueDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      keyboardType: keyboardType,
    ),
  );
  if (value != null) onSaved(value);
}

Future<void> _editPassword(BuildContext context) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => const _PasswordDialog(),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui.')),
    );
  }
}

class _EditValueDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final TextInputType? keyboardType;

  const _EditValueDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.keyboardType,
  });

  @override
  State<_EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<_EditValueDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('profile-edit-input'),
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-profile-edit'),
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) Navigator.of(context).pop(text);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _save() {
    if (_newPassword.text.length < 8) {
      setState(() => _error = 'Minimal 8 karakter.');
    } else if (_newPassword.text != _confirmation.text) {
      setState(() => _error = 'Password tidak sama.');
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('new-password-input'),
            controller: _newPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password baru',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('confirm-password-input'),
            controller: _confirmation,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Ulangi password',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-password'),
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  final Key editKey;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _ProfileField({
    required this.editKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
      child: Row(
        children: [
          Icon(icon, color: SkinProfilePage._deepTeal, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: SkinTokens.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SkinProfilePage._navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: editKey,
            tooltip: 'Edit $label',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: SkinProfilePage._deepTeal,
          ),
        ],
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 52,
      endIndent: 14,
      color: SkinTokens.border,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk membuka data akun SkinSight.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('confirm-logout'),
            style: FilledButton.styleFrom(
              backgroundColor: SkinProfilePage._coral,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AuthService>().signOut();
      } catch (_) {
        // Best effort: sesi lokal tetap diakhiri bila server tidak tersedia.
      }
      if (!context.mounted) return;
      AuthSession.instance.signOut();
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Kamu telah keluar dari akun.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('logout-account'),
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: SkinProfilePage._coral,
          side: const BorderSide(color: Color(0xFFE7A5AA)),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SkinTokens.radius),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Keluar akun',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
