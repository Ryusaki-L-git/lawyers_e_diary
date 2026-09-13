import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const _advocateTypes = <String>[
    'Junior',
    'Senior',
    'Corporate',
    'Independent',
  ];

  static final _nameInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]'));

  final _formKey = GlobalKey<FormState>();
  final _dateOfBirthFieldKey = GlobalKey<FormFieldState<String>>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _courtAddressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _degreesController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _courtAddressFocusNode = FocusNode();
  final _dateOfBirthFocusNode = FocusNode();
  final _degreesFocusNode = FocusNode();
  final _advocateTypeFocusNode = FocusNode();

  late final AnimationController _entryController;
  late final AnimationController _shakeController;
  late final List<Animation<double>> _entryAnimations;
  late final List<Animation<Offset>> _entryOffsetAnimations;

  DateTime? _selectedDateOfBirth;
  String _advocateType = _advocateTypes.first;
  bool _isSaving = false;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _entryAnimations = List<Animation<double>>.generate(9, (index) {
      final start = 0.04 + (index * 0.07);
      return CurvedAnimation(
        parent: _entryController,
        curve: Interval(
          start,
          start + 0.34,
          curve: Curves.easeOutCubic,
        ),
      );
    });
    _entryOffsetAnimations = _entryAnimations
        .map(
          (animation) => Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation),
        )
        .toList(growable: false);

    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _courtAddressController.dispose();
    _dateOfBirthController.dispose();
    _degreesController.dispose();

    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    _courtAddressFocusNode.dispose();
    _dateOfBirthFocusNode.dispose();
    _degreesFocusNode.dispose();
    _advocateTypeFocusNode.dispose();

    _entryController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_isSaving) {
      return;
    }

    _dismissKeyboard();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final selectedDateOfBirth = _selectedDateOfBirth;
    if (!isFormValid || selectedDateOfBirth == null) {
      _showInvalidSubmissionFeedback();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(
        'Your session has expired. Please sign in again.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _saveProfile(
        userId: user.uid,
        dateOfBirth: selectedDateOfBirth,
        profileYear: DateTime.now().year,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) {
        return;
      }

      unawaited(HapticFeedback.mediumImpact());
      _showMessage('Profile saved successfully.', isError: false);
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error.code == 'permission-denied'
            ? 'We could not save your profile. Please try again.'
            : 'Unable to save your profile. Please try again.',
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to save your profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveProfile({
    required String userId,
    required DateTime dateOfBirth,
    required int profileYear,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final counterReference = firestore.collection('metadata').doc('counters');
    final userReference = firestore.collection('users').doc(userId);
    final profileData = _buildProfileData(dateOfBirth);

    await firestore.runTransaction<void>((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final existingUserData = userSnapshot.data();
      final storedLedId = existingUserData?['ledId'];

      late final String ledId;
      if (storedLedId is String && storedLedId.trim().isNotEmpty) {
        ledId = storedLedId.trim();
      } else {
        final counterSnapshot = await transaction.get(counterReference);
        final rawCount = counterSnapshot.data()?['userCount'];
        final currentCount =
            rawCount is num && rawCount.isFinite && rawCount >= 0
                ? rawCount.toInt()
                : 0;
        final nextCount = currentCount + 1;

        ledId = '${nextCount.toString().padLeft(4, '0')}-$profileYear';

        transaction.set(
          counterReference,
          <String, dynamic>{
            'userCount': nextCount,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      final dataToSave = Map<String, dynamic>.from(profileData)
        ..['ledId'] = ledId
        ..['profileCompleted'] = true
        ..['updatedAt'] = FieldValue.serverTimestamp();

      if (!userSnapshot.exists || existingUserData?['createdAt'] == null) {
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(
        userReference,
        dataToSave,
        SetOptions(merge: true),
      );
    });
  }

  Map<String, dynamic> _buildProfileData(DateTime dateOfBirth) {
    final profileData = <String, dynamic>{
      'name': _normaliseWhitespace(_nameController.text),
      'dob': Timestamp.fromDate(dateOfBirth),
      'advocateType': _advocateType,
      'profileCompleted': true,
    };

    _addOptionalValue(
      profileData,
      key: 'address',
      value: _addressController.text,
    );
    _addOptionalValue(
      profileData,
      key: 'courtAddress',
      value: _courtAddressController.text,
    );
    _addOptionalValue(
      profileData,
      key: 'degrees',
      value: _degreesController.text,
    );

    return profileData;
  }

  void _addOptionalValue(
    Map<String, dynamic> data, {
    required String key,
    required String value,
  }) {
    final cleanedValue = _normaliseWhitespace(value);
    if (cleanedValue.isNotEmpty) {
      data[key] = cleanedValue;
    }
  }

  Future<void> _pickDateOfBirth() async {
    if (_isSaving) {
      return;
    }

    _dismissKeyboard();

    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ??
        DateTime(now.year - 30, now.month, now.day);
    final datePickerTheme = Theme.of(context).copyWith(
      colorScheme: _welcomeColorScheme,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _WelcomePalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'SELECT DATE OF BIRTH',
      builder: (context, child) {
        return Theme(
          data: datePickerTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = pickedDate;
      _dateOfBirthController.text = _formatDate(pickedDate);
    });

    final isDateOfBirthValid =
        _dateOfBirthFieldKey.currentState?.validate() ?? true;
    if (isDateOfBirthValid) {
      FocusScope.of(context).requestFocus(_degreesFocusNode);
    } else {
      FocusScope.of(context).requestFocus(_dateOfBirthFocusNode);
    }
  }

  void _showInvalidSubmissionFeedback() {
    if (!_showValidationErrors) {
      setState(() => _showValidationErrors = true);
    }

    unawaited(HapticFeedback.heavyImpact());
    _shakeController.forward(from: 0);
    _focusFirstInvalidField();
  }

  void _focusFirstInvalidField() {
    if (_validateName(_nameController.text) != null) {
      _nameFocusNode.requestFocus();
      return;
    }

    if (_selectedDateOfBirth == null) {
      _dateOfBirthFocusNode.requestFocus();
    }
  }

  String? _validateDegrees(String? value) {
    if ((value ?? '').length > 50) {
      return 'Too long';
    }
    return null;
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _requestFocus(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _onAdvocateTypeChanged(String? value) {
    if (value == null || value == _advocateType) {
      return;
    }

    unawaited(HapticFeedback.selectionClick());
    setState(() => _advocateType = value);
    _dismissKeyboard();
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        backgroundColor:
            isError ? _WelcomePalette.ink : _WelcomePalette.success,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.info_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final normalisedName = _normaliseWhitespace(value ?? '');

    if (normalisedName.isEmpty) {
      return 'Enter your full name';
    }
    if (normalisedName.length < 2) {
      return 'Name must contain at least 2 letters';
    }
    if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$')
        .hasMatch(normalisedName)) {
      return 'Use letters and spaces only';
    }

    return null;
  }

  String? _validateDateOfBirth(String? _) {
    final dateOfBirth = _selectedDateOfBirth;

    if (dateOfBirth == null) {
      return 'Select your date of birth';
    }
    if (!_isAtLeastThirteen(dateOfBirth)) {
      return 'You must be at least 13 years old';
    }

    return null;
  }

  static bool _isAtLeastThirteen(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;

    final birthdayHasNotOccurredYet = today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month &&
            today.day < dateOfBirth.day);
    if (birthdayHasNotOccurredYet) {
      age--;
    }

    return age >= 13;
  }

  static String _normaliseWhitespace(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildStaggeredEntry(int index, Widget child) {
    return FadeTransition(
      opacity: _entryAnimations[index],
      child: SlideTransition(
        position: _entryOffsetAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildProfileCard(bool isNarrow) {
    final horizontalPadding = isNarrow ? 20.0 : 28.0;

    return AnimatedBuilder(
      animation: _shakeController,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _WelcomePalette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _WelcomePalette.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x180B1020),
              blurRadius: 36,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            28,
            horizontalPadding,
            22,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _showValidationErrors
                ? AutovalidateMode.always
                : AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProfileSectionHeader(),
                const SizedBox(height: 24),
                _buildStaggeredEntry(
                  2,
                  _ProfileTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    label: 'Full name *',
                    hintText: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    inputFormatters: [_nameInputFormatter],
                    validator: _validateName,
                    onEditingComplete: () => _requestFocus(_addressFocusNode),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStaggeredEntry(
                  3,
                  _ProfileTextField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    label: 'Address',
                    hintText: 'Enter your residential address',
                    icon: Icons.home_outlined,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.fullStreetAddress],
                    onEditingComplete: () =>
                        _requestFocus(_courtAddressFocusNode),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStaggeredEntry(
                  4,
                  _ProfileTextField(
                    controller: _courtAddressController,
                    focusNode: _courtAddressFocusNode,
                    label: 'Court address',
                    hintText: 'Enter your primary court',
                    icon: Icons.account_balance_outlined,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onEditingComplete: () {
                      unawaited(_pickDateOfBirth());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildStaggeredEntry(
                  5,
                  _ProfileTextField(
                    formFieldKey: _dateOfBirthFieldKey,
                    controller: _dateOfBirthController,
                    focusNode: _dateOfBirthFocusNode,
                    label: 'Date of birth *',
                    hintText: 'DD/MM/YYYY',
                    icon: Icons.cake_outlined,
                    suffixIcon: const Icon(
                      Icons.calendar_month_rounded,
                      color: _WelcomePalette.muted,
                    ),
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    validator: _validateDateOfBirth,
                    onTap: () {
                      unawaited(_pickDateOfBirth());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildStaggeredEntry(
                  6,
                  _ProfileTextField(
                    controller: _degreesController,
                    focusNode: _degreesFocusNode,
                    label: 'Degrees',
                    hintText: 'For example, LL.B., LL.M.',
                    icon: Icons.school_outlined,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: _validateDegrees,
                    onEditingComplete: () =>
                        _requestFocus(_advocateTypeFocusNode),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStaggeredEntry(
                  7,
                  _ProfileDropdownField(
                    focusNode: _advocateTypeFocusNode,
                    value: _advocateType,
                    label: 'Advocate type',
                    hintText: 'Choose your practice profile',
                    icon: Icons.workspace_premium_outlined,
                    items: _advocateTypes,
                    onChanged: _onAdvocateTypeChanged,
                  ),
                ),
                const SizedBox(height: 28),
                _buildStaggeredEntry(
                  8,
                  _ContinueButton(
                    isLoading: _isSaving,
                    onPressed: () {
                      unawaited(_saveAndContinue());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const _ProfileFooter(),
              ],
            ),
          ),
        ),
      ),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final progress = Curves.easeOut.transform(_shakeController.value);
        final horizontalOffset =
            math.sin(progress * math.pi * 6) * 9 * (1 - progress);

        return Transform.translate(
          offset: Offset(horizontalOffset, 0),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: _welcomeColorScheme,
        scaffoldBackgroundColor: _WelcomePalette.background,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: _WelcomePalette.ink,
              displayColor: _WelcomePalette.ink,
            ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const _OnboardingBackground(),
            SafeArea(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: keyboardInset),
                child: AbsorbPointer(
                  absorbing: _isSaving,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _dismissKeyboard,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 390;
                        final horizontalPadding = isNarrow ? 16.0 : 22.0;

                        return SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            24,
                            horizontalPadding,
                            32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 540),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildStaggeredEntry(
                                    0,
                                    const _WelcomeHeader(),
                                  ),
                                  const SizedBox(height: 26),
                                  _buildStaggeredEntry(
                                    1,
                                    _buildProfileCard(isNarrow),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (_isSaving) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _WelcomePalette {
  const _WelcomePalette._();

  static const background = Color(0xFFF7F2E8);
  static const surface = Color(0xFFFFFCF7);
  static const field = Color(0xFFF8F4EC);
  static const cardBorder = Color(0xFFE9E0D2);
  static const fieldBorder = Color(0xFFE4DACB);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF727988);
  static const gold = Color(0xFFD1A72B);
  static const goldSoft = Color(0xFFF6E8B7);
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF227A5B);
}

final _welcomeColorScheme = ColorScheme.fromSeed(
  seedColor: _WelcomePalette.gold,
  brightness: Brightness.light,
).copyWith(
  primary: _WelcomePalette.gold,
  onPrimary: _WelcomePalette.ink,
  primaryContainer: _WelcomePalette.goldSoft,
  onPrimaryContainer: _WelcomePalette.ink,
  surface: _WelcomePalette.surface,
  onSurface: _WelcomePalette.ink,
  error: _WelcomePalette.error,
);

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _WelcomePalette.goldSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: _WelcomePalette.ink,
              ),
              SizedBox(width: 7),
              Text(
                'WELCOME TO LAWYER’S E-DIARY',
                style: TextStyle(
                  color: _WelcomePalette.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Build your professional profile.',
          style: TextStyle(
            color: _WelcomePalette.ink,
            fontSize: 31,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'A few details now make your diary feel personal from day one.',
          style: TextStyle(
            color: _WelcomePalette.muted,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your details',
                style: TextStyle(
                  color: _WelcomePalette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Fields marked with * are required.',
                style: TextStyle(
                  color: _WelcomePalette.muted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        _ProgressBadge(),
      ],
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _WelcomePalette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _WelcomePalette.cardBorder),
      ),
      child: const Text(
        'STEP 1 OF 1',
        style: TextStyle(
          color: _WelcomePalette.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 15,
          color: _WelcomePalette.muted,
        ),
        SizedBox(width: 7),
        Flexible(
          child: Text(
            'You can update these details anytime.',
            style: TextStyle(
              color: _WelcomePalette.muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatefulWidget {
  const _ProfileTextField({
    this.formFieldKey,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.validator,
    this.onTap,
    this.onEditingComplete,
    this.readOnly = false,
  });

  final GlobalKey<FormFieldState<String>>? formFieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hintText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final bool readOnly;

  @override
  State<_ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<_ProfileTextField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ProfileTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      _hasFocus = widget.focusNode.hasFocus;
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = widget.focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: _WelcomePalette.gold.withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: TextFormField(
        key: widget.formFieldKey,
        controller: widget.controller,
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        autofillHints: widget.autofillHints,
        validator: widget.validator,
        onTap: widget.onTap,
        onEditingComplete: widget.onEditingComplete,
        cursorColor: _WelcomePalette.ink,
        style: const TextStyle(
          color: _WelcomePalette.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: _fieldDecoration(
          hasFocus: _hasFocus,
          label: widget.label,
          hintText: widget.hintText,
          icon: widget.icon,
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}

class _ProfileDropdownField extends StatefulWidget {
  const _ProfileDropdownField({
    required this.focusNode,
    required this.value,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final FocusNode focusNode;
  final String value;
  final String label;
  final String hintText;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<_ProfileDropdownField> createState() => _ProfileDropdownFieldState();
}

class _ProfileDropdownFieldState extends State<_ProfileDropdownField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _hasFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ProfileDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      _hasFocus = widget.focusNode.hasFocus;
      widget.focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = widget.focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: _WelcomePalette.gold.withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: DropdownButtonFormField<String>(
        focusNode: widget.focusNode,
        initialValue: widget.value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _WelcomePalette.muted,
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: _WelcomePalette.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: _fieldDecoration(
          hasFocus: _hasFocus,
          label: widget.label,
          hintText: widget.hintText,
          icon: widget.icon,
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required bool hasFocus,
  required String label,
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    hintStyle: const TextStyle(
      color: _WelcomePalette.muted,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: const TextStyle(
      color: _WelcomePalette.muted,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelStyle: TextStyle(
      color: hasFocus ? _WelcomePalette.ink : _WelcomePalette.muted,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(
      icon,
      size: 21,
      color: hasFocus ? _WelcomePalette.ink : _WelcomePalette.muted,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: hasFocus ? _WelcomePalette.surface : _WelcomePalette.field,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 19,
    ),
    border: border(_WelcomePalette.fieldBorder),
    enabledBorder: border(_WelcomePalette.fieldBorder),
    focusedBorder: border(_WelcomePalette.gold, width: 1.5),
    errorBorder: border(_WelcomePalette.error),
    focusedErrorBorder: border(_WelcomePalette.error, width: 1.5),
    errorStyle: const TextStyle(
      color: _WelcomePalette.error,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    errorMaxLines: 2,
  );
}

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.isLoading || _isPressed == value) {
      return;
    }

    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isPressed = _isPressed && !widget.isLoading;

    return Listener(
      onPointerDown: (_) {
        if (!widget.isLoading) {
          unawaited(HapticFeedback.selectionClick());
          _setPressed(true);
        }
      },
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: isPressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _WelcomePalette.gold,
              foregroundColor: _WelcomePalette.ink,
              disabledBackgroundColor:
                  _WelcomePalette.gold.withValues(alpha: 0.65),
              disabledForegroundColor:
                  _WelcomePalette.ink.withValues(alpha: 0.7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey<String>('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: _WelcomePalette.ink,
                      ),
                    )
                  : const Row(
                      key: ValueKey<String>('continue'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save and continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFBF3),
                  _WelcomePalette.background,
                ],
              ),
            ),
          ),
          Positioned(
            top: -138,
            right: -102,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _WelcomePalette.gold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 72,
            left: -142,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB8C6D9).withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Semantics(
        label: 'Saving your profile',
        liveRegion: true,
        child: Stack(
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: ColoredBox(
                  color: _WelcomePalette.ink.withValues(alpha: 0.22),
                ),
              ),
            ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _WelcomePalette.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          color: _WelcomePalette.gold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Saving your profile',
                        style: TextStyle(
                          color: _WelcomePalette.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Please keep this screen open.',
                        style: TextStyle(
                          color: _WelcomePalette.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}