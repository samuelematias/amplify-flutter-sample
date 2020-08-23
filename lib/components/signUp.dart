import 'package:flutter/material.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'dart:developer' as dev;

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSignedUp = false;
  bool _loading = false;

  String _signUpError = "";
  List<String> _signUpExceptions = [];

  void _signUp() async {
    _loading = true;
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Signing Up...')));
    Map<String, dynamic> userAttributes = {"email": _emailController.text};
    try {
      SignUpResult res = await Amplify.Auth.signUp(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      setState(() {
        _isSignedUp = true;
        _loading = false;
      });
    } on AuthError catch (error) {
      print(error);
      setState(() {
        _isSignedUp = false;
        _loading = false;
      });
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create account')));
    }
  }

  void _confirm() async {
    setState(() {
      _loading = true;
    });
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Confirming...')));
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: _usernameController.text.trim(),
          confirmationCode: _confirmController.text.trim());
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Confirmed, you can now login.')));
      setState(() {
        _loading = false;
        _isSignedUp = false;
      });
    } on AuthError catch (error) {
      dev.log(error.toString());
      setState(() {
        _loading = false;
        _isSignedUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: _loading,
                  child: Container(
                      child: Center(
                    child: Loading(
                        indicator: BallPulseIndicator(),
                        size: 100.0,
                        color: Colors.deepOrange),
                  )),
                ),
                Visibility(
                    visible: _isSignedUp,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('Enter Confirmation Code',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                        TextFormField(
                          controller: _confirmController,
                          decoration: InputDecoration(
                              hintText: "Enter confirmation code"),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter confirmation code';
                            }
                            return null;
                          },
                        ),
                        ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: double.infinity),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: RaisedButton(
                                onPressed: () {
                                  // Validate returns true if the form is valid, otherwise false.
                                  if (_formKey.currentState.validate()) {
                                    _confirm();
                                  }
                                },
                                child: Text('CONFIRM ACCOUNT'),
                              ),
                            )),
                        ConstrainedBox(
                            constraints:
                                const BoxConstraints(minWidth: double.infinity),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    _isSignedUp = false;
                                  });
                                },
                                child: Text('CANCEL'),
                              ),
                            )),
                      ],
                    )),
                Visibility(
                  visible: !_isSignedUp,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text('Create a New Account',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24)),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration:
                            InputDecoration(hintText: "Enter a Username"),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a Username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration:
                            InputDecoration(hintText: "Enter your Email"),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an Email Address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            InputDecoration(hintText: "Enter a Password"),
                        obscureText: true,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a Password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _verifyPasswordController,
                        decoration:
                            InputDecoration(hintText: "Verify Password"),
                        obscureText: true,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please verify password';
                          }
                          if (value.contains(_passwordController.text.trim())) {
                            return null;
                          } else {
                            return 'Passwords do not match';
                          }
                        },
                      ),
                      ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: RaisedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, otherwise false.
                                if (_formKey.currentState.validate()) {
                                  _signUp();
                                }
                              },
                              child: Text('SIGN UP'),
                            ),
                          )),
                      ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  _isSignedUp = true;
                                });
                              },
                              child: Text('CONFIRM ACCOUNT'),
                            ),
                          )),
                    ],
                  ),
                )
              ],
            )));
  }
}
