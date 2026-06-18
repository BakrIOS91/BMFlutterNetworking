import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_example/services/client/auth_client.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/core/location_services/location_manager.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart'
    as lookups;

part 'home_bloc.freezed.dart';

part 'home_event.dart';

part 'home_state.dart';

@Injectable()
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HotelClient _hotelClient;
  final AuthClient _authClient;
  final AppPreferences _appPreferences;
  final LocationManager _locationManager;

  HomeBloc(
    this._hotelClient,
    this._authClient,
    this._appPreferences,
    this._locationManager,
  ) : super(HomeState.initial()) {
    on<_Started>(_onStarted);
    on<_Refresh>(_onRefresh);
    on<_RequestPopularHotels>(_onRequestPopularHotels);
    on<_PopularHotelsResponse>(_onPopularHotelsResponse);
    on<_RequestRecommendedHotels>(_onRequestRecommendedHotels);
    on<_RecommendedHotelsResponse>(_onRecommendedHotelsResponse);
    on<_SelectCategory>(_onSelectCategory);
    on<_RequestToggleFavorite>(_onRequestToggleFavorite);
    on<_UpdateUserLocation>(_onUpdateUserLocation);
    on<_Logout>(_onLogout);
    on<_ProfileUpdated>(_onProfileUpdated);
  }

  void _onProfileUpdated(
    _ProfileUpdated event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        name: _appPreferences.userProfile?.fullName ?? '',
        avatarUrl: _appPreferences.userProfile?.avatarUrl ?? '',
      ),
    );
  }

  Future<void> refreshHomeData() {
    add(const HomeEvent.refresh());
    return stream
        .skipWhile((s) => s.viewState != ViewState.loading)
        .firstWhere((s) => s.viewState != ViewState.loading);
  }

  Future<void> paginateRecommended() {
    add(const HomeEvent.requestRecommendedHotels(page: AtPage.next));
    return stream
        .skipWhile((s) => !s.isRecommendedPaginating)
        .firstWhere((s) => !s.isRecommendedPaginating);
  }

  // ─────────────────────────────────────────────
  // Startup
  // ─────────────────────────────────────────────

  Future<void> _onStarted(_Started event, Emitter<HomeState> emit) async {
    // Restore cached data so state is ready before any network call
    emit(state.copyWith(
      isInitializing:
          true, // Mark that we are in the primary initial load phase
      isLoggedIn: _appPreferences.loggedIn,
      categories: _appPreferences.lookups?.hotelCategories ?? [],
      name: _appPreferences.userProfile?.fullName ?? '',
      avatarUrl: _appPreferences.userProfile?.avatarUrl ?? '',
    ));

    // Fetch location silently in the background — never blocks the screen
    _fetchLocation();

    // Fetch all primary data in parallel, then reveal the screen together
    await _fetchInitialData(emit, isInitial: true);
  }

  void _fetchLocation() {
    _locationManager.getCurrentLocationString().then((location) {
      if (location != null) add(HomeEvent.updateUserLocation(location));
    });
  }

  /// Fetches popular hotels and (if logged in) profile + recommended in parallel.
  /// viewState stays loading until everything is done, so the screen reveals cleanly.
  Future<void> _fetchInitialData(Emitter<HomeState> emit,
      {bool isInitial = false}) async {
    try {
      final results = await Future.wait([
        _hotelClient.getPopularHotels(
          PopularHotelsRequest(
            lang: _appPreferences.currentLanguage,
            pageIndex: 1,
            pageSize: 3,
          ),
        ),
        if (state.isLoggedIn) _authClient.getProfile(),
        if (state.isLoggedIn) _fetchRecommendedHotels(),
      ]);

      final popularResult = results[0] as Result<Hotels?, APIError>;

      ViewState popularViewState = ViewState.loaded;
      Hotels? popularHotels;

      popularResult.when(
        success: (data) {
          if (data?.hotels != null) {
            popularHotels = data;
          } else {
            emit(state.copyWith(popularViewState: ViewState.noData));
          }
        },
        failure: (error) {
          popularViewState = WithViewState.failHandler(error);
        },
      );

      String name = state.name;
      String avatarUrl = state.avatarUrl;
      ViewState recommendedViewState = ViewState.loaded;
      List<Hotel> recommendedProperties = [];

      bool recommendedShouldPaginate = false;
      if (state.isLoggedIn && results.length >= 3) {
        final profileResult = results[1] as Result<Profile?, APIError>;
        final recommendedResult = results[2] as Result<Hotels?, APIError>;

        profileResult.when(
          success: (profile) {
            name = profile?.fullName ?? '';
            avatarUrl = profile?.avatarUrl ?? '';
            _appPreferences.userProfile = profile;
          },
          failure: (_) {},
        );

        recommendedResult.when(
          success: (data) {
            recommendedProperties = data?.hotels ?? [];
            recommendedShouldPaginate =
                data?.pagination?.shouldPaginate ?? false;
          },
          failure: (error) =>
              recommendedViewState = WithViewState.failHandler(error),
        );
      }

      emit(state.copyWith(
        isInitializing: false,
        viewState: popularViewState,
        popularViewState: popularViewState,
        popularProperties: popularHotels?.hotels ?? [],
        shouldPaginate: popularHotels?.pagination?.shouldPaginate ?? false,
        recommendedViewState: recommendedViewState,
        recommendedProperties: recommendedProperties,
        recommendedPageIndex: 1,
        recommendedShouldPaginate: recommendedShouldPaginate,
        name: name,
        avatarUrl: avatarUrl,
      ));
    } catch (_) {
      emit(state.copyWith(
        isInitializing: false,
        viewState: ViewState.unexpectedError,
      ));
    }
  }

  /// Builds the recommended hotels request using current category selection.
  Future<Result<Hotels?, APIError>> _fetchRecommendedHotels(
      {int pageIndex = 1}) {
    final categoryId = state.categories.isNotEmpty
        ? (state.categories[state.selectedCategoryIndex].id)
        : null;
    final catId = categoryId == 0 ? null : categoryId;
    return _hotelClient.filterHotels(FilterHotelsRequest(
      lang: _appPreferences.currentLanguage,
      catId: catId,
      pageIndex: pageIndex,
      pageSize: 4,
    ));
  }

  // ─────────────────────────────────────────────
  // Pull-to-refresh
  // ─────────────────────────────────────────────

  Future<void> _onRefresh(_Refresh event, Emitter<HomeState> emit) async {
    emit(state.copyWith(viewState: ViewState.loading));
    await _fetchInitialData(emit);
  }

  // ─────────────────────────────────────────────
  // Popular hotels
  // ─────────────────────────────────────────────

  Future<void> _onRequestPopularHotels(
      _RequestPopularHotels event, Emitter<HomeState> emit) async {
    emit(state.copyWith(popularViewState: ViewState.loading));
    final request = PopularHotelsRequest(
      lang: _appPreferences.currentLanguage,
      pageIndex: 1,
      pageSize: 3,
    );
    final result = await _hotelClient.getPopularHotels(request);
    add(HomeEvent.popularHotelsResponse(result));
  }

  Future<void> _onPopularHotelsResponse(
      _PopularHotelsResponse event, Emitter<HomeState> emit) async {
    event.result.when(
      success: (data) => emit(
        state.copyWith(
          popularViewState: ViewState.loaded,
          popularProperties: data?.hotels ?? [],
          shouldPaginate: data?.pagination?.shouldPaginate ?? false,
        ),
      ),
      failure: (error) => emit(state.copyWith(
        popularViewState: WithViewState.failHandler(error),
      )),
    );
  }

  // ─────────────────────────────────────────────
  // Recommended hotels
  // ─────────────────────────────────────────────

  Future<void> _onRequestRecommendedHotels(
      _RequestRecommendedHotels event, Emitter<HomeState> emit) async {
    if (!state.isLoggedIn || state.categories.isEmpty) return;

    if (event.page == AtPage.first) {
      emit(state.copyWith(
        recommendedViewState: ViewState.loading,
        recommendedProperties: [],
        recommendedPageIndex: 1,
        recommendedShouldPaginate: false,
      ));
    } else {
      emit(state.copyWith(
        isRecommendedPaginating: true,
        recommendedPageIndex: state.recommendedPageIndex + 1,
      ));
    }

    final result = await _fetchRecommendedHotels(
      pageIndex: event.page == AtPage.first ? 1 : state.recommendedPageIndex,
    );
    add(HomeEvent.recommendedHotelsResponse(result));
  }

  Future<void> _onRecommendedHotelsResponse(
      _RecommendedHotelsResponse event, Emitter<HomeState> emit) async {
    event.result.when(
      success: (data) {
        final newHotels = data?.hotels ?? [];
        emit(state.copyWith(
          recommendedViewState: ViewState.loaded,
          recommendedProperties: [
            ...state.recommendedProperties,
            ...newHotels,
          ],
          recommendedShouldPaginate: data?.pagination?.shouldPaginate ?? false,
          isRecommendedPaginating: false,
        ));
      },
      failure: (error) => emit(state.copyWith(
        recommendedViewState: WithViewState.failHandler(error),
        isRecommendedPaginating: false,
      )),
    );
  }

  // ─────────────────────────────────────────────
  // Category selection
  // ─────────────────────────────────────────────

  Future<void> _onSelectCategory(
      _SelectCategory event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selectedCategoryIndex: event.index));
    add(const HomeEvent.requestRecommendedHotels());
  }

  // ─────────────────────────────────────────────
  // Toggle favorite
  // ─────────────────────────────────────────────

  Future<void> _onRequestToggleFavorite(
      _RequestToggleFavorite event, Emitter<HomeState> emit) async {
    final hotel = event.hotel;
    final newFavoriteStatus = !(hotel.isFavorite ?? false);

    // 1. Optimistically update UI immediately
    emit(state.copyWith(
      popularProperties: _toggleFavoriteInList(
          state.popularProperties, hotel, newFavoriteStatus),
      recommendedProperties: _toggleFavoriteInList(
          state.recommendedProperties, hotel, newFavoriteStatus),
    ));

    // 2. Send request in background
    final result = await _hotelClient.toggleFavoriteHotel(hotel.id.toString());

    // 3. Revert on failure
    result.when(
      success: (_) {}, // already updated optimistically
      failure: (_) => emit(state.copyWith(
        popularProperties: _toggleFavoriteInList(
            state.popularProperties, hotel, !newFavoriteStatus),
        recommendedProperties: _toggleFavoriteInList(
            state.recommendedProperties, hotel, !newFavoriteStatus),
      )),
    );
  }

  List<Hotel> _toggleFavoriteInList(
      List<Hotel> hotels, Hotel target, bool isFavorite) {
    return hotels.map((hotel) {
      return hotel.id == target.id
          ? hotel.copyWith(isFavorite: isFavorite)
          : hotel;
    }).toList();
  }

  // ─────────────────────────────────────────────
  // Location / Logout
  // ─────────────────────────────────────────────

  Future<void> _onUpdateUserLocation(
      _UpdateUserLocation event, Emitter<HomeState> emit) async {
    emit(state.copyWith(location: event.location));
  }

  Future<void> _onLogout(_Logout event, Emitter<HomeState> emit) async {
    // 1. Clear session preferences
    _appPreferences.loggedIn = false;
    _appPreferences.userProfile = null;
    _appPreferences.userAccessTokens = null;

    // 2. Clear user-specific state
    emit(state.copyWith(
      isLoggedIn: false,
      name: '',
      avatarUrl: '',
      recommendedProperties: [], // Recommended hotels are usually user-specific
      // Map popular properties to clear their favorite status immediately
      popularProperties: state.popularProperties
          .map((h) => h.copyWith(isFavorite: false))
          .toList(),
    ));

    // 3. Refresh data as a guest to get the latest public content
    await _fetchInitialData(emit);
  }
}
