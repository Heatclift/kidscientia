import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {

  // ── Role selection ─────────────────────────────────────────────────────
  String _selectedRole = 'Learner'; // 'Learner' or 'Teacher'

  // ── Form controllers ───────────────────────────────────────────────────
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  // ── Birthday dropdowns ─────────────────────────────────────────────────
  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedYear;
  String? _selectedGender;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _days = List.generate(31, (i) => '${i + 1}');
  final List<String> _years = List.generate(
    30, (i) => '${DateTime.now().year - 5 - i}',
  );
  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];

  // ── Animations ─────────────────────────────────────────────────────────
  late AnimationController _cardController;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;

  late AnimationController _moonController;
  late Animation<Offset> _moonSlide;

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _moonSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _moonController, curve: Curves.easeOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    _cardController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _moonController.forward();
  }

@override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  // ── Save user data to SharedPreferences ─────────────────────────────────
  Future<void> _saveUserData({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String dob,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setString('user_first_name', firstName);
    await prefs.setString('user_last_name', lastName);
    await prefs.setString('user_role', role);
    await prefs.setString('user_dob', dob);
    await prefs.setString('user_gender', gender);
    await prefs.setBool('is_logged_in', true);

// Navigate to login screen after successful sign up
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    _showSnack('Account created successfully! Please log in.');
  }

  // ── Validation & Save ──────────────────────────────────────────────────
  void _handleSave() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      _showSnack('Please enter your first and last name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showSnack('Passwords do not match.');
      return;
    }
    if (_selectedMonth == null || _selectedDay == null || _selectedYear == null) {
      _showSnack('Please select your date of birth.');
      return;
    }
    if (_selectedGender == null) {
      _showSnack('Please select your gender.');
      return;
    }
    if (!_agreedToTerms) {
      _showSnack('Please agree to the Terms and Conditions.');
      return;
    }

// Save user data to SharedPreferences
    _saveUserData(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: _selectedRole,
dob: _selectedMonth != null ? '$_selectedMonth $_selectedDay $_selectedYear' : '',
      gender: _selectedGender ?? '',
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5BBFBF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Input decoration helper ────────────────────────────────────────────
  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF5BBFBF), width: 2),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      body: Stack(
        children: [

          // ─── MOON ──────────────────────────────────────────────────────
          Positioned(
            bottom: -size.width * 0.1,
            left: -size.width * 0.1,
            right: -size.width * 0.1,
            child: SlideTransition(
              position: _moonSlide,
              child: Image.asset(
                'assets/images/moon.png', // 🔁 moon asset
                width: size.width * 1.2,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // ─── SCROLLABLE CONTENT ────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // ── Title ─────────────────────────────────────
                          const Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Role selector ─────────────────────────────
                          Row(
                            children: [
                              _RoleTile(
                                label: 'Learner',
                                imagePath: 'assets/images/learner.png', // 🔁
                                isSelected: _selectedRole == 'Learner',
                                onTap: () =>
                                    setState(() => _selectedRole = 'Learner'),
                              ),
                              const SizedBox(width: 16),
                              _RoleTile(
                                label: 'Teacher',
                                imagePath: 'assets/images/teacher.png', // 🔁
                                isSelected: _selectedRole == 'Teacher',
                                onTap: () =>
                                    setState(() => _selectedRole = 'Teacher'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── First Name ────────────────────────────────
                          TextField(
                            controller: _firstNameController,
                            decoration: _inputDecoration('Enter First Name'),
                          ),
                          const SizedBox(height: 12),

                          // ── Last Name ─────────────────────────────────
                          TextField(
                            controller: _lastNameController,
                            decoration: _inputDecoration('Enter Last Name'),
                          ),
                          const SizedBox(height: 12),

                          // ── Email ─────────────────────────────────────
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration('Enter Email'),
                          ),
                          const SizedBox(height: 12),

                          // ── Password ──────────────────────────────────
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              'Enter Password',
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black45,
                                ),
                                onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Confirm Password ──────────────────────────
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: _inputDecoration(
                              'Confirm Password',
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black45,
                                ),
                                onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Date of Birth row ─────────────────────────
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _DropdownField<String>(
                                  value: _selectedMonth,
                                  hint: 'Month',
                                  items: _months,
                                  onChanged: (v) =>
                                      setState(() => _selectedMonth = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _DropdownField<String>(
                                  value: _selectedDay,
                                  hint: 'Day',
                                  items: _days,
                                  onChanged: (v) =>
                                      setState(() => _selectedDay = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _DropdownField<String>(
                                  value: _selectedYear,
                                  hint: 'Year',
                                  items: _years,
                                  onChanged: (v) =>
                                      setState(() => _selectedYear = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Gender ────────────────────────────────────
                          _DropdownField<String>(
                            value: _selectedGender,
                            hint: 'Gender',
                            items: _genders,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                          ),

                          const SizedBox(height: 20),

                          // ── Cancel / Save buttons ─────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    side: const BorderSide(
                                        color: Colors.black26),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5BBFBF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Terms and Conditions ──────────────────────
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  activeColor: const Color(0xFF5BBFBF),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  onChanged: (v) =>
                                      setState(() => _agreedToTerms = v!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  // TODO: show terms
                                },
                                child: const Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Already have account ──────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an Account? ',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFF5A58C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Role Tile Widget ─────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5BBFBF) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5BBFBF)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF5BBFBF).withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 56,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown Field Widget ────────────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.black38, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.black45),
          items: items
              .map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}