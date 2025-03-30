import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/weather_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user_screen.dart';
import 'screens/fake_user_screen.dart';
import 'blocs/weather/weather_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'repositories/weather_repository.dart';
import 'repositories/user_repository.dart';
import 'services/weather_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firebaseService = FirebaseService();
  final userRepository = UserRepository();

  runApp(WeatherApp(firebaseService: firebaseService, userRepository: userRepository));
}

class WeatherApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final UserRepository userRepository;

  const WeatherApp({
    super.key,
    required this.firebaseService,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherBloc(
            WeatherRepository(weatherService: WeatherService()),
          ),
        ),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => UserBloc(firebaseService, userRepository)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Погода',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/fakeUser': (context) => const FakeUserScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WeatherScreen(),
    const ProfileScreen(),
    const FeedScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Погода"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Лента"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
        ],
      ),
    );
  }
}
