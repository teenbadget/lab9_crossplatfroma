import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'logo_data.dart';

void main() => runApp(const AuthApp());

// ---------------------------------------------------------------------------
// Тема застосунку: уся стилізація віджетів задана одним екземпляром ThemeData
// ---------------------------------------------------------------------------
class AppTheme {
  static const Color primary = Color(0xFF3F51B5);
  static const Color background = Color(0xFFF4F5FB);

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: background,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: primary),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    // Стиль усіх полів введення (TextField / TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _border(Colors.grey.shade400),
      enabledBorder: _border(Colors.grey.shade400),
      focusedBorder: _border(primary, 2),
      errorBorder: _border(Colors.red.shade700),
      focusedErrorBorder: _border(Colors.red.shade700, 2),
    ),
    // Стиль ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    // Стиль OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    // Стиль TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Застосунок і маршрути
// ---------------------------------------------------------------------------
class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лаба 9: форми',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Перевірка введених даних
// ---------------------------------------------------------------------------
class Validators {
  // Мінімальна довжина пароля за завданням
  static const int minPasswordLength = 7;

  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$",
  );
  static final RegExp _nameChars = RegExp(r"^[A-Za-zА-Яа-яІіЇїЄєҐґ'’\s\-]+$");

  // Ім'я: обов'язкове, лише літери
  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return "Вкажіть ім'я";
    if (v.length < 2) return "Ім'я має містити щонайменше 2 символи";
    if (!_nameChars.hasMatch(v)) return "Ім'я може містити лише літери";
    return null;
  }

  // Логін = e-mail: обов'язковий, має бути правильною адресою
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Вкажіть e-mail';
    if (!_email.hasMatch(v)) return 'Некоректна адреса e-mail (приклад: name@mail.com)';
    return null;
  }

  // Пароль: обов'язковий, не менше 7 символів
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Вкажіть пароль';
    if (v.length < minPasswordLength) {
      return 'Пароль має містити щонайменше $minPasswordLength символів';
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Спільні віджети
// ---------------------------------------------------------------------------
final Uint8List _logoBytes = base64Decode(kLogoBase64);

// Каркас екрана: логотип (Image), заголовок, підзаголовок і вміст.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.memory(
                      _logoBytes,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Поле пароля з кнопкою «показати/сховати».
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputAction? textInputAction;

  const PasswordField({
    super.key,
    required this.controller,
    required this.validator,
    this.label = 'Пароль',
    this.textInputAction,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Показати пароль' : 'Сховати пароль',
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// Модальне вікно з повідомленням (як у прикладі: заголовок + текст + кнопка OK)
void _showMessage(BuildContext context, String text) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Повідомлення'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Екран авторизації
// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Помилки валідації показуються під полями; вікно з'являється завжди (як у прикладі)
    _formKey.currentState!.validate();
    _showMessage(context, 'Заповніть поля');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Вхід',
      subtitle: 'Увійдіть у свій акаунт',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _loginController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-mail (логін)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordController,
                validator: Validators.password,
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot'),
                  child: const Text('Забули пароль?'),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _submit, child: const Text('Увійти')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Створити акаунт'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Екран реєстрації
// ---------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Помилки валідації показуються під полями; вікно з'являється завжди (як у прикладі)
    _formKey.currentState!.validate();
    _showMessage(context, 'Заповніть поля');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Реєстрація',
      subtitle: 'Створіть новий акаунт',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                validator: Validators.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Ім'я",
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loginController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-mail (логін)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordController,
                validator: Validators.password,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Зареєструватися'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Вже є акаунт? Увійти'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Екран відновлення пароля
// ---------------------------------------------------------------------------
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  void _submit() {
    // Помилки валідації показуються під полями; вікно з'являється завжди (як у прикладі)
    _formKey.currentState!.validate();
    _showMessage(context, 'Заповніть поля');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Відновлення пароля',
      subtitle: 'Вкажіть e-mail, і ми допоможемо скинути пароль',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _loginController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Скинути пароль'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Назад до входу'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}