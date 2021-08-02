import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './api/google_sign_in_api.dart';
import './constants/pref_keys.dart';
import './home.dart';
import './models/user.dart';
 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        Home.routeName: (_) => Home(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                Image.asset(
                  'assets/images/google_logo.png',
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            onPressed: () => signIn(),
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final user = await GoogleSignInApi.login();
    debugPrint('$user');
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed!'),
        ),
      );
    } else {
      final userInfo = User(
        uId: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      );
      Navigator.pushReplacementNamed(context, Home.routeName,
          arguments: userInfo);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool(SharedPreferenceKeys.isLoggedIn, true);
      pref.setString(SharedPreferenceKeys.email, user.email);
      pref.setString(
          SharedPreferenceKeys.displayName, user.displayName ?? 'user');
      pref.setString(SharedPreferenceKeys.uId, user.id);
      pref.setString(SharedPreferenceKeys.photoUrl, user.photoUrl ?? '');
    }
  }
}
