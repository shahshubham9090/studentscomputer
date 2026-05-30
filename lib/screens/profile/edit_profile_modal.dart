

part of 'profile_screen.dart';

class _EditProfileModal extends StatefulWidget {
  const _EditProfileModal();

  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  late TextEditingController _nameController;
  String? _selectedAvatarUrl;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _selectedAvatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _generateNewAvatar() {
    final newSeed = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _selectedAvatarUrl = AvatarUtils.getFunnyAvatarUrl(newSeed);
    });
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      await context.read<AuthProvider>().updateProfile(
        displayName: _nameController.text,
        avatarUrl: _selectedAvatarUrl,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final currentAvatar = _selectedAvatarUrl ?? (user != null ? AvatarUtils.getAvatarUrl(user) : 'https://i.pravatar.cc/150');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Edit Profile", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              if (_isSaving) const ShimmerWidget.circular(width: 24, height: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Center(
            child: Stack(
               children: [
                 CircleAvatar(
                   radius: 50, 
                   backgroundColor: AppColors.primary.withOpacity(0.1),
                   backgroundImage: NetworkImage(currentAvatar),
                 ),
                 Positioned(
                   bottom: 0, right: 0,
                   child: InkWell(
                     onTap: _isSaving ? null : _generateNewAvatar,
                     child: CircleAvatar(
                       radius: 18, 
                       backgroundColor: AppColors.primary,
                       child: const Icon(Icons.refresh, size: 18, color: Colors.white),
                     ),
                   ),
                 )
               ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          CustomTextField(
            label: "Display Name",
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            enabled: !_isSaving,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: "Save Changes",
            isLoading: _isSaving,
            onPressed: _saveChanges,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
