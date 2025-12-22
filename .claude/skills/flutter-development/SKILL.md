---
name: flutter-development
description: Comprehensive Flutter mobile app development guide covering project setup, MVVM architecture, UI/UX design, state management, backend integration (Firebase/Supabase), Figma-to-Flutter workflows, testing strategies, performance optimization, and Play Store publishing. Use when building Flutter apps, creating new Flutter projects, implementing features, debugging, designing UIs, connecting backends, or preparing apps for release.
---

# Flutter Development Skill

Expert guidance for Flutter mobile app development from project setup to Play Store release.

## Quick Start

1. **New Project**: See [project-setup.md](references/project-setup.md)
2. **Architecture**: See [mvvm-architecture.md](references/mvvm-architecture.md)
3. **UI Development**: See [widgets-cheatsheet.md](references/widgets-cheatsheet.md)
4. **State Management**: See [state-management.md](references/state-management.md)

## Reference Files

| Topic | File | Use When |
|-------|------|----------|
| Project Setup | [project-setup.md](references/project-setup.md) | Starting new project, environment setup |
| MVVM Architecture | [mvvm-architecture.md](references/mvvm-architecture.md) | Structuring app, organizing code |
| Widgets | [widgets-cheatsheet.md](references/widgets-cheatsheet.md) | Building UI components |
| State Management | [state-management.md](references/state-management.md) | Managing app state |
| Navigation | [navigation.md](references/navigation.md) | Screen routing, deep links |
| Backend Integration | [backend-integration.md](references/backend-integration.md) | Firebase/Supabase setup |
| Figma to Flutter | [figma-to-flutter.md](references/figma-to-flutter.md) | Design handoff, converting designs |
| Testing | [testing.md](references/testing.md) | Unit, widget, integration tests |
| Performance | [performance.md](references/performance.md) | Optimization, debugging |
| Publishing | [publishing.md](references/publishing.md) | Play Store release |
| Packages | [packages.md](references/packages.md) | Essential pub.dev packages |

## Development Workflow

1. **Setup** → Create project with proper structure
2. **Architecture** → Implement MVVM pattern
3. **UI** → Build screens using Material 3
4. **State** → Add state management
5. **Backend** → Connect Firebase/Supabase
6. **Test** → Write unit/widget/integration tests
7. **Optimize** → Performance tuning
8. **Release** → Build and publish to Play Store

## Key Commands

```bash
# Create new project
flutter create --org com.yourcompany app_name

# Run app
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Official Resources

- **Flutter Docs**: https://docs.flutter.dev
- **Pub.dev**: https://pub.dev
- **Material 3**: https://m3.material.io
- **Flutter Cookbook**: https://docs.flutter.dev/cookbook
