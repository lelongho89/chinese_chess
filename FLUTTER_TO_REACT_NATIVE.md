# Flutter to React Native Migration Guide

This document outlines the key differences between Flutter and React Native to help with the migration process of the Chinese Chess application.

## Framework Comparison

| Feature | Flutter | React Native | Migration Notes |
|---------|---------|--------------|----------------|
| Language | Dart | JavaScript/TypeScript | Need to rewrite all code |
| UI Rendering | Custom rendering engine | Native components | Components will look more native |
| State Management | Provider, Riverpod, BLoC | Redux, Context API, MobX | Similar concepts, different implementation |
| Navigation | Navigator, Navigator 2.0 | React Navigation | Different API but similar concepts |
| Hot Reload | Yes | Yes | Both support development efficiency |
| Performance | Excellent | Good | May need optimization for complex UI |
| Native Access | Plugins | Native Modules | Different approach to native code |

## Component Mapping

### UI Components

| Flutter | React Native | Notes |
|---------|--------------|-------|
| `Container` | `View` | Basic container element |
| `Text` | `Text` | Text display |
| `Image` | `Image` | Image display |
| `Column` | `View` with flexDirection: 'column' | Vertical layout |
| `Row` | `View` with flexDirection: 'row' | Horizontal layout |
| `Stack` | `View` with position: 'absolute' for children | Layered components |
| `ListView` | `FlatList` or `ScrollView` | Scrollable lists |
| `GridView` | `FlatList` with numColumns | Grid layouts |
| `MaterialApp` | `NavigationContainer` | App container |
| `Scaffold` | Combination of components | Need to recreate with multiple components |
| `AppBar` | Custom component or library | No direct equivalent |
| `FloatingActionButton` | Custom component or library | No direct equivalent |
| `BottomNavigationBar` | `BottomTabNavigator` | Similar but different API |
| `Drawer` | `DrawerNavigator` | Similar but different API |
| `TabBar` | `TabNavigator` | Similar but different API |
| `Dialog` | `Modal` | Different API |
| `SnackBar` | Third-party library | No direct equivalent |
| `Card` | Custom component | Need to recreate |
| `TextField` | `TextInput` | Different API |
| `GestureDetector` | `TouchableOpacity`, `PanResponder` | Different API |

### Styling

| Flutter | React Native | Notes |
|---------|--------------|-------|
| `BoxDecoration` | `StyleSheet` | Different approach |
| `ThemeData` | Theme context | Different implementation |
| `MediaQuery` | `Dimensions` API | Different API |
| `EdgeInsets` | `margin`, `padding` | Different syntax |
| `Alignment` | `justifyContent`, `alignItems` | Different properties |
| `Colors` | Custom color definitions | Need to recreate color palette |

## Game-Specific Components

### Board

**Flutter:**
```dart
class Board extends StatefulWidget {
  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: gamer.skin.width,
      height: gamer.skin.height,
      child: Image.asset(gamer.skin.boardImage),
    );
  }
}
```

**React Native:**
```javascript
import React from 'react';
import { View, Image, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';

const Board = () => {
  const { skin } = useSelector(state => state.game);
  
  return (
    <View style={[styles.board, { width: skin.width, height: skin.height }]}>
      <Image 
        source={{ uri: skin.boardImage }} 
        style={{ width: skin.width, height: skin.height }}
        resizeMode="contain"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  board: {
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default Board;
```

### Chess Piece

**Flutter:**
```dart
class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;

  const Piece({
    Key? key,
    required this.item,
    this.isActive = false,
    this.isAblePoint = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameManager gamer = GameWrapper.of(context).gamer;
    return SizedBox(
      width: gamer.skin.size,
      height: gamer.skin.size,
      child: Image.asset(
        gamer.skin.getPieceImage(item.type),
        width: gamer.skin.size * gamer.scale,
        height: gamer.skin.size * gamer.scale,
      ),
    );
  }
}
```

