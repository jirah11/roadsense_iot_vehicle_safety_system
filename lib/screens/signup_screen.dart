import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
//mga pang call
class SignUpScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;
  final void Function({
  required String firstName,
  required String middleName,
  required String lastName,
  required String email,
  required String phoneNumber,
  required String password,
  }) onSignUp;

  const SignUpScreen({
    super.key,
    required this.onGoToLogin,
    required this.onSignUp,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
//logic para makapagtype sa input fields
class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }
//logic if clinick mo submit
  void _submit() {
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignUp(
        firstName: _firstName.text.trim(),
        middleName: _middleName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
        phoneNumber: _phone.text.trim(),
        password: _password.text,
      );
    }
  }
//visuals ng sign-up
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: widget.onGoToLogin,
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.3)),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Account', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Join RoadSense today', style: GoogleFonts.inter(fontSize: 14, color: AppColors.accent)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _field('First Name', 'Enter your first name', Icons.person_outline, _firstName),
            _field('Middle Name', 'Enter your middle name', Icons.person_outline, _middleName),
            _field('Last Name', 'Enter your last name', Icons.person_outline, _lastName),
            _field('Email Address', 'Enter your email', Icons.mail_outline, _email, keyboardType: TextInputType.emailAddress),
            _field('Phone Number', 'Enter your phone number', Icons.phone_outlined, _phone, keyboardType: TextInputType.phone),
            _passwordField('Password', 'Create a password', _password, _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
            _passwordField('Confirm Password', 'Confirm your password', _confirmPassword, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: Text('Create Account', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                  children: [
                    const TextSpan(text: 'By creating an account, you agree to our '),
                    TextSpan(text: 'Terms of Service', style: GoogleFonts.inter(color: AppColors.accent)),
                    const TextSpan(text: ' and '),
                    TextSpan(text: 'Privacy Policy', style: GoogleFonts.inter(color: AppColors.accent)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
//eto yung parang container nung mga input fields, kung ano design ng loob
  Widget _field(String label, String hint, IconData icon, TextEditingController c, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            keyboardType: keyboardType,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white38),
              prefixIcon: Icon(icon, color: Colors.white38, size: 22),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
            ),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ],
      ),
    );
  }

  //kung anong meron sa password field, yung container niya
  Widget _passwordField(String label, String hint, TextEditingController c, bool obscure, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            obscureText: obscure,
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white38),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white38, size: 22),
              suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white60), onPressed: toggle),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
            ),
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
