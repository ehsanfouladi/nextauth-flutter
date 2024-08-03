import 'package:flutter/material.dart';
import 'package:flutter_nextauth_app/signIn_web_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInScreen(),
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    // Load session token from local storage
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('sessionToken');

    // If there's a session token, the user is considered connected
    if (sessionToken != null) {
      setState(() {
        _isConnected = true;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove session token from local storage
    await prefs.remove('sessionToken');
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter NextAuth SignIn')),
      body: Center(
        child: _isConnected
            ? ElevatedButton(
                onPressed: () async {
                  // Logout action
                  await _logout();
                  print('User logged out!');
                },
                child: const Text('Logout'),
              )
            : ElevatedButton(
                onPressed: () {
                  // Navigate to the SignInWebView when the button is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInWebView(
                        initialUrl:
                            'https://your-nextjs-app.com/sign-in?provider=google',
                        redirectTo: '/home',
                      ),
                    ),
                  );
                },
                child: const Text('Sign In'),
              ),
      ),
    );
  }
}
