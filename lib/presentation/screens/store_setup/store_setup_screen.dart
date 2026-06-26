import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/l10n.dart';
import '../../../domain/entities/store_profile.dart';
import '../../../services/auth_service.dart';
import '../../providers/providers.dart';
import '../../widgets/sangam_logo.dart';
import '../auth/login_screen.dart' show ContextSnack;

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});
  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _locationCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final auth = ref.read(authServiceProvider);
    try {
      final admin = await auth.createAdmin(
        name: _ownerCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await ref.read(currentUserProvider.notifier).setUser(admin);

      await ref.read(storeProfileProvider.notifier).save(
            StoreProfile(
              name: _nameCtrl.text.trim(),
              ownerName: _ownerCtrl.text.trim(),
              location: _locationCtrl.text.trim(),
            ),
          );

      final source = ref.read(localSourceProvider);
      await source.startFresh();

      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(customersStreamProvider);
      ref.invalidate(todayTotalsProvider);
      ref.invalidate(overdueCustomersProvider);
      ref.invalidate(usersProvider);

      if (mounted) {
        context.go('/dashboard');
        context.showSnack('Your shop is ready!');
      }
    } on DuplicateUsernameException {
      if (mounted) {
        context.showSnack('That username is taken, try another', isError: true);
      }
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not finish setup, try again', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SangamLogo(size: 56).animate().scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 22),
                Text(
                  tr('Set up your shop', 'अपनी दुकान सेट करें', hi),
                  style: AppTextStyles.h1,
                ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'Keep setup minimal. We create the owner login now. Staff can be added later from Settings.',
                    'सेटअप को सरल रखें। अभी मालिक का लॉगिन बनेगा। स्टाफ को बाद में सेटिंग्स से जोड़ा जा सकता है।',
                    hi,
                  ),
                  style: AppTextStyles.body,
                ).animate(delay: 250.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 28),
                _label(tr('SHOP NAME', 'दुकान का नाम', hi)),
                _field(
                  _nameCtrl,
                  'e.g. Sharma General Store',
                  cap: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr('Enter your shop name', 'दुकान का नाम भरें', hi) : null,
                ),
                _label(tr('OWNER NAME', 'मालिक का नाम', hi)),
                _field(
                  _ownerCtrl,
                  'e.g. Smriti Sharma',
                  cap: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr('Enter the owner name', 'मालिक का नाम भरें', hi) : null,
                ),
                _label(tr('LOCATION (optional)', 'स्थान (वैकल्पिक)', hi)),
                _field(
                  _locationCtrl,
                  'e.g. Patna, Bihar',
                  cap: TextCapitalization.words,
                  formatters: [LengthLimitingTextInputFormatter(60)],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                _label(tr('OWNER USERNAME', 'मालिक यूज़रनेम', hi)),
                _field(
                  _userCtrl,
                  'e.g. smriti',
                  autocorrect: false,
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? tr('At least 3 characters, no spaces', 'कम से कम 3 अक्षर, बिना स्पेस', hi)
                      : null,
                ),
                _label(tr('OWNER PASSWORD', 'मालिक पासवर्ड', hi)),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: AppTextStyles.bodyMd,
                  validator: (v) =>
                      (v == null || v.length < 4) ? tr('Use at least 4 characters', 'कम से कम 4 अक्षर रखें', hi) : null,
                  decoration: InputDecoration(
                    hintText: tr('Choose a password', 'पासवर्ड चुनें', hi),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderLight, width: 0.6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.text3),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tr(
                            'This creates the main owner account. After setup, you can add staff logins and share access from Settings.',
                            'यह मुख्य मालिक खाता बनाता है। सेटअप के बाद आप सेटिंग्स से स्टाफ लॉगिन जोड़कर एक्सेस साझा कर सकते हैं।',
                            hi,
                          ),
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _finish,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(tr('Create shop & start', 'दुकान बनाएँ और शुरू करें', hi)),
                  ),
                ).animate(delay: 360.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    tr(
                      'No sample or demo data will be added.',
                      'कोई नमूना या डेमो डेटा नहीं जोड़ा जाएगा।',
                      hi,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _saving ? null : () => context.go('/login'),
                    child: Text(tr('Already have a shop? Log in', 'पहले से दुकान है? लॉगिन करें', hi)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t, style: AppTextStyles.labelCaps),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextCapitalization cap = TextCapitalization.none,
    bool autocorrect = true,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      textCapitalization: cap,
      autocorrect: autocorrect,
      textInputAction: TextInputAction.next,
      inputFormatters: formatters,
      validator: validator,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
