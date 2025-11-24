import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'calendar_screen.dart';
import 'theme_constants.dart';
import 'home_page.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final bool isLoggedIn;
  final VoidCallback onBackTap;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.isLoggedIn = false, // Default to false in case guest mode
    required this.onBackTap,
  });



  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isAttending = false;
  bool _isBookmarked = false;
  bool _showDescription = false;
  int _currentImageIndex = 0;
  int _selectedIndex = 5;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final TextEditingController _commentController = TextEditingController();



  final List<Map<String, String>> _comments = [
    {'comment': 'WOW im definitely coming!!!',
      'username': 'student1',    },
    {'comment': 'i have a lab tomorrow :(',
     'username': 'baris_manco',},
    {'comment': 'dummy comment',
    'username': 'dummy_user',
    },

    {'comment': 'ilk yorum',
    'username': 'funny_student',
    },
  ];

  // Dummy images for now
  final List<String> _eventImages = [
    'assets/images/event_image1.jpg',
    'assets/images/event_image2.jpg',
    'assets/images/event_image3.jpg',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }


  void _handleCommentTap() {
    if (!widget.isLoggedIn) {

      Navigator.pushNamed(context, '/login').then((_) {
       //login code needed
      });
    } else {
      // Show comment input dialog
      _showCommentDialog();
    }
    print("Comment button pressed");
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: const Text(
            "Add Comment",
            style: TextStyle(color: AppColors.textBlack),
          ),
          content: TextField(
            controller: _commentController,
            style: const TextStyle(color: AppColors.textBlack),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Write your comment...",
              hintStyle: AppTextStyles.hintText,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textBlack),
              ),
              onPressed: () {
                _commentController.clear();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                "Post",
                style: AppTextStyles.bodyBold,
              ),
              onPressed: () {
                if (_commentController.text.trim().isNotEmpty) {
                  setState(() {
                    _comments.insert(0, {
                      'username': _commentController.text.trim(),
                    });
                  });
                  _commentController.clear();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment posted!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    final VoidCallback onBackToHome = () => _onItemTapped(0);

    if (_selectedIndex == 0) {
      bodyContent = HomePage();
    } else if (_selectedIndex == 1) {
      bodyContent = SearchScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 2) {
      bodyContent = CreateEventScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 3) {
      bodyContent = CalendarScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 4) {
      bodyContent = ProfilePage(onBackTap: onBackToHome);
    } else {
      bodyContent = eventDetails();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: bodyContent,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.accentLight,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0, isActive: _selectedIndex == 0),
            _buildNavItem(Icons.search, 1, isActive: _selectedIndex == 1),
            _buildNavItem(Icons.add_circle_outline, 2, isActive: _selectedIndex == 2),
            _buildNavItem(Icons.calendar_today_outlined, 3, isActive: _selectedIndex == 3),
            _buildNavItem(Icons.person_outline, 4, isActive: _selectedIndex == 4),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButton({
    required IconData icon,
    IconData? activeIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? Colors.black54 : AppColors.accentLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black26,
            width: 2,
          ),
        ),
        child: Icon(
          isActive && activeIcon != null ? activeIcon : icon,
          color: isActive ? Colors.white : Colors.black,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCommentItem(String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.person,
              color: Colors.black54,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black54, width: 2),
        )
            : null,
        child: Icon(
          icon,
          size: AppDimens.iconMedium,
          color: AppColors.iconBlack,
        ),
      ),
    );
  }

  Widget eventDetails() {
    return Column(
      children: [
        Container(
          color: AppColors.backgroundHeader,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: 40, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.event.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event info card with swipeable images
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top info section
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and time
                            Text(
                              widget.event.time,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Location
                            Text(
                              widget.event.location,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description preview or full description
                            if (!_showDescription)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello everyone, this will be our ${widget.event.title.toLowerCase()} event...",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showDescription = true;
                                      });
                                    },
                                    child: const Text(
                                      "View More",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello everyone, this will be our ${widget.event.title.toLowerCase()} event featuring a selection of acclaimed independent films. We'll be watching Pedro's films, along with popcorn and drinks. Join us for an evening of great cinema and discussion. The event starts at ${widget.event.time} at ${widget.event.location}. Feel free to bring your friends!",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showDescription = false;
                                      });
                                    },
                                    child: const Text(
                                      "Show Less",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Swipeable image gallery
                      // Swipeable image gallery - DEBUG VERSION
                      SizedBox(
                        height: 200,
                        child: Container(
                          color: Colors.red.withOpacity(0.3), // Debug border
                          child: Stack(
                            children: [
                              // PageView with expanded touch area
                              Positioned.fill(
                                child: Container(
                                  color: Colors.blue.withOpacity(0.3), // Debug border
                                  child: PageView.builder(
                                    itemCount: _eventImages.length,
                                    physics: const PageScrollPhysics(),
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.green, width: 2), // Debug border
                                        ),
                                        child: Image.asset(
                                          _eventImages.length > index ? _eventImages[index] : _eventImages[0],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[400],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Page indicator
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    color: Colors.yellow.withOpacity(0.3), // Debug border
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(_eventImages.length, (index) {
                                        return Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentImageIndex == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Action buttons row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        isActive: _isAttending,
                        onTap: () {
                          setState(() {
                            _isAttending = !_isAttending;
                          });
                          print("Attend button pressed: $_isAttending");
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        isActive: false,
                        onTap: _handleCommentTap,
                      ),
                      _buildActionButton(
                        icon: Icons.bookmark_border,
                        isActive: _isBookmarked,
                        activeIcon: Icons.bookmark,
                        onTap: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                          print("Bookmark button pressed: $_isBookmarked");
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.send,
                        isActive: false,
                        onTap: () {
                          print("Share button pressed");
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Comments section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Comments:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Comment list
                      ..._comments.map((comment) => _buildCommentItem(comment['comment']!,)),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }


}