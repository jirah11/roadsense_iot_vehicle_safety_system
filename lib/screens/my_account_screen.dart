import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/user_info.dart';


// mga pangcall, dinedefine niya yung data na kailangan sa screen
class MyAccountScreen extends StatefulWidget {
  final UserInfo userInfo;
  final VoidCallback onBack;
  final ValueChanged<UserInfo> onUserInfoChanged;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;


  const MyAccountScreen({
    super.key,
    required this.userInfo,
    required this.onBack,
    required this.onUserInfoChanged,
    required this.onLogout,
    required this.onDeleteAccount,
  });


  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}


//this class ay nag-eexist if the user wants to edit their info
class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isEditing = false;
  bool _showChangePassword = false;
  late TextEditingController _firstName;
  late TextEditingController _middleName;
  late TextEditingController _lastName;
  late TextEditingController _email;


  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.userInfo.firstName);
    _middleName = TextEditingController(text: widget.userInfo.middleName);
    _lastName = TextEditingController(text: widget.userInfo.lastName);
    _email = TextEditingController(text: widget.userInfo.email);
  }


  //updating the needed data para magreflect sa display
  @override
  void didUpdateWidget(MyAccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userInfo != widget.userInfo) {
      _firstName.text = widget.userInfo.firstName;
      _middleName.text = widget.userInfo.middleName;
      _lastName.text = widget.userInfo.lastName;
      _email.text = widget.userInfo.email;
    }
  }


  //kiniclear yung controllers from memory pag umalis si user sa settings
  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }


  void _saveAccount() {
    widget.onUserInfoChanged(
      widget.userInfo.copyWith(
        firstName: _firstName.text
            .trim(), //purpose ng trim, tinatanggal niya yung whitespace
        middleName: _middleName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim(),
      ),
    );
    setState(() => _isEditing = false);
  }


  //nagrereset to orig values
  void _cancelEdit() {
    _firstName.text = widget.userInfo.firstName;
    _middleName.text = widget.userInfo.middleName;
    _lastName.text = widget.userInfo.lastName;
    _email.text = widget.userInfo.email;
    setState(() => _isEditing = false);
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Account',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Manage your account',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (!_isEditing)
                TextButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: Icon(Icons.edit, size: 16, color: AppColors.accent),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cardDark, AppColors.cardDarker],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _accountRow(
                  Icons.person_outline,
                  'First Name',
                  _isEditing ? null : widget.userInfo.firstName,
                  controller: _isEditing ? _firstName : null,
                ),
                _accountRow(
                  Icons.person_outline,
                  'Middle Name',
                  _isEditing ? null : widget.userInfo.middleName,
                  controller: _isEditing ? _middleName : null,
                ),
                _accountRow(
                  Icons.person_outline,
                  'Last Name',
                  _isEditing ? null : widget.userInfo.lastName,
                  controller: _isEditing ? _lastName : null,
                ),
                _accountRow(
                  Icons.mail_outline,
                  'Email Address',
                  _isEditing ? null : widget.userInfo.email,
                  controller: _isEditing ? _email : null,
                ),
                _accountRow(
                  Icons.phone_outlined,
                  'Phone Number',
                  widget.userInfo.phoneNumber,
                  controller: null,
                ),
                _accountRow(
                  Icons.calendar_today,
                  'Member Since',
                  widget.userInfo.createdAt,
                  controller: null,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveAccount,
                          icon: const Icon(Icons.save, size: 18),
                          label: Text(
                            'Save',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // purpose ng GestureDetector, ginagawang collapsible ang container
          GestureDetector(
            onTap: () =>
                setState(() => _showChangePassword = !_showChangePassword),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cardDark, AppColors.cardDarker],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Update your account password',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showChangePassword
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
          if (_showChangePassword)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cardDarker, Color(0xFF344259)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: GoogleFonts.inter(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.inter(color: Colors.white),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: GoogleFonts.inter(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.inter(color: Colors.white),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: GoogleFonts.inter(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.inter(color: Colors.white),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Update Password',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to log out?',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  widget.onLogout();
                }
              },
              icon: const Icon(Icons.logout, size: 20),
              label: Text(
                'Logout',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          // delete account section
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showDeleteAccountConfirmation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.rose.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: AppColors.rose, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Account',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.rose,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showDeleteAccountConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text(
            'Delete account',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This action is permanent and cannot be undone. Your account data will be removed from our system.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteAccount();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _accountRow(
      IconData icon,
      String label,
      String? value, {
        TextEditingController? controller,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                if (controller != null)
                  TextField(
                    controller: controller,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    value ?? '–',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