**React Native:**
```javascript
import React from 'react';
import { View, Image, StyleSheet } from 'react-native';
import { useSelector } from 'react-redux';

const Piece = ({ item, isActive = false, isAblePoint = false }) => {
  const { skin, scale } = useSelector(state => state.game);
  
  return (
    <View style={[
      styles.piece, 
      { width: skin.size, height: skin.size },
      isActive && styles.activePiece
    ]}>
      <Image 
        source={{ uri: skin.getPieceImage(item.type) }} 
        style={{ 
          width: skin.size * scale, 
          height: skin.size * scale 
        }}
        resizeMode="contain"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  piece: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  activePiece: {
    // Add active styling
  }
});

export default Piece;
```

## State Management Migration

### Flutter (Provider):
```dart
// Provider setup
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: localeProvider),
    ChangeNotifierProvider.value(value: authService),
  ],
  child: const MainApp(),
)

// Usage
final localeProvider = Provider.of<LocaleProvider>(context);
```

### React Native (Redux):
```javascript
// Store setup
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from './reducers';

const store = configureStore({
  reducer: rootReducer
});

// Provider setup
import { Provider } from 'react-redux';

const App = () => (
  <Provider store={store}>
    <NavigationContainer>
      <MainApp />
    </NavigationContainer>
  </Provider>
);

// Usage
import { useSelector, useDispatch } from 'react-redux';

const Component = () => {
  const locale = useSelector(state => state.locale);
  const dispatch = useDispatch();
  
  // Use locale and dispatch actions
};
```

## Firebase Integration

### Flutter:
```dart
// Initialize Firebase
await Firebase.initializeApp();

// Firestore
await FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Authentication
final authService = await AuthService.getInstance();
```

### React Native:
```javascript
// Initialize Firebase
import { initializeApp } from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';

const firebaseConfig = {
  // Your config here
};

const app = initializeApp(firebaseConfig);

// Firestore
firestore().settings({
  persistence: true,
});

// Authentication
const signIn = async (email, password) => {
  try {
    await auth().signInWithEmailAndPassword(email, password);
  } catch (error) {
    console.error(error);
  }
};
```

## Localization

### Flutter:
```dart
// Setup
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en', ''),
  Locale('zh', 'CN'),
  Locale('vi', ''),
],
locale: localeProvider.locale,

// Usage
context.l10n.appTitle
```

### React Native:
```javascript
// Setup with i18next
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: require('./locales/en.json') },
      zh: { translation: require('./locales/zh.json') },
      vi: { translation: require('./locales/vi.json') },
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  });

// Usage
import { useTranslation } from 'react-i18next';

const { t } = useTranslation();
t('appTitle');
```

## Navigation

### Flutter:
```dart
Navigator.of(context).push<String>(
  MaterialPageRoute(
    builder: (BuildContext context) {
      return GameWrapper(child: EditFen(fen: gamer.fenStr));
    },
  ),
).then((fenStr) {
  if (fenStr != null && fenStr.isNotEmpty) {
    gamer.newGame(fen: fenStr);
  }
});
```

### React Native:
```javascript
import { createStackNavigator } from '@react-navigation/stack';

const Stack = createStackNavigator();

// Navigation setup
<Stack.Navigator>
  <Stack.Screen name="Home" component={HomeScreen} />
  <Stack.Screen name="EditFen" component={EditFenScreen} />
</Stack.Navigator>

// Navigation usage
import { useNavigation } from '@react-navigation/native';

const navigation = useNavigation();
navigation.navigate('EditFen', { fen: gamer.fenStr });

// Receiving result
// In EditFenScreen
const route = useRoute();
const { fen } = route.params;

// To return result
navigation.navigate('Home', { fenStr: newFen });

// In HomeScreen
useEffect(() => {
  if (route.params?.fenStr) {
    gamer.newGame(fen: route.params.fenStr);
  }
}, [route.params?.fenStr]);
```

## Conclusion

This guide provides a high-level overview of the key differences between Flutter and React Native to help with the migration process. While the concepts are often similar, the implementation details differ significantly. The migration will require rewriting most of the code, but the business logic and game rules can be ported with minimal changes.
