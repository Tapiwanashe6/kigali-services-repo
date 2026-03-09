import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // App Theme Colors
  static const Color primaryColor = Color(0xFF1A237E); // Dark Navy Blue
  static const Color accentColor = Color(0xFFFFD700); // Golden Yellow
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light blue-grey for better contrast
  static const Color textPrimary = Color(0xFF1E2A3A); // Dark blue-grey - better than pure black
  static const Color textSecondary = Color(0xFF6B7A8A); // Medium grey-blue - better contrast than grey
  static const Color dividerColor = Color(0xFFE8ECF0); // Subtle light grey

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali Services Directory',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
          // Kigali Services Directory Theme
          // Color Palette: Dark Navy Blue, Pure White, Golden-Yellow Accents
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: backgroundColor,

          // Color Scheme
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            secondary: accentColor,
            surface: surfaceColor,
            error: Color(0xFFDC3545),
            onPrimary: Colors.white,
            onSecondary: textPrimary,
            onSurface: textPrimary,
            onError: Colors.white,
          ),

          // AppBar Theme
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // Card Theme
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: primaryColor.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: surfaceColor,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // Elevated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: primaryColor.withValues(alpha: 0.3),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Outlined Button Theme
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(color: primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Text Button Theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Floating Action Button Theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: accentColor,
            foregroundColor: primaryColor,
            elevation: 4,
            shape: CircleBorder(),
          ),

          // Input Decoration Theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC3545), width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.grey.shade500),
            labelStyle: const TextStyle(color: textSecondary),
          ),

          // Bottom Navigation Bar Theme
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: surfaceColor,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade500,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),

          // Navigation Bar Theme (Material 3)
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: surfaceColor,
            indicatorColor: accentColor.withValues(alpha: 0.2),
            elevation: 3,
            height: 70,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                );
              }
              return TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: primaryColor,
                  size: 26,
                );
              }
              return IconThemeData(
                color: Colors.grey.shade600,
                size: 24,
              );
            }),
          ),

          // Chip Theme
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey.shade100,
            selectedColor: accentColor.withValues(alpha: 0.3),
            labelStyle: const TextStyle(fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Divider Theme
          dividerTheme: DividerThemeData(
            color: Colors.grey.shade200,
            thickness: 1,
            space: 1,
          ),

          // List Tile Theme
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            minLeadingWidth: 24,
          ),

          // Snackbar Theme
          snackBarTheme: SnackBarThemeData(
            backgroundColor: primaryColor,
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),

          // Dialog Theme
          dialogTheme: DialogThemeData(
            backgroundColor: surfaceColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titleTextStyle: const TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Text Theme - Improved hierarchy with better spacing
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: -0.5),
            displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -0.5),
            displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
            headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.25),
            headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 0.15),
            headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.15),
            titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.15),
            titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.1),
            titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
            bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.5),
            bodyMedium: TextStyle(color: textPrimary, fontSize: 14, height: 1.5),
            bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
            labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
            labelMedium: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
            labelSmall: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeAuthListener();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading while checking auth state
          if (authProvider.state == AuthState.initial ||
              authProvider.state == AuthState.loading) {
            return const _LoadingScreen();
          }

          // Show login if not authenticated
          if (authProvider.state == AuthState.unauthenticated ||
              authProvider.state == AuthState.error) {
            return const LoginScreen();
          }

          // Show home screen if authenticated
          if (authProvider.state == AuthState.authenticated) {
            // Check if email is verified
            if (!authProvider.emailVerified) {
              return const UnverifiedEmailScreen();
            }
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

// Custom Loading Screen
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_city,
                  size: 60,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Kigali Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your directory to city services',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UnverifiedEmailScreen extends StatelessWidget {
  const UnverifiedEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Email Not Verified',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please verify your email address to access the app. Check your inbox for the verification link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6C757D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.reloadUser();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text('Checking verification status...'),
                              ],
                            ),
                            backgroundColor: primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'Check Verification',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().signOut();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

