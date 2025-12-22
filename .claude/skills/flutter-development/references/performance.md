# Performance Optimization Guide

## Flutter DevTools

### Launch DevTools
```bash
flutter run --profile  # Run in profile mode
# Then open DevTools from terminal link or VS Code
```

### Key Tools
- **Widget Inspector**: Visualize widget tree
- **Performance Overlay**: Show render times
- **Timeline**: Profile frame rendering
- **Memory**: Track memory usage
- **Network**: Monitor HTTP requests

---

## Widget Optimization

### Use const Constructors
```dart
// ❌ Bad - Creates new instance every rebuild
Container(
  child: Text('Hello'),
)

// ✅ Good - Reuses same instance
const Container(
  child: Text('Hello'),
)
```

### Avoid Rebuilding Entire Trees
```dart
// ❌ Bad - Entire widget rebuilds
class BadExample extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Static content'),
        Text('Counter: $_count'),  // Only this changes
        const ExpensiveWidget(),    // But this rebuilds too
      ],
    );
  }
}

// ✅ Good - Only counter rebuilds
class GoodExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Static content'),
        const CounterWidget(),      // Isolated rebuild
        const ExpensiveWidget(),    // Never rebuilds
      ],
    );
  }
}
```

### Use RepaintBoundary
```dart
// Isolate frequently repainting widgets
RepaintBoundary(
  child: AnimatedWidget(), // Prevents parent repaints
)
```

### Split Large Widgets
```dart
// ❌ Bad - One giant build method
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // 500 lines of widgets...
      ],
    ),
  );
}

// ✅ Good - Extracted widgets
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        const HeaderSection(),
        const ContentSection(),
        const FooterSection(),
      ],
    ),
  );
}
```

---

## List Optimization

### Use ListView.builder
```dart
// ❌ Bad - All items built at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ Good - Items built on-demand
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### Specify itemExtent for Fixed Heights
```dart
ListView.builder(
  itemCount: 1000,
  itemExtent: 72.0,  // Fixed height enables optimizations
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

### Use Keys for Dynamic Lists
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(
    key: ValueKey(items[index].id),  // Helps Flutter track items
    item: items[index],
  ),
)
```

### Lazy Loading / Pagination
```dart
class PaginatedList extends StatefulWidget {
  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  final ScrollController _scrollController = ScrollController();
  final List<Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    final newItems = await fetchItems(offset: _items.length);
    
    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ItemWidget(item: _items[index]);
      },
    );
  }
}
```

---

## Image Optimization

### Use CachedNetworkImage
```yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInDuration: const Duration(milliseconds: 300),
  memCacheWidth: 400,  // Limit memory cache size
)
```

### Resize Images
```dart
// Resize on load
Image.asset(
  'assets/large_image.jpg',
  cacheWidth: 400,   // Decode at smaller resolution
  cacheHeight: 300,
)
```

### Use Appropriate Formats
- **PNG**: Transparency needed
- **JPEG**: Photos (smaller file size)
- **WebP**: Best compression (Android 4.0+, iOS 14+)
- **SVG**: Icons and simple graphics (use flutter_svg)

---

## State Management Performance

### Provider - Use select()
```dart
// ❌ Bad - Rebuilds on any change
Consumer<UserProvider>(
  builder: (context, provider, _) => Text(provider.user.name),
)

// ✅ Good - Only rebuilds when name changes
Selector<UserProvider, String>(
  selector: (_, provider) => provider.user.name,
  builder: (_, name, __) => Text(name),
)

// Or with context
final name = context.select<UserProvider, String>((p) => p.user.name);
```

### Avoid Notifying Unnecessarily
```dart
// ❌ Bad - Notifies even if value didn't change
void updateCount(int newCount) {
  _count = newCount;
  notifyListeners();
}

// ✅ Good - Only notify on actual change
void updateCount(int newCount) {
  if (_count != newCount) {
    _count = newCount;
    notifyListeners();
  }
}
```

---

## Animation Performance

### Use AnimatedBuilder
```dart
// ✅ Efficient - Only child rebuilds, not entire subtree
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * 2 * pi,
      child: child,  // Passed through, not rebuilt
    );
  },
  child: const ExpensiveWidget(),  // Built once
)
```

### Prefer Implicit Animations
```dart
// Simple animations without controllers
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  width: _expanded ? 200 : 100,
  color: _selected ? Colors.blue : Colors.grey,
)

AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: _visible ? 1.0 : 0.0,
  child: const MyWidget(),
)
```

### Use Rive/Lottie for Complex Animations
```yaml
dependencies:
  lottie: ^3.0.0
```

```dart
Lottie.asset('assets/animation.json')
```

---

## Memory Management

### Dispose Controllers
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Cancel Async Operations
```dart
class _MyWidgetState extends State<MyWidget> {
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchData() async {
    final data = await api.getData();
    if (_mounted) {
      setState(() => _data = data);
    }
  }
}
```

---

## Build Optimization

### Reduce App Size
```bash
# Build with split APKs per ABI
flutter build apk --split-per-abi

# Analyze APK size
flutter build apk --analyze-size
```

### Tree Shaking Icons
```dart
// pubspec.yaml - Only include used icons
flutter:
  fonts:
    - family: MaterialIcons
      fonts:
        - asset: fonts/MaterialIcons-Regular.otf
```

### Deferred Loading (Code Splitting)
```dart
import 'package:my_app/heavy_feature.dart' deferred as heavy;

Future<void> loadFeature() async {
  await heavy.loadLibrary();
  // Now use heavy.HeavyWidget()
}
```

---

## Profiling Commands

```bash
# Profile mode (for performance testing)
flutter run --profile

# Release mode (for final testing)
flutter run --release

# Analyze app size
flutter build apk --analyze-size

# Check for common issues
flutter analyze

# Performance overlay
# In app: Press 'P' in debug mode
```

---

## Checklist

- [ ] Use `const` wherever possible
- [ ] Split large widgets into smaller ones
- [ ] Use `ListView.builder` for long lists
- [ ] Cache network images
- [ ] Dispose controllers and subscriptions
- [ ] Use `select()` for targeted rebuilds
- [ ] Test in profile/release mode
- [ ] Profile with DevTools before shipping
