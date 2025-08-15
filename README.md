# Artacho App (Versión Desarrollo)

[![Flutter](https://img.shields.io/badge/Flutter-3.16.7-blue.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Play Store Internal](https://img.shields.io/badge/Google%20Play-Internal%20Testing-orange)](https://play.google.com/store/apps/details?id=com.martinartacho.artachoapp)

Repositorio oficial de la aplicación Artacho App en su versión de desarrollo y pruebas internas.

## 🔍 Descripción
Este repositorio contiene el código fuente de la versión de desarrollo de Artacho App, actualmente en **pruebas internas** (Versión 1.0.19). Es un fork limpio de [`artacho_app_dev`](https://github.com/martinartacho/artachoapp/tree/main/artacho_app_dev) sin historial de commits previos.

## 📱 Enlaces a Google Play
| Versión          | Estado           | Enlace                                                                 |
|------------------|------------------|------------------------------------------------------------------------|
| Producción       | Publicada (1.0.16) | [Descargar en Play Store](https://play.google.com/store/apps/details?id=com.martinartacho.artachoapp) |
| Pruebas Internas | Activa (1.0.19)   | [Acceso interno](https://play.google.com/store/apps/details?id=com.martinartacho.artachoapp) |

## ⚙️ Requisitos Técnicos
- **Flutter SDK**: 3.16.7 o superior
- **Dart**: 3.2.6
- **Entorno Android**: Android Studio Giraffe+ con Android SDK 34
- **Dependencias clave**:
  ```yaml
  cupertino_icons: ^1.0.6
  flutter_bloc: ^8.1.3
  firebase_core: ^2.24.0
  http: ^1.1.0

##  🚀 Cómo Ejecutar el Proyecto
### Clonar repositorio:

```
git clone https://github.com/martinartacho/artacho_app_dev.git
```

### Instalar dependencias:
```
flutter pub get
```

Ejecutar en dispositivo:
```
flutter run --flavor dev --target lib/main_dev.dart
```
## 🔧 Configuración de Entornos
Parámetro	        Producción	    Desarrollo
Flavor	            production	    dev
Entry point	        main_prod.dart	main_dev.dart
Firebase Project	artacho-prod	artacho-dev

### Personalizar package
Para personalizar el package a otros nombre y dominios, ejemplo:
el package actual "com.artacho.app" cambiarlo a al package nuevo "com.ochatra.mobile"

```
 rename_package.bat
``` 
Pedirá: 
   Introduce el package actual: com.artacho.app
   Introduce el package nuevo: com.ochatra.mobile
y después
¿Quieres ejecutar en modo simulación? (s/n):

Indica "s" para que te liste las acciones, asi decides si prefieres hacerlo manualmente buscando y reemplazando archivos

- **Antes** de ejecutar rename_package.bat sería aconsable:
- Cerrar cualquier IDE o editor que tenga abierto artacho_app_dev.
- Ir a tu carpeta de proyectos (ej: flutter_projects) y hacer una copia completa:
  C: ...\flutter_projects

```
robocopy artacho_app_dev artacho_app_dev_backup /E
``` 

Esto crea **artacho_app_backup** con todo el contenido, incluso archivos ocultos como .git.
Confirmar que la copia pesa lo mismo que el original y que dentro tiene todos los archivos.

## 📊 Estructura del Proyecto
artacho_app_dev/
├── android/          # Configuración específica Android
├── ios/              # Configuración específica iOS
├── lib/
│   ├── src/          # Código fuente
│   │   ├── features/ # Funcionalidades (BLoC/Cubit)
│   │   ├── core/     # Utilidades comunes
│   │   ├── data/     # Fuentes de datos
│   ├── main_dev.dart # Punto de entrada dev
├── test/             # Pruebas unitarias
├── .gitignore
├── pubspec.yaml

### 📌 Próximos Pasos
Implementar CI/CD con GitHub Actions
Migrar a Flutter 3.19
Agregar pruebas de integración


## 📄 Licencia
Este proyecto está bajo licencia MIT. Ver LICENSE para más detalles.
Nota: Este repositorio contiene solo la versión de desarrollo. Para producción, consulte artacho_app
EOF
