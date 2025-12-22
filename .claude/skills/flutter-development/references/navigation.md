# Navigation Patterns Guide

## Navigator 1.0 (Imperative)

### Basic Navigation
```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondScreen()),
);

// Push and remove all previous
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
  (route) => false,
);

// Go back
Navigator.pop(context);

// Pop with result
Navigator.pop(context, result);

// Check if can pop
if (Navigator.canPop(context)) {
  Navigator.pop(context);
}
```

### Named Routes
```dart
// Define routes in MaterialApp
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomeScreen(),
    '/details': (context) => DetailsScreen(),
    '/settings': (context) => SettingsScreen(),
  },
)

// Navigate
Navigator.pushNamed(context, '/details');

// With arguments
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'id': 123, 'title': 'Item'},
);

// Receive arguments
class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return Text('ID: ${args['id']}');
  }
}
```

### onGenerateRoute (Dynamic Routes)
```dart
MaterialApp(
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/details':
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (_) => DetailsScreen(id: args['id']),
        );
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  },
)
```

## Navigator 2.0 (Declarative) with go_router

### Setup
```yaml
dependencies:
  go_router: ^13.0.0
```

### Basic Configuration
```dart
// router.dart
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details/:id',
      name: 'details',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

// main.dart
void main() {
  runApp(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
}
```

### Navigation Commands
```dart
// Navigate to route
context.go('/details/123');

// Navigate with name
context.goNamed('details', pathParameters: {'id': '123'});

// Push (add to stack, allows back)
context.push('/details/123');

// Replace current route
context.replace('/home');

// Go back
context.pop();

// Query parameters
context.go('/search?query=flutter&page=1');

// Access query params
final query = state.uri.queryParameters['query'];
```

### Nested Navigation (Tabs, Drawers)
```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeTab(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchTab(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileTab(),
        ),
      ],
    ),
  ],
);

// MainShell with BottomNavigationBar
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/search');
      case 2:
        context.go('/profile');
    }
  }
}
```

### Route Guards (Redirect)
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoggingIn = state.uri.path == '/login';

    // Redirect to login if not logged in
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // Redirect to home if logged in and trying to access login
    if (isLoggedIn && isLoggingIn) {
      return '/home';
    }

    return null; // No redirect
  },
  routes: [/* ... */],
);
```

### Refresh Router on Auth Change
```dart
final router = GoRouter(
  refreshListenable: authProvider, // ChangeNotifier
  redirect: (context, state) {
    // Redirect logic
  },
  routes: [/* ... */],
);
```

## Deep Linking

### Android Setup
`android/app/src/main/AndroidManifest.xml`:
```xml
<activity>
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="https"
      android:host="yourapp.com"
      android:pathPrefix="/details" />
  </intent-filter>
</activity>
```

### go_router Deep Link Handling
```dart
// Routes automatically handle deep links
// https://yourapp.com/details/123 → DetailsScreen(id: '123')
GoRoute(
  path: '/details/:id',
  builder: (context, state) => DetailsScreen(
    id: state.pathParameters['id']!,
  ),
)
```

## Page Transitions

### Custom Transitions
```dart
GoRoute(
  path: '/details',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const DetailsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  },
)
```

### Slide Transition
```dart
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  final tween = Tween(begin: begin, end: end)
      .chain(CurveTween(curve: Curves.easeInOut));
  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
```

## Pass Data Between Screens

### With go_router
```dart
// Using extra
context.go('/details', extra: myObject);

// Receive
GoRoute(
  path: '/details',
  builder: (context, state) {
    final data = state.extra as MyObject;
    return DetailsScreen(data: data);
  },
)

// Using query params (for simple data)
context.go('/details?id=123&name=John');

// Receive
final id = state.uri.queryParameters['id'];
final name = state.uri.queryParameters['name'];
```

## Best Practices

1. **Use Named Routes**: Easier to maintain and refactor
2. **Centralize Routes**: Define all routes in one file
3. **Use go_router**: Better for complex navigation, deep links
4. **Implement Guards**: Protect routes that require authentication
5. **Handle Errors**: Always provide a 404/error screen
6. **Test Navigation**: Write integration tests for navigation flows
