import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:url_launcher/url_launcher.dart';

part 'hotel_details_bloc.freezed.dart';
part 'hotel_details_event.dart';
part 'hotel_details_state.dart';

@injectable
class HotelDetailsBloc extends Bloc<HotelDetailsEvent, HotelDetailsState> {
  final Hotel hotel;
  final AppPreferences _pref;
  final HotelClient _client;
  HotelDetailsBloc(@factoryParam this.hotel, this._pref, this._client)
      : super(HotelDetailsState.initial(hotel)) {
    on<_Started>(_onStarted);
    on<_SheetSizeChanged>(_onSheetSizeChanged);
    on<_ToggleFavorite>(_onToggleFavorite);
    on<_ResetNavigation>(_onResetNavigation);
    on<_DidPressOnSeeAllFacilities>(_onDidPressOnSeeAllFacilities);
    on<_DidPressOnToggleDescription>(_onDidPressOnToggleDescription);
    on<_DidPressOnOpenMap>(_onDidPressOnOpenMap);
    on<_DidPressOnBookNow>(_onDidPressOnBookNow);
    on<_DidFetchAddress>(_onDidFetchAddress);
  }

  Future<void> _onDidFetchAddress(
    _DidFetchAddress event,
    Emitter<HotelDetailsState> emit,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(event.lat, event.lon);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        emit(state.copyWith(pinAddress: address));
      }
    } catch (e) {
      log('Error fetching address: $e');
    }
  }

  // MARK: - Starter Event
  void _onStarted(
    _Started event,
    Emitter<HotelDetailsState> emit,
  ) {
    final lat = hotel.location?.lat;
    final lon = hotel.location?.lon;
    if (lat != null && lon != null) {
      add(HotelDetailsEvent.didFetchAddress(lat, lon));
    }
  }

  void _onDidPressOnToggleDescription(
    _DidPressOnToggleDescription event,
    Emitter<HotelDetailsState> emit,
  ) {
    emit(state.copyWith(isDescriptionExpanded: !state.isDescriptionExpanded));
  }

  Future<void> _onDidPressOnOpenMap(
    _DidPressOnOpenMap event,
    Emitter<HotelDetailsState> emit,
  ) async {
    final lat = state.hotel.location?.lat;
    final lon = state.hotel.location?.lon;
    if (lat != null && lon != null) {
      try {
        final Uri uri;
        if (Platform.isIOS) {
          // Apple's recommended way — iOS intercepts this to open the native Maps app directly.
          uri = Uri.parse('https://maps.apple.com/?q=$lat,$lon');
        } else {
          // Standard Android geo URI — works with Google Maps, Waze, HERE, etc.
          uri = Uri(
              scheme: 'geo',
              path: '$lat,$lon',
              queryParameters: {'q': '$lat,$lon'});
        }

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: open in Google Maps browser (mostly for Android devices without any map app)
          final fallbackUri = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$lat,$lon');
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } else {
            log('Could not launch map URL: $fallbackUri');
          }
        }
      } catch (e) {
        log('Error launching map: $e');
      }
    }
  }

  void _onSheetSizeChanged(
    _SheetSizeChanged event,
    Emitter<HotelDetailsState> emit,
  ) {
    final isCollapsed = event.size >= 0.95;

    if (state.isCollapsed != isCollapsed) {
      emit(state.copyWith(isCollapsed: isCollapsed));
    }
  }

  Future<void> _onToggleFavorite(
    _ToggleFavorite event,
    Emitter<HotelDetailsState> emit,
  ) async {
    if (_pref.loggedIn) {
      emit(state.copyWith(viewState: ViewState.loading));

      final result =
          await _client.toggleFavoriteHotel((state.hotel.id ?? -1).toString());

      result.when(
        success: (_) {
          final updatedHotel = state.hotel
              .copyWith(isFavorite: !(state.hotel.isFavorite ?? false));
          emit(
              state.copyWith(hotel: updatedHotel, viewState: ViewState.loaded));
        },
        failure: (error) {
          emit(state.copyWith(viewState: WithViewState.failHandler(error)));
        },
      );
    } else {
      emit(
        state.copyWith(navigationTo: NavigationType.login),
      );
    }
  }

  void _onResetNavigation(
    _ResetNavigation event,
    Emitter<HotelDetailsState> emit,
  ) {
    emit(state.copyWith(navigationTo: null));
  }

  void _onDidPressOnBookNow(
    _DidPressOnBookNow event,
    Emitter<HotelDetailsState> emit,
  ) {
    if (_pref.loggedIn) {
      emit(state.copyWith(navigationTo: NavigationType.booking));
    } else {
      emit(state.copyWith(navigationTo: NavigationType.login));
    }
  }

  void _onDidPressOnSeeAllFacilities(
    _DidPressOnSeeAllFacilities event,
    Emitter<HotelDetailsState> emit,
  ) {
    emit(state.copyWith(navigationTo: NavigationType.facilities));
  }
}
