part of 'tab_view.dart';

class AdaptiveTabBottomView extends StatelessWidget {
  final CupertinoTabController cupertinoTabController;

  const AdaptiveTabBottomView({
    super.key,
    required this.cupertinoTabController,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final tabs = TabContentView.allTabs;

    return BlocBuilder<TabBloc, TabState>(
      builder: (context, state) {
        final selectedIndex = state.currentSelectTabIndex;

        if (platform == TargetPlatform.iOS) {
          return CupertinoTabScaffold(
            controller: cupertinoTabController,
            tabBar: CupertinoTabBar(
              currentIndex: selectedIndex,
              activeColor: context.colors.primary800,
              inactiveColor: context.colors.gray600,
              border: Border(
                top: BorderSide(
                  color: context.colors.border,
                  width: context.scaleValue(1),
                ),
              ),
              onTap: (index) {
                context.read<TabBloc>().add(TabEvent.tabChanged(index));
              },
              items: tabs.map((tab) {
                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(
                      top: context.scaleValue(8.0),
                    ),
                    child: tab.tabIcon,
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(
                      top: context.scaleValue(8.0),
                    ),
                    child: tab.activeTabIcon,
                  ),
                  label: tab.tabTitle(context),
                );
              }).toList(),
            ),
            tabBuilder: (context, index) => tabs[index].tabView,
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: tabs.map((tab) => tab.tabView).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.read<TabBloc>().add(TabEvent.tabChanged(index));
            },
            indicatorColor: Colors.transparent,
            elevation: 2,
            labelTextStyle:
                WidgetStateProperty.resolveWith<TextStyle?>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.labelMedium(
                  context,
                  color: context.colors.primary800,
                );
              }

              return AppTextStyles.labelMedium(
                context,
                color: context.colors.gray600,
              );
            }),
            destinations: tabs.map((tab) {
              return NavigationDestination(
                icon: tab.tabIcon,
                selectedIcon: tab.activeTabIcon,
                label: tab.tabTitle(context),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
