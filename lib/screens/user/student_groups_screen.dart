import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/custom_text_field.dart';

class StudentGroupsScreen extends StatefulWidget {
  const StudentGroupsScreen({super.key});

  @override
  State<StudentGroupsScreen> createState() => _StudentGroupsScreenState();
}

class _StudentGroupsScreenState extends State<StudentGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        final gp = Provider.of<GroupProvider>(context, listen: false);
        gp.fetchStudentGroups(user.id);
        gp.fetchPendingStudentGroups(user.id);
      }
    });
  }

  void _showJoinGroupDialog() {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Join a Classroom", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter the 6-character code shared by your teacher to join their group.",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Group Code",
                  controller: codeController,
                  prefixIcon: Icons.vpn_key_outlined,
                  enabled: !isSubmitting,
                  validator: (v) => v!.trim().length != 6 ? "Enter a valid 6-char code" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setModalState(() => isSubmitting = true);
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final groupProv = Provider.of<GroupProvider>(context, listen: false);
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);

                        final success = await groupProv.joinGroup(
                          codeController.text.trim().toUpperCase(),
                          auth.currentUser!.id,
                        );

                        if (navigator.mounted) {
                          navigator.pop();
                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Joined classroom successfully!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(groupProv.error ?? "Failed to join group"),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Text("Join", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProv = context.watch<GroupProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Classrooms", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Joined", icon: Icon(Icons.class_outlined)),
              Tab(text: "Invitations", icon: Icon(Icons.mail_outline)),
            ],
          ),
        ),
        body: groupProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      if (user != null) {
                        await groupProv.fetchStudentGroups(user.id);
                      }
                    },
                    child: groupProv.studentGroups.isEmpty
                        ? _buildEmptyState("You haven't joined any classrooms yet.")
                        : _buildGroupList(groupProv.studentGroups),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      if (user != null) {
                        await groupProv.fetchPendingStudentGroups(user.id);
                      }
                    },
                    child: groupProv.pendingStudentGroups.isEmpty
                        ? _buildEmptyState("No pending classroom invitations.")
                        : _buildPendingInvitesList(context, groupProv.pendingStudentGroups, user?.id),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showJoinGroupDialog,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Join Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_outlined, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInvitesList(BuildContext context, List<GroupModel> groups, String? studentId) {
    if (studentId == null) return const SizedBox.shrink();
    final groupProv = Provider.of<GroupProvider>(context, listen: false);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: groups.length,
      itemBuilder: (ctx, idx) {
        final group = groups[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mail_outline, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Teacher: ${group.teacherName}",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      onPressed: () async {
                        final success = await groupProv.declineInvite(group.id, studentId);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invitation declined"),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Decline"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final success = await groupProv.acceptInvite(group.id, studentId);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Joined classroom successfully!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Approve"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
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
          shadowColor: AppColors.primary.withOpacity(0.1),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToGroupDetails(group),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.class_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Teacher: ${group.teacherName}",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
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
        builder: (ctx) => _StudentGroupDetailScreen(group: group),
      ),
    );
  }
}

class _StudentGroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const _StudentGroupDetailScreen({required this.group});

  @override
  State<_StudentGroupDetailScreen> createState() => _StudentGroupDetailScreenState();
}

class _StudentGroupDetailScreenState extends State<_StudentGroupDetailScreen> {
  late Future<List<UserModel>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers(widget.group.studentIds);
  }

  Future<List<UserModel>> _fetchMembers(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    final firestore = FirebaseFirestore.instance;
    final List<UserModel> members = [];
    
    for (var i = 0; i < studentIds.length; i += 10) {
      final chunk = studentIds.sublist(i, min(i + 10, studentIds.length));
      final querySnapshot = await firestore
          .collection('users')
          .where('id', whereIn: chunk)
          .get();
      for (var doc in querySnapshot.docs) {
        members.add(UserModel.fromJson(doc.data()));
      }
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher detail
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(Icons.school, color: AppColors.primary),
              ),
              title: Text("Teacher", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13)),
              subtitle: Text(
                widget.group.teacherName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const Divider(height: 32),
            const Text(
              "Classmates",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _membersFuture,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching members: ${snapshot.error}"));
                  }
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) {
                    return const Center(child: Text("No classmates have joined yet."));
                  }
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (c, idx) {
                      final member = members[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                          child: member.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
                        ),
                        title: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          "${member.points} pts",
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
