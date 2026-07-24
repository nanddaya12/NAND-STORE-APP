import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchDialog extends StatefulWidget {
  const VoiceSearchDialog({super.key});

  @override
  State<VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<VoiceSearchDialog> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitializing = true;
  String _text = 'Initializing speech...';
  bool _hasSpeech = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
            _pulseController.stop();
            if (_text.isNotEmpty && 
                _text != 'Say something...' && 
                _text != 'Listening...' &&
                _text != 'Initializing speech...') {
              // Automatically submit and pop back with safety checks
              final navigator = Navigator.of(context);
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  navigator.pop(_text);
                }
              });
            }
          }
        },
        onError: (errorNotification) {
          if (!mounted) return;
          setState(() {
            _text = "Error: ${errorNotification.errorMsg}";
            _isListening = false;
          });
          _pulseController.stop();
        },
      );

      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasSpeech = available;
      });

      if (available) {
        _startListening();
      } else {
        setState(() {
          _text = "Speech recognition is not available on this device.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasSpeech = false;
        _text = "Unsupported environment or permission denied.";
      });
    }
  }

  void _startListening() async {
    if (_hasSpeech && !_isListening) {
      setState(() {
        _isListening = true;
        _text = 'Say something...';
      });
      _pulseController.repeat(reverse: true);
      await _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          setState(() {
            _text = val.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _pulseController.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voice Search',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF000613),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF43474E)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // Audio wave visualizer / Mic button
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = _isListening ? _pulseAnimation.value : 1.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated level rings
                      Container(
                        width: 90 * scale,
                        height: 90 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB62C).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 76 * scale,
                        height: 76 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB62C).withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isListening) {
                            _stopListening();
                          } else if (_hasSpeech) {
                            _startListening();
                          } else {
                            _initSpeech();
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFF000613),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Transcribed text panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: Text(
                _text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1B1B),
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Simulating trigger for devices without voice drivers
            if (!_hasSpeech && !_isInitializing) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB62C),
                    foregroundColor: const Color(0xFF000613),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.psychology, size: 18),
                  label: const Text('Simulate Speech ("Audio Z1")'),
                  onPressed: () {
                    setState(() {
                      _text = "Audio Z1";
                    });
                    final navigator = Navigator.of(context);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        navigator.pop("Audio Z1");
                      }
                    });
                  },
                ),
              ),
            ],
            
            if (_isListening) ...[
              const SizedBox(height: 8),
              const Text(
                'Listening to your voice...',
                style: TextStyle(color: Color(0xFF43474E), fontSize: 11),
              ),
            ] else if (_hasSpeech) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap the microphone to speak again',
                style: TextStyle(color: Color(0xFF43474E), fontSize: 11),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
