// lib/features/admin/users/presentation/pages/users_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/widgets/user_card.dart';
import 'package:surabhi/core/widgets/error_display.dart';
import 'package:surabhi/features/admin/users/domain/entities/register_user_entity.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';
import 'package:surabhi/features/admin/users/presentation/pages/user_details_page.dart';
import 'package:surabhi/features/auth/domain/entities/user_entity.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when user scrolls near the bottom (80% of scroll)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<UsersBloc>().state;
      if (state is UsersLoaded && state.hasMoreData && state is! UsersLoadingMore) {
        context.read<UsersBloc>().add(const LoadMoreUsersEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersInitial) {
            context.read<UsersBloc>().add(const GetUsersEvent());
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            return _buildUsersList(state.users, state.hasMoreData);
          } else if (state is UsersLoadingMore) {
            return _buildUsersList(state.users, state.hasMoreData);
          } else if (state is UsersError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () => context.read<UsersBloc>().add(const GetUsersEvent()),
              icon: Icons.people_outline,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUsersList(List<RegisterUserEntity> users, bool hasMoreData) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: users.length + (hasMoreData ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        // Show loading indicator at the end if there's more data
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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserDetailsPage(user: user)));
          },
        );
      },
    );
  }
}
