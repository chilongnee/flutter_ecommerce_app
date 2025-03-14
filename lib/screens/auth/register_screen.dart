import 'package:flutter/material.dart';
// SCREEN
import 'package:ecomerce_app/screens/auth/login_screen.dart';
// MODEL REPO
import 'package:ecomerce_app/models/user_model.dart';
import 'package:ecomerce_app/repository/user_repository.dart';
// FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecomerce_app/services/firebase_auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final UserRepository _userRepo = UserRepository();

  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final cfpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureTextPassword = true;
  bool _obscureTextCFPassword = true;
  bool _isSigningUp = false;
  // final FocusNode _fullName = FocusNode();
  final FocusNode _email = FocusNode();
  final FocusNode _password = FocusNode();
  final FocusNode _cfpassword = FocusNode();

  void _signUp() async {
    setState(() {
      _isSigningUp = true;
    });
    String email = _emailController.text.trim();
    String fullName = _fullNameController.text.trim();
    String password = _passwordController.text;
    String address = _addressController.text.trim();

    try {
      User? user = await _auth.createUserWithEmailAndPassword(
        context: context,
        email: email,
        password: password,
      );

      if (user != null) {
        print("User created successfully");

        UserModel newUser = UserModel(
          id: user.uid,
          fullName: fullName,
          email: email,
          address: address,
          linkImage: "",
        );
        await _userRepo.createUser(context, newUser);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng ký thất bại: $e")));
    }

    setState(() {
      _isSigningUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: SizedBox(
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
                        'Bạn đã có tài khoản?',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7AE582),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(70, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Đăng nhập',
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
                  height: height / 1.35,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HA SHOP',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Text(
                                'Tạo tài khoản để mua sắm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  hintText: 'Email',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                validator: (String? value) {
                                  final RegExp emailRegExp = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  );
                                  if (!emailRegExp.hasMatch(value ?? '')) {
                                    _email.requestFocus();
                                    return 'Email is not in the correct format';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 24,
                                left: 24,
                                bottom: 24,
                              ),
                              child: TextFormField(
                                controller: _fullNameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  hintText: 'Họ tên',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                validator: (String? value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập họ tên';
                                  } else if (value.trim().length < 2) {
                                    return 'Họ tên quá ngắn';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 24,
                                left: 24,
                                bottom: 24,
                              ),
                              child: TextFormField(
                                controller: _addressController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  hintText: 'Địa chỉ',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                validator: (String? value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập địa chỉ';
                                  } else if (value.trim().length < 5) {
                                    return 'Địa chỉ quá ngắn';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 24,
                                left: 24,
                                bottom: 24,
                              ),
                              child: TextFormField(
                                focusNode: _password,
                                controller: _passwordController,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscureTextPassword,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  hintText: 'Mật khẩu',
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
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
                                    _password.requestFocus();
                                    return "Password should have at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 24,
                                left: 24,
                                bottom: 24,
                              ),
                              child: TextFormField(
                                focusNode: _cfpassword,
                                controller: cfpasswordController,
                                textInputAction: TextInputAction.done,
                                obscureText: _obscureTextCFPassword,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  hintText: 'Nhập lại mật khẩu',
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureTextCFPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureTextCFPassword =
                                              !_obscureTextCFPassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.length < 6) {
                                    _cfpassword.requestFocus();
                                    return "Password should have at least 6 characters";
                                  } else if (value !=
                                      _passwordController.text) {
                                    _cfpassword.requestFocus();
                                    return "Confirm password do not match";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24.0,
                                right: 24.0,
                                bottom: 24.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _signUp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child:
                                    _isSigningUp
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
                                          'Đăng ký',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
