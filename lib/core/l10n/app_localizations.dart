import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @idiomas.
  ///
  /// In es, this message translates to:
  /// **'Idiomas'**
  String get idiomas;

  /// No description provided for @ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustes;

  /// No description provided for @combustible.
  ///
  /// In es, this message translates to:
  /// **'Combustible'**
  String get combustible;

  /// No description provided for @estadisticas.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get estadisticas;

  /// No description provided for @accesibilidad.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get accesibilidad;

  /// No description provided for @guardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get guardarCambios;

  /// No description provided for @seleccionarIdioma.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get seleccionarIdioma;

  /// No description provided for @idiomaGuardado.
  ///
  /// In es, this message translates to:
  /// **'Idioma guardado correctamente'**
  String get idiomaGuardado;

  /// No description provided for @opciones.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get opciones;

  /// No description provided for @idiomaActual.
  ///
  /// In es, this message translates to:
  /// **'Idioma Actual'**
  String get idiomaActual;

  /// No description provided for @configuracionIdioma.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Idioma'**
  String get configuracionIdioma;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email o Usuario'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// No description provided for @iniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get iniciarSesion;

  /// No description provided for @crearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get crearCuenta;

  /// No description provided for @olvidoPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Has olvidado la contraseña?'**
  String get olvidoPassword;

  /// No description provided for @recordarme.
  ///
  /// In es, this message translates to:
  /// **'Recuérdame'**
  String get recordarme;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @ingresaEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email o usuario'**
  String get ingresaEmail;

  /// No description provided for @emailValido.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un email válido'**
  String get emailValido;

  /// No description provided for @ingresaPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get ingresaPassword;

  /// No description provided for @ingresaNombre.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu nombre'**
  String get ingresaNombre;

  /// No description provided for @ingresaTuEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu email'**
  String get ingresaTuEmail;

  /// No description provided for @confirmaPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get confirmaPassword;

  /// No description provided for @passwordsNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsNoCoinciden;

  /// No description provided for @passwordRequisitos.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no cumple todos los requisitos'**
  String get passwordRequisitos;

  /// No description provided for @loginExitoso.
  ///
  /// In es, this message translates to:
  /// **'Login exitoso'**
  String get loginExitoso;

  /// No description provided for @errorConexion.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Asegúrate de que el servidor esté corriendo.'**
  String get errorConexion;

  /// No description provided for @errorLogin.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get errorLogin;

  /// No description provided for @registroExitoso.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada exitosamente'**
  String get registroExitoso;

  /// No description provided for @requisitosPassword.
  ///
  /// In es, this message translates to:
  /// **'Requisitos de contraseña:'**
  String get requisitosPassword;

  /// No description provided for @minimo8Caracteres.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get minimo8Caracteres;

  /// No description provided for @unNumero.
  ///
  /// In es, this message translates to:
  /// **'Al menos un número'**
  String get unNumero;

  /// No description provided for @caracterEspecial.
  ///
  /// In es, this message translates to:
  /// **'Al menos un carácter especial'**
  String get caracterEspecial;

  /// No description provided for @mayuscula.
  ///
  /// In es, this message translates to:
  /// **'Al menos una letra mayúscula'**
  String get mayuscula;

  /// No description provided for @recuperarPassword.
  ///
  /// In es, this message translates to:
  /// **'Recuperar Contraseña'**
  String get recuperarPassword;

  /// No description provided for @enviarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Enviar Código'**
  String get enviarCodigo;

  /// No description provided for @ingresarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Ingresar Código'**
  String get ingresarCodigo;

  /// No description provided for @nuevaPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva Contraseña'**
  String get nuevaPassword;

  /// No description provided for @codigoEnviado.
  ///
  /// In es, this message translates to:
  /// **'Código enviado a tu email'**
  String get codigoEnviado;

  /// No description provided for @passwordActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada exitosamente'**
  String get passwordActualizada;

  /// No description provided for @codigoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Código inválido o expirado'**
  String get codigoInvalido;

  /// No description provided for @ingresaTuCodigo.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de 6 dígitos'**
  String get ingresaTuCodigo;

  /// No description provided for @facturas.
  ///
  /// In es, this message translates to:
  /// **'Facturas'**
  String get facturas;

  /// No description provided for @crearFactura.
  ///
  /// In es, this message translates to:
  /// **'Crear Factura'**
  String get crearFactura;

  /// No description provided for @detalleFactura.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Factura'**
  String get detalleFactura;

  /// No description provided for @listaFacturas.
  ///
  /// In es, this message translates to:
  /// **'Lista de Facturas'**
  String get listaFacturas;

  /// No description provided for @fechaFactura.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fechaFactura;

  /// No description provided for @montoTotal.
  ///
  /// In es, this message translates to:
  /// **'Monto Total'**
  String get montoTotal;

  /// No description provided for @proveedor.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get proveedor;

  /// No description provided for @descripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descripcion;

  /// No description provided for @categoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoria;

  /// No description provided for @noFacturas.
  ///
  /// In es, this message translates to:
  /// **'No hay facturas registradas'**
  String get noFacturas;

  /// No description provided for @presionaBotonFactura.
  ///
  /// In es, this message translates to:
  /// **'Presiona el botón + para agregar una factura'**
  String get presionaBotonFactura;

  /// No description provided for @gastosFacturas.
  ///
  /// In es, this message translates to:
  /// **'Gastos/Facturas'**
  String get gastosFacturas;

  /// No description provided for @facturaCreadaExito.
  ///
  /// In es, this message translates to:
  /// **'Factura creada exitosamente'**
  String get facturaCreadaExito;

  /// No description provided for @facturaActualizadaExito.
  ///
  /// In es, this message translates to:
  /// **'Factura actualizada exitosamente'**
  String get facturaActualizadaExito;

  /// No description provided for @facturaEliminadaExito.
  ///
  /// In es, this message translates to:
  /// **'Factura eliminada exitosamente'**
  String get facturaEliminadaExito;

  /// No description provided for @confirmarEliminar.
  ///
  /// In es, this message translates to:
  /// **'¿Confirmar eliminar?'**
  String get confirmarEliminar;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @aceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get aceptar;

  /// No description provided for @buscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get buscar;

  /// No description provided for @filtrar.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filtrar;

  /// No description provided for @seleccionarFecha.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Fecha'**
  String get seleccionarFecha;

  /// No description provided for @seleccionarImagen.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Imagen'**
  String get seleccionarImagen;

  /// No description provided for @tomarFoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar Foto'**
  String get tomarFoto;

  /// No description provided for @galeria.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get galeria;

  /// No description provided for @consumo.
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get consumo;

  /// No description provided for @gastos.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get gastos;

  /// No description provided for @mantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento'**
  String get mantenimiento;

  /// No description provided for @graficos.
  ///
  /// In es, this message translates to:
  /// **'Gráficos'**
  String get graficos;

  /// No description provided for @resumen.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get resumen;

  /// No description provided for @detalles.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get detalles;

  /// No description provided for @periodo.
  ///
  /// In es, this message translates to:
  /// **'Período'**
  String get periodo;

  /// No description provided for @hoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get hoy;

  /// No description provided for @semana.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get semana;

  /// No description provided for @mes.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get mes;

  /// No description provided for @anio.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get anio;

  /// No description provided for @personalizado.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get personalizado;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @promedio.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get promedio;

  /// No description provided for @maximo.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get maximo;

  /// No description provided for @minimo.
  ///
  /// In es, this message translates to:
  /// **'Mínimo'**
  String get minimo;

  /// No description provided for @combustibleConfig.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Combustible'**
  String get combustibleConfig;

  /// No description provided for @tipoCombustible.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Combustible'**
  String get tipoCombustible;

  /// No description provided for @gasolina.
  ///
  /// In es, this message translates to:
  /// **'Gasolina'**
  String get gasolina;

  /// No description provided for @diesel.
  ///
  /// In es, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @electrico.
  ///
  /// In es, this message translates to:
  /// **'Eléctrico'**
  String get electrico;

  /// No description provided for @hibrido.
  ///
  /// In es, this message translates to:
  /// **'Híbrido'**
  String get hibrido;

  /// No description provided for @unidadMedida.
  ///
  /// In es, this message translates to:
  /// **'Unidad de Medida'**
  String get unidadMedida;

  /// No description provided for @litros.
  ///
  /// In es, this message translates to:
  /// **'Litros'**
  String get litros;

  /// No description provided for @galones.
  ///
  /// In es, this message translates to:
  /// **'Galones'**
  String get galones;

  /// No description provided for @kilometros.
  ///
  /// In es, this message translates to:
  /// **'Kilómetros'**
  String get kilometros;

  /// No description provided for @millas.
  ///
  /// In es, this message translates to:
  /// **'Millas'**
  String get millas;

  /// No description provided for @accesibilidadConfig.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Accesibilidad'**
  String get accesibilidadConfig;

  /// No description provided for @tamanoFuente.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de Fuente'**
  String get tamanoFuente;

  /// No description provided for @pequeno.
  ///
  /// In es, this message translates to:
  /// **'Pequeño'**
  String get pequeno;

  /// No description provided for @mediano.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get mediano;

  /// No description provided for @grande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get grande;

  /// No description provided for @muyGrande.
  ///
  /// In es, this message translates to:
  /// **'Muy Grande'**
  String get muyGrande;

  /// No description provided for @altoContraste.
  ///
  /// In es, this message translates to:
  /// **'Alto Contraste'**
  String get altoContraste;

  /// No description provided for @modoOscuro.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get modoOscuro;

  /// No description provided for @activado.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get activado;

  /// No description provided for @desactivado.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get desactivado;

  /// No description provided for @cargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get cargando;

  /// No description provided for @sinDatos.
  ///
  /// In es, this message translates to:
  /// **'Sin datos disponibles'**
  String get sinDatos;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @intenteNuevamente.
  ///
  /// In es, this message translates to:
  /// **'Inténtelo nuevamente'**
  String get intenteNuevamente;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @perfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @configuracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configuracion;

  /// No description provided for @ayuda.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get ayuda;

  /// No description provided for @acercaDe.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get acercaDe;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @si.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get si;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @continuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @salir.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get salir;

  /// No description provided for @atras.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get atras;

  /// No description provided for @siguiente.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get siguiente;

  /// No description provided for @finalizar.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finalizar;

  /// No description provided for @aplicar.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get aplicar;

  /// No description provided for @restaurar.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restaurar;

  /// No description provided for @predeterminado.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get predeterminado;

  /// No description provided for @nuevaFactura.
  ///
  /// In es, this message translates to:
  /// **'Nueva Factura'**
  String get nuevaFactura;

  /// No description provided for @titulo.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get titulo;

  /// No description provided for @costeTotal.
  ///
  /// In es, this message translates to:
  /// **'Coste Total'**
  String get costeTotal;

  /// No description provided for @fecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fecha;

  /// No description provided for @hora.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get hora;

  /// No description provided for @comprobante.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get comprobante;

  /// No description provided for @ingreseTitulo.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un título'**
  String get ingreseTitulo;

  /// No description provided for @ingreseCoste.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa el coste total'**
  String get ingreseCoste;

  /// No description provided for @formatoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Formato inválido'**
  String get formatoInvalido;

  /// No description provided for @infoRepostaje.
  ///
  /// In es, this message translates to:
  /// **'Información del Repostaje'**
  String get infoRepostaje;

  /// No description provided for @coche.
  ///
  /// In es, this message translates to:
  /// **'Coche'**
  String get coche;

  /// No description provided for @precioLitro.
  ///
  /// In es, this message translates to:
  /// **'Precio por Litro'**
  String get precioLitro;

  /// No description provided for @kilometraje.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje Actual'**
  String get kilometraje;

  /// No description provided for @imagenFactura.
  ///
  /// In es, this message translates to:
  /// **'Imagen de Factura'**
  String get imagenFactura;

  /// No description provided for @agregarImagen.
  ///
  /// In es, this message translates to:
  /// **'Agregar Imagen'**
  String get agregarImagen;

  /// No description provided for @camara.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camara;

  /// No description provided for @descripcionOpcional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (Opcional)'**
  String get descripcionOpcional;

  /// No description provided for @errorCargarCoches.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar coches'**
  String get errorCargarCoches;

  /// No description provided for @errorSeleccionarImagen.
  ///
  /// In es, this message translates to:
  /// **'Error al seleccionar imagen'**
  String get errorSeleccionarImagen;

  /// No description provided for @errorCrearFactura.
  ///
  /// In es, this message translates to:
  /// **'Error al crear factura'**
  String get errorCrearFactura;

  /// No description provided for @guardarFactura.
  ///
  /// In es, this message translates to:
  /// **'Guardar Factura'**
  String get guardarFactura;

  /// No description provided for @errorCargarEstadisticas.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar estadísticas'**
  String get errorCargarEstadisticas;

  /// No description provided for @reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// No description provided for @resumenGeneral.
  ///
  /// In es, this message translates to:
  /// **'Resumen General'**
  String get resumenGeneral;

  /// No description provided for @gastoTotal.
  ///
  /// In es, this message translates to:
  /// **'Gasto Total'**
  String get gastoTotal;

  /// No description provided for @repostajes.
  ///
  /// In es, this message translates to:
  /// **'repostajes'**
  String get repostajes;

  /// No description provided for @mesActual.
  ///
  /// In es, this message translates to:
  /// **'Mes Actual'**
  String get mesActual;

  /// No description provided for @promedioRepostaje.
  ///
  /// In es, this message translates to:
  /// **'Promedio por Repostaje'**
  String get promedioRepostaje;

  /// No description provided for @costoKilometro.
  ///
  /// In es, this message translates to:
  /// **'Costo por Kilómetro'**
  String get costoKilometro;

  /// No description provided for @analisisVehiculoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis detallado por vehículo'**
  String get analisisVehiculoSubtitle;

  /// No description provided for @totalCoches.
  ///
  /// In es, this message translates to:
  /// **'Total Coches'**
  String get totalCoches;

  /// No description provided for @facturasTotales.
  ///
  /// In es, this message translates to:
  /// **'Facturas Totales'**
  String get facturasTotales;

  /// No description provided for @analisisVehiculo.
  ///
  /// In es, this message translates to:
  /// **'Análisis por Vehículo'**
  String get analisisVehiculo;

  /// No description provided for @queEsCostoKm.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es el costo por kilómetro?'**
  String get queEsCostoKm;

  /// No description provided for @explainCostoKm.
  ///
  /// In es, this message translates to:
  /// **'El costo por kilómetro incluye el gasto en combustible dividido por la distancia recorrida entre repostajes. Es una métrica útil para comparar la eficiencia de diferentes vehículos y hábitos de conducción.'**
  String get explainCostoKm;

  /// No description provided for @recargasValidas.
  ///
  /// In es, this message translates to:
  /// **'recargas válidas'**
  String get recargasValidas;

  /// No description provided for @costoPromedioKm.
  ///
  /// In es, this message translates to:
  /// **'Costo promedio por km:'**
  String get costoPromedioKm;

  /// No description provided for @estadisticasDetalladas.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas Detalladas'**
  String get estadisticasDetalladas;

  /// No description provided for @costoMinimo.
  ///
  /// In es, this message translates to:
  /// **'Costo mínimo'**
  String get costoMinimo;

  /// No description provided for @costoMaximo.
  ///
  /// In es, this message translates to:
  /// **'Costo máximo'**
  String get costoMaximo;

  /// No description provided for @rangoMinMax.
  ///
  /// In es, this message translates to:
  /// **'← Mín    Máx →'**
  String get rangoMinMax;

  /// No description provided for @costo100km.
  ///
  /// In es, this message translates to:
  /// **'Costo/100km'**
  String get costo100km;

  /// No description provided for @excelenteEficiencia.
  ///
  /// In es, this message translates to:
  /// **'¡Excelente eficiencia!'**
  String get excelenteEficiencia;

  /// No description provided for @eficienciaNormal.
  ///
  /// In es, this message translates to:
  /// **'Eficiencia normal'**
  String get eficienciaNormal;

  /// No description provided for @eficienciaBaja.
  ///
  /// In es, this message translates to:
  /// **'Eficiencia baja - Considera optimizar'**
  String get eficienciaBaja;

  /// No description provided for @noDatosConsumo.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de consumo disponibles'**
  String get noDatosConsumo;

  /// No description provided for @agregaFacturasConsumo.
  ///
  /// In es, this message translates to:
  /// **'Agrega facturas con kilometraje para calcular costos'**
  String get agregaFacturasConsumo;

  /// No description provided for @errorCargarMantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Error cargando mantenimiento'**
  String get errorCargarMantenimiento;

  /// No description provided for @noDatosMantenimiento.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de mantenimiento'**
  String get noDatosMantenimiento;

  /// No description provided for @anadeCochesMantenimiento.
  ///
  /// In es, this message translates to:
  /// **'Añade coches con información de kilometraje'**
  String get anadeCochesMantenimiento;

  /// No description provided for @kmActual.
  ///
  /// In es, this message translates to:
  /// **'KM actual'**
  String get kmActual;

  /// No description provided for @cambioAceite.
  ///
  /// In es, this message translates to:
  /// **'Cambio de Aceite'**
  String get cambioAceite;

  /// No description provided for @kmDesdeCambio.
  ///
  /// In es, this message translates to:
  /// **'KM desde último cambio'**
  String get kmDesdeCambio;

  /// No description provided for @kmRestantes.
  ///
  /// In es, this message translates to:
  /// **'KM restantes'**
  String get kmRestantes;

  /// No description provided for @progreso.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progreso;

  /// No description provided for @necesitaCambio.
  ///
  /// In es, this message translates to:
  /// **'¡Necesita cambio!'**
  String get necesitaCambio;

  /// No description provided for @buenEstado.
  ///
  /// In es, this message translates to:
  /// **'En buen estado'**
  String get buenEstado;

  /// No description provided for @programaCambioAceite.
  ///
  /// In es, this message translates to:
  /// **'Programa el cambio de aceite próximamente'**
  String get programaCambioAceite;

  /// No description provided for @comparativaMensual.
  ///
  /// In es, this message translates to:
  /// **'Comparativa Mensual'**
  String get comparativaMensual;

  /// No description provided for @mesAnterior.
  ///
  /// In es, this message translates to:
  /// **'Mes Anterior'**
  String get mesAnterior;

  /// No description provided for @proyeccionFinMes.
  ///
  /// In es, this message translates to:
  /// **'Proyección Fin de Mes'**
  String get proyeccionFinMes;

  /// No description provided for @proyeccion.
  ///
  /// In es, this message translates to:
  /// **'Proyección'**
  String get proyeccion;

  /// No description provided for @gastoActual.
  ///
  /// In es, this message translates to:
  /// **'Gasto Actual'**
  String get gastoActual;

  /// No description provided for @diaXdeY.
  ///
  /// In es, this message translates to:
  /// **'Día {dia} de {total}'**
  String diaXdeY(Object dia, Object total);

  /// No description provided for @tema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get tema;

  /// No description provided for @predeterminadoNaranja.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado (Naranja)'**
  String get predeterminadoNaranja;

  /// No description provided for @protanopia.
  ///
  /// In es, this message translates to:
  /// **'Daltonismo: Protanopia'**
  String get protanopia;

  /// No description provided for @deuteranopia.
  ///
  /// In es, this message translates to:
  /// **'Daltonismo: Deuteranopia'**
  String get deuteranopia;

  /// No description provided for @tritanopia.
  ///
  /// In es, this message translates to:
  /// **'Daltonismo: Tritanopia'**
  String get tritanopia;

  /// No description provided for @achromatopsia.
  ///
  /// In es, this message translates to:
  /// **'Daltonismo: Achromatopsia'**
  String get achromatopsia;

  /// No description provided for @tamanoPersonalizado.
  ///
  /// In es, this message translates to:
  /// **'Tamaño Personalizado'**
  String get tamanoPersonalizado;

  /// No description provided for @tamanoLabel.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get tamanoLabel;

  /// No description provided for @ejemploTexto.
  ///
  /// In es, this message translates to:
  /// **'Este es un ejemplo'**
  String get ejemploTexto;

  /// No description provided for @borrarCuenta.
  ///
  /// In es, this message translates to:
  /// **'Borrar Cuenta'**
  String get borrarCuenta;

  /// No description provided for @confirmarBorrarCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar tu cuenta?\n\nEsta acción no se puede deshacer.'**
  String get confirmarBorrarCuenta;

  /// No description provided for @eliminandoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Eliminando cuenta...'**
  String get eliminandoCuenta;

  /// No description provided for @errorEliminarCuenta.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar cuenta'**
  String get errorEliminarCuenta;

  /// No description provided for @ajustesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustesTitulo;

  /// No description provided for @holaUsuario.
  ///
  /// In es, this message translates to:
  /// **'Hola, '**
  String get holaUsuario;

  /// No description provided for @conexionMapa.
  ///
  /// In es, this message translates to:
  /// **'Conexión y Mapa'**
  String get conexionMapa;

  /// No description provided for @servidorBackend.
  ///
  /// In es, this message translates to:
  /// **'Servidor Backend'**
  String get servidorBackend;

  /// No description provided for @actualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizar;

  /// No description provided for @radioBusqueda.
  ///
  /// In es, this message translates to:
  /// **'Radio de búsqueda'**
  String get radioBusqueda;

  /// No description provided for @confirmarCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get confirmarCerrarSesion;

  /// No description provided for @confirmarCambio.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambio'**
  String get confirmarCambio;

  /// No description provided for @seguroCambiarIdioma.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cambiar el idioma a {idioma}?'**
  String seguroCambiarIdioma(Object idioma);

  /// No description provided for @idiomaCambiado.
  ///
  /// In es, this message translates to:
  /// **'Idioma cambiado a: {idioma}'**
  String idiomaCambiado(Object idioma);

  /// No description provided for @filtros.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filtros;

  /// No description provided for @precio.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get precio;

  /// No description provided for @apertura.
  ///
  /// In es, this message translates to:
  /// **'Apertura'**
  String get apertura;

  /// No description provided for @veinticuatroHoras.
  ///
  /// In es, this message translates to:
  /// **'24 Horas'**
  String get veinticuatroHoras;

  /// No description provided for @atendidasPersonal.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras atendidas por personal'**
  String get atendidasPersonal;

  /// No description provided for @abiertasAhora.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras abiertas ahora'**
  String get abiertasAhora;

  /// No description provided for @todas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get todas;

  /// No description provided for @tiposCombustible.
  ///
  /// In es, this message translates to:
  /// **'Tipos de Combustible'**
  String get tiposCombustible;

  /// No description provided for @filtrarPrecio.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por Precio'**
  String get filtrarPrecio;

  /// No description provided for @desde.
  ///
  /// In es, this message translates to:
  /// **'Desde (€)'**
  String get desde;

  /// No description provided for @hasta.
  ///
  /// In es, this message translates to:
  /// **'Hasta (€)'**
  String get hasta;

  /// No description provided for @ejemploPrecio.
  ///
  /// In es, this message translates to:
  /// **'Ej: 1,50'**
  String get ejemploPrecio;

  /// No description provided for @seleccioneCombustibleAlert.
  ///
  /// In es, this message translates to:
  /// **'Por favor, antes de filtrar por precio seleccione un tipo de combustible'**
  String get seleccioneCombustibleAlert;

  /// No description provided for @mapa.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapa;

  /// No description provided for @lista.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get lista;

  /// No description provided for @noGasolinerasCercanas.
  ///
  /// In es, this message translates to:
  /// **'No hay gasolineras cercanas con estos filtros'**
  String get noGasolinerasCercanas;

  /// No description provided for @gasolinerasFavoritas.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras favoritas'**
  String get gasolinerasFavoritas;

  /// No description provided for @todos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get todos;

  /// No description provided for @filtrarPor.
  ///
  /// In es, this message translates to:
  /// **'Filtrar Por'**
  String get filtrarPor;

  /// No description provided for @nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombre;

  /// No description provided for @precioAscendente.
  ///
  /// In es, this message translates to:
  /// **'Precio Ascendente'**
  String get precioAscendente;

  /// No description provided for @precioDescendente.
  ///
  /// In es, this message translates to:
  /// **'Precio Descendente'**
  String get precioDescendente;

  /// No description provided for @noHayFavoritos.
  ///
  /// In es, this message translates to:
  /// **'No hay gasolineras favoritas en tu lista'**
  String get noHayFavoritos;

  /// No description provided for @seleccionaGasolinerasEnMapa.
  ///
  /// In es, this message translates to:
  /// **'Selecciona gasolineras en el mapa para añadirlas aquí'**
  String get seleccionaGasolinerasEnMapa;

  /// No description provided for @verMapa.
  ///
  /// In es, this message translates to:
  /// **'Ver mapa'**
  String get verMapa;

  /// No description provided for @eliminadoDeFavoritos.
  ///
  /// In es, this message translates to:
  /// **'eliminado de favoritos'**
  String get eliminadoDeFavoritos;

  /// No description provided for @ordenNombre.
  ///
  /// In es, this message translates to:
  /// **'Orden: Nombre'**
  String get ordenNombre;

  /// No description provided for @ordenPrecioAsc.
  ///
  /// In es, this message translates to:
  /// **'Orden: Precio ↑'**
  String get ordenPrecioAsc;

  /// No description provided for @ordenPrecioDesc.
  ///
  /// In es, this message translates to:
  /// **'Orden: Precio ↓'**
  String get ordenPrecioDesc;

  /// No description provided for @cochesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Coches'**
  String get cochesTitulo;

  /// No description provided for @anadirCoche.
  ///
  /// In es, this message translates to:
  /// **'Añadir Coche'**
  String get anadirCoche;

  /// No description provided for @noHayCoches.
  ///
  /// In es, this message translates to:
  /// **'No hay coches añadidos'**
  String get noHayCoches;

  /// No description provided for @pulsaAnadirCoche.
  ///
  /// In es, this message translates to:
  /// **'Pulsa el botón \"Añadir Coche\" para empezar'**
  String get pulsaAnadirCoche;

  /// No description provided for @marca.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get marca;

  /// No description provided for @ejemploMarca.
  ///
  /// In es, this message translates to:
  /// **'Ej: Toyota, BMW, Seat...'**
  String get ejemploMarca;

  /// No description provided for @ingresaMarca.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa la marca'**
  String get ingresaMarca;

  /// No description provided for @modelo.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get modelo;

  /// No description provided for @ejemploModelo.
  ///
  /// In es, this message translates to:
  /// **'Ej: Corolla, Serie 3, León...'**
  String get ejemploModelo;

  /// No description provided for @ingresaModelo.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa el modelo'**
  String get ingresaModelo;

  /// No description provided for @kilometrajeInicial.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje Inicial'**
  String get kilometrajeInicial;

  /// No description provided for @ejemploKilometraje.
  ///
  /// In es, this message translates to:
  /// **'Ej: 50000'**
  String get ejemploKilometraje;

  /// No description provided for @capacidadTanque.
  ///
  /// In es, this message translates to:
  /// **'Capacidad del Tanque (L)'**
  String get capacidadTanque;

  /// No description provided for @ejemploTanque.
  ///
  /// In es, this message translates to:
  /// **'Ej: 50'**
  String get ejemploTanque;

  /// No description provided for @consumoTeorico.
  ///
  /// In es, this message translates to:
  /// **'Consumo Teórico (L/100km)'**
  String get consumoTeorico;

  /// No description provided for @ejemploConsumo.
  ///
  /// In es, this message translates to:
  /// **'Ej: 5.5'**
  String get ejemploConsumo;

  /// No description provided for @seleccionaCombustibleError.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un tipo de combustible'**
  String get seleccionaCombustibleError;

  /// No description provided for @cocheCreadoExito.
  ///
  /// In es, this message translates to:
  /// **'Coche creado exitosamente: {marca} {modelo}'**
  String cocheCreadoExito(String marca, String modelo);

  /// No description provided for @errorCrearCoche.
  ///
  /// In es, this message translates to:
  /// **'Error al crear coche: {error}'**
  String errorCrearCoche(String error);

  /// No description provided for @confirmarEliminacion.
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get confirmarEliminacion;

  /// No description provided for @confirmarEliminarCoche.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar {marca} {modelo}?'**
  String confirmarEliminarCoche(String marca, String modelo);

  /// No description provided for @cocheEliminado.
  ///
  /// In es, this message translates to:
  /// **'Coche eliminado: {marca} {modelo}'**
  String cocheEliminado(String marca, String modelo);

  /// No description provided for @errorEliminarCoche.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar coche: {error}'**
  String errorEliminarCoche(String error);

  /// No description provided for @errorCocheSinId.
  ///
  /// In es, this message translates to:
  /// **'Error: El coche no tiene ID'**
  String get errorCocheSinId;

  /// No description provided for @kilometrajeItem.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje: {km} km'**
  String kilometrajeItem(int km);

  /// No description provided for @tanqueItem.
  ///
  /// In es, this message translates to:
  /// **'Tanque: {capacidad}L'**
  String tanqueItem(double capacidad);

  /// No description provided for @tiposCombustibleLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipos de combustible:'**
  String get tiposCombustibleLabel;

  /// No description provided for @errorCargarCochesDetalle.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los coches: {error}'**
  String errorCargarCochesDetalle(String error);

  /// No description provided for @gasolina95.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 95'**
  String get gasolina95;

  /// No description provided for @gasolina98.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 98'**
  String get gasolina98;

  /// No description provided for @dieselPremium.
  ///
  /// In es, this message translates to:
  /// **'Diésel Premium'**
  String get dieselPremium;

  /// No description provided for @glp.
  ///
  /// In es, this message translates to:
  /// **'GLP (Autogas)'**
  String get glp;

  /// No description provided for @escanearFacturaAutocompletar.
  ///
  /// In es, this message translates to:
  /// **'Escanear Factura (Autocompletar)'**
  String get escanearFacturaAutocompletar;

  /// No description provided for @cambiarFotoPerfil.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto de perfil'**
  String get cambiarFotoPerfil;

  /// No description provided for @seleccionarFuenteFoto.
  ///
  /// In es, this message translates to:
  /// **'Selecciona de dónde quieres tomar la foto:'**
  String get seleccionarFuenteFoto;

  /// No description provided for @seleccionarFacturas.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Facturas'**
  String get seleccionarFacturas;

  /// No description provided for @seleccionarTodo.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar todo'**
  String get seleccionarTodo;

  /// No description provided for @deseleccionar.
  ///
  /// In es, this message translates to:
  /// **'Deseleccionar'**
  String get deseleccionar;

  /// No description provided for @exportarComo.
  ///
  /// In es, this message translates to:
  /// **'Exportar como...'**
  String get exportarComo;

  /// No description provided for @exportarExcel.
  ///
  /// In es, this message translates to:
  /// **'Excel (.xlsx)'**
  String get exportarExcel;

  /// No description provided for @exportarPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF (.pdf)'**
  String get exportarPdf;

  /// No description provided for @exportarExitoExcel.
  ///
  /// In es, this message translates to:
  /// **'Exportado a Excel correctamente'**
  String get exportarExitoExcel;

  /// No description provided for @exportarExitoPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportado a PDF correctamente'**
  String get exportarExitoPdf;

  /// No description provided for @seleccionarAlMenosUna.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una factura'**
  String get seleccionarAlMenosUna;

  /// No description provided for @exportarConConteo.
  ///
  /// In es, this message translates to:
  /// **'Exportar ({count})'**
  String exportarConConteo(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ca',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
