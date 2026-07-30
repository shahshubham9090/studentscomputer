import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../models/group_model.dart';
import '../../models/quiz_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/quiz_provider.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_text_field.dart';
import '../admin/create_quiz_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const _TeacherGroupsTab(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildNavigationRail(),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomBar(),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        labelType: NavigationRailLabelType.selected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIconTheme: const IconThemeData(color: Colors.teal, size: 28),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade400, size: 24),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.teal,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
        leading: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Icon(Icons.school, size: 40, color: Colors.teal),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: Text("My Groups"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text("Profile"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        itemPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.group_outlined),
            activeIcon: const Icon(Icons.group),
            title: const Text("My Groups"),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _TeacherGroupsTab extends StatefulWidget {
  const _TeacherGroupsTab();

  @override
  State<_TeacherGroupsTab> createState() => _TeacherGroupsTabState();
}

class _TeacherGroupsTabState extends State<_TeacherGroupsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<GroupProvider>(context, listen: false).fetchTeacherGroups(user.id);
      }
    });
  }

  void _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final groupProv = Provider.of<GroupProvider>(context, listen: false);

    // Fetch students list
    List<UserModel> students = [];
    try {
      students = await groupProv.fetchAllStudents();
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }

    List<String> selectedStudentIds = [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Create a New Group", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create a separate workspace for your students and invite them.",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Group Name",
                  controller: nameController,
                  prefixIcon: Icons.group_add_outlined,
                  validator: (v) => v!.trim().isEmpty ? "Group name is required" : null,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Invite Students (Optional):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 8),
                StudentMultiSelector(
                  allStudents: students,
                  initialSelectedIds: selectedStudentIds,
                  onSelectedChanged: (ids) {
                    selectedStudentIds = ids;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final groupProv = Provider.of<GroupProvider>(context, listen: false);
                
                final teacherId = auth.currentUser!.id;
                final teacherName = auth.currentUser!.displayName;

                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);

                try {
                  await groupProv.createGroup(
                    nameController.text.trim(),
                    teacherId,
                    teacherName,
                    initialInvitedStudentIds: selectedStudentIds,
                  );
                  if (navigator.mounted) {
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Group created successfully and invitations sent!"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProv = context.watch<GroupProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Workspace", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: groupProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await groupProv.fetchTeacherGroups(user.id);
                }
              },
              color: Colors.teal,
              child: groupProv.teacherGroups.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupList(groupProv.teacherGroups),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroupDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_outlined, size: 64, color: Colors.teal),
            ),
            const SizedBox(height: AppSpacing.l),
            const Text(
              "No groups created yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Create a group to share and interact with students separately.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList(List<GroupModel> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: groups.length,
      itemBuilder: (ctx, idx) {
        final group = groups[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Colors.teal.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToGroupDetails(group),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.teal),
                        tooltip: "Copy Group Code",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: group.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Copied Code: ${group.code}"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Code: ${group.code}",
                          style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${group.studentIds.length} Students",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToGroupDetails(GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _GroupDetailScreen(group: group),
      ),
    );
  }
}

