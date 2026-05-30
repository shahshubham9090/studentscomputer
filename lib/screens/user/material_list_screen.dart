import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/material_provider.dart';
import '../../models/study_material_model.dart';
import '../../core/constants.dart';
import 'material_detail_screen.dart';
import '../../widgets/shimmer_loading.dart';

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<MaterialProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.visibleMaterials.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    itemCount: 5,
                    itemBuilder: (context, index) => const MaterialCardSkeleton(),
                  );
                }

                final filteredMaterials = _filterType == 'all'
                    ? provider.visibleMaterials
                    : provider.visibleMaterials.where((m) => m.type == _filterType).toList();

                if (filteredMaterials.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  itemCount: filteredMaterials.length,
                  itemBuilder: (context, index) {
                    final material = filteredMaterials[index];
                    return _buildMaterialCard(context, material);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final types = [
      {'value': 'all', 'label': 'All'},
      {'value': 'mcq', 'label': 'MCQs'},
      {'value': 'pdf', 'label': 'PDFs'},
      {'value': 'video', 'label': 'Videos'},
      {'value': 'link', 'label': 'Links'},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _filterType == type['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type['label']?.toString() ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _filterType = type['value']?.toString() ?? 'all');
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, StudyMaterial material) {
    IconData typeIcon;
    Color typeColor;

    switch (material.type) {
      case 'pdf':
        typeIcon = Icons.picture_as_pdf_rounded;
        typeColor = Colors.red;
        break;
      case 'video':
        typeIcon = Icons.play_circle_fill_rounded;
        typeColor = Colors.orange;
        break;
      case 'mcq':
        typeIcon = Icons.quiz_rounded;
        typeColor = Colors.green;
        break;
      default:
        typeIcon = Icons.link_rounded;
        typeColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _handleMaterialTap(context, material),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(typeIcon, color: typeColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      material.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                    ),
                    if (material.category != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          material.category ?? '',
                          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMaterialTap(BuildContext context, StudyMaterial material) async {
    if (material.type == 'mcq') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MaterialDetailScreen(material: material)),
      );
    } else if (material.url != null) {
      final uri = Uri.parse(material.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the link')),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No materials found in this category', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
