import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../settings/presentation/widget/section_card.dart';
import '../../../settings/presentation/widget/section_title.dart';
import '../../controllers/feedback_controller.dart';
import '../../data/models/feedback_model.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? theme.cardColor : Colors.white);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('Back button pressed'); // Debug log
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offNamed('/settings');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feedback Type Selection
                  SectionCard(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Feedback Type'),
                        const SizedBox(height: 12),
                        ...FeedbackType.values.map((type) {
                          return RadioListTile<FeedbackType>(
                            title: Text(
                              type.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: type,
                            groupValue: controller.selectedType.value,
                            onChanged: (value) {
                              if (value != null) {
                                controller.setFeedbackType(value);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  SectionCard(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Title'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.titleController,
                          decoration: InputDecoration(
                            hintText: 'Brief summary of your feedback',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            if (value.trim().length < 10) {
                              return 'Title should be at least 10 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  SectionCard(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Description'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Describe your feedback in detail...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.trim().length < 20) {
                              return 'Description should be at least 20 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority Selection
                  SectionCard(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Priority'),
                        const SizedBox(height: 12),
                        Row(
                          children: FeedbackPriority.values.map((priority) {
                            final isSelected = controller.selectedPriority.value == priority;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: priority != FeedbackPriority.values.last ? 8.0 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () => controller.setPriority(priority),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        priority.label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () {
                        print('Submit button tapped!'); // Debug
                        controller.submitFeedback();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Text
                  Center(
                    child: Text(
                      'Your device and app information will be included to help us resolve issues faster.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}