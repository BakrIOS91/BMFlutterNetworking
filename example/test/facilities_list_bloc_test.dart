import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/features/hotel_details/childs/facilities_list/bloc/facilities_list_bloc.dart';
import 'package:flutter_example/services/models/hotels/hotel_model.dart';

void main() {
  group('FacilitiesListBloc', () {
    late List<Facility> mockFacilities;

    setUp(() {
      mockFacilities = [
        Facility(categoryId: 1, categoryTitle: 'Category 1'),
        Facility(categoryId: 2, categoryTitle: 'Category 2'),
      ];
    });

    test('initial state is correct', () {
      final bloc = FacilitiesListBloc(mockFacilities);
      expect(bloc.state.facilities, equals(mockFacilities));
      expect(bloc.state.expandedIndices, isEmpty);
      bloc.close();
    });

    blocTest<FacilitiesListBloc, FacilitiesListState>(
      'emits correct state when _ToggleExpansion adds an index',
      build: () => FacilitiesListBloc(mockFacilities),
      act: (bloc) => bloc.add(const FacilitiesListEvent.toggleExpansion(1)),
      expect: () => [
        FacilitiesListState(facilities: mockFacilities, expandedIndices: {1}),
      ],
    );

    blocTest<FacilitiesListBloc, FacilitiesListState>(
      'emits correct state when _ToggleExpansion removes an existing index',
      build: () => FacilitiesListBloc(mockFacilities),
      seed: () => FacilitiesListState(
        facilities: mockFacilities,
        expandedIndices: {1, 2},
      ),
      act: (bloc) => bloc.add(const FacilitiesListEvent.toggleExpansion(1)),
      expect: () => [
        FacilitiesListState(facilities: mockFacilities, expandedIndices: {2}),
      ],
    );
  });
}
