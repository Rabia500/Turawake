import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:Truawake/theme/theme_provider.dart';

class CameraScreen extends StatefulWidget {
  final bool isFrontCamera;
  final String resolution;
  final bool isAudioEnabled;

  const CameraScreen({
    super.key,
    required this.isFrontCamera,
    required this.resolution,
    required this.isAudioEnabled,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isDetectionEnabled = false;
  XFile? _videoFile;

  String _detectionResult = "No detection yet";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _initializeCamera();
    } else {
      print("Permissions denied!");
    }
  }

  ResolutionPreset _getResolutionPreset(String res) {
    switch (res) {
      case "Low":
        return ResolutionPreset.low;
      case "Medium":
        return ResolutionPreset.medium;
      case "High":
      default:
        return ResolutionPreset.high;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        print("No cameras found!");
        return;
      }

      final camera = widget.isFrontCamera
          ? cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => cameras!.first)
          : cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => cameras!.first);

      _controller = CameraController(
        camera,
        _getResolutionPreset(widget.resolution),
        enableAudio: widget.isAudioEnabled,
      );

      await _controller!.initialize();

      // Start frame streaming for dummy detection
      _controller!.startImageStream((image) {
        if (_isDetectionEnabled) {
          _runDummyDetection(image);
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _runDummyDetection(CameraImage image) async {
    // Dummy simulation — replace with real ML model later if needed
    setState(() {
      _detectionResult = "🟢 Drowsiness not detected";
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      _videoFile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      print('Video saved at: ${_videoFile!.path}');
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  void _toggleDetection(bool? value) async {
    if (value == true) {
      await _initializeCamera();
    } else {
      await _controller?.stopImageStream();
    }
    setState(() {
      _isDetectionEnabled = value ?? false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Detection'),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? const Color(0xFF0D47A1)
            : const Color(0xFF8BC34A),
        foregroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeProvider.themeMode == ThemeMode.dark
              ? const LinearGradient(
                  colors: [Color(0xFF0D47A1), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.white, Color(0xFFE3F2FD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Column(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              Expanded(child: CameraPreview(_controller!))
            else if (_isDetectionEnabled)
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8BC34A))),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 70,
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.videocam_rounded,
                    color: _isRecording
                        ? Colors.redAccent
                        : const Color(0xFF8BC34A),
                  ),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
              ],
            ),

            SwitchListTile(
              title: Text(
                "Enable Detection",
                style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ),
              subtitle: Text(
                "Start drowsiness detection using camera feed.",
                style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.white70
                        : Colors.black54),
              ),
              value: _isDetectionEnabled,
              activeThumbColor: const Color(0xFF8BC34A),
              onChanged: _toggleDetection,
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Detection: $_detectionResult',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),

            if (_videoFile != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? const Color(0xFF0D47A1)
                      : const Color(0xFF8BC34A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '🎥 Video saved:\n${_videoFile!.path}',
                      style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
