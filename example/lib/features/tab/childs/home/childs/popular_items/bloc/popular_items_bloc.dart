import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/models/hotels/hotel_requests.dart';
import 'package:flutter_example/utilities/constants/app_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/services/client/hotel_client.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

part 'popular_items_event.dart';
part 'popular_items_state.dart';
part 'popular_items_bloc.freezed.dart';

@Injectable()
class PopularItemsBloc extends Bloc<PopularItemsEvent, PopularItemsState> {
  final HotelClient _hotelClient;
  final AppPreferences _appPreferences;

  PopularItemsBloc(this._hotelClient, this._appPreferences)
      : super(PopularItemsState.initial()) {
    on<_Started>(_onStarted);
    on<_RequestPopularItems>(_onRequestPopularItems);
    on<_ItemsResponse>(_onItemsResponse);
    on<_DidTapToggleFavorite>(_onDidTapToggleFavorite);
  }

  Future<void> refresh() {
    add(const PopularItemsEvent.requestPopularItems(AtPage.first));
    return stream
        .skipWhile((s) => s.viewState != ViewState.loading)
        .firstWhere((s) => s.viewState != ViewState.loading);
  }

  Future<void> paginate() {
    add(const PopularItemsEvent.requestPopularItems(AtPage.next));
    return stream.skipWhile((s) => !s.isPaginating).firstWhere((s) => !s.isPaginating);
  }

  Future<void> _onStarted(
      _Started event, Emitter<PopularItemsState> emit) async {
    emit(state.copyWith(
        currentLanguage: _appPreferences.currentLanguage,
        isLoggedIn: _appPreferences.loggedIn));
    add(const PopularItemsEvent.requestPopularItems(AtPage.first));
  }

  Future<void> _onRequestPopularItems(
    _RequestPopularItems event,
    Emitter<PopularItemsState> emit,
  ) async {
    switch (event.page) {
      case AtPage.first:
        emit(
          state.copyWith(
            viewState: ViewState.loading,
            pageIndex: 1,
            items: [],
            shouldPaginate: false,
          ),
        );
      case AtPage.next:
        emit(state.copyWith(pageIndex: state.pageIndex + 1, isPaginating: true));
        break;
    }

    final request = PopularHotelsRequest(
      lang: _appPreferences.currentLanguage,
      pageIndex: event.page == AtPage.first ? 1 : state.pageIndex,
      pageSize: 4,
    );

    add(
      PopularItemsEvent.itemsResponse(
        await _hotelClient.getPopularHotels(request),
      ),
    );
  }

  Future<void> _onItemsResponse(
      _ItemsResponse event, Emitter<PopularItemsState> emit) async {
    event.result.when(
      success: (data) {
        emit(state.copyWith(
          viewState: ViewState.loaded,
          items: [
            ...state.items,
            ...?data?.hotels,
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
      _DidTapToggleFavorite event, Emitter<PopularItemsState> emit) async {
    final hotel = event.hotel;
    emit(state.copyWith(viewState: ViewState.loading));

    final result = await _hotelClient.toggleFavoriteHotel(hotel.id.toString());

    result.when(
      success: (_) {
        final currentIsFavorite = hotel.isFavorite ?? false;
        final updatedItems = state.items.map<Hotel>((p) {
          if (p.id == hotel.id) {
            return p.copyWith(isFavorite: !currentIsFavorite);
          }
          return p;
        }).toList();
        emit(state.copyWith(viewState: ViewState.loaded, items: updatedItems));
      },
      failure: (error) {
        emit(state.copyWith(viewState: WithViewState.failHandler(error)));
      },
    );
  }
}
