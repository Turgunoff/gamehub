import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Galereyadan rasm tanlash va kvadrat qilib kesish
  Future<File?> pickAndCropAvatar(BuildContext context) async {
    try {
      // Galereyadan rasm tanlash
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      // Rasm byte larini olish
      final imageBytes = await File(pickedFile.path).readAsBytes();

      // Cropper sahifasini ochish
      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (context) => _CropperPage(imageBytes: imageBytes),
        ),
      );

      if (croppedBytes == null) return null;

      // Vaqtinchalik faylga saqlash
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(croppedBytes);

      return tempFile;
    } catch (e) {
      debugPrint('ImagePickerService error: $e');
      return null;
    }
  }
}

/// Rasm kesish sahifasi
class _CropperPage extends StatefulWidget {
  final Uint8List imageBytes;

  const _CropperPage({required this.imageBytes});

  @override
  State<_CropperPage> createState() => _CropperPageState();
}

class _CropperPageState extends State<_CropperPage> {
  final _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rasmni kesish',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cropper
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              aspectRatio: 1,
              withCircleUi: true,
              baseColor: const Color(0xFF0F0F1A),
              maskColor: Colors.black.withOpacity(0.7),
              progressIndicator: const CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
              cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
              onCropped: (croppedImage) {
                setState(() => _isCropping = false);
                Navigator.pop(context, croppedImage);
              },
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1F3A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                // Bekor qilish
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bekor qilish',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Saqlash
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isCropping
                          ? null
                          : () {
                              setState(() => _isCropping = true);
                              _cropController.crop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCropping
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Saqlash',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
