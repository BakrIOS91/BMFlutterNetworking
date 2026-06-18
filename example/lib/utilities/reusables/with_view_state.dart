import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/router/app_router.dart';
import 'package:flutter_example/core/router/app_router.gr.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/app_error_view.dart';
import 'package:flutter_example/services/models/response_error.dart';
import 'package:bm_flutter/core.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

/// Display mode for error states
enum ErrorDisplayMode {
  /// Replace content with error view (default)
  replace,

  /// Show error as bottom sheet, keeping content visible
  bottomSheet,
}

/// Flutter equivalent of SwiftUI's `WithViewState`
///
/// Wraps content and automatically displays loaders, overlays,
/// and error views based on the provided [viewState].
class WithViewState extends StatefulWidget {
  final ViewState viewState;
  final bool isRefreshable;
  final VoidCallback retryAction;
  final Widget child;
  final ErrorDisplayMode errorDisplayMode;

  const WithViewState({
    super.key,
    required this.viewState,
    required this.child,
    this.isRefreshable = false,
    this.retryAction = _emptyCallback,
    this.errorDisplayMode = ErrorDisplayMode.replace,
  });

  static void _emptyCallback() {}

  /// Maps an [APIError] to the appropriate [ViewState] error variant.
  ///
  /// Use in BLoC failure handlers:
  /// ```dart
  /// emit(state.copyWith(viewState: WithViewState.failHandler(error)));
  /// ```
  static ViewState failHandler(dynamic error) {
    if (error is! APIError) return UnexpectedError(errorModel: error);
    switch (error.type) {
      case APIErrorType.noNetwork:
        return NoNetwork(errorModel: error);
      case APIErrorType.httpError:
        if (error.statusCode == HTTPStatusCode.notAuthorize) {
          return Unauthorized(errorModel: error);
        }
        return ServerError(errorModel: error);
      default:
        return UnexpectedError(errorModel: error);
    }
  }

  @override
  State<WithViewState> createState() => _WithViewStateState();
}

class _WithViewStateState extends State<WithViewState> {
  bool _isBottomSheetOpen = false;

  /// Track last shown error TYPE (not instance)
  Type? _lastShownErrorType;

