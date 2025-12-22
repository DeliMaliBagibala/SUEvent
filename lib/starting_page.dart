import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_constants.dart';
import 'home_page.dart';
import 'providers/auth_provider.dart';

void AlertDialogShower(context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

String? LoginRegisterValidation(value, hint, isPassword){
  if (value == null || value.isEmpty) {
    return "Required";
  }
  if (hint.toLowerCase().contains("mail")) {
    final emailRegex = RegExp(r'^[\w-\.]+@sabanciuniv.edu$');
    if (!emailRegex.hasMatch(value)) {
      return "Invalid Email (please use only *****@sabanciuniv.edu mails)";
    }
  } else if (isPassword) {
    if (value.length < 6) {
      return "Password too short (at least 6 characters)";
    }
  }
  return null;
}

Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFFF3E5F5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return LoginRegisterValidation(value, hint, isPassword);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black26),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
  );
}

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    if (authProvider.isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                child: Image.asset(
                  "assets/images/SUEventLogo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      AlertDialogShower(context, "Invalid Input", "Please check your inputs.");
      return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    String? error = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (error == null) {
      if (mounted) {
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
    } else {
       if (mounted) {
        String message = "Login Failed";
        if (error.contains('user-not-found')) {
          message = 'No user found for that email.';
        } else if (error.contains('wrong-password')) {
          message = 'Wrong password provided for that user.';
        } else if (error.contains('invalid-credential')) {
          message = 'Invalid email or password.';
        }
        AlertDialogShower(context, "Login Failed", message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AppAuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_left, size: 40, color: AppColors.textBlack),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "WELCOME BACK!\nGLAD TO SEE YOU, AGAIN!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 50),
                _buildTextField("Enter Email", _emailController),
                SizedBox(height: 20),
                _buildTextField("Enter password", _passwordController, isPassword: true),
                SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _trySubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Login",
                      style: TextStyle(color: AppColors.textBlack, fontSize: 18),
                    ),
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Register Now",
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      AlertDialogShower(context, "Invalid Input", "Please check your inputs.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
       AlertDialogShower(context, "Password Mismatch", "Passwords do not match!");
       return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    String? error = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
    );

    if (error == null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
    } else {
      if (mounted) {
        String message = "Registration failed.";
        if (error.contains('weak-password')) {
          message = 'The password provided is too weak.';
        } else if (error.contains('email-already-in-use')) {
          message = 'The account already exists for that email.';
        }
        AlertDialogShower(context, "Registration Error", message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AppAuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_left, size: 40, color: AppColors.textBlack),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "WELCOME TO SUEVENT!\nREGISTER NOW \nAND JOIN THE FUN!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField("Enter Su-mail", _emailController),
                  SizedBox(height: 15),
                  _buildTextField("Username", _usernameController),
                  SizedBox(height: 15),
                  _buildTextField("Password", _passwordController, isPassword: true),
                  SizedBox(height: 15),
                  _buildTextField("Password again", _confirmPasswordController, isPassword: true),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _trySubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
