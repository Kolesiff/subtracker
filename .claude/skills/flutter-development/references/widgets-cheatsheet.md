# Flutter Widgets Cheatsheet

## Layout Widgets

### Container
```dart
Container(
  width: 200,
  height: 100,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: const Text('Hello'),
)
```

### Row & Column
```dart
// Horizontal layout
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [Widget1(), Widget2(), Widget3()],
)

// Vertical layout
Column(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [Widget1(), Widget2(), Widget3()],
)
```

### Stack (Overlapping)
```dart
Stack(
  alignment: Alignment.center,
  children: [
    Container(color: Colors.red, width: 200, height: 200),
    Positioned(
      top: 10,
      right: 10,
      child: Icon(Icons.close),
    ),
  ],
)
```

### Expanded & Flexible
```dart
Row(
  children: [
    Expanded(flex: 2, child: Container(color: Colors.red)),
    Expanded(flex: 1, child: Container(color: Colors.blue)),
    Flexible(child: Container(color: Colors.green)),
  ],
)
```

### SizedBox (Spacing)
```dart
Column(
  children: [
    Text('Item 1'),
    const SizedBox(height: 16),  // Vertical space
    Text('Item 2'),
  ],
)
```

### Padding
```dart
Padding(
  padding: const EdgeInsets.only(left: 16, top: 8),
  child: Text('Padded text'),
)
```

## Scrolling Widgets

### ListView
```dart
// Simple list
ListView(
  children: [ListTile(), ListTile(), ListTile()],
)

// Builder (for large lists - RECOMMENDED)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
)

// Separated
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  separatorBuilder: (context, index) => const Divider(),
)
```

### GridView
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => Card(child: Text(items[index])),
)
```

### SingleChildScrollView
```dart
SingleChildScrollView(
  child: Column(
    children: [/* Many widgets */],
  ),
)
```

### CustomScrollView with Slivers
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(title: Text('Title')),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('Item $index')),
        childCount: 20,
      ),
    ),
  ],
)
```

## Input Widgets

### TextField
```dart
TextField(
  controller: _textController,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: const Icon(Icons.email),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    errorText: hasError ? 'Invalid email' : null,
  ),
  keyboardType: TextInputType.emailAddress,
  obscureText: false,  // true for passwords
  onChanged: (value) => print(value),
  onSubmitted: (value) => submit(),
)
```

### Form & Validation
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required field';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

## Button Widgets

### ElevatedButton
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text('Elevated'),
)
```

### TextButton, OutlinedButton, IconButton
```dart
TextButton(onPressed: () {}, child: const Text('Text'))
OutlinedButton(onPressed: () {}, child: const Text('Outlined'))
IconButton(onPressed: () {}, icon: const Icon(Icons.favorite))
```

### FloatingActionButton
```dart
FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
)

FloatingActionButton.extended(
  onPressed: () {},
  label: const Text('Add Item'),
  icon: const Icon(Icons.add),
)
```

## Display Widgets

### Text
```dart
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    letterSpacing: 1.2,
  ),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### Image
```dart
// Asset image
Image.asset('assets/images/logo.png', width: 100, fit: BoxFit.cover)

// Network image
Image.network('https://example.com/image.jpg', fit: BoxFit.cover)

// With placeholder and caching (use cached_network_image package)
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Icon
```dart
Icon(
  Icons.favorite,
  size: 24,
  color: Colors.red,
)
```

### Card
```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Card content'),
  ),
)
```

## Navigation Widgets

### AppBar
```dart
AppBar(
  title: const Text('Screen Title'),
  centerTitle: true,
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {},
  ),
  actions: [
    IconButton(icon: const Icon(Icons.search), onPressed: () {}),
    IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
  ],
)
```

### BottomNavigationBar
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

### Drawer
```dart
Scaffold(
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Text('Menu')),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
)
```

### TabBar
```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      bottom: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.home), text: 'Home'),
          Tab(icon: Icon(Icons.search), text: 'Search'),
          Tab(icon: Icon(Icons.settings), text: 'Settings'),
        ],
      ),
    ),
    body: TabBarView(
      children: [HomeTab(), SearchTab(), SettingsTab()],
    ),
  ),
)
```

## Dialog & Modal Widgets

### AlertDialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // Action
          Navigator.pop(context);
        },
        child: const Text('Confirm'),
      ),
    ],
  ),
);
```

### BottomSheet
```dart
showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  builder: (context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [/* Content */],
    ),
  ),
);
```

### SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Action completed'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {},
    ),
    duration: const Duration(seconds: 3),
  ),
);
```

## Utility Widgets

### GestureDetector
```dart
GestureDetector(
  onTap: () => print('Tapped'),
  onLongPress: () => print('Long pressed'),
  onDoubleTap: () => print('Double tapped'),
  child: Container(child: Text('Tap me')),
)
```

### InkWell (with ripple effect)
```dart
InkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(8),
  child: Container(child: Text('Tap me')),
)
```

### Visibility
```dart
Visibility(
  visible: isVisible,
  child: Text('Conditionally visible'),
)

// Alternative
if (isVisible) Text('Conditionally visible'),
```

### FutureBuilder
```dart
FutureBuilder<List<User>>(
  future: fetchUsers(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final users = snapshot.data!;
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => Text(users[index].name),
    );
  },
)
```

### StreamBuilder
```dart
StreamBuilder<int>(
  stream: counterStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const Text('Loading...');
    return Text('Count: ${snapshot.data}');
  },
)
```
