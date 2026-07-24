import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaUploadDialog extends StatefulWidget {
  final String mediaType; // 'image', 'video', or 'avatar'

  const MediaUploadDialog({super.key, required this.mediaType});

  @override
  State<MediaUploadDialog> createState() => _MediaUploadDialogState();
}

class _MediaUploadDialogState extends State<MediaUploadDialog> {
  bool _isUploading = false;
  double _progress = 0.0;
  String _selectedFileName = '';
  String _selectedFileUrl = '';
  String _fileSizeText = '';
  Timer? _uploadTimer;

  // Preset mock assets
  final List<Map<String, String>> _imagePresets = [
    {
      'name': 'headphones.jpg',
      'size': '2.4 MB',
      'url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'shoes.jpg',
      'size': '3.1 MB',
      'url': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'watch.jpg',
      'size': '1.8 MB',
      'url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'chair.jpg',
      'size': '4.5 MB',
      'url': 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?q=80&w=600&auto=format&fit=crop',
    },
  ];

  final List<Map<String, String>> _videoPresets = [
    {
      'name': 'product_review.mp4',
      'size': '14.2 MB',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
    {
      'name': 'commercial_ad.mp4',
      'size': '22.8 MB',
      'url': 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
    },
  ];

  final List<Map<String, String>> _avatarPresets = [
    {
      'name': 'avatar_male.png',
      'size': '420 KB',
      'url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'avatar_female.png',
      'size': '380 KB',
      'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'avatar_dev.png',
      'size': '510 KB',
      'url': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop',
    },
  ];

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }

  void _startUpload(String name, String url, String size) {
    setState(() {
      _selectedFileName = name;
      _selectedFileUrl = url;
      _fileSizeText = size;
      _isUploading = true;
      _progress = 0.0;
    });

    _uploadTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.1;
        } else {
          timer.cancel();
          _isUploading = false;
          // Return the selected file URL
          Navigator.pop(context, _selectedFileUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded "$_selectedFileName" successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF000613),
            ),
          );
        }
      });
    });
  }

  void _pickFromDevice() async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (widget.mediaType == 'video') {
        final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          _startUpload(video.name, video.path, 'Local Video File');
        }
      } else {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          _startUpload(image.name, image.path, 'Local Image File');
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Device file picking error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mediaType == 'image'
        ? 'Upload Image'
        : widget.mediaType == 'video'
            ? 'Upload Video'
            : 'Upload Profile Picture';
    
    final accentColor = widget.mediaType == 'video' ? const Color(0xFFFFB62C) : const Color(0xFF000613);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF000613)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF43474E)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),

            if (_isUploading) ...[
              // Uploading Status Section
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      value: _progress,
                      color: accentColor,
                      backgroundColor: const Color(0xFFF6F3F2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Uploading $_selectedFileName (${(_progress * 100).toInt()}%)...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: $_fileSizeText • Status: Writing to NAND cloud API...',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF43474E)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ] else ...[
              // Drag and Drop Simulator
              GestureDetector(
                onTap: _pickFromDevice,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC4C6CF),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        widget.mediaType == 'image'
                            ? Icons.image_outlined
                            : widget.mediaType == 'video'
                                ? Icons.video_library_outlined
                                : Icons.account_circle_outlined,
                        size: 40,
                        color: accentColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Click to upload from your real device',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Opens native system gallery or file selector',
                        style: TextStyle(fontSize: 11, color: Color(0xFF43474E)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Presets Selection Grid
              const Text(
                'SIMULATOR PRESETS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF43474E), letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              
              // Preset Grid Builder
              _buildPresetGrid(accentColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetGrid(Color themeColor) {
    final presets = widget.mediaType == 'image'
        ? _imagePresets
        : widget.mediaType == 'video'
            ? _videoPresets
            : _avatarPresets;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final p = presets[index];
        return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Color(0xFFC4C6CF)),
          ),
          icon: Icon(
            widget.mediaType == 'image'
                ? Icons.photo
                : widget.mediaType == 'video'
                    ? Icons.movie
                    : Icons.face,
            size: 16,
            color: themeColor,
          ),
          label: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  p['name']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF000613)),
                ),
                Text(
                  p['size']!,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF43474E)),
                ),
              ],
            ),
          ),
          onPressed: () => _startUpload(p['name']!, p['url']!, p['size']!),
        );
      },
    );
  }
}
