import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trash_classifier_app/data/notifiers.dart';
import 'package:trash_classifier_app/theme/app_spacing.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  late CameraDescription _backCamera;
  late CameraDescription _frontCamera;

  final _picker = ImagePicker();

  bool _isCameraReady = false;
  bool _isBackCamera = true;
  String? _cameraError;
  int _flashSetting = 0;

  final List<IconData> _flashIcons = [
    Icons.flash_off,
    Icons.flash_on,
    Icons.flash_auto,
  ];

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final navigator = Navigator.of(context);
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      imageCapturedNotifier.value = pickedImage;
      if (!mounted) return;
      setState(() {});
      navigator.pop();
    }
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();

    _backCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.last,
    );

    _controller = CameraController(_backCamera, ResolutionPreset.max);
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.code == 'CameraAccessDenied'
            ? 'Camera access denied. Please enable camera '
                'permissions in Settings.'
            : 'Failed to initialize camera.';
      });
      log('Camera init error: $e');
    }
  }

  Future<void> flipCamera() async {
    setState(() {
      _isCameraReady = false;
    });
    await _controller.dispose();

    _controller = _isBackCamera
        ? CameraController(_frontCamera, ResolutionPreset.max)
        : CameraController(_backCamera, ResolutionPreset.max);

    _isBackCamera = !_isBackCamera;

    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.code == 'CameraAccessDenied'
            ? 'Camera access denied. Please enable camera '
                'permissions in Settings.'
            : 'Failed to initialize camera.';
      });
      log('Camera flip error: $e');
    }
  }

  void _changeFlash() {
    _flashSetting = (_flashSetting + 1) % 3;
    if (_flashSetting == 0) {
      log('Flash Mode: Off');
      _controller.setFlashMode(FlashMode.off);
    } else if (_flashSetting == 1) {
      log('Flash Mode: On');
      _controller.setFlashMode(FlashMode.always);
    } else {
      log('Flash Mode: Auto');
      _controller.setFlashMode(FlashMode.auto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            log('Camera Page Close');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              log('Flash Button Pressed');
              setState(_changeFlash);
            },
            icon: Icon(_flashIcons[_flashSetting], color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              flipCamera();
              setState(() {});
              log('Camera Flip Pressed');
            },
            icon: const Icon(
              Icons.flip_camera_ios_outlined,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: _isCameraReady ? _buildCameraView() : _buildLoadingOrError(),
    );
  }

  Widget _buildCameraView() {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Rounded camera preview ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ClipRRect(
                borderRadius: AppSpacing.borderRadiusLg,
                child: CameraPreview(_controller),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery picker
                Expanded(
                  child: IconButton(
                    onPressed: pickImage,
                    icon: const Icon(
                      Icons.photo_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Capture button (ring + inner circle)
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final image = await _controller.takePicture();
                      if (!mounted) return;
                      log('Capture Button Pressed');
                      log('Picture saved at: ${image.path}');
                      imageCapturedNotifier.value = image;
                      navigator.pop();
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            _cameraError!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
