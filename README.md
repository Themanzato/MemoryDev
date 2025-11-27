**Proyecto**

MemoryDev

**Descripción**
- **Qué es:** MemoryDev es una aplicación Flutter para crear, visualizar y gestionar proyectos/documentación personal con soporte para dibujos, timeline y animaciones (archivos JSON incluidos).
- **Para qué sirve:** Permite crear proyectos con notas y dibujos, gestionar objetivos y visualizar una línea temporal de eventos. Es útil para prototipado, documentación visual y diarios multimedia.

**Características principales**
- **Gestión de proyectos:** Crear, editar y ver proyectos.
- **Canvas de dibujo:** Dibujar a mano alzada y guardar/visualizar dibujos.
- **Timeline:** Visualizar eventos o estados en una línea temporal.
- **Animaciones:** Soporte para animaciones en formato JSON incluidas en `assets/animations`.
- **Multiplataforma:** Preparado para Android, iOS, Web, Windows, macOS y Linux (proyecto Flutter estándar).

**Requisitos**
- **Flutter SDK:** Canal `stable` (recomendado). Instalar desde https://flutter.dev
- **Dart:** Se instala junto con Flutter.
- **Herramientas de plataforma:** Para Android: Android SDK / Android Studio. Para iOS: Xcode (macOS). Para Windows/macOS/Linux: ver la guía oficial de Flutter para configurar el soporte de escritorio.

**Instalación y ejecución (rápido)**

Clona el repositorio y entra en la carpeta del proyecto:

```powershell
git clone https://github.com/Themanzato/MemoryDev.git
cd MemoryDev
```

Instala dependencias y ejecuta en modo debug:

```powershell
flutter pub get
flutter run
```

Ejemplos de ejecución en plataformas específicas:

- Android (dispositivo/emulador conectado):

```powershell
flutter run -d <device-id>
```

- Web (navegador):

```powershell
flutter run -d chrome
```

- Build para release (Android APK):

```powershell
flutter build apk --release
```

**Estructura del proyecto (resumen)**
- **`lib/`**: Código Dart principal.
  - `main.dart`: Punto de entrada de la app.
  - `models/`: Modelos de datos (`project.dart`, `documentation_item.dart`).
  - `screens/`: Pantallas de la aplicación.
  - `services/`: Servicios (ej. `storage_service.dart`).
  - `widgets/`: Componentes reutilizables (canvas, tarjetas, timeline).
- **`assets/`**: Animaciones, datos JSON y otros activos usados por la app.
- **`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`**: Configuración y código específico por plataforma.
- **`pubspec.yaml`**: Dependencias y configuración de assets.

**Pruebas**
- Test básico incluido en `test/widget_test.dart`.

Ejecutar tests:

```powershell
flutter test
```

**Cómo contribuir**
- Clona el repo y crea una rama para tu cambio:

```powershell
git checkout -b feat/nueva-funcionalidad
```

- Haz tus cambios, añade tests si corresponde, haz commit y push:

```powershell
git add .
git commit -m "Describe tu cambio"
git push origin feat/nueva-funcionalidad
```

- Abre un pull request en GitHub describiendo los cambios y pasos para probarlos.

**Consejos de desarrollo**
- Usa `flutter pub get` tras subir/recibir cambios en `pubspec.yaml`.
- Verifica la versión del SDK con `flutter --version`.
- Para depurar visualmente, usa Android Studio o VS Code con los plugins de Flutter/Dart.

**Licencia**
- Este repositorio no incluye una licencia explícita por defecto. Si quieres añadir una licencia, crea un archivo `LICENSE` en la raíz (por ejemplo MIT, Apache-2.0, etc.).

**Contacto / Autor**
- Repository Owner: `Themanzato` (https://github.com/Themanzato)
- Para problemas o preguntas, abre un issue en GitHub.

**Notas finales**
- Si necesitas que documente más internamente (API, modelos, flujos de trabajo concretos o ejemplos de uso), dime qué sección prefieres y la amplio.
# memorydev

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
