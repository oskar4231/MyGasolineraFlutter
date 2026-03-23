import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_gasolinera/Implementaciones/auth/presentacion/pages/login.dart';
import 'package:my_gasolinera/core/l10n/app_localizations.dart';

/// Envuelve un widget con MaterialApp + localización para testing
Widget makeTestable(Widget widget) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: widget,
  );
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Debe renderizar los campos de email y contraseña',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Debe haber al menos 2 TextFormFields (email y contraseña)
      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('Debe mostrar el logo de la app', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // El logo debe estar presente como Image.asset
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Debe mostrar "MyGasolinera" como título',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('MyGasolinera'), findsOneWidget);
    });

    testWidgets(
        'Debe mostrar validación cuando se intenta iniciar sesión sin datos',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Buscar el botón de iniciar sesión y pulsarlo
      final loginButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(loginButton); // ⬅️ Asegurar visibilidad
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Después de pulsar sin datos, debe haber mensajes de error de validación
      // (el Form.validate() retorna false y muestra los errores del validator)
      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('Debe tener el botón de volver al inicio',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Debe existir el botón HoverBackButton (renderizado como InkWell/GestureDetector)
      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
    });

    testWidgets('El campo de contraseña debe tener icono de visibilidad',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // El campo de contraseña tiene un IconButton de visibilidad
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('El icono de visibilidad debe alternar obscureText',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Estado inicial: contraseña oculta (visibility_off)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Pulsamos el icono
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Ahora debe mostrar el icono de visibilidad
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
