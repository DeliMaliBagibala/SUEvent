import 'dart:convert';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'calendar_screen.dart';
import 'theme_constants.dart';
import 'home_page.dart';
import 'models/event_model.dart';
import 'package:provider/provider.dart';
import 'providers/event_provider.dart';
import 'models/comment_model.dart';
import 'providers/auth_provider.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final bool isLoggedIn;
  final VoidCallback onBackTap;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.isLoggedIn = false,
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
    if (index == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  final TextEditingController _commentController = TextEditingController();


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _shareEvent() {
    final String eventText =
        "📅 You are invited to this event!: ${widget.event.title}\n\n"
        "⏰ When: ${widget.event.date} at ${widget.event.time}\n"
        "📍 Where: ${widget.event.location}\n"
        "📂 Category: ${widget.event.category}\n\n"
        "${widget.event.description.isNotEmpty ? widget.event.description : ''}\n\n"
        "Sent from SuEvent App";

    Share.share(eventText, subject: "Invitation to ${widget.event.title}");
  }

  void _handleCommentTap() {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      Navigator.pushNamed(context, '/login').then((_) {
        setState(() {});
      });
    } else {
      _showCommentDialog();
    }
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
              onPressed: () async {
                final text = _commentController.text.trim();

                if (text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    final eventProvider =
                    Provider.of<EventProvider>(context, listen: false);

                    await eventProvider.addComment(widget.event.id, text);

                    _commentController.clear();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Comment posted!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to post: $e")),
                      );
                    }
                  }
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
      backgroundColor: AppColors.backgroundDark,
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

  Widget _buildCommentItem(Comment comment) {
    ImageProvider pic;
    final val = comment.photoUrl;
    if (val.isNotEmpty) {
      if (val.startsWith("data:image")) {
        final data = val.split(",").last;
        pic = MemoryImage(base64Decode(data));
      } else if (val.startsWith("assets/")) {
        pic = AssetImage(val);
      } else {
        pic = NetworkImage(val);
      }
    } else {
      pic = const AssetImage("assets/images/generic_user_photo.png");
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: pic,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

  Widget _imgView(String url) {
    if (url.startsWith("data:image")) {
      final data = url.split(",").last;
      return Image.memory(
        base64Decode(data),
        fit: BoxFit.cover,
      );
    }
    if (url.startsWith("assets/")) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[400],
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 60,
              color: AppColors.iconBlack,
            ),
          ),
        );
      },
    );
  }

  String _fallbackFor(String category) {
    final key = category.toLowerCase().replaceAll(" ", "");
    if (key.contains("food")) return "assets/images/generic_food.png";
    if (key.contains("sport")) return "assets/images/generic_sports.png";
    if (key.contains("music")) return "assets/images/generic_music.png";
    if (key.contains("movie") || key.contains("film")) return "assets/images/generic_movie.png";
    if (key.contains("club")) return "assets/images/generic_clubs.png";
    if (key.contains("hang")) return "assets/images/generic_hangout.png";
    if (key.contains("game") || key.contains("dice")) return "assets/images/generic_dice.png";
    return "assets/images/generic_other.png";
  }

  Widget eventDetails() {
    final pics = widget.event.imageUrls;
    final hasPics = pics.isNotEmpty;
    return Column(
      children: [
        Container(
          color: AppColors.backgroundHeader,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: 40, color: AppColors.iconBlack),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.event.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.time,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Text(
                              widget.event.location,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: AppColors.textBlack,
                              ),
                            ),
                            const SizedBox(height: 12),

                            if (!_showDescription)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.event.description.isEmpty
                                        ? "No description yet."
                                        : widget.event.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
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
                                    widget.event.description.isEmpty
                                        ? "No description yet."
                                        : widget.event.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
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

                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: PageView.builder(
                                itemCount: hasPics ? pics.length : 1,
                                physics: const PageScrollPhysics(),
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  if (!hasPics) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          _fallbackFor(widget.event.category),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _imgView(pics[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (hasPics && pics.length > 1)
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(pics.length, (index) {
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
                          ],
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
                          print("Attend button pressed: $_isAttending"); //ph
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
                          print("Bookmark button pressed: $_isBookmarked"); //ph
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.send,
                        isActive: false,
                        onTap: _shareEvent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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

                      StreamBuilder<List<Comment>>(
                        stream: Provider.of<EventProvider>(context, listen: false)
                            .getCommentsStream(widget.event.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white));
                          }

                          final comments = snapshot.data ?? [];

                          if (comments.isEmpty) {
                            return const Text(
                              "No comments yet. Be the first!",
                              style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return _buildCommentItem(comment);
                            },
                          );
                        },
                      ),
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
