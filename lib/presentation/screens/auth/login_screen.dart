import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/l10n.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/providers.dart';
import '../../widgets/sangam_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _role = UserRole.admin;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final user = await ref.read(currentUserProvider.notifier).login(
          username: _userCtrl.text.trim(),
          password: _passCtrl.text,
          role: _role,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (user != null) {
      context.go('/dashboard');
      context.showSnack(
        _role == UserRole.admin
            ? 'Welcome back, ${user.name}!'
            : 'Logged in as staff: ${user.name}',
      );
    } else {
      context.showSnack(
        _role == UserRole.admin
            ? 'Wrong owner username or password'
            : 'Wrong staff username or password',
        isError: true,
      );
    }
  }

  void _goToCreateShop() {
    context.go('/store-setup');
  }

  @override
  Widget build(BuildContext context) {
    final hi = ref.watch(languageProvider);

    final title = _role == UserRole.admin
        ? tr('Owner login', 'मालिक लॉगिन', hi)
        : tr('Staff login', 'स्टाफ लॉगिन', hi);

    final subtitle = _role == UserRole.admin
        ? tr(
            'Manage your customers, payments, reports and daily reconciliation.',
            'अपने ग्राहकों, भुगतानों, रिपोर्ट और रोज़ाना मिलान को संभालें।',
            hi,
          )
        : tr(
            'Use the username and password shared by the owner to access the shop.',
            'दुकान में प्रवेश के लिए मालिक द्वारा साझा किया गया यूज़रनेम और पासवर्ड इस्तेमाल करें।',
            hi,
          );

    final buttonLabel = _role == UserRole.admin
        ? tr('Log in as owner', 'मालिक के रूप में लॉगिन करें', hi)
        : tr('Log in as staff', 'स्टाफ के रूप में लॉगिन करें', hi);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      SangamLogo(size: 84).animate().scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 16),
                      Text(
                        'Sangam',
                        style: AppTextStyles.h1.copyWith(letterSpacing: -0.5),
                      ).animate(delay: 120.ms).fadeIn(),
                      const SizedBox(height: 4),
                      Text(
                        tr('Sab ka ek hisaab', 'सब का एक हिसाब', hi),
                        style: AppTextStyles.body,
                      ).animate(delay: 180.ms).fadeIn(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.borderLight, width: 0.6),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Welcome back', 'वापसी पर स्वागत है', hi),
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tr(
                          'Choose how you want to enter the shop ledger.',
                          'दुकान के हिसाब में प्रवेश करने का तरीका चुनें।',
                          hi,
                        ),
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTinted,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            _roleTab(UserRole.admin, Icons.shield_outlined, hi),
                            _roleTab(UserRole.staff, Icons.person_outline_rounded, hi),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 260.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySm),
                const SizedBox(height: 20),
                Text(tr('USERNAME', 'यूज़रनेम', hi), style: AppTextStyles.labelCaps),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _userCtrl,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  style: AppTextStyles.bodyMd,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr('Enter your username', 'अपना यूज़रनेम भरें', hi) : null,
                  decoration: InputDecoration(
                    hintText: _role == UserRole.admin ? 'e.g. smriti' : 'e.g. staff.riya',
                    prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                Text(tr('PASSWORD', 'पासवर्ड', hi), style: AppTextStyles.labelCaps),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: AppTextStyles.bodyMd,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? tr('Enter your password', 'अपना पासवर्ड भरें', hi) : null,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _GradientButton(
                  label: buttonLabel,
                  loading: _loading,
                  onTap: _login,
                ).animate(delay: 360.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 14),
                if (_role == UserRole.staff)
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    title: tr('Staff help', 'स्टाफ सहायता', hi),
                    body: tr(
                      'Ask the owner to create your login from Settings → Team and share your username and password.',
                      'मालिक से कहें कि वे Settings → Team से आपका लॉगिन बनाएँ और आपका यूज़रनेम व पासवर्ड साझा करें।',
                      hi,
                    ),
                  ).animate(delay: 420.ms).fadeIn(duration: 400.ms),
                if (_role == UserRole.admin) ...[
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _goToCreateShop,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Text(tr('Create new shop', 'नई दुकान बनाएँ', hi)),
                  ).animate(delay: 420.ms).fadeIn(duration: 400.ms),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _role == UserRole.admin
                        ? tr(
                            'First-time owner? Create your shop and start today.',
                            'पहली बार इस्तेमाल कर रहे हैं? अपनी दुकान बनाएँ और आज ही शुरू करें।',
                            hi,
                          )
                        : tr(
                            'Staff can only log in after the owner creates their account.',
                            'स्टाफ तभी लॉगिन कर सकता है जब मालिक उसका खाता बना दे।',
                            hi,
                          ),
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(UserRole role, IconData icon, bool hi) {
    final selected = _role == role;
    final label = role == UserRole.admin
        ? tr('Owner', 'मालिक', hi)
        : tr('Staff', 'स्टाफ', hi);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: selected ? AppShadows.sm : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.saffron : AppColors.text3),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.btnSm.copyWith(
                  color: selected ? AppColors.saffron : AppColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, size: 18, color: AppColors.text3),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMd),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _GradientButton({required this.label, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          decoration: BoxDecoration(
            gradient: onTap != null
                ? AppGradients.saffron
                : const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFFB8C2CF)]),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: onTap != null ? AppShadows.saffron : [],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(label, style: AppTextStyles.btn.copyWith(color: Colors.white)),
          ),
        ),
      );
}

extension ContextSnack on BuildContext {
  void showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.text1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
