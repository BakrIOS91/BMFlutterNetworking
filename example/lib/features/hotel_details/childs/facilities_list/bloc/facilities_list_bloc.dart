import 'package:bloc/bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'facilities_list_bloc.freezed.dart';
part 'facilities_list_event.dart';
part 'facilities_list_state.dart';

@injectable
class FacilitiesListBloc
    extends Bloc<FacilitiesListEvent, FacilitiesListState> {
  final List<Facility> facilities;
  FacilitiesListBloc(@factoryParam this.facilities)
      : super(FacilitiesListState.initial(facilities)) {
    on<_Started>(_onStarted);
    on<_ToggleExpansion>(_onToggleExpansion);
  }

  // MARK: - Starter Event
  void _onStarted(
    _Started event,
    Emitter<FacilitiesListState> emit,
  ) {}

  void _onToggleExpansion(
    _ToggleExpansion event,
    Emitter<FacilitiesListState> emit,
  ) {
    final expandedIndices = Set<int>.from(state.expandedIndices);
    if (expandedIndices.contains(event.index)) {
      expandedIndices.remove(event.index);
    } else {
      expandedIndices.add(event.index);
    }
    emit(state.copyWith(expandedIndices: expandedIndices));
  }
}
