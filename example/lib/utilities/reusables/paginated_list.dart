import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaginatedList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool shouldPaginate;
  final Future<void> Function() onPaginate;
  final Future<void> Function()? onRefresh;
  final Widget? emptyView;
  final Widget? paginateLoader;
  final ScrollController? controller;

  const PaginatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.shouldPaginate,
    required this.onPaginate,
    this.onRefresh,
    this.emptyView,
    this.paginateLoader,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    Widget scrollBody = CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (isIOS && onRefresh != null)
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
        PaginatedSliverList<T>(
          items: items,
          itemBuilder: itemBuilder,
          shouldPaginate: shouldPaginate,
          onPaginate: onPaginate,
          emptyView: emptyView,
          paginateLoader: _buildLoader(context),
        ),
      ],
    );

    if (!isIOS && onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: scrollBody,
      );
    }

    return scrollBody;
  }

  Widget _buildLoader(BuildContext context) {
    return paginateLoader ??
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

class PaginatedSliverList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool shouldPaginate;
  final Future<void> Function() onPaginate;
  final Widget? emptyView;
  final Widget? paginateLoader;
  const PaginatedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.shouldPaginate,
    required this.onPaginate,
    this.emptyView,
    this.paginateLoader,
  });

  @override
  State<PaginatedSliverList<T>> createState() => _PaginatedSliverListState<T>();
}

class _PaginatedSliverListState<T> extends State<PaginatedSliverList<T>> {
  bool _isPaginating = false;

  Future<void> _paginate() async {
    if (_isPaginating || !widget.shouldPaginate) return;
    _isPaginating = true;
    await widget.onPaginate();
    if (mounted) _isPaginating = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.shouldPaginate) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widget.emptyView ?? const SizedBox.shrink(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < widget.items.length) {
            return widget.itemBuilder(context, widget.items[index], index);
          } else if (widget.shouldPaginate) {
            return _PaginationTrigger(
              key: ValueKey(widget.items.length),
              onTrigger: _paginate,
              child: _buildLoader(context),
            );
          }
          return null;
        },
        childCount: widget.items.length + (widget.shouldPaginate ? 1 : 0),
      ),
    );
  }

  Widget _buildLoader(BuildContext context) {
    return widget.paginateLoader ??
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

class _PaginationTrigger extends StatefulWidget {
  final VoidCallback onTrigger;
  final Widget child;

  const _PaginationTrigger({
    super.key,
    required this.onTrigger,
    required this.child,
  });

  @override
  State<_PaginationTrigger> createState() => _PaginationTriggerState();
}

class _PaginationTriggerState extends State<_PaginationTrigger> {
  @override
  void initState() {
    super.initState();
    // Trigger on the first frame when the widget is built/inserted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // Add a small delay to prevent eager consecutive requests
        // and allow the user to see the loader.
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          widget.onTrigger();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
