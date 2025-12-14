import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/widgets/user_card.dart';
import 'package:surabhi/core/widgets/error_display.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';
import 'package:surabhi/features/admin/users/presentation/pages/user_details_page.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Trigger initial load here, not in build
    // Using addPostFrameCallback ensures context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersBloc>().add(const GetUsersEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final usersBloc = context.read<UsersBloc>();
      // Only load more if currently loaded and has more data
      if (usersBloc.state.status == UsersStatus.loaded && usersBloc.state.hasMoreData) {
        usersBloc.add(const LoadMoreUsersEvent());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.8); // Load when 80% down
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Management')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<UsersBloc>().add(const GetUsersEvent());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              switch (state.status) {
                case UsersStatus.loading:
                  return const Center(child: CircularProgressIndicator());

                case UsersStatus.error:
                  return Center(
                    child: ErrorDisplay(
                      message: state.errorMessage,
                      onRetry: () => context.read<UsersBloc>().add(const GetUsersEvent()),
                      icon: Icons.people_outline,
                    ),
                  );

                case UsersStatus.loaded:
                case UsersStatus.initial: // Fallthrough to list if initial (usually empty)
                  return _buildUsersList(state.users, state.hasMoreData);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(List<RegisteredUserModel> users, bool hasMoreData) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(), // Ensures RefreshIndicator works even if list is short
      itemCount: users.length + (hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == users.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = users[index];
        return UserCard(
          user: user,
          onTap: () {
            // Pass the EXISTING bloc to the new screen so it can update the list (e.g. after delete)
            final usersBloc = context.read<UsersBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: usersBloc,
                  child: UserDetailsPage(user: user),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
