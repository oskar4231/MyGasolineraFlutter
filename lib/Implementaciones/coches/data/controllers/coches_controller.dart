import 'package:flutter/material.dart';
import 'package:my_gasolinera/Implementaciones/coches/data/services/coche_service.dart';
import 'package:my_gasolinera/Implementaciones/coches/domain/models/coche.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';
import 'package:my_gasolinera/core/utils/dialog_helper.dart';

/// Controlador que gestiona la lista de coches: carga, creación y eliminación.
/// Extiende [ChangeNotifier] para que la UI pueda escuchar cambios de estado.
class CochesController extends ChangeNotifier {
  final BuildContext context;

  List<Coche> coches = [];
  bool isLoading = false;

  CochesController(this.context) {
    cargar();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  // ── Carga ──────────────────────────────────────────────────────────────────

  Future<void> cargar() async {
    isLoading = true;
    notifyListeners();

    try {
      final cochesJson = await CocheService.obtenerCoches();
      final lista = List<Map<String, dynamic>>.from(cochesJson);
      coches = lista.map((json) => Coche.fromJson(json)).toList();
    } catch (error) {
      if (context.mounted) {
        DialogHelper.showErrorSnackbar(
          context,
          _l10n.errorCargarCochesDetalle(error.toString()),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Creación ───────────────────────────────────────────────────────────────

  Future<void> crear({
    required String marca,
    required String modelo,
    required List<String> tiposCombustible,
    int? kilometrajeInicial,
    double? capacidadTanque,
    double? consumoTeorico,
    String? fechaUltimoCambioAceite,
    int? kmUltimoCambioAceite,
    int intervaloCambioAceiteKm = 15000,
    int intervaloCambioAceiteMeses = 12,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await CocheService.crearCoche(
        marca: marca,
        modelo: modelo,
        tiposCombustible: tiposCombustible,
        kilometrajeInicial: kilometrajeInicial,
        capacidadTanque: capacidadTanque,
        consumoTeorico: consumoTeorico,
        fechaUltimoCambioAceite: fechaUltimoCambioAceite,
        kmUltimoCambioAceite: kmUltimoCambioAceite,
        intervaloCambioAceiteKm: intervaloCambioAceiteKm,
        intervaloCambioAceiteMeses: intervaloCambioAceiteMeses,
      );

      if (context.mounted) {
        DialogHelper.showSuccessSnackbar(
          context,
          _l10n.cocheCreadoExito(marca, modelo),
        );
      }
      await cargar();
    } catch (error) {
      if (context.mounted) {
        DialogHelper.showErrorSnackbar(
          context,
          _l10n.errorCrearCoche(error.toString()),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Eliminación ────────────────────────────────────────────────────────────

  Future<void> eliminar(Coche coche) async {
    if (coche.idCoche == null) {
      if (context.mounted) {
        DialogHelper.showErrorSnackbar(context, _l10n.errorCocheSinId);
      }
      return;
    }

    DialogHelper.showConfirmationDialog(
      context: context,
      title: _l10n.confirmarEliminacion,
      content: _l10n.confirmarEliminarCoche(coche.marca, coche.modelo),
      confirmText: _l10n.eliminar,
      cancelText: _l10n.cancelar,
      isDestructive: true,
      onConfirm: () async {
        isLoading = true;
        notifyListeners();

        try {
          await CocheService.eliminarCoche(coche.idCoche!);

          if (context.mounted) {
            DialogHelper.showSuccessSnackbar(
              context,
              _l10n.cocheEliminado(coche.marca, coche.modelo),
            );
          }
          await cargar();
        } catch (error) {
          if (context.mounted) {
            DialogHelper.showErrorSnackbar(
              context,
              _l10n.errorEliminarCoche(error.toString()),
            );
          }
        } finally {
          isLoading = false;
          notifyListeners();
        }
      },
    );
  }
}
