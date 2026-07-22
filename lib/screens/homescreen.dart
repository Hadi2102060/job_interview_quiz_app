import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../core/api_constants.dart';
import '../core/services/local_storage_service.dart';
import '../routes/appRoutes.dart';
import 'interview_tips_screen.dart';
import 'quiz_screen.dart';
import 'saved_quizzes_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isUnsubscribing = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _categories = [
    'All',
    'Flutter',
    'Dart',
    'Android',
    'iOS',
    'JavaScript',
    'Python',
    'Behavioral',
    'System Design',
    'SQL',
  ];

  final List<Map<String, dynamic>> _allTopics = [
    {
      'title': 'Flutter Basics',
      'description': 'Widgets, State Management, Lifecycle',
      'category': 'Flutter',
      'icon': Icons.flutter_dash,
      'color': Colors.blue,
      'questionCount': 25,
      'difficulty': 'Beginner',
      'popularity': 4.8,
    },
    {
      'title': 'Flutter Advanced',
      'description': 'Custom Paint, Animations, Performance',
      'category': 'Flutter',
      'icon': Icons.animation,
      'color': Colors.indigo,
      'questionCount': 30,
      'difficulty': 'Advanced',
      'popularity': 4.9,
    },
    {
      'title': 'State Management',
      'description': 'Provider, Bloc, GetX, Riverpod',
      'category': 'Flutter',
      'icon': Icons.account_tree,
      'color': Colors.teal,
      'questionCount': 20,
      'difficulty': 'Intermediate',
      'popularity': 4.7,
    },

    // Dart Topics
    {
      'title': 'Dart Programming',
      'description': 'OOP, Async, Null Safety, Collections',
      'category': 'Dart',
      'icon': Icons.code,
      'color': Colors.cyan,
      'questionCount': 35,
      'difficulty': 'Beginner',
      'popularity': 4.6,
    },

    {
      'title': 'Android Development',
      'description': 'Kotlin, Jetpack, Compose, Architecture',
      'category': 'Android',
      'icon': Icons.android,
      'color': Colors.green,
      'questionCount': 40,
      'difficulty': 'Intermediate',
      'popularity': 4.7,
    },

    {
      'title': 'iOS Development',
      'description': 'Swift, UIKit, SwiftUI, Core Data',
      'category': 'iOS',
      'icon': Icons.apple,
      'color': Colors.grey,
      'questionCount': 35,
      'difficulty': 'Intermediate',
      'popularity': 4.8,
    },

    {
      'title': 'JavaScript Core',
      'description': 'ES6+, Closures, Promises, Events',
      'category': 'JavaScript',
      'icon': Icons.javascript,
      'color': Colors.yellow.shade800,
      'questionCount': 45,
      'difficulty': 'Beginner',
      'popularity': 4.9,
    },
    {
      'title': 'React & Node.js',
      'description': 'Hooks, Context, Express, MongoDB',
      'category': 'JavaScript',
      'icon': Icons.code,
      'color': Colors.lightBlue,
      'questionCount': 30,
      'difficulty': 'Advanced',
      'popularity': 4.8,
    },

    {
      'title': 'Python Basics',
      'description': 'Syntax, OOP, Modules, File Handling',
      'category': 'Python',
      'icon': Icons.code,
      'color': Colors.blueGrey,
      'questionCount': 40,
      'difficulty': 'Beginner',
      'popularity': 4.7,
    },
    {
      'title': 'Django Framework',
      'description': 'ORM, Templates, REST API, Auth',
      'category': 'Python',
      'icon': Icons.code,
      'color': Colors.green.shade800,
      'questionCount': 30,
      'difficulty': 'Intermediate',
      'popularity': 4.6,
    },

    {
      'title': 'HR Interview Questions',
      'description': 'Strength, Weakness, Teamwork, Leadership',
      'category': 'Behavioral',
      'icon': Icons.people,
      'color': Colors.orange,
      'questionCount': 50,
      'difficulty': 'All Levels',
      'popularity': 4.9,
    },
    {
      'title': 'Situational Questions',
      'description': 'Conflict Resolution, Decision Making',
      'category': 'Behavioral',
      'icon': Icons.psychology,
      'color': Colors.deepOrange,
      'questionCount': 35,
      'difficulty': 'Intermediate',
      'popularity': 4.8,
    },

    {
      'title': 'System Design Basics',
      'description': 'Load Balancing, Caching, DB Sharding',
      'category': 'System Design',
      'icon': Icons.architecture,
      'color': Colors.purple,
      'questionCount': 25,
      'difficulty': 'Advanced',
      'popularity': 4.9,
    },
    {
      'title': 'Microservices',
      'description': 'API Gateway, Service Discovery, Docker',
      'category': 'System Design',
      'icon': Icons.cloud,
      'color': Colors.deepPurple,
      'questionCount': 20,
      'difficulty': 'Advanced',
      'popularity': 4.8,
    },

    {
      'title': 'SQL Queries',
      'description': 'Joins, Subqueries, Indexes, Normalization',
      'category': 'SQL',
      'icon': Icons.storage,
      'color': Colors.blue.shade900,
      'questionCount': 35,
      'difficulty': 'Intermediate',
      'popularity': 4.7,
    },
  ];

  List<Map<String, dynamic>> get _filteredTopics {
    return _allTopics.where((topic) {
      final matchesCategory =
          _selectedCategory == 'All' || topic['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          topic['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          topic['description'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startQuiz(Map<String, dynamic> topic) {
    HapticFeedback.mediumImpact();
    Get.to(
      () => QuizScreen(),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  void _goHomeFromDrawer() {
    _closeDrawer();
    // Already on HomeScreen — just close the drawer.
  }

  void _openSavedQuizzes() {
    _closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SavedQuizzesScreen()),
    );
  }

  void _openInterviewTips() {
    _closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InterviewTipsScreen()),
    );
  }

  void _openSettings() {
    _closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _confirmLogout() async {
    _closeDrawer();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You will need to verify your phone number again to continue.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userPhone');
    try {
      await Get.find<LocalStorageService>().logout();
    } catch (_) {}
    Get.offAllNamed(AppRoutes.phoneRoute);
  }




  /// Normalizes to 11-digit BD mobile (01XXXXXXXXX) as required by unsubscribe.php.
  String _normalizeBdMobile(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D+'), '');
    if (digits.length == 13 && digits.startsWith('88')) {
      digits = digits.substring(2);
    }
    if (digits.length == 14 && digits.startsWith('880')) {
      digits = digits.substring(3);
    }
    return digits;
  }

  bool _isUnsubscribeApiSuccess(Map<String, dynamic> data) {
    if (data.containsKey('error') && data['success'] != true) {
      return false;
    }

    final success = data['success'] == true;
    final apiStatusCode = (data['statusCode'] ?? '').toString().toUpperCase();
    final subscriptionStatus =
        (data['subscriptionStatus'] ?? '').toString().toUpperCase();
    final statusDetail = (data['statusDetail'] ?? '').toString().toLowerCase();

    return success ||
        apiStatusCode == 'S1000' ||
        subscriptionStatus == 'UNREGISTERED' ||
        statusDetail.contains('un-registered') ||
        statusDetail.contains('unregistered');
  }

  Future<http.Response> _postUnsubscribe(String phone) {
    return http
        .post(
          Uri.parse(ApiConstants.unsubscribeEndpoint),
          headers: ApiConstants.formHeaders,
          body: {'user_mobile': phone},
        )
        .timeout(ApiConstants.requestTimeout);
  }

  Future<void> _handleUnsubscribe() async {
    final prefs = await SharedPreferences.getInstance();
    final rawPhone = (prefs.getString('userPhone') ??
            prefs.getString(StorageKeys.lastPhoneNumber) ??
            '')
        .trim();
    final phone = _normalizeBdMobile(rawPhone);

    if (phone.isEmpty || phone.length != 11 || !phone.startsWith('01')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number found')),
      );
      return;
    }

    setState(() => _isUnsubscribing = true);

    try {
      final resp = await _postUnsubscribe(phone);

      Map<String, dynamic> parsed = {};
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          parsed = decoded;
        }
      } catch (_) {
        throw Exception('Invalid server response');
      }

      final statusDetail = (parsed['statusDetail'] ?? '').toString();
      final subscriptionStatus =
          (parsed['subscriptionStatus'] ?? '').toString().toUpperCase();
      final apiError = (parsed['error'] ?? '').toString().trim();
      final apiMessage = (parsed['message'] ?? '').toString().trim();

      String message = 'Successfully unsubscribed. Please login again.';
      if (statusDetail.toLowerCase().contains('un-registered') ||
          statusDetail.toLowerCase().contains('unregistered') ||
          subscriptionStatus == 'UNREGISTERED') {
        message = 'Successfully unsubscribed. Please login again with OTP.';
      } else if (apiMessage.isNotEmpty) {
        message = apiMessage;
      } else if (apiError.isNotEmpty) {
        message = apiError;
      } else if (statusDetail.isNotEmpty) {
        message = statusDetail;
      }

      final ok = _isUnsubscribeApiSuccess(parsed);
      if (!ok) {
        throw Exception(message.isNotEmpty ? message : 'Unsubscribe failed');
      }

      // Keep phone so the next OTP login can prefill it.
      await prefs.setString(StorageKeys.lastPhoneNumber, phone);
      await prefs.remove('userPhone');
      await prefs.remove('userId');
      await prefs.setBool('isLoggedIn', false);

      try {
        await Get.find<LocalStorageService>().logout();
      } catch (_) {
        await prefs.setBool(StorageKeys.isLoggedIn, false);
        await prefs.remove(StorageKeys.accessToken);
        await prefs.remove(StorageKeys.refreshToken);
        await prefs.remove(StorageKeys.subscriberId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Get.offAllNamed(AppRoutes.phoneRoute);
    } catch (e) {
      if (mounted) setState(() => _isUnsubscribing = false);
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsubscribe failed: $msg')),
      );
    }
  }

  Future<void> _confirmUnsubscribe() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Unsubscribe'),
          content: const Text('Are you sure you want to unsubscribe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (res == true) {
      await _handleUnsubscribe();
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconBackground,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          splashColor: Color(0xFF4F46E5).withOpacity(0.12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF94A3B8).withOpacity(0.08),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBackground ?? Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor ?? Color(0xFF2563EB), size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFEAEEF6),
      drawer: Drawer(
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Container(
          color: Color(0xFFF8FAFF),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFDDE7FF), Color(0xFFF8FAFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(34),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QuizForge',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Premium quiz access & insights',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  _buildDrawerItem(
                    icon: Icons.home,
                    iconBackground: Color(0xFFEFF6FF),
                    iconColor: Color(0xFF3B82F6),
                    title: 'Home',
                    onTap: _goHomeFromDrawer,
                  ),
                  _buildDrawerItem(
                    icon: Icons.bookmark,
                    iconBackground: Color(0xFFE0F2FE),
                    iconColor: Color(0xFF0284C7),
                    title: 'Saved Quizzes',
                    onTap: _openSavedQuizzes,
                  ),
                  _buildDrawerItem(
                    icon: Icons.lightbulb,
                    iconBackground: Color(0xFFFEF3C7),
                    iconColor: Color(0xFFF59E0B),
                    title: 'Interview Tips',
                    onTap: _openInterviewTips,
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    iconBackground: Color(0xFFEEE7FF),
                    iconColor: Color(0xFF7C3AED),
                    title: 'Settings',
                    onTap: _openSettings,
                  ),
                  SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4F46E5),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed:
                                _isUnsubscribing ? null : _confirmUnsubscribe,
                            child: _isUnsubscribing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Unsubscribe',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF0F172A),
                              side: BorderSide(color: Color(0xFFCBD5E1)),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: _confirmLogout,
                            child: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _openDrawer,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFF445D92),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 234, 236, 240),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 35,),
                                  Expanded(
                                    child: Text(
                                      'QuizForge',
                                      style: GoogleFonts.poppins(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    Container(
                      height: 220,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFE3E8F5),
                        borderRadius: BorderRadius.circular(28),
                        image: DecorationImage(
                          image: AssetImage('assets/image.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.18),
                              Colors.white.withOpacity(0.06),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEEF2FB), Color(0xFFDDE5F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF54699E).withOpacity(0.12),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: GoogleFonts.poppins(
                              color: Color(0xFF313A58),
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Container(
                                width: 46,
                                height: 46,
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFF5D77B3),
                                  size: 20,
                                ),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Color(0xFF7384A0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              hintText: 'Search topics...',
                              hintStyle: GoogleFonts.poppins(
                                color: Color(0xFF7B8BA4),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFFD7E6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? Color(0xFF4C7AED) : Color(0xFFE4E9F2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Color(0xFF274E94) : Color(0xFF667085),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final topic = _filteredTopics[index];
                    final topicColor = topic['color'] as Color;
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 350 + (index * 50)),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 14,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () => _startQuiz(topic),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: topicColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            topic['icon'],
                                            color: topicColor,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topic['title'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF121827),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              topic['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: topic['difficulty'] == 'Beginner'
                                              ? Color(0xFFEAF7EE)
                                              : topic['difficulty'] == 'Intermediate'
                                                  ? Color(0xFFFFF4EC)
                                                  : Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          topic['difficulty'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: topic['difficulty'] == 'Beginner'
                                                ? Color(0xFF16A34A)
                                                : topic['difficulty'] == 'Intermediate'
                                                    ? Color(0xFFB45309)
                                                    : Color(0xFFB91C1C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.help_outline,
                                        size: 16,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${topic['questionCount']} questions',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      SizedBox(width: 18),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        topic['popularity'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: _filteredTopics.length),
                ),
              ),
              if (_filteredTopics.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No topics found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
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
