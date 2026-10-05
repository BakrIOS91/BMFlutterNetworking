import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_example/features/auth/account-info/bloc/account_info_bloc.dart';
import 'package:flutter_example/features/auth/account-info/view/widgets/account_info_app_bar.dart';
import 'package:flutter_example/utilities/extensions/context_extension.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:flutter_example/utilities/reusables/app_text_field.dart';
import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/theme/app_button_styles.dart';

@RoutePage()
class AccountInfoView extends StatefulWidget implements AutoRouteWrapper {
  const AccountInfoView({super.key});

  @override
  State<AccountInfoView> createState() => _AccountInfoViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AccountInfoBloc>()..add(AccountInfoEvent.started()),
      child: this,
    );
  }
}

class _AccountInfoViewState extends State<AccountInfoView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountInfoBloc, AccountInfoState>(
          listenWhen: (previous, current) =>
              previous.firstName != current.firstName,
          listener: (context, state) {
            _firstNameController.text = state.firstName;
          },
        ),
        BlocListener<AccountInfoBloc, AccountInfoState>(
          listenWhen: (previous, current) =>
              previous.lastName != current.lastName,
          listener: (context, state) {
            _lastNameController.text = state.lastName;
          },
        ),
        BlocListener<AccountInfoBloc, AccountInfoState>(
          listenWhen: (previous, current) => previous.email != current.email,
          listener: (context, state) {
            _emailController.text = state.email;
          },
        ),
        BlocListener<AccountInfoBloc, AccountInfoState>(
          listenWhen: (previous, current) => previous.phone != current.phone,
          listener: (context, state) {
            _phoneController.text = state.phone;
          },
        ),
      ],
      child: BlocBuilder<AccountInfoBloc, AccountInfoState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AccountInfoAppBar(),
            body: WithViewState(
              viewState: state.viewState,
              retryAction: () {
                context.read<AccountInfoBloc>().add(
                      const AccountInfoEvent.loadData(),
                    );
              },
              errorDisplayMode: ErrorDisplayMode.bottomSheet,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: context.scaleValue(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.scaleValue(16)),
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleValue(16)),
                          child: AppTextField(
                            label: context
                                .localization.account_info_first_name_label,
                            inputTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            enabled: state.isEditing,
                            readOnly: !state.isEditing,
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
                            textInputAction: TextInputAction.next,
                            isError: state.firstNameError,
                            errorText: state.firstNameError
                                ? context
                                    .localization.account_info_first_name_error
                                : null,
                            onChanged: (val) {
                              context.read<AccountInfoBloc>().add(
                                    AccountInfoEvent.firstNameChanged(val),
                                  );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleValue(16)),
                          child: AppTextField(
                            label: context
                                .localization.account_info_last_name_label,
                            inputTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            enabled: state.isEditing,
                            readOnly: !state.isEditing,
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            textInputAction: TextInputAction.next,
                            isError: state.lastNameError,
                            errorText: state.lastNameError
                                ? context
                                    .localization.account_info_last_name_error
                                : null,
                            onChanged: (val) {
                              context.read<AccountInfoBloc>().add(
                                    AccountInfoEvent.lastNameChanged(val),
                                  );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleValue(16)),
                          child: AppTextField(
                            label:
                                context.localization.account_info_email_label,
                            inputTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            enabled: false,
                            readOnly: true,
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: context.scaleValue(16)),
                          child: AppTextField(
                            label:
                                context.localization.account_info_phone_label,
                            inputTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            enabled: state.isEditing,
                            readOnly: !state.isEditing,
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            isError: state.phoneError,
                            errorText: state.phoneError
                                ? context.localization.account_info_phone_error
                                : null,
                            onChanged: (val) {
                              context.read<AccountInfoBloc>().add(
                                    AccountInfoEvent.phoneChanged(val),
                                  );
                            },
                          ),
                        ),
                        SizedBox(height: context.scaleValue(56)),
                        if (state.isEditing)
                          SizedBox(
                            height: context.scaleValue(56),
                            child: AppButtonStyles.primaryPlatform(
                              context: context,
                              onPressed: state.isEditing
                                  ? () => context
                                      .read<AccountInfoBloc>()
                                      .add(AccountInfoEvent.didTapSave())
                                  : null,
                              title: context.localization
                                  .account_info_save_changes_button,
                            ),
                          ),
                        SizedBox(height: context.scaleValue(48)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
