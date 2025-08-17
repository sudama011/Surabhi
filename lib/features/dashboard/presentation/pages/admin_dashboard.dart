// lib/features/dashboard/presentation/pages/admin_dashboard.dart
// lib/features/dashboard/presentation/pages/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/users/data/repositories/users_repository.dart';
import 'package:surabhi/features/users/data/datasources/users_remote_datasource.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Dashboard',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () => context.push('/admin/create-user'), child: const Text('Register User')),
              ],
            ),
            const SizedBox(height: 12),
            const Expanded(child: _UsersPager()),
          ],
        ),
      ),
    );
  }
}

class _UsersPager extends StatefulWidget {
  const _UsersPager();

  @override
  State<_UsersPager> createState() => _UsersPagerState();
}

class _UsersPagerState extends State<_UsersPager> {
  int _page = 1;
  static const int _size = 10;
  PaginatedUsers? _data;
  bool _loading = false;
  String? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = RepositoryProvider.of<UsersRepository>(context);
      final res = await repo.getUsers(page: _page, size: _size);
      setState(() {
        _data = res;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    final users = _data?.items ?? [];
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final u = users[i];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(u.email),
                subtitle: Text('Role: ${u.role}  •  2FA: ${u.is2faEnabled ? 'On' : 'Off'}'),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Page ${_data?.page ?? _page} of ${_data?.pages ?? 1}  •  Total ${_data?.total ?? 0}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: (_data?.hasPrev ?? false)
                    ? () {
                        setState(() {
                          _page--;
                        });
                        _load();
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: (_data?.hasNext ?? false)
                    ? () {
                        setState(() {
                          _page++;
                        });
                        _load();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
