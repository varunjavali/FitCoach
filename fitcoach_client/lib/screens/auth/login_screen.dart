import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_animate/flutter_animate.dart';

import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_services.dart';
import '../dashboard/dashboard_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  /// Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Services
  final AuthService authService = AuthService();
  final LocalAuthentication auth = LocalAuthentication();

  /// Secure, encrypted, per-app storage (Android Keystore / iOS Keychain).
  /// This is where the email/password used for silent biometric
  /// re-login live — never in SharedPreferences.
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static const _bioEmailKey = "bio_email";
  static const _bioPasswordKey = "bio_password";

  /// UI State
  bool loading = false;
  bool obscure = true;
  bool rememberMe = true;

  /// Biometric state
  /// biometricAvailable  -> device supports biometrics (hardware + enrolled)
  /// hasSavedCredentials -> there's an email/password saved securely on
  ///                        this device that fingerprint can unlock.
  ///                        This survives logout and app kill, unlike a
  ///                        session token, because it's stored separately.
  bool biometricAvailable = false;
  bool hasSavedCredentials = false;
  bool checkingBiometric = true;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  //---------------------------------------------------------
  // Check device biometric support + existing saved credentials
  //---------------------------------------------------------

  Future<void> _initBiometrics() async {
    if (kIsWeb) {
      setState(() => checkingBiometric = false);
      return;
    }

    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final savedEmail = await secureStorage.read(key: _bioEmailKey);
      final savedPassword = await secureStorage.read(key: _bioPasswordKey);

      setState(() {
        biometricAvailable = canCheck && isSupported;
        hasSavedCredentials =
            savedEmail != null && savedEmail.isNotEmpty &&
            savedPassword != null && savedPassword.isNotEmpty;
        checkingBiometric = false;
      });
    } catch (e) {
      debugPrint("Biometric init error: $e");
      setState(() => checkingBiometric = false);
    }
  }

  //---------------------------------------------------------
  // Login Method (unchanged logic from the working version)
  //---------------------------------------------------------

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      setState(() {
        loading = true;
      });

      final response = await authService.login(email, password);

      // Save/clear the biometric credentials based on Remember Me.
      // Unchecking Remember Me and logging in again removes any
      // previously saved fingerprint credentials for this account.
      if (!kIsWeb) {
        if (rememberMe) {
          await secureStorage.write(key: _bioEmailKey, value: email);
          await secureStorage.write(key: _bioPasswordKey, value: password);
          if (mounted) setState(() => hasSavedCredentials = true);
        } else {
          await secureStorage.delete(key: _bioEmailKey);
          await secureStorage.delete(key: _bioPasswordKey);
          if (mounted) setState(() => hasSavedCredentials = false);
        }
      }

      if (!mounted) return;
      await _handleLoginResponse(response);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  //---------------------------------------------------------
  // Shared handling for a successful login API response,
  // whether it came from the password form or a silent
  // biometric re-login.
  //---------------------------------------------------------

  Future<void> _handleLoginResponse(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("clientToken", response["token"]);
    await prefs.setString("clientId", response["client"]["_id"]);
    await prefs.setString("trainerId", response["client"]["trainer"]);
    await prefs.setString("clientName", response["client"]["name"]);
    await prefs.setString("clientEmail", response["client"]["email"]);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response["message"]),
        backgroundColor: Colors.green,
      ),
    );

    if (response["firstLogin"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  //---------------------------------------------------------
  // Biometric Login
  // local_auth has no web implementation, so every entry
  // point is guarded behind kIsWeb to avoid
  // MissingPluginException on Flutter Web.
  //
  // Biometric auth here acts as a "quick unlock" for a
  // session that was already created via a normal password
  // login (token saved in SharedPreferences). It does NOT
  // call the login API again — it just gates access to the
  // already-saved session behind the device fingerprint.
  //---------------------------------------------------------

  Future<void> biometricLogin() async {
    if (kIsWeb) return;

    if (!hasSavedCredentials) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Login with your password and keep \"Remember Me\" checked to enable fingerprint login",
          ),
        ),
      );
      return;
    }

    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric authentication is not available on this device")),
        );
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: "Login to FitCoach",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) return;

      setState(() => loading = true);

      final savedEmail = await secureStorage.read(key: _bioEmailKey);
      final savedPassword = await secureStorage.read(key: _bioPasswordKey);

      if (savedEmail == null || savedPassword == null) {
        // Credentials vanished between the check above and now
        // (e.g. cleared on another screen) — bail out cleanly.
        if (!mounted) return;
        setState(() {
          hasSavedCredentials = false;
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login with your password.")),
        );
        return;
      }

      // Real re-authentication against the actual login API —
      // fingerprint just unlocks these stored credentials, it
      // never bypasses your server.
      final response = await authService.login(savedEmail, savedPassword);

      if (!mounted) return;
      await _handleLoginResponse(response);
    } on PlatformException catch (e) {
      if (!mounted) return;

      String message = "Fingerprint authentication failed";
      switch (e.code) {
        case 'NotAvailable':
          message = "Biometric authentication is not available";
          break;
        case 'NotEnrolled':
          message = "No fingerprint is set up on this device";
          break;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          message = "Too many attempts. Please use your password.";
          break;
        default:
          message = "Fingerprint authentication failed";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Most likely the login API rejected the stored credentials
      // (e.g. password was changed elsewhere). Clear the stale
      // saved credentials so the user isn't stuck failing silently.
      debugPrint(e.toString());
      if (!mounted) return;

      await secureStorage.delete(key: _bioEmailKey);
      await secureStorage.delete(key: _bioPasswordKey);
      setState(() => hasSavedCredentials = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fingerprint login failed. Please login with your password."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //---------------------------------------------------------
  // Build Method
  //---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          //-------------------------------------------------
          // Animated Background Gradient
          //-------------------------------------------------

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0F2027),
                  Color(0xff203A43),
                  Color(0xff2C5364),
                ],
              ),
            ),
          ),

          //-------------------------------------------------
          // Floating Decorative Circles
          //-------------------------------------------------

          Positioned(
            top: -100,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ).animate().scale(duration: 1500.ms),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ).animate().fadeIn(),
          ),

          //-------------------------------------------------
          // Center Login Card
          //-------------------------------------------------

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassmorphicContainer(
                width: size.width > 500 ? 420 : double.infinity,
                // Responsive height so short viewports never overflow.
                height: size.height > 720 ? 650 : size.height * 0.9,
                borderRadius: 30,
                blur: 20,
                alignment: Alignment.center,
                border: 1.5,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(.18),
                    Colors.white.withOpacity(.08),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(.40),
                    Colors.white.withOpacity(.15),
                  ],
                ),
                // Own scroll view so content that's ever taller
                // than the card scrolls instead of overflowing.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      //-------------------------------------------------
                      // Logo (icon-based — no external asset needed)
                      //-------------------------------------------------

                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 46,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 700.ms)
                          .scale(
                            begin: const Offset(.7, .7),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 20),

                      //-------------------------------------------------
                      // App Name
                      //-------------------------------------------------

                      Text(
                        "FitCoach",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: .5, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        "Client Login",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 35),

                      //-------------------------------------------------
                      // Email TextField
                      //-------------------------------------------------

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -.2),

                      const SizedBox(height: 20),

                      //-------------------------------------------------
                      // Password TextField
                      //-------------------------------------------------

                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                            icon: Icon(
                              obscure ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: .2),

                      const SizedBox(height: 18),

                      //-------------------------------------------------
                      // Remember Me & Forgot Password
                      //-------------------------------------------------

                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            activeColor: Colors.greenAccent.shade400,
                            checkColor: Colors.black,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // TODO: Forgot Password Screen
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      //-------------------------------------------------
                      // Login Button
                      //-------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade400,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "LOGIN",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ).animate().fadeIn(delay: 900.ms).scale(),

                      const SizedBox(height: 25),

                      //-------------------------------------------------
                      // OR Divider — only shown when fingerprint
                      // login is actually offered below.
                      //-------------------------------------------------

                      if (!kIsWeb && !checkingBiometric && biometricAvailable) ...[
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Colors.white38, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Colors.white38, thickness: 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        //-------------------------------------------------
                        // Fingerprint Login
                        // Shown only once biometric hardware is confirmed
                        // available. If there's no saved session yet the
                        // button is still shown but visually muted, and
                        // tapping it explains that a password login is
                        // needed first.
                        //-------------------------------------------------

                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: biometricLogin,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(hasSavedCredentials ? .12 : .06),
                              border: Border.all(
                                color: hasSavedCredentials ? Colors.white24 : Colors.white10,
                              ),
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              color: hasSavedCredentials ? Colors.white : Colors.white38,
                              size: 40,
                            ),
                          ),
                        ).animate().fadeIn(delay: 1200.ms).scale(),

                        const SizedBox(height: 18),

                        Text(
                          hasSavedCredentials
                              ? "Use Fingerprint"
                              : "Login with Remember Me to enable fingerprint",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],

                      //-------------------------------------------------
                      // Footer
                      //-------------------------------------------------

                      Text(
                        "FitCoach",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
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