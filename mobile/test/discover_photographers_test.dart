import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumen_studio/app/models/photographer_profile.dart';
import 'package:lumen_studio/app/models/user.dart';
import 'package:lumen_studio/app/providers/auth_provider.dart';
import 'package:lumen_studio/app/screens/photographers/nearby_photographers_screen.dart';
import 'package:lumen_studio/app/services/photographer_service.dart';
import 'package:provider/provider.dart';

class MockPhotographerService extends PhotographerService {
  MockPhotographerService({required this.mockData});

  final List<PhotographerProfile> mockData;
  String? lastState;
  String? lastDistrict;
  String? lastQuery;
  List<String> lastCategories = [];

  @override
  Future<List<PhotographerProfile>> searchNearby({
    required String token,
    String? location,
    String? query,
    String? state,
    String? district,
    List<String> categories = const [],
    double? latitude,
    double? longitude,
    bool includeSelf = true,
  }) async {
    lastState = state;
    lastDistrict = district;
    lastQuery = query ?? location;
    lastCategories = List.from(categories);

    return mockData.where((p) {
      if (state != null && state.isNotEmpty && p.state.toLowerCase() != state.toLowerCase()) {
        return false;
      }
      if (district != null && district.isNotEmpty) {
        final matchesDistrict = p.district.toLowerCase() == district.toLowerCase() ||
            p.city.toLowerCase() == district.toLowerCase();
        if (!matchesDistrict) return false;
      }
      if (lastQuery != null && lastQuery!.isNotEmpty) {
        final q = lastQuery!.toLowerCase();
        final matchesQuery = p.displayName.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.state.toLowerCase().contains(q) ||
            p.district.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }
      if (categories.isNotEmpty) {
        final hasAny = categories.any((c) => p.categories.contains(c));
        if (!hasAny) return false;
      }
      return true;
    }).toList();
  }
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  String? get token => 'test-jwt-token';

  @override
  bool get isLoggedIn => true;

