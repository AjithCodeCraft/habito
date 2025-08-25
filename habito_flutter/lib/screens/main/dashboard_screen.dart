import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../food/food_overview_screen.dart';
import '../sleep/sleep_overview_screen.dart';
import '../habits/habits_screen.dart';
import '../todos/todos_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Overview',
    ),
    NavigationItem(
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu,
      label: 'Food',
    ),
    NavigationItem(
      icon: Icons.bedtime_outlined,
      selectedIcon: Icons.bedtime,
      label: 'Sleep',
    ),
    NavigationItem(
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
      label: 'Habits',
    ),
    NavigationItem(
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
      label: 'Tasks',
    ),
  ];

  List<Widget> get _screens => [
    const OverviewScreen(),
    const FoodOverviewScreen(),
    const SleepOverviewScreen(),
    const HabitsScreen(),
    const TodosScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNavigation(),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_navigationItems[_selectedIndex].label),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar() {
    final theme = Theme.of(context);
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Text(
              _navigationItems[_selectedIndex].label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNavigation() {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand
          Container(
            height: 80,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.spa,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Habito',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = index == _selectedIndex;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    selected: isSelected,
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => _onItemTapped(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: _navigationItems.map((item) {
        final index = _navigationItems.indexOf(item);
        final isSelected = index == _selectedIndex;
        
        return BottomNavigationBarItem(
          icon: Icon(isSelected ? item.selectedIcon : item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Good morning! 🌅',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s your wellness summary for today',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            // Quick Stats Cards
            ResponsiveGrid(
              children: [
                _buildQuickStatCard(
                  context,
                  title: 'Today\'s Calories',
                  value: '1,240 / 2,000',
                  icon: Icons.restaurant_menu,
                  color: Colors.orange,
                ),
                _buildQuickStatCard(
                  context,
                  title: 'Sleep Last Night',
                  value: '7h 45m',
                  icon: Icons.bedtime,
                  color: Colors.indigo,
                ),
                _buildQuickStatCard(
                  context,
                  title: 'Active Habits',
                  value: '2 / 3',
                  icon: Icons.task_alt,
                  color: Colors.green,
                ),
                _buildQuickStatCard(
                  context,
                  title: 'Pending Tasks',
                  value: '4',
                  icon: Icons.checklist,
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Today's Progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LinearLoadingIndicator(
                      message: 'Loading your daily progress...',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}