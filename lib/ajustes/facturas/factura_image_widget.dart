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

  static void showFullScreen(BuildContext context,
      {required int? facturaId, required String? serverPath}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: FacturaImageWidget(
                facturaId: facturaId,
                serverPath: serverPath,
                fit: BoxFit.contain,
                errorBuilder: (context) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 100,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No se pudo cargar la imagen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
      print('Checking local image for id: ${widget.facturaId}');
      final bytes = await LocalImageService.getImageBytes(
        'factura',
        widget.facturaId.toString(),
      );
      print('Local image found: ${bytes != null}');
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
    if (path.isEmpty) return '';

    // Si ya es una URL completa, devolverla
    if (path.startsWith('http')) return path;

    String normalizedPath = path.replaceAll('\\', '/');

    // INTENTO DE CORRECCIÓN: Si el path es absoluto del servidor (ej C:/Users/.../uploads/foto.jpg)
    // Intentar extraer la parte relativa desde 'uploads/'
    if (normalizedPath.contains('uploads/')) {
      normalizedPath =
          normalizedPath.substring(normalizedPath.indexOf('uploads/'));
    }

    // Quitar barra inicial si la hay para evitar doble barra con baseUrl
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    final url = '${ApiConfig.baseUrl}/$normalizedPath';
    print(
        'Building image URL: $url (original path: $path, baseUrl: ${ApiConfig.baseUrl})');
    return url;
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
