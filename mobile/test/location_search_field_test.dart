import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumen_studio/app/models/user.dart';
import 'package:lumen_studio/app/providers/auth_provider.dart';
import 'package:lumen_studio/app/services/location_search_service.dart';
import 'package:lumen_studio/app/widgets/location_search_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('selecting a venue reports its geocoded coordinates in custom service mode', (
    tester,
  ) async {
    final controller = TextEditingController();
    PlaceLocation? selectedPlace;
    var coordinatesCleared = false;
    final service = LocationSearchService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'features': [
              {
                'properties': {'name': 'Test Venue', 'city': 'Hyderabad'},
                'geometry': {
                  'coordinates': [78.4867, 17.385],
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSearchField(
            label: 'Location / Venue',
            controller: controller,
            locationSearchService: service,
            onLocationSelected: (place) => selectedPlace = place,
            onCoordinatesCleared: () => coordinatesCleared = true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Test Venue');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Venue').last);
    await tester.pumpAndSettle();

    expect(selectedPlace?.latitude, 17.385);
    expect(selectedPlace?.longitude, 78.4867);
    expect(controller.text, 'Test Venue, Hyderabad');

    await tester.enterText(find.byType(TextFormField), 'Different venue');
    expect(coordinatesCleared, isTrue);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('renders STEP 1 & STEP 2 cards without overflow on small screens', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSearchField(
            label: 'Studio Location',
            controller: controller,
            onLocationSelected: (_) {},
          ),
        ),
      ),
    );

    // Verify STEP 1 Card
    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('Open Google Maps App'), findsOneWidget);

    // Verify STEP 2 Card
    expect(find.text('STEP 2'), findsOneWidget);
    expect(find.text('Paste Google Maps Link'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('renders Verified Card when coordinates are locked', (tester) async {
    final controller = TextEditingController(text: 'Vintage Palace, Karwan, Hyderabad');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSearchField(
            label: 'Studio Location',
            controller: controller,
            initialLatitude: 17.3850,
            initialLongitude: 78.4867,
            onLocationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Studio Location Verified'), findsOneWidget);
    expect(find.text('Vintage Palace, Karwan, Hyderabad'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Tapping close clears location and restores the STEP cards
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('STEP 2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  test('AuthProvider flags needsLocationUpdate for existing users without Google Maps verification', () {
    final auth = AuthProvider();
    const existingUser = User(
      id: 'existing_usr_1',
      username: 'studio_user',
      phone: '9876543210',
      studioName: 'Flash Studio',
      ownerName: 'Owner',
      email: 'studio@test.com',
      city: 'Hyderabad',
      address: 'Old Address Without Maps Link',
      specialties: 'Weddings',
      about: 'Pro Studio',
      latitude: 17.385,
      longitude: 78.4867,
    );

    // User is logged in but hasn't verified via Google Maps flow
    auth.setUserForTesting(existingUser, 'token_xyz', true, false);

    expect(auth.isLoggedIn, isTrue);
    expect(auth.hasVerifiedGoogleMaps, isFalse);
    expect(auth.needsLocationUpdate, isTrue);

    // Once Google Maps is verified
    auth.setUserForTesting(existingUser, 'token_xyz', true, true);
    expect(auth.hasVerifiedGoogleMaps, isTrue);
    expect(auth.needsLocationUpdate, isFalse);
  });
}
