import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

typedef CroppedImage = ({Uint8List bytes, String filename});

/// Full-screen square cropper with a circular guide for profile photos.
/// Pops with the cropped PNG, the untouched original ("Keep original"),
/// or `null` if the user cancels.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({
    super.key,
    required this.bytes,
    required this.filename,
  });

  final Uint8List bytes;
  final String filename;

  static Future<CroppedImage?> open(
    BuildContext context, {
    required Uint8List bytes,
    required String filename,
  }) {
    return Navigator.of(context).push<CroppedImage>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AvatarCropScreen(bytes: bytes, filename: filename),
      ),
    );
  }

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  static const _maxOutputPx = 1024.0;
  static const _minOutputPx = 256.0;

  final _boundaryKey = GlobalKey();
  final _controller = TransformationController();
  ui.Image? _image;
  double? _side;
  bool _decodeFailed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    try {
      final image = await decodeImageFromList(widget.bytes);
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => _image = image);
    } catch (_) {
      if (mounted) setState(() => _decodeFailed = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _image?.dispose();
    super.dispose();
  }

  Size _childSize(ui.Image image, double side) {
    final scale = side / math.min(image.width, image.height);
    return Size(image.width * scale, image.height * scale);
  }

  Matrix4 _centeredTransform(Size child, double side) =>
      Matrix4.translationValues(
        -(child.width - side) / 2,
        -(child.height - side) / 2,
        0,
      );

  void _syncSide(ui.Image image, double side) {
    if (_side == side) return;
    final firstLayout = _side == null;
    _side = side;
    final transform = _centeredTransform(_childSize(image, side), side);
    if (firstLayout) {
      _controller.value = transform;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.value = transform;
      });
    }
  }

  void _reset() {
    final image = _image;
    final side = _side;
    if (image == null || side == null) return;
    _controller.value = _centeredTransform(_childSize(image, side), side);
  }

  Future<void> _crop() async {
    final image = _image;
    final side = _side;
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (image == null || side == null || boundary == null) return;

    setState(() => _saving = true);
    try {
      final zoom = _controller.value.getMaxScaleOnAxis();
      final visibleSourcePx = math.min(image.width, image.height) / zoom;
      final outputPx = visibleSourcePx.clamp(_minOutputPx, _maxOutputPx);
      final cropped = await boundary.toImage(pixelRatio: outputPx / side);
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      cropped.dispose();
      if (data == null) throw StateError('Could not encode image');
      if (!mounted) return;
      Navigator.of(context).pop<CroppedImage>((
        bytes: data.buffer.asUint8List(),
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.png',
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not crop the photo. Try again.')),
      );
    }
  }

  void _keepOriginal() {
    Navigator.of(context).pop<CroppedImage>(
      (bytes: widget.bytes, filename: widget.filename),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Crop photo',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset',
            onPressed: _image == null || _saving ? null : _reset,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildCropArea()),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Pinch to zoom, drag to reposition',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saving ? null : _keepOriginal,
                      child: const Text('Keep original'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _image == null || _saving ? null : _crop,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crop & use'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropArea() {
    if (_decodeFailed) {
      return const Center(
        child: Text(
          'Could not load this image.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final image = _image;
    if (image == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight) - 40;
        _syncSide(image, side);
        final child = _childSize(image, side);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              children: [
                RepaintBoundary(
                  key: _boundaryKey,
                  child: InteractiveViewer(
                    transformationController: _controller,
                    constrained: false,
                    minScale: 1,
                    maxScale: 6,
                    boundaryMargin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: child.width,
                      height: child.height,
                      child: RawImage(image: image, fit: BoxFit.fill),
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CircleGuidePainter()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleGuidePainter extends CustomPainter {
  const _CircleGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = Path()..addOval(rect);
    final shade = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      circle,
    );
    canvas.drawPath(shade, Paint()..color = Colors.black.withValues(alpha: 0.55));
    canvas.drawPath(
      circle,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleGuidePainter oldDelegate) => false;
}
