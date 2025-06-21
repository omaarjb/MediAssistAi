import 'package:dio/dio.dart';
import 'package:dr_ai/utils/constant/api_url.dart';
import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../model/find_hospital_place_info.dart';

class PlacesWebservices {
  static Dio dio = Dio();

  /// Determines the country code from coordinates using reverse geocoding
  static Future<String?> getCountryCodeFromCoordinates(
      double lat, double lng) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': ApiUrlManager.googleMapApiKey,
        },
      );

      log('Reverse geocoding response status: ${response.statusCode}');

      if (response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final addressComponents =
            response.data['results'][0]['address_components'];
        for (var component in addressComponents) {
          if (component['types'].contains('country')) {
            final countryCode = component['short_name'].toLowerCase();
            log('Detected country code: $countryCode');
            return countryCode;
          }
        }
      }
      log('No country code found in geocoding response');
      return null;
    } catch (error) {
      log('Error getting country code: $error');
      return null;
    }
  }

  /// Fetches place suggestions based on user input and location
  static Future fetchPlaceSuggestions(String place, String sessionToken,
      {double? latitude, double? longitude}) async {
    try {
      // Log the search parameters for debugging
      log('Searching for "$place" near lat:$latitude, lng:$longitude');

      // Build base query parameters
      Map<String, dynamic> queryParams = {
        'input': place,
        'key': ApiUrlManager.googleMapApiKey,
        'sessiontoken': sessionToken,
        'types': 'hospital',
      };

      // Add location parameters if coordinates are available
      if (latitude != null && longitude != null) {
        queryParams['location'] = '$latitude,$longitude';
        queryParams['radius'] = 50000; // 50km radius
        queryParams['strictbounds'] = true; // Force respect for the radius

        // Get country code dynamically and add country restriction
        String? countryCode =
            await getCountryCodeFromCoordinates(latitude, longitude);
        if (countryCode != null) {
          queryParams['components'] = 'country:$countryCode';
          log('Restricting search to country: $countryCode');
        }
      } else {
        log('Warning: No location coordinates provided for place suggestions');
      }

      // Make the API request
      log('Making Places API request with params: $queryParams');
      Response response = await dio.get(
        ApiUrlManager.placeSuggetion,
        queryParameters: queryParams,
      );

      // Log the response status and first few results
      log('Places API response status: ${response.statusCode}');
      if (response.data['predictions'] != null &&
          response.data['predictions'].isNotEmpty) {
        log('First result: ${response.data['predictions'][0]['description']}');
      }

      return response.data['predictions'];
    } on DioException catch (e) {
      log('DioException in fetchPlaceSuggestions: ${e.message}');
      log('DioException response: ${e.response?.data}');
      return Future.error("Place suggestions error: ${e.message}",
          StackTrace.fromString("DioException in fetchPlaceSuggestions"));
    } catch (err) {
      log('Error in fetchPlaceSuggestions: $err');
      return Future.error("Place suggestions error", StackTrace.current);
    }
  }

  /// Fetches detailed location information for a selected place
  static Future fetchPlaceLocation(String placeId, String sessionToken) async {
    try {
      log('Fetching location details for place ID: $placeId');
      Response response = await dio.get(
        ApiUrlManager.placeLocation,
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': ApiUrlManager.googleMapApiKey,
          'sessiontoken': sessionToken,
        },
      );
      log('Place location API response status: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      log('DioException in fetchPlaceLocation: ${e.message}');
      return Future.error(
          "Place location error: ${e.message}", StackTrace.current);
    } catch (err) {
      log('Error in fetchPlaceLocation: $err');
      return Future.error("Place location error: $err", StackTrace.current);
    }
  }

  /// Gets directions between origin and destination points
  static Future getPlaceDirections(LatLng origin, LatLng destination) async {
    try {
      log('Getting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      Response response = await dio.get(
        ApiUrlManager.directions,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': ApiUrlManager.googleMapApiKey,
        },
      );
      log('Directions API response status: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      log('DioException in getPlaceDirections: ${e.message}');
      return Future.error(
          "Place directions error: ${e.message}", StackTrace.current);
    } catch (err) {
      log('Error in getPlaceDirections: $err');
      return Future.error("Place directions error: $err", StackTrace.current);
    }
  }

  /// Legacy method - can be removed if not used elsewhere
  static Future getNearestHospital(
      double latitude, double longitude, String sessionToken) async {
    final queryParameters = {
      'location': '$latitude,$longitude',
      'radius': '5000',
      'types': 'hospital',
      'key': ApiUrlManager.googleMapApiKey,
      'sessiontoken': sessionToken,
    };

    try {
      final response = await dio.get(ApiUrlManager.nearestHospital,
          queryParameters: queryParameters);

      for (int i = 0; i < response.data['results'].length; i++) {
        log(response.data['results'][i]['name']);
      }
    } catch (err) {
      log(err.toString());
    }
  }
}

class FindHospitalWebService {
  static final Dio dio = Dio();

  /// Gets a list of nearest hospitals based on current location
  static Future<List<FindHospitalsPlaceInfo>> getNearestHospital(
      double latitude, double longitude, double? radius) async {
    List<FindHospitalsPlaceInfo> hospitals = [];

    log('Searching for nearest hospitals at lat:$latitude, lng:$longitude with radius:${radius ?? 5000}m');
    try {
      String? countryCode =
          await PlacesWebservices.getCountryCodeFromCoordinates(
              latitude, longitude);

      Map<String, dynamic> queryParams = {
        'location': '$latitude,$longitude',
        'radius': radius?.toString() ?? '5000',
        'types': ['hospital', 'emergency_hospital', 'surgery_hospital'],
        'key': ApiUrlManager.googleMapApiKey,
      };

      // Add country restriction if we have a country code
      if (countryCode != null) {
        queryParams['components'] = 'country:$countryCode';
        log('Restricting hospital search to country: $countryCode');
      }

      final response = await dio.get(
        ApiUrlManager.nearestHospital,
        queryParameters: queryParams,
      );

      if (response.data == null || response.data['results'] == null) {
        log('Response data is null or missing results key');
        return hospitals;
      }

      final List<dynamic> results = response.data['results'];
      log('Found ${results.length} hospitals nearby');

      for (var item in results) {
        hospitals.add(FindHospitalsPlaceInfo.fromJson(item));
      }
    } catch (err) {
      log('Error finding nearest hospitals: $err');
      return hospitals;
    }

    return hospitals;
  }
}