  final AppRouter _router = getIt<AppRouter>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowBottomSheet(widget.viewState);
    });
  }

  @override
  void didUpdateWidget(WithViewState oldWidget) {
    super.didUpdateWidget(oldWidget);

    _maybeShowBottomSheet(widget.viewState);
  }

  void _maybeShowBottomSheet(ViewState state) {
    final isError = _isErrorState(state);

    // Reset when leaving error state
    if (!isError) {
      _lastShownErrorType = null;
      return;
    }

    final currentType = state.runtimeType;

    if (widget.errorDisplayMode == ErrorDisplayMode.bottomSheet &&
        !_isBottomSheetOpen &&
        currentType != _lastShownErrorType) {
      _lastShownErrorType = currentType;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorBottomSheet(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildContent(),
        if (widget.viewState is OverlayLoading)
          _buildLoaderOverlay(
            context,
            backgroundColor: (widget.viewState as OverlayLoading).color,
          ),
        if (widget.errorDisplayMode == ErrorDisplayMode.replace ||
            !_isErrorState(widget.viewState))
          _buildStateView(context),
      ],
    );
  }

  Widget _buildContent() {
    final showContent = !(widget.errorDisplayMode == ErrorDisplayMode.replace &&
        _isErrorState(widget.viewState));

    Widget content = widget.child;

    if (widget.isRefreshable) {
      content = RefreshIndicator.adaptive(
        onRefresh: () async => widget.retryAction(),
        child: widget.child,
      );
    }

    return Visibility(
      visible: showContent,
      maintainState: true,
      child: content,
    );
  }

  Widget _buildStateView(BuildContext context) {
    switch (widget.viewState) {
      case Loading():
        return _buildLoaderOverlay(context);

      case OverlayLoading(color: final color):
        return _buildLoaderOverlay(context, backgroundColor: color);

      default:
        if (_isErrorState(widget.viewState)) {
          return _buildErrorView(context) ?? const SizedBox.shrink();
        }
        return const SizedBox.shrink();
    }
  }

  bool _isErrorState(ViewState state) {
    return state is NoNetwork ||
        state is CustomErrorState ||
        state is NoData ||
        state is ServerError ||
        state is SearchError ||
        state is UnexpectedError ||
        state is Unauthorized ||
        state is ForceUpdateError ||
        state is JailBroken;
  }

  void _showErrorBottomSheet(BuildContext context) {
    if (!_isErrorState(widget.viewState) || !mounted || _isBottomSheetOpen) {
      return;
    }

    final errorView = _buildErrorView(context);
    if (errorView == null) return;

    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.gray0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Wrap(
          children: [errorView],
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        _isBottomSheetOpen = false;
      }
    });
  }

  Widget? _buildErrorView(BuildContext context) {
    switch (widget.viewState) {
      case NoNetwork():
        return AppErrorView(
          title: context.localization.noNetworkErrorTitle,
          message: context.localization.noNetworkErrorMessage,
          image: Image.asset(
            context.imageConstants.errorNoNetwork,
            width: context.scaleValue(100),
          ),
          mainActionTitle: context.localization.commonRetry,
          onMainAction: widget.retryAction,
        );

      case CustomErrorState(
          title: final title,
          message: final message,
          image: final image,
          buttonText: final buttonText,
          onPressed: final onPressed,
          secondaryButtonText: final secondaryButtonText,
          onSecondaryPressed: final onSecondaryPressed
        ):
        return AppErrorView(
          image: Image.asset(
            image ?? context.imageConstants.errorUnExpected,
            width: context.scaleValue(100),
          ),
          title: title ?? "",
          message: message ?? "",
          mainActionTitle: buttonText,
          onMainAction: onPressed,
          secondaryActionTitle: secondaryButtonText,
          onSecondaryAction: onSecondaryPressed,
        );

      case NoData():
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorNoData,
            width: context.scaleValue(100),
          ),
          title: context.localization.noDataErrorTitle,
          message: context.localization.noDataErrorMessage,
        );

      case ServerError(errorModel: final errorModel):
        final serverMessage = _serverMessage(errorModel);
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorServer,
            width: context.scaleValue(100),
          ),
          title: context.localization.serverErrorTitle,
          message: (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : context.localization.serverErrorMessage,
          mainActionTitle: context.localization.commonRetry,
          onMainAction: widget.retryAction,
        );

      case SearchError(errorModel: final errorModel):
        final serverMessage = _serverMessage(errorModel);
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorUnExpected,
            width: context.scaleValue(100),
          ),
          title: context.localization.unexpectedErrorTitle,
          message: (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : context.localization.unexpectedErrorMessage,
          mainActionTitle: context.localization.commonRetry,
          onMainAction: widget.retryAction,
        );

      case UnexpectedError(errorModel: final errorModel):
        final serverMessage = _serverMessage(errorModel);
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorUnExpected,
            width: context.scaleValue(100),
          ),
          title: context.localization.unexpectedErrorTitle,
          message: (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : context.localization.unexpectedErrorMessage,
          mainActionTitle: context.localization.commonRetry,
          onMainAction: widget.retryAction,
        );

      case Unauthorized(errorModel: final errorModel):
        final serverMessage = _serverMessage(errorModel);
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorUnExpected,
            width: context.scaleValue(100),
          ),
          title: context.localization.unauthorizedErrorTitle,
          message: (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : context.localization.unauthorizedErrorMessage,
          mainActionTitle: context.localization.login_view_login_button,
          onMainAction: () {
            _router.push(const LoginRoute());
          },
        );

      case ForceUpdateError(errorModel: final errorModel):
        final serverMessage = _serverMessage(errorModel);
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.errorUpdate,
            width: context.scaleValue(100),
          ),
          title: context.localization.updateRequiredErrorTitle,
          message: (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : context.localization.updateRequiredErrorMessage,
          mainActionTitle: context.localization.commonUpdate,
          onMainAction: widget.retryAction,
        );

      case JailBroken():
        return AppErrorView(
          image: Image.asset(
            context.imageConstants.jailbreak,
            width: context.scaleValue(100),
            color: context.colors.primary500,
          ),
          title: context.localization.jailbreakErrorTitle,
          message: context.localization.jailbreakErrorMessage,
          mainActionTitle: context.localization.commonExit,
          onMainAction: () => exit(0),
        );

      default:
        return null;
    }
  }

  String? _serverMessage(dynamic raw) =>
      (raw as APIError?)?.errorModelAs<ResponseError>()?.msg;

  Widget _buildLoaderOverlay(
    BuildContext context, {
    Color? backgroundColor,
  }) {
    return IgnorePointer(
      ignoring: false,
      child: Container(
        color: backgroundColor ?? Colors.transparent,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
