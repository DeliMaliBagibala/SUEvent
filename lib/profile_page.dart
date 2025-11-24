import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'home_page.dart';

// Result object used when coming back from the edit page.
class ProfileEditResult {
  final String name;
  final String biography;

  ProfileEditResult({
    required this.name,
    required this.biography,
  });
}

// Main profile page
class ProfilePage extends StatefulWidget {
  final VoidCallback onBackTap;

  const ProfilePage({
    super.key,
    required this.onBackTap,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Your Name";
  String _bioText = "";

  bool _showUpcoming = true;

  // Upcoming and Attended Lists
  final List<Event> _upcomingEvents = [
    Event(
      title: "Upcoming Event 1",
      location: "FMAN G098",
      category: "Category-1",
      time: "09.00",
    ),
    Event(
      title: "Upcoming Event 2",
      location: "FMAN G098",
      category: "Category-1",
      time: "09.00",
    ),
    Event(
      title: "Upcoming Event 3",
      location: "FMAN G098",
      category: "Category-1",
      time: "09.00",
    ),
    Event(
      title: "Upcoming Event 4",
      location: "FMAN G098",
      category: "Category-1",
      time: "09.00",
    ),
    Event(
      title: "Upcoming Event 5",
      location: "FMAN G098",
      category: "Category-1",
      time: "09.00",
    ),
    Event(
      title: "Movie Night",
      location: "FMAN G098",
      category: "Category-2",
      time: "21.30",
    ),
  ];

  final List<Event> _attendedEvents = [
    Event(
      title: "Past Event",
      location: "FMAN G098",
      category: "Category-3",
      time: "18.00",
    ),
  ];

  List<Event> get _visibleEvents =>
      _showUpcoming ? _upcomingEvents : _attendedEvents;

  Future<void> _openEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialName: _userName,
          initialBio: _bioText,
        ),
      ),
    );

    if (result is ProfileEditResult) {
      setState(() {
        _userName = result.name.isEmpty ? "Your Name" : result.name;
        _bioText = result.biography;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pagePadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_left,
                    size: AppDimens.iconLarge,
                    color: AppColors.textBlack,
                  ),
                  onPressed: widget.onBackTap,
                  padding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 8),

              // Avatar, name and edit button
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.accentLight,
                      child: Icon(
                        Icons.person_outline,
                        size: AppDimens.iconLarge,
                        color: AppColors.iconBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userName,
                      style: AppTextStyles.headerLarge,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _openEditPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.buttonRadius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 6,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Edit Profile",
                          style: AppTextStyles.bodyBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Biography section
              Text(
                "Biography",
                style: AppTextStyles.headerMediumThin,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                ),
                child: Text(
                  _bioText.isEmpty
                      ? "Write something about yourself..."
                      : _bioText,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Saved Events title with lines
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Saved Events",
                      style: AppTextStyles.bodyBold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tabs: Upcoming and Attended
              Row(
                children: [
                  Expanded(
                    child: _ProfileTabButton(
                      text: "Upcoming Events",
                      isSelected: _showUpcoming,
                      onTap: () {
                        setState(() {
                          _showUpcoming = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ProfileTabButton(
                      text: "Attended Events",
                      isSelected: !_showUpcoming,
                      onTap: () {
                        setState(() {
                          _showUpcoming = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Event list using EventCard from the Event.dart class.
              Column(
                children: _visibleEvents
                    .map(
                      (event) => EventCard(
                    event: event,
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small tab button widget for the two buttons upcoming and attended event
class _ProfileTabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTabButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cardBackground
              : AppColors.accentLight.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.bodyBold.copyWith(
            color: AppColors.textBlack,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Edit profile page
class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialBio;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialBio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _bioCtrl = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    Navigator.pop(
      context,
      ProfileEditResult(
        name: _nameCtrl.text.trim(),
        biography: _bioCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pagePadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                  size: AppDimens.iconLarge,
                  color: AppColors.textBlack,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // Avatar with small edit icon
              Center(
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.accentLight,
                          child: Icon(
                            Icons.person_outline,
                            size: AppDimens.iconLarge,
                            color: AppColors.iconBlack,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            print("Photo Change Button Pressed");
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.cardBackground,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: AppDimens.iconSmall,
                              color: AppColors.iconBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Username field
              const Text(
                "Username",
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textBlack,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Users Name Surname",
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Biography field
              const Text(
                "Biography",
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                ),
                child: TextField(
                  controller: _bioCtrl,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textBlack,
                  ),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Users Biography",
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveAndClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppDimens.buttonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: AppTextStyles.bodyBold,
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
