import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_studio/app/models/photographer_profile.dart';
import 'package:lumen_studio/app/utils/fuzzy_search_utils.dart';

void main() {
  group('FuzzySearchUtils Tests', () {
    test('1. Matches uppercase studio details with lowercase search query', () {
      const profile = PhotographerProfile(
        id: 'p-1',
        username: 'lumen_studio',
        phone: '9876543210',
        studioName: 'SRI BALAJI STUDIOS',
        ownerName: 'KUMAR',
        city: 'HYDERABAD',
        state: 'TELANGANA',
        district: 'HYDERABAD',
        address: 'THILAK NAGAR, MAIN ROAD',
        categories: ['Traditional Photographer', 'Candid Photographer'],
      );

      // Lowercase location search
      final scoreLocation = FuzzySearchUtils.scorePhotographer(profile, 'thilak nagar');
      expect(scoreLocation > 0.7, isTrue, reason: 'Lowercase thilak nagar should match uppercase THILAK NAGAR');

      // Single word location
      final scoreCity = FuzzySearchUtils.scorePhotographer(profile, 'hyderabad');
      expect(scoreCity > 0.7, isTrue);

      // Studio name match
      final scoreStudio = FuzzySearchUtils.scorePhotographer(profile, 'balaji');
      expect(scoreStudio > 0.7, isTrue);
    });

    test('2. Typo tolerance: matches misspelled location names', () {
      const profile = PhotographerProfile(
        id: 'p-2',
        username: 'lens_art',
        phone: '9876543211',
        studioName: 'Lens Art Studio',
        city: 'Thilak Nagar',
        district: 'Hyderabad',
        state: 'Telangana',
        address: 'Opposite Gandhi Statue, Thilak Nagar',
        categories: ['Candid Photographer'],
      );

      // "tilak nagar" (omitted 'h')
      final scorePhonetic = FuzzySearchUtils.scorePhotographer(profile, 'tilak nagar');
      expect(scorePhonetic > 0.7, isTrue, reason: 'tilak nagar should match Thilak Nagar');

      // "thilak nager" (vowel typo)
      final scoreTypo = FuzzySearchUtils.scorePhotographer(profile, 'thilak nager');
      expect(scoreTypo > 0.7, isTrue, reason: 'thilak nager should match Thilak Nagar');

      // "thilaknagar" (no space)
      final scoreSquashed = FuzzySearchUtils.scorePhotographer(profile, 'thilaknagar');
      expect(scoreSquashed > 0.7, isTrue, reason: 'thilaknagar should match Thilak Nagar');

      // "hyderbad" typo for Hyderabad
      const profile2 = PhotographerProfile(
        id: 'p-3',
        username: 'city_lens',
        phone: '9876543212',
        studioName: 'City Lens',
        city: 'Hyderabad',
      );
      final scoreHyd = FuzzySearchUtils.scorePhotographer(profile2, 'hyderbad');
      expect(scoreHyd > 0.7, isTrue, reason: 'hyderbad should match Hyderabad');
    });

    test('3. Category search: matches photographers when query specifies related categories', () {
      const dronePhotographer = PhotographerProfile(
        id: 'p-drone',
        username: 'sky_drone',
        phone: '9876543213',
        studioName: 'Sky High Shoots',
        city: 'Visakhapatnam',
        categories: ['Drones'],
      );

      const weddingPhotographer = PhotographerProfile(
        id: 'p-wedding',
        username: 'royal_weddings',
        phone: '9876543214',
        studioName: 'Royal Weddings',
        city: 'Vijayawada',
        categories: ['Traditional Photographer', 'Candid Photographer'],
      );

      // Search "drone" matches Drones category
      final scoreDrone = FuzzySearchUtils.scorePhotographer(dronePhotographer, 'drone');
      expect(scoreDrone > 0.7, isTrue);

      // Search "wedding" matches Traditional/Candid Photographer
      final scoreWedding = FuzzySearchUtils.scorePhotographer(weddingPhotographer, 'wedding');
      expect(scoreWedding > 0.7, isTrue);
    });

    test('4. District fuzzy matching in India location picker', () {
      // Matches even with typos or colloquial aliases
      expect(FuzzySearchUtils.matchesLocation('Visakhapatnam', 'visakapatnam'), isTrue);
      expect(FuzzySearchUtils.matchesLocation('Visakhapatnam', 'vizag'), isTrue);
      expect(FuzzySearchUtils.matchesLocation('Hyderabad', 'hyderbad'), isTrue);
      expect(FuzzySearchUtils.matchesLocation('Bengaluru Urban', 'bangalore'), isTrue);
      expect(FuzzySearchUtils.matchesLocation('Thiruvananthapuram', 'trivandrum'), isTrue);
    });
  });
}
