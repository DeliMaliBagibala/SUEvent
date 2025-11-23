import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'calendar_screen.dart';
import 'starting_page.dart';

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        useMaterial3: true,
      ),
      home: const StartingPage(),
    );
  }
}


class Event {
  final String title;
  final String location;
  final String category;
  final String time;

  Event({
    required this.title,
    required this.location,
    required this.category,
    required this.time,
  });
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Event> _homeEvents = [
    Event(title: "Sample Event 1", location: "FMAN G098", category: "Category-1", time: "09.00"),
    Event(title: "Sample Event 3", location: "UC 1023", category: "Category-1", time: "20.00"),
    Event(title: "Movie Night", location: "FMAN G098", category: "Category-2", time: "21.30"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;


    final VoidCallback onBackToHome = () => _onItemTapped(0);


    if (_selectedIndex == 0) {
      bodyContent = _buildHomeContent();
    } else if (_selectedIndex == 1) {
      bodyContent = SearchScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 2) {
      bodyContent = CreateEventScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 3) {
      bodyContent = CalendarScreen(onBackTap: onBackToHome);
    } else if (_selectedIndex == 4) {
      bodyContent = Center(child: Text("Profile Page Placeholder", style: AppTextStyles.headerLarge));
    } else {
      bodyContent = Center(child: Text("Page Index $_selectedIndex"));
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

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Text(
            "Welcome Back, User!",
            style: AppTextStyles.headerLarge,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppDimens.smallRadius),
          ),
          child: const Text(
            "Upcoming Events:",
            style: AppTextStyles.bodyBold,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            color: AppColors.backgroundDark,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              itemCount: _homeEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: _homeEvents[index]);
              },
            ),
          ),
        ),
      ],
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
}

class SearchScreen extends StatelessWidget {
  final VoidCallback onBackTap;

  SearchScreen({super.key, required this.onBackTap});

  final List<dynamic> searchItems = [
    "01/01/2026",
    Event(title: "Sample Event 1", location: "FMAN G098", category: "Category-1", time: "09.00"),
    Event(title: "Sample Event 2", location: "FMAN G098", category: "Category-2", time: "10.00"),
    Event(title: "Movie Night", location: "FMAN G098", category: "Category-1", time: "21.30"),
    "02/01/2026",
    Event(title: "Sample Event 4", location: "FMAN G098", category: "Category-1", time: "09.00"),
    Event(title: "Sample Event 5", location: "FMAN G098", category: "Category-1", time: "11.00"),
    Event(title: "Sample Event 6", location: "FMAN G098", category: "Category-1", time: "14.00"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.backgroundHeader,
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
                onPressed: onBackTap,
              ),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    style: AppTextStyles.labelLarge,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: AppTextStyles.labelLarge,
                      prefixIcon: Icon(Icons.search, color: AppColors.textBlack, size: 28),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.backgroundDark,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              itemCount: searchItems.length,
              itemBuilder: (context, index) {
                final item = searchItems[index];
                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Text(
                      item,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.dateHeader,
                    ),
                  );
                }
                if (item is Event) {
                  return EventCard(event: item);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CreateEventScreen extends StatefulWidget {
  final VoidCallback onBackTap;

  const CreateEventScreen({super.key, required this.onBackTap});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String _eventTitle = "NEW EVENT";

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: "01/01/2000");
    _timeController = TextEditingController(text: "00:00");
    _categoryController = TextEditingController(text: "Category 1");
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _editTitle() async {
    TextEditingController controller = TextEditingController(text: _eventTitle);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: const Text("Event Name", style: TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: const InputDecoration(
              hintText: "Enter event name",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                setState(() {
                  _eventTitle = controller.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editField(String label, TextEditingController controller) async {
    TextEditingController tempController = TextEditingController(text: controller.text);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.accentLight,
          title: Text(label, style: const TextStyle(color: AppColors.textBlack)),
          content: TextField(
            controller: tempController,
            style: const TextStyle(color: AppColors.textBlack),
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: AppTextStyles.hintText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: AppColors.textBlack)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save", style: AppTextStyles.bodyBold),
              onPressed: () {
                setState(() {
                  controller.text = tempController.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: AppDimens.iconLarge, color: AppColors.textBlack),
                  onPressed: widget.onBackTap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _editTitle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _eventTitle.toUpperCase(),
                          style: AppTextStyles.headerMediumThin,
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.edit_outlined, color: AppColors.textBlack, size: AppDimens.iconSmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildEditableRow("Date:", _dateController, () => _editField("Date", _dateController)),
                const SizedBox(height: 15),
                _buildEditableRow("Time:", _timeController, () => _editField("Time", _timeController)),
                const SizedBox(height: 15),
                _buildEditableRow("Category:", _categoryController, () => _editField("Category", _categoryController)),

                const SizedBox(height: 30),

                Container(
                  height: 80,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    border: Border.all(color: Colors.black54),
                  ),
                  child: const TextField(
                    maxLines: null,
                    style: TextStyle(color: AppColors.textBlack),
                    decoration: InputDecoration(
                      hintText: "Add description",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Text(
                      "Add Photo:",
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        print("Button tapped");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundHeader,
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textBlack, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Container(
                    width: 200,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: AppColors.iconBlack,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, VoidCallback onEdit) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.labelLarge,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: onEdit,
            style: AppTextStyles.labelLarge,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textBlack, size: AppDimens.iconSmall),
                onPressed: onEdit,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.textWhite,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTextStyles.bodyBold,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      event.location,
                      style: AppTextStyles.cardSubtitle,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      event.category,
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  print("Detailed event button pressed");
                  ;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textWhite.withOpacity(0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "View\nEvent",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonSmall,
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.play_arrow, color: AppColors.textWhite, size: AppDimens.iconSmall),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.time,
                style: AppTextStyles.bodyBold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}