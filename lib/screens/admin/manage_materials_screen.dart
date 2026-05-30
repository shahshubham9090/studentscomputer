import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/material_provider.dart';
import '../../models/study_material_model.dart';
import '../../core/constants.dart';
import 'add_material_screen.dart';
import 'edit_material_screen.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:flutter_animate/flutter_animate.dart';


class ManageMaterialsScreen extends StatelessWidget {
  const ManageMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Materials', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MaterialProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.materials.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: 5,
              itemBuilder: (context, index) => const MaterialCardSkeleton(),
            );
          }

          if (provider.materials.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: provider.materials.length,
            itemBuilder: (context, index) {
              final material = provider.materials[index];
              return _buildMaterialCard(context, material, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMaterialScreen()),
        ),
        backgroundColor: AppColors.primary,
        tooltip: 'Add Material',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, StudyMaterial material, MaterialProvider provider) {
    IconData typeIcon;
    Color typeColor;

    switch (material.type) {
      case 'pdf':
        typeIcon = Icons.picture_as_pdf_rounded;
        typeColor = Colors.red.shade400;
        break;
      case 'video':
        typeIcon = Icons.play_circle_fill_rounded;
        typeColor = Colors.orange.shade400;
        break;
      case 'mcq':
        typeIcon = Icons.quiz_rounded;
        typeColor = Colors.green.shade400;
        break;
      default:
        typeIcon = Icons.link_rounded;
        typeColor = Colors.blue.shade400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: material.isHidden 
              ? Colors.orange.withOpacity(0.2) 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              material.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                letterSpacing: -0.3,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (material.isHidden)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange.withOpacity(0.2)),
                              ),
                              child: const Text(
                                'HIDDEN',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      if (material.type == 'mcq') ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.help_outline, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${material.questions?.length ?? 0} MCQ Questions',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  context,
                  material.isHidden ? 'Restore' : 'Hide',
                  material.isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  material.isHidden ? Colors.orange : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  () async => await provider.toggleHide(material.id, material.isHidden),
                ),
                _buildActionButton(
                  context,
                  'Edit',
                  Icons.edit_outlined,
                  AppColors.primary,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditMaterialScreen(material: material),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Delete',
                  Icons.delete_outline_rounded,
                  AppColors.error,
                  () => _confirmDelete(context, material, provider),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No materials found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Material" to create your first one',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudyMaterial material, MaterialProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteMaterial(material.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
