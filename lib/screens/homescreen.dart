import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image.png'),
                        fit: BoxFit.cover,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade400, Colors.green.shade400],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search topics...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blue.shade400,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.shade50,
                          checkmarkColor: Colors.blue,
                          labelStyle: GoogleFonts.poppins(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final topic = _filteredTopics[index];
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => _startQuiz(topic),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              (topic['color'] as Color)
                                                  .withOpacity(0.2),
                                              (topic['color'] as Color)
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          topic['icon'],
                                          color: topic['color'],
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topic['title'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              topic['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (topic['difficulty'] ==
                                                  'Beginner')
                                              ? Colors.green.shade50
                                              : (topic['difficulty'] ==
                                                    'Intermediate')
                                              ? Colors.orange.shade50
                                              : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          topic['difficulty'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                (topic['difficulty'] ==
                                                    'Beginner')
                                                ? Colors.green.shade700
                                                : (topic['difficulty'] ==
                                                      'Intermediate')
                                                ? Colors.orange.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.help_outline,
                                        size: 16,
                                        color: Colors.grey.shade500,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${topic['questionCount']} questions',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        topic['popularity'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Colors.blue.shade700,
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

              // Empty State
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
