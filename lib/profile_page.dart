import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_constants.dart';
import 'home_page.dart'; // Imports EventCard
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'models/event_model.dart';
import 'starting_page.dart'; // Import LoginPage

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
  
  bool _showCreated = true; // 'Created' events vs 'Saved/Attended'

  Future<void> _openEditPage(BuildContext context, String currentName, String currentBio) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialName: currentName,
          initialBio: currentBio,
        ),
      ),
    );

    if (result is ProfileEditResult) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      try {
        await authProvider.updateProfile(
          username: result.name,
          bio: result.biography,
        );
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update profile: $e")),
          );
        }
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      // Navigate to the login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _deleteEvent(String eventId, String createdBy) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    await eventProvider.deleteEvent(eventId, createdBy);

    if (mounted) {
      if (eventProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(eventProvider.error!)),
        );
        eventProvider.clearError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event deleted successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppAuthProvider, EventProvider>(
      builder: (context, authProvider, eventProvider, child) {
        
        final userData = authProvider.userData;
        final username = userData?['username'] ?? "User";
        final bio = userData?['bio'] ?? "";
        final currentUserId = authProvider.user?.uid;

        final createdEvents = eventProvider.events.where((e) => e.createdBy == currentUserId).toList();
        final attendedEvents = <Event>[]; // Placeholder for saved events

        final visibleEvents = _showCreated ? createdEvents : attendedEvents;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
                        onPressed: widget.onBackTap,
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 28, color: Colors.redAccent),
                        onPressed: () => _logout(context),
                        tooltip: "Logout",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.accentLight,
                          child: Icon(Icons.person_outline, size: AppDimens.iconLarge, color: AppColors.iconBlack),
                        ),
                        const SizedBox(height: 8),
                        Text(username, style: AppTextStyles.headerLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => _openEditPage(context, username, bio),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardBackground,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.buttonRadius)),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                              elevation: 0,
                            ),
                            child: const Text("Edit Profile", style: AppTextStyles.bodyBold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Biography", style: AppTextStyles.headerMediumThin),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                    ),
                    child: Text(
                      bio.isEmpty ? "Write something about yourself..." : bio,
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.textBlack),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: Colors.white)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("My Events", style: AppTextStyles.bodyBold),
                      ),
                      Expanded(child: Container(height: 1, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileTabButton(
                          text: "Created Events",
                          isSelected: _showCreated,
                          onTap: () => setState(() => _showCreated = true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProfileTabButton(
                          text: "Saved Events",
                          isSelected: !_showCreated,
                          onTap: () => setState(() => _showCreated = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (visibleEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          _showCreated ? "You haven't created any events." : "No saved events yet.",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: visibleEvents.map((event) => EventCard(
                          event: event,
                          onDelete: _showCreated ? () => _deleteEvent(event.id, event.createdBy) : null,
                        )).toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Small tab button widget
class _ProfileTabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTabButton({super.key, required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.accentLight.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.bodyBold.copyWith(color: AppColors.textBlack),
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

  const EditProfilePage({super.key, required this.initialName, required this.initialBio});

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
      ProfileEditResult(name: _nameCtrl.text.trim(), biography: _bioCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundHeader,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
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
                          child: Icon(Icons.person_outline, size: AppDimens.iconLarge, color: AppColors.iconBlack),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => print("Photo Change Button Pressed"),
                          child: Container(
                            decoration: const BoxDecoration(color: AppColors.cardBackground, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.edit_outlined, size: AppDimens.iconSmall, color: AppColors.iconBlack),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Username", style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textBlack),
                  decoration: const InputDecoration(
                    hintText: "Users Name Surname",
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Biography", style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                ),
                child: TextField(
                  controller: _bioCtrl,
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textBlack),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Users Biography",
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveAndClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.buttonRadius)),
                    elevation: 0,
                  ),
                  child: const Text("Save Changes", style: AppTextStyles.bodyBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
