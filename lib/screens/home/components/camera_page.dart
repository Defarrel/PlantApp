import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  int _selectedCameraIdx = 0;
  FlashMode _flashMode = FlashMode.off;
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isZoomSupported = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    await _setupCamera(_selectedCameraIdx);
  }

  Future<void> _setupCamera(int cameraIdx) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final controller = CameraController(
      _cameras[cameraIdx],
      ResolutionPreset.max,
      enableAudio: false,
    );

    await controller.initialize();
    _minZoom = await controller.getMinZoomLevel();
    _maxZoom = await controller.getMaxZoomLevel();
    _isZoomSupported = _maxZoom > _minZoom;
    _zoomLevel = _minZoom;
    await controller.setZoomLevel(_zoomLevel);
    await controller.setFlashMode(_flashMode);

    if (mounted) {
      setState(() {
        _controller = controller;
        _selectedCameraIdx = cameraIdx;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile file = await _controller!.takePicture();
    Navigator.pop(context, File(file.path));
  }

  void _switchCamera() async {
    final nextIndex = (_selectedCameraIdx + 1) % _cameras.length;
    await _setupCamera(nextIndex);
  }

  void _toggleFlash() async {
    FlashMode next =
        _flashMode == FlashMode.off
            ? FlashMode.auto
            : _flashMode == FlashMode.auto
            ? FlashMode.always
            : FlashMode.off;
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
  }

void _setZoom(double value) async {
  if (!_isZoomSupported) return;
  await _controller?.setZoomLevel(value);
  setState(() {
    _zoomLevel = value;
  });
}


  void _handleTrap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller?.setFocusPoint(offset);
    _controller?.setExposurePoint(offset);
  }

  IconData _flashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, {double size = 32}) {
    return ClipOval(
      child: Material(
        color: Colors.white24,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    if (!_isZoomSupported) return const SizedBox.shrink();

    return Positioned(
      bottom: 160,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleButton(Icons.looks_one, () => _setZoom(1.0), size: 44),
              const SizedBox(width: 10),
              if (_maxZoom >= 3.0)
                _circleButton(Icons.looks_3, () => _setZoom(3.0), size: 44),
              const SizedBox(width: 10),
              if (_maxZoom >= 5.0)
                _circleButton(Icons.looks_5, () => _setZoom(5.0), size: 44),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.zoom_out, color: Colors.white),
              Expanded(
                child: Slider(
                  value: _zoomLevel,
                  min: _minZoom,
                  max: _maxZoom,
                  divisions: ((_maxZoom - _minZoom) / 0.1).toInt(),
                  label: '${_zoomLevel.toStringAsFixed(1)}x',
                  onChanged: (value) => _setZoom(value),
                ),
              ),
              const Icon(Icons.zoom_in, color: Colors.white),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_zoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _controller?.value.isInitialized != true
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTapDown:
                            (details) => _handleTrap(details, constraints),
                        child: CameraPreview(_controller!),
                      ),
                      Positioned(
                        top: 40,
                        left: 20,
                        child: _circleButton(Icons.cameraswitch, _switchCamera),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: _circleButton(_flashIcon(), _toggleFlash),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _captureImage,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade800,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isZoomSupported)
                        Positioned(
                          bottom: 160,
                          left: 20,
                          child: Row(
                            children: [
                              _circleButton(
                                Icons.looks_one,
                                () => _setZoom(1.0),
                              ),
                              const SizedBox(width: 10),
                              if (_maxZoom >= 3.0)
                                _circleButton(
                                  Icons.looks_3,
                                  () => _setZoom(3.0),
                                ),
                              const SizedBox(width: 10),
                              if (_maxZoom >= 5.0)
                                _circleButton(
                                  Icons.looks_5,
                                  () => _setZoom(5.0),
                                ),
                            ],
                          ),
                        ),
                      if (_isZoomSupported)
                        Positioned(
                          bottom: 110,
                          left: 20,
                          right: 20,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.zoom_out,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _zoomLevel,
                                      min: _minZoom,
                                      max: _maxZoom,
                                      divisions:
                                          ((_maxZoom - _minZoom) / 0.1).toInt(),
                                      label:
                                          '${_zoomLevel.toStringAsFixed(1)}x',
                                      onChanged: _setZoom,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              Text(
                                '${_zoomLevel.toStringAsFixed(1)}x',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
    );
  }
}
