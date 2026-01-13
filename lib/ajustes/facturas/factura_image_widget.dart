import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/services/api_config.dart';
import 'package:my_gasolinera/services/local_image_service.dart';

class FacturaImageWidget extends StatefulWidget {
  final int? facturaId;
  final String? serverPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? errorBuilder;

  const FacturaImageWidget({
    super.key,
    required this.facturaId,
    required this.serverPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  State<FacturaImageWidget> createState() => _FacturaImageWidgetState();
}

class _FacturaImageWidgetState extends State<FacturaImageWidget> {
  Uint8List? _localBytes;
  bool _checkingLocal = true;

  @override
  void initState() {
    super.initState();
    _checkLocalImage();
  }

  Future<void> _checkLocalImage() async {
    if (widget.facturaId == null) {
      if (mounted) setState(() => _checkingLocal = false);
      return;
    }

    try {
      final bytes = await LocalImageService.getImageBytes(
        'factura',
        widget.facturaId.toString(),
      );
      if (mounted) {
        setState(() {
          _localBytes = bytes;
          _checkingLocal = false;
        });
      }
    } catch (e) {
      print('Error checking local image: $e');
      if (mounted) setState(() => _checkingLocal = false);
    }
  }

  String _buildImageUrl(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return '${ApiConfig.baseUrl}/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLocal) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
      ); // or loading
    }

    if (_localBytes != null) {
      return Image.memory(
        _localBytes!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) =>
            widget.errorBuilder?.call(context) ?? _buildError(),
      );
    }

    if (widget.serverPath != null && widget.serverPath!.isNotEmpty) {
      return Image.network(
        _buildImageUrl(widget.serverPath!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) =>
            widget.errorBuilder?.call(context) ?? _buildError(),
      );
    }

    return widget.errorBuilder?.call(context) ?? _buildError();
  }

  Widget _buildError() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 30),
    );
  }
}
