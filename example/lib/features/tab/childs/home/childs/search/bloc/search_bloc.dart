import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';

part 'search_event.dart';
part 'search_state.dart';
part 'search_bloc.freezed.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final HotelClient _hotelClient;
  final AppPreferences _appPreferences;

  SearchBloc(
    this._hotelClient,
    this._appPreferences,
  ) : super(SearchState.initial()) {
    on<_Started>(_onStarted);
    on<_RequestSearch>(_onSearchRequested);
    on<_SearchResponse>(_onSearchResponse);
    on<_DidTapToggleFavorite>(_onDidTapToggleFavorite);
    on<_FilterViewToggled>(_onFilterViewToggled);
    on<_FilterIsDismissed>(_onFilterIsDismissed);
    on<_QueryChanged>(_onQueryChanged);
    on<_ClearSearch>(_onClearSearch);
  }

  Future<void> refresh() {
    add(const SearchEvent.requestSearch(page: AtPage.first));
    return stream
        .skipWhile((s) => s.viewState != ViewState.loading)
        .firstWhere((s) => s.viewState != ViewState.loading);
  }

  Future<void> paginate() {
    add(const SearchEvent.requestSearch(page: AtPage.next));
    return stream
        .skipWhile((s) => !s.isPaginating)
        .firstWhere((s) => !s.isPaginating);
  }

  Future<void> _onStarted(_Started event, Emitter<SearchState> emit) async {
    emit(state.copyWith(isLoggedIn: _appPreferences.loggedIn));
    add(SearchEvent.requestSearch());
  }

  Future<void> _onClearSearch(
      _ClearSearch event, Emitter<SearchState> emit) async {
    emit(state.copyWith(query: "", viewState: ViewState.loading));
    add(SearchEvent.requestSearch());
  }

  Future<void> _onQueryChanged(
      _QueryChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSearchRequested(
      _RequestSearch event, Emitter<SearchState> emit) async {
    if (event.page == AtPage.first) {
      emit(state.copyWith(
        viewState: ViewState.loading,
        searchResults: [],
        pageIndex: 1,
        shouldPaginate: false,
      ));
    } else {
      emit(state.copyWith(
        isPaginating: true,
        pageIndex: state.pageIndex + 1,
      ));
    }

    final request = state.lastFilterRequest != null
        ? state.lastFilterRequest?.copyWith(
            searchText: state.query,
            lang: _appPreferences.currentLanguage,
            pageIndex: state.pageIndex,
            pageSize: 10,
          )
        : FilterHotelsRequest(
            searchText: state.query,
            lang: _appPreferences.currentLanguage,
            pageIndex: state.pageIndex,
            pageSize: 10,
          );

    final result = await _hotelClient.filterHotels(request!);

    add(SearchEvent.searchResponse(result));
  }

  Future<void> _onSearchResponse(
      _SearchResponse event, Emitter<SearchState> emit) async {
    event.result.when(
      success: (data) {
        final newHotels = data?.hotels ?? [];
        emit(state.copyWith(
          viewState: (state.searchResults.isEmpty && newHotels.isEmpty)
              ? ViewState.noData
              : ViewState.loaded,
          searchResults: [
            ...state.searchResults,
            ...newHotels,
          ],
          shouldPaginate: data?.pagination?.shouldPaginate ?? false,
          isPaginating: false,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          viewState: WithViewState.failHandler(error),
          isPaginating: false,
        ));
      },
    );
  }

  Future<void> _onDidTapToggleFavorite(
      _DidTapToggleFavorite event, Emitter<SearchState> emit) async {
    final hotel = event.hotel;
    final hotelId = hotel.id;
    if (hotelId == null) return;

    final result = await _hotelClient.toggleFavoriteHotel(hotelId.toString());

    result.when(
      success: (_) {
        final currentIsFavorite = hotel.isFavorite ?? false;
        final updatedItems = state.searchResults.map<Hotel>((p) {
          if (p.id == hotelId) {
            return p.copyWith(isFavorite: !currentIsFavorite);
          }
          return p;
        }).toList();
        emit(state.copyWith(
          searchResults: updatedItems,
        ));
      },
      failure: (error) {
        emit(state.copyWith(
          viewState: WithViewState.failHandler(error),
        ));
      },
    );
  }

  Future<void> _onFilterViewToggled(
      _FilterViewToggled event, Emitter<SearchState> emit) async {
    emit(state.copyWith(showFilerView: event.show));
  }

  Future<void> _onFilterIsDismissed(
      _FilterIsDismissed event, Emitter<SearchState> emit) async {
    emit(state.copyWith(showFilerView: false));
    if (event.request != null) {
      emit(state.copyWith(
        lastFilterRequest: event.request,
        viewState: ViewState.loading,
      ));

      final result = await _hotelClient.filterHotels(
        event.request!.copyWith(
          lang: _appPreferences.currentLanguage,
          searchText: state.query,
        ),
      );
      add(SearchEvent.searchResponse(result));
    }
  }
}