class _GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const _GroupDetailScreen({required this.group});

  @override
  State<_GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<_GroupDetailScreen> {
  late GroupModel _currentGroup;
  late Future<List<UserModel>> _enrolledStudentsFuture;
  late Future<List<UserModel>> _pendingStudentsFuture;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
    _refreshStudents();
  }

  void _refreshStudents() {
    setState(() {
      _enrolledStudentsFuture = _fetchStudents(_currentGroup.studentIds);
      _pendingStudentsFuture = _fetchStudents(_currentGroup.pendingStudentIds);
    });
  }

  Future<List<UserModel>> _fetchStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    final firestore = FirebaseFirestore.instance;
    final List<UserModel> students = [];
    
    for (var i = 0; i < studentIds.length; i += 10) {
      final chunk = studentIds.sublist(i, min(i + 10, studentIds.length));
      final querySnapshot = await firestore
          .collection('users')
          .where('id', whereIn: chunk)
          .get();
      for (var doc in querySnapshot.docs) {
        students.add(UserModel.fromJson(doc.data()));
      }
    }
    return students;
  }

  void _showInviteStudentsDialog() async {
    final groupProv = Provider.of<GroupProvider>(context, listen: false);
    List<UserModel> allStudents = [];
    try {
      allStudents = await groupProv.fetchAllStudents();
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }

    // Filter out students who are already enrolled or pending
    final filterStudents = allStudents.where((s) {
      return !_currentGroup.studentIds.contains(s.id) &&
             !_currentGroup.pendingStudentIds.contains(s.id);
    }).toList();

    List<String> selectedStudentIds = [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Invite Students", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select students to invite to this group. They will receive an invitation to approve.",
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            StudentMultiSelector(
              allStudents: filterStudents,
              initialSelectedIds: selectedStudentIds,
              onSelectedChanged: (ids) {
                selectedStudentIds = ids;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (selectedStudentIds.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);
                try {
                  await groupProv.inviteStudentsToGroup(_currentGroup.id, selectedStudentIds);
                  
                  setState(() {
                    final updatedPending = List<String>.from(_currentGroup.pendingStudentIds)
                      ..addAll(selectedStudentIds);
                    _currentGroup = _currentGroup.copyWith(pendingStudentIds: updatedPending);
                    _refreshStudents();
                  });

                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Invitations sent successfully!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
                  );
                }
              } else {
                Navigator.pop(ctx);
              }
            },
            child: const Text("Invite", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteQuiz(BuildContext context, QuizProvider quizProv, String quizId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Quiz?"),
        content: const Text("Are you sure you want to permanently delete this quiz? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await quizProv.deleteQuiz(quizId);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text("Quiz deleted successfully")),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text("Error deleting quiz: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildJoiningCodeCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Joining Code",
                  style: TextStyle(
                    color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentGroup.code,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.teal.shade300 : Colors.teal,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.copy, color: isDark ? Colors.teal.shade300 : Colors.teal),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _currentGroup.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Group code copied to clipboard!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Class Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showInviteStudentsDialog,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text("Invite", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<UserModel>>(
            future: _enrolledStudentsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }
              final enrolled = snapshot.data ?? [];
              return FutureBuilder<List<UserModel>>(
                future: _pendingStudentsFuture,
                builder: (ctx2, snapshot2) {
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal));
                  }
                  final pending = snapshot2.data ?? [];

                  if (enrolled.isEmpty && pending.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                          const SizedBox(height: 8),
                          Text(
                            "No students yet. Copy code or click Invite to add students.",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      if (enrolled.isNotEmpty) ...[
                        Text(
                          "Enrolled",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 8),
                        ...enrolled.map((student) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                            child: student.avatarUrl == null ? const Icon(Icons.person, color: Colors.teal) : null,
                          ),
                          title: Text(student.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(student.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          trailing: Text(
                            "${student.points} pts",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.teal.shade300 : Colors.teal),
                          ),
                        )),
                        const SizedBox(height: 16),
                      ],
                      if (pending.isNotEmpty) ...[
                        Text(
                          "Pending Invite",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 8),
                        ...pending.map((student) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                            child: student.avatarUrl == null ? const Icon(Icons.person, color: Colors.orange) : null,
                          ),
                          title: Text(student.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(student.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Pending",
                              style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesTab(List<Quiz> quizzes, QuizProvider quizProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Class Quizzes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => CreateQuizScreen(assignedGroupId: _currentGroup.id),
                  ),
                );
              },
              icon: const Icon(Icons.add_task, size: 18),
              label: const Text("Create Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      Text(
                        "No quizzes created for this group",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (ctx, idx) {
                    final quiz = quizzes[idx];
                    return Card(
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    quiz.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => CreateQuizScreen(
                                              quizToEdit: quiz,
                                              assignedGroupId: _currentGroup.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => _confirmDeleteQuiz(context, quizProv, quiz.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quiz.description,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  quiz.isPublished ? "Status: Published" : "Status: Draft",
                                  style: TextStyle(
                                    color: quiz.isPublished ? Colors.green : Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "${quiz.questions.length} Questions",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    quizProv.togglePublishStatus(quiz.id);
                                  },
                                  child: Text(quiz.isPublished ? "Unpublish" : "Publish"),
                                ),
                                const SizedBox(width: 8),
                                if (!quiz.isResultsDeclared)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await quizProv.declareResults(quiz.id);
                                      messenger.showSnackBar(
                                        const SnackBar(content: Text("Results declared successfully!")),
                                      );
                                    },
                                    child: const Text("Declare Results"),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Results Declared",
                                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProv = context.watch<QuizProvider>();
    final groupQuizzes = quizProv.quizzes.where((q) => q.groupId == _currentGroup.id).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentGroup.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Students", icon: Icon(Icons.people_outline)),
              Tab(text: "Quizzes", icon: Icon(Icons.quiz_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJoiningCodeCard(),
                  const SizedBox(height: AppSpacing.l),
                  Expanded(
                    child: _buildStudentsListSection(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: _buildQuizzesTab(groupQuizzes, quizProv),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentMultiSelector extends StatefulWidget {
  final List<UserModel> allStudents;
  final List<String> initialSelectedIds;
  final Function(List<String>) onSelectedChanged;

  const StudentMultiSelector({
    super.key,
    required this.allStudents,
    required this.initialSelectedIds,
    required this.onSelectedChanged,
  });

  @override
  State<StudentMultiSelector> createState() => _StudentMultiSelectorState();
}

class _StudentMultiSelectorState extends State<StudentMultiSelector> {
  late List<String> _selectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = widget.allStudents.where((s) {
      return s.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             s.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: "Search students...",
            prefixIcon: Icon(Icons.search, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          width: double.maxFinite,
          child: filteredStudents.isEmpty
              ? const Center(child: Text("No students found"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, idx) {
                    final student = filteredStudents[idx];
                    final isChecked = _selectedIds.contains(student.id);
                    return CheckboxListTile(
                      activeColor: Colors.teal,
                      title: Text(student.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(student.email, style: const TextStyle(fontSize: 12)),
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedIds.add(student.id);
                          } else {
                            _selectedIds.remove(student.id);
                          }
                          widget.onSelectedChanged(_selectedIds);
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
