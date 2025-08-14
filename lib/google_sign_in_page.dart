import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInExample extends StatefulWidget {
  const GoogleSignInExample({super.key});

  @override
  GoogleSignInExampleState createState() => GoogleSignInExampleState();
}

class GoogleSignInExampleState extends State<GoogleSignInExample> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '195416354852-pl3grb265172huc5694ovajnnrm56i73.apps.googleusercontent.com', // Your client ID
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('Sign in error: $error');
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In')),
      body: Center(
        child: _currentUser != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hello, ${_currentUser!.displayName}'),
                  ElevatedButton(
                    onPressed: _handleSignOut,
                    child: Text('Sign Out'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _handleSignIn,
                child: Text('Sign In with Google'),
              ),
      ),
    );
  }
}
