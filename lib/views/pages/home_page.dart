import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:trash_classifier_app/data/classes/classification_result.dart';
import 'package:trash_classifier_app/data/classes/classifier_model.dart';
import 'package:trash_classifier_app/data/notifiers.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';
import 'package:trash_classifier_app/utils/app_directory.dart';
import 'package:trash_classifier_app/utils/compress_image.dart';
import 'package:trash_classifier_app/utils/validators.dart';
import 'package:trash_classifier_app/views/widgets/action_button.dart';
import 'package:trash_classifier_app/views/widgets/empty_state_widget.dart';
import 'package:trash_classifier_app/views/widgets/info_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ClassifierModel model = ClassifierModel.instance;
  ClassificationResult? prediction;
  bool _modelReady = false;
  bool _modelLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _initModel();
    imageCapturedNotifier.addListener(_onImageCaptured);
  }

  Future<void> _initModel() async {
    final success = await model.loadModel();
    if (!mounted) return;
    _modelReady = success;
    _modelLoadFailed = !success;
    setState(() {});
  }

  Future<void> _onImageCaptured() async {
    final image = imageCapturedNotifier.value;
    if (image != null && _modelReady) {
      prediction = await model.runModel(image.path);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageCapturedNotifier.removeListener(_onImageCaptured);
    _nameController.dispose();
    super.dispose();
  }

  void _deleteImage() {
    if (imageCapturedNotifier.value != null) {
      imageCapturedNotifier.value = null;
      _nameController.text = '';
      prediction = null;
      log('Image Deleted');
    }
  }

  Future<bool> _confirmOverwrite(String name) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overwrite Existing Item?'),
        content: Text('"$name" already exists. Do you want to replace it?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _saveImage(
    XFile image,
    ClassificationResult? prediction,
  ) async {
    final appDirectory = await getAppDirectory();
    final appDirectoryPath = appDirectory.path;
    final sanitizedName = _nameController.text.trim();
    final sourceImage = File(image.path);
    final fileName = '$sanitizedName.jpg';
    final filePath = '$appDirectoryPath/user_saved_data/$sanitizedName';

    if (await Directory(filePath).exists()) {
      if (!mounted) return false;
      final overwrite = await _confirmOverwrite(sanitizedName);
      if (!overwrite) return false;
    } else {
      await Directory(filePath).create(recursive: true);
    }

    await compressAndSave(sourceImage, '$filePath/$fileName');
    log('Image Saved as: ${_nameController.text} to $filePath/$fileName');

    final classificationFile = File('$filePath/classification.txt');
    if (prediction != null) {
      try {
        final content =
            '${prediction.label} (${prediction.confidencePercent})';
        await classificationFile.writeAsString(content);
        log('Prediction: $content Saved to $filePath/classification.txt');
      } on Exception catch (e) {
        log('Error saving file: $e');
      }
    }

    return true;
  }

  Widget _buildClassificationValue() {
    final theme = Theme.of(context);
    if (_modelLoadFailed) {
      return Text(
        'Model failed to load',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }
    if (prediction == null) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Text(
      '${prediction!.label} — ${prediction!.confidencePercent}',
      style: theme.textTheme.bodyLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: imageCapturedNotifier,
      builder: (context, image, child) {
        if (image == null) {
          return const EmptyStateWidget(
            icon: Icons.camera_alt_outlined,
            title: 'No Image Yet',
            subtitle: 'Tap the camera button to capture or pick an image',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Image ──────────────────────────────────────────
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusLg,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Classification result ──────────────────────────
                InfoCard(
                  label: 'Classification',
                  child: _buildClassificationValue(),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Name input ─────────────────────────────────────
                InfoCard(
                  label: 'Name',
                  child: TextFormField(
                    validator: validateItemName,
                    decoration: const InputDecoration(
                      hintText: 'Enter object name',
                      isDense: true,
                    ),
                    controller: _nameController,
                    onEditingComplete: () => setState(() {}),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Action buttons ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      icon: Icons.delete_outline,
                      color: theme.colorScheme.error,
                      tooltip: 'Delete',
                      onPressed: () {
                        _deleteImage();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 3),
                            content: Text('Image deleted'),
                          ),
                        );
                      },
                    ),
                    ActionButton(
                      icon: Icons.save_outlined,
                      color: theme.colorScheme.tertiary,
                      tooltip: 'Save',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final messenger = ScaffoldMessenger.of(context);
                          final saved = await _saveImage(image, prediction);
                          if (!saved) return;

                          newSavedDataNotifier.value =
                              !newSavedDataNotifier.value;
                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 3),
                              content: Text(
                                'Image saved as: ${_nameController.text}',
                              ),
                            ),
                          );
                          _deleteImage();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
