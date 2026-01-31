import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:my_gasolinera/core/config/api_config.dart';
import 'package:my_gasolinera/core/utils/local_image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                fit: BoxFit.contain, // Full res in full screen
                // No width/height constraints for full screen
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

  @override
  void didUpdateWidget(FacturaImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.facturaId != oldWidget.facturaId) {
      _checkLocalImage();
    }
  }

  Future<void> _checkLocalImage() async {
    // Si tenemos path de servidor, priorizamos ese para evitar lectura local innecesaria
    // (Opcional: Si queremos modo offline, cambiamos la prioridad)
    // Para esta app, asumimos que si hay ID local, intentamos cargar local primero
    // para ahorrar datos, pero si falla vamos a red.

    if (widget.facturaId == null) {
      if (mounted) setState(() => _checkingLocal = false);
      return;
    }

    setState(() {
      _checkingLocal = true;
      _localBytes = null;
    });

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
      // debugPrint('Error checking local image: $e'); // Reduce noise
      if (mounted) setState(() => _checkingLocal = false);
    }
  }

  String _buildImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    String normalizedPath = path.replaceAll('\\', '/');
    if (normalizedPath.contains('uploads/')) {
      normalizedPath =
          normalizedPath.substring(normalizedPath.indexOf('uploads/'));
    }
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    // Usar la URL base configurada
    return '${ApiConfig.baseUrl}/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mostrar Imagen Local (Optimizada con ResizeImage)
    if (_localBytes != null) {
      // MEMORY OPTIMIZATION: Usar ResizeImage para decodificar a menor resolución
      // Calculamos cacheWidth basado en el tamaño del widget o un default
      final int cacheWidth = widget.width != null
          ? (widget.width! * 2).toInt() // *2 para pantallas retina
          : 200; // Thumbnail size default

      return Image.memory(
        _localBytes!,
        cacheWidth: cacheWidth,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildNetworkFallback(),
      );
    }

    // 2. Cargando Local...
    if (_checkingLocal && (widget.serverPath == null)) {
      return _buildPlaceholder();
    }

    // 3. Fallback a Red (Si no hay local o falló)
    return _buildNetworkFallback();
  }

  Widget _buildNetworkFallback() {
    if (widget.serverPath != null && widget.serverPath!.isNotEmpty) {
      // MEMORY OPTIMIZATION: Usar CachedNetworkImage con memCacheWidth
      final int memCacheWidth = widget.width != null
          ? (widget.width! * 2).toInt()
          : 200; // Thumbnail size default

      return CachedNetworkImage(
        imageUrl: _buildImageUrl(widget.serverPath!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        memCacheWidth: memCacheWidth, // Redimensionar en memoria
        maxWidthDiskCache: 1024, // Limitar tamaño en disco
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildError(),
      );
    }

    if (_checkingLocal) return _buildPlaceholder();

    return _buildError();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }

  Widget _buildError() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image,
          size: (widget.height ?? 30) * 0.5, color: Colors.grey[600]),
    );
  }
}
