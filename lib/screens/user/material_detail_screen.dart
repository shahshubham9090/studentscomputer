import 'package:flutter/material.dart';
import '../../models/study_material_model.dart';
import '../../core/constants.dart';

class MaterialDetailScreen extends StatelessWidget {
  final StudyMaterial material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            if (material.type == 'mcq' && material.questions != null)
              _buildMcqList(context)
            else
              _buildGenericDetail(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            material.description,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          if (material.category != null)
            Chip(
              label: Text(material.category!),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildMcqList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: material.questions?.length ?? 0,
      itemBuilder: (context, index) {
        final question = material.questions![index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  question.text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...question.choices.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final choice = entry.value;
                  final isCorrect = idx == question.correctChoiceIndex;

                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCorrect 
                          ? Colors.green.withOpacity(0.1) 
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCorrect 
                            ? Colors.green.withOpacity(0.3) 
                            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.circle_outlined,
                          size: 18,
                          color: isCorrect 
                              ? (isDark ? Colors.greenAccent : Colors.green) 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            choice,
                            style: TextStyle(
                              color: isCorrect 
                                  ? (isDark ? Colors.greenAccent : Colors.green.shade700) 
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Explanation:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenericDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('This material should be opened in an external viewer.'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Already handled in list tap, but here as fallback
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open External'),
            ),
          ],
        ),
      ),
    );
  }
}