  @override
  User? get user => const User(
        id: 'u1',
        username: 'test_studio',
        phone: '9999999999',
        studioName: 'Test Studio',
        email: 'test@example.com',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final List<PhotographerProfile> samplePhotographers = [
    const PhotographerProfile(
      id: 'p1',
      username: 'krishna_studio',
      studioName: 'Sri Krishna Studio',
      ownerName: 'Krishna Varma',
      phone: '9876543210',
      email: 'krishna@example.com',
      state: 'Telangana',
      district: 'Hyderabad',
      city: 'Hyderabad',
      address: 'Banjara Hills, Hyderabad',
      categories: ['Traditional Photographer', 'Candid Photographer'],
    ),
    const PhotographerProfile(
      id: 'p2',
      username: 'royal_cinema',
      studioName: 'Royal Cinema Works',
      ownerName: 'Rajesh Kumar',
      phone: '9876543211',
      email: 'rajesh@example.com',
      state: 'Telangana',
      district: 'Hyderabad',
      city: 'Hyderabad',
      address: 'Madhapur, Hyderabad',
      categories: ['Cinematic Videographer', 'Drones'],
    ),
    const PhotographerProfile(
      id: 'p3',
      username: 'warangal_clicks',
      studioName: 'Warangal Clicks',
      ownerName: 'Suresh',
      phone: '9876543212',
      email: 'suresh@example.com',
      state: 'Telangana',
      district: 'Warangal',
      city: 'Warangal',
      address: 'Hanamkonda, Warangal',
      categories: ['Traditional Photographer'],
    ),
  ];

  Widget buildTestWidget({required PhotographerService service}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => FakeAuthProvider(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: NearbyPhotographersScreen(
            service: service,
          ),
        ),
      ),
    );
  }

  group('Discover Tab Global & Location-Based Photographer Discovery Tests', () {
    testWidgets('1. Shows all registered photographers worldwide by default on opening Discover', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Should show worldwide count & badge
      expect(find.text('3 photographers discovered worldwide'), findsOneWidget);
      expect(find.text('Worldwide'), findsOneWidget);
      expect(find.text('Filter by State & District'), findsOneWidget);

      // All registered studios should appear without requiring state/district selection
      expect(find.text('Sri Krishna Studio'), findsOneWidget);
      expect(find.text('Royal Cinema Works'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsOneWidget);
    });

    testWidgets('2. Worldwide search bar searches by city or studio name', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Search for "Warangal" in the worldwide search bar
      await tester.enterText(find.byType(TextField), 'Warangal');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Warangal Clicks'), findsOneWidget);
      expect(find.text('Sri Krishna Studio'), findsNothing);
      expect(find.text('Royal Cinema Works'), findsNothing);

      // Clear search restores all photographers
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Sri Krishna Studio'), findsOneWidget);
      expect(find.text('Royal Cinema Works'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsOneWidget);
    });

    testWidgets('3. Can open State & District filter and drill down to a district', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Tap "Filter by State & District"
      await tester.tap(find.text('Filter by State & District'));
      await tester.pumpAndSettle();

      // State selector should be visible
      expect(find.text('Explore Photographers in India'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'Andhra Pradesh'), findsOneWidget);

      // Search and select Telangana
      await tester.enterText(find.byType(TextField), 'Telangana');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Telangana'));
      await tester.pumpAndSettle();

      // District selector should be visible
      expect(find.text('Select District in Telangana'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'Hyderabad'), findsOneWidget);

      // Select Hyderabad
      await tester.tap(find.widgetWithText(InkWell, 'Hyderabad'));
      await tester.pumpAndSettle();

      // Now back to list, filtered to Hyderabad
      expect(find.text('2 photographers found in Hyderabad'), findsOneWidget);
      expect(find.text('Sri Krishna Studio'), findsOneWidget);
      expect(find.text('Royal Cinema Works'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsNothing);
      expect(find.widgetWithText(Container, 'Hyderabad, Telangana'), findsOneWidget);
    });

    testWidgets('4. Category filter refines district results and clear restores district photographers', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Open state filter -> Telangana -> Hyderabad
      await tester.tap(find.text('Filter by State & District'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Telangana');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Telangana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Hyderabad'));
      await tester.pumpAndSettle();

      // Open category filter hamburger sheet
      await tester.tap(find.byTooltip('Filter by Category'));
      await tester.pumpAndSettle();

      // Filter by Traditional Photographer
      await tester.tap(find.widgetWithText(FilterChip, 'Traditional Photographer'));
      await tester.pumpAndSettle();

      // Apply filter
      await tester.tap(find.text('Apply Filters (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Sri Krishna Studio'), findsOneWidget);
      expect(find.text('Royal Cinema Works'), findsNothing);

      // Clear filters button restores both Hyderabad studios
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Sri Krishna Studio'), findsOneWidget);
      expect(find.text('Royal Cinema Works'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsOneWidget);
    });

    testWidgets('5. Closing location filter restores worldwide listing', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Filter to Telangana -> Hyderabad
      await tester.tap(find.text('Filter by State & District'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Telangana');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Telangana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Hyderabad'));
      await tester.pumpAndSettle();

      expect(find.text('2 photographers found in Hyderabad'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsNothing);

      // Tap close [x] on Hyderabad pill
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Restores worldwide listing
      expect(find.text('3 photographers discovered worldwide'), findsOneWidget);
      expect(find.text('Warangal Clicks'), findsOneWidget);
    });

    testWidgets('6. Empty state displays location change and clear options', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1.0;

      final mockService = MockPhotographerService(mockData: samplePhotographers);
      await tester.pumpWidget(buildTestWidget(service: mockService));
      await tester.pumpAndSettle();

      // Drill down to Adilabad (0 studios)
      await tester.tap(find.text('Filter by State & District'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Telangana');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Telangana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(InkWell, 'Adilabad'));
      await tester.pumpAndSettle();

      // Empty state
      expect(find.text('No Studios in Adilabad Yet'), findsOneWidget);
      expect(find.text('Change District'), findsOneWidget);
      expect(find.text('Change State'), findsOneWidget);
    });
  });
}
