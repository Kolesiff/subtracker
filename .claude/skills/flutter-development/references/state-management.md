# State Management Guide

## Comparison

| Solution | Best For | Complexity | Learning Curve |
|----------|----------|------------|----------------|
| setState | Simple widgets | Low | Easy |
| Provider | Small-medium apps | Low | Easy |
| Riverpod | Medium-large apps | Medium | Medium |
| Bloc/Cubit | Large/enterprise apps | High | Steep |
| GetX | Rapid development | Low | Easy |

## Provider

### Setup
```yaml
dependencies:
  provider: ^6.1.1
```

### Basic Usage
```dart
// 1. Create a ChangeNotifier
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// 2. Provide it at the top of widget tree
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: const MyApp(),
    ),
  );
}

// 3. Consume in widgets
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Read value (rebuilds when changed)
        Consumer<CounterProvider>(
          builder: (context, counter, child) {
            return Text('Count: ${counter.count}');
          },
        ),
        // Or use context.watch
        Text('Count: ${context.watch<CounterProvider>().count}'),
        
        // Call methods (doesn't rebuild)
        ElevatedButton(
          onPressed: () => context.read<CounterProvider>().increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Multiple Providers
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    Provider(create: (_) => ApiService()),
  ],
  child: const MyApp(),
)
```

## Riverpod

### Setup
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
```

### Basic Usage
```dart
// 1. Define providers (outside of widgets)
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

// 2. Wrap app with ProviderScope
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// 3. Consume in widgets (extend ConsumerWidget)
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Provider Types
```dart
// Simple value
final nameProvider = Provider<String>((ref) => 'John');

// Mutable state
final counterProvider = StateProvider<int>((ref) => 0);

// Complex state with notifier
final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  return TodosNotifier();
});

// Async data (API calls)
final usersProvider = FutureProvider<List<User>>((ref) async {
  return await fetchUsers();
});

// Stream data
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return messageStream();
});
```

### Async Provider Example
```dart
final userProvider = FutureProvider<User>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchUser();
});

class UserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (user) => Text('Hello, ${user.name}'),
    );
  }
}
```

## Bloc / Cubit

### Setup
```yaml
dependencies:
  flutter_bloc: ^8.1.3
```

### Cubit (Simpler)
```dart
// 1. Define Cubit
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

// 2. Provide it
BlocProvider(
  create: (context) => CounterCubit(),
  child: const CounterScreen(),
)

// 3. Consume
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CounterCubit, int>(
          builder: (context, count) => Text('Count: $count'),
        ),
        ElevatedButton(
          onPressed: () => context.read<CounterCubit>().increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Bloc (With Events)
```dart
// Events
abstract class CounterEvent {}
class IncrementEvent extends CounterEvent {}
class DecrementEvent extends CounterEvent {}

// State
class CounterState {
  final int count;
  CounterState(this.count);
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    on<DecrementEvent>((event, emit) {
      emit(CounterState(state.count - 1));
    });
  }
}

// Usage
context.read<CounterBloc>().add(IncrementEvent());
```

### Bloc Listeners
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: /* ... */,
)

// Combined builder + listener
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    // Side effects (navigation, snackbars)
  },
  builder: (context, state) {
    // Build UI
    return /* ... */;
  },
)
```

## GetX

### Setup
```yaml
dependencies:
  get: ^4.6.6
```

### Basic Usage
```dart
// 1. Controller
class CounterController extends GetxController {
  var count = 0.obs;  // Observable

  void increment() => count++;
}

// 2. Initialize
void main() {
  Get.put(CounterController());
  runApp(const MyApp());
}

// 3. Use in widgets
class CounterScreen extends StatelessWidget {
  final controller = Get.find<CounterController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Text('Count: ${controller.count}')),
        ElevatedButton(
          onPressed: controller.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### GetX Navigation
```dart
// Navigate
Get.to(() => SecondScreen());
Get.toNamed('/second');

// Navigate and remove previous
Get.off(() => HomeScreen());
Get.offAll(() => LoginScreen());

// Go back
Get.back();

// Pass data
Get.to(() => DetailScreen(), arguments: item);
final item = Get.arguments;
```

## Best Practices

1. **Choose Based on App Size**
   - Small apps: Provider or setState
   - Medium apps: Riverpod or Provider
   - Large apps: Bloc or Riverpod

2. **Avoid Over-Engineering**
   - Don't use Bloc for simple counter apps
   - Start simple, refactor when needed

3. **Separate Business Logic**
   - Keep UI widgets stateless when possible
   - Move logic to ViewModels/Blocs/Notifiers

4. **Minimize Rebuilds**
   - Use `context.select()` for specific values
   - Use `Consumer` for targeted rebuilds
   - Avoid `context.watch()` at top of widget tree

5. **Testing**
   - State management makes testing easier
   - Mock dependencies for unit tests
