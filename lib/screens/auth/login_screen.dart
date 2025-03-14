import 'package:flutter/material.dart';
// SCREEN
import 'package:ecomerce_app/home.dart';
import 'package:ecomerce_app/screens/auth/forgot_password_screen.dart';
import 'package:ecomerce_app/screens/auth/register_screen.dart';
import 'package:ecomerce_app/screens/admin/admin_home_screen.dart';
// LIB
import 'package:flutter_social_button/flutter_social_button.dart';
// FIREBASE
import 'package:ecomerce_app/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureTextPassword = true;
  // bool _rememberMe = false;
  bool _isSigning = false;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    _formKey.currentState!.validate();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email == "admin@gmail.com" && password == "admin123") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', 'admin');

      setState(() {
        _isSigning = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập Admin thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    User? user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', 'user');

      print("Sign in successfully!!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Thông tin không chính xác! Vui lòng kiểm tra lại"),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Đóng',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      print("Some error happened");
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80.0, right: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bạn chưa có tài khoản?',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7AE582),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(70, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: width,
                    height: height / 1.4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7AE582),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'HA SHOP',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // const SizedBox(height: 10),
                        const Text(
                          'Mua sắm - Giá tốt - Mỗi ngày',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: TextFormField(
                                  focusNode: _focusNode,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple)),
                                      hintText: 'Email',
                                      fillColor: Colors.white,
                                      filled: true),
                                  validator: (String? value) {
                                    final RegExp emailRegExp =
                                        RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                    if (!emailRegExp.hasMatch(value ?? '')) {
                                      _focusNode.requestFocus();
                                      return 'Email is not in the correct format';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 24, left: 24, bottom: 24),
                                child: TextFormField(
                                  focusNode: _focusNode2,
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obscureTextPassword,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.deepPurple)),
                                    hintText: 'Mật khẩu',
                                    fillColor: Colors.white,
                                    filled: true,
                                    suffixIcon: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: IconButton(
                                        icon: Icon(
                                          _obscureTextPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureTextPassword =
                                                !_obscureTextPassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.length < 6) {
                                      _focusNode2.requestFocus();
                                      return "Password should have at least 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 24.0, right: 24.0, bottom: 24.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _signIn();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: _isSigning
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 24.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPassword()),
                                    );
                                  },
                                  child: const Text(
                                    'Bạn quên mật khẩu?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 40.0,
                                    right: 40.0,
                                    top: 24,
                                    bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                        child: Divider(
                                            color: Colors.black, thickness: 1)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'Đăng nhập với',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: Colors.black, thickness: 1)),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FlutterSocialButton(
                                    onTap: () {},
                                    buttonType: ButtonType.facebook,
                                    mini: true,
                                    iconSize: 15,
                                  ),
                                  const SizedBox(width: 12),
                                  FlutterSocialButton(
                                    onTap: () {},
                                    buttonType: ButtonType.google,
                                    mini: true,
                                    iconSize: 15,
                                  ),
                                  const SizedBox(width: 12),
                                  FlutterSocialButton(
                                    onTap: () {},
                                    buttonType: ButtonType.linkedin,
                                    mini: true,
                                    iconSize: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
