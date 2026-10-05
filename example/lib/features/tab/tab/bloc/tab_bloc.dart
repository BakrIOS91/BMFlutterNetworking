import 'package:bloc/bloc.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/features/tab/tab/model/tab_content_view.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'tab_bloc.freezed.dart';
part 'tab_event.dart';
part 'tab_state.dart';

@injectable
class TabBloc extends Bloc<TabEvent, TabState> {
  final AppPreferences pref;
  TabBloc({required this.pref}) : super(TabState.initial()) {
    on<TabEvent>(_onEvent);
  }

  Future<void> _onEvent(
    TabEvent event,
    Emitter<TabState> emit,
  ) async {
    await event.map(
      started: (_) async {},
      tabChanged: (e) async {
        if (state.currentSelectTabIndex == e.indx) return;
        final tab = TabContentView.allTabs[e.indx];
        pref.selectedTab = tab;
        emit(state.copyWith(currentSelectTabIndex: e.indx));
      },
    );
  }
}
