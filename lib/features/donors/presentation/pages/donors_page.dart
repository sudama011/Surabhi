// lib/features/donors/presentation/pages/donors_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/donors/models/donor_model.dart';
import 'package:surabhi/features/donors/presentation/bloc/donors_bloc.dart';

class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});

  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Trigger initial load
    context.read<DonorsBloc>().add(const SearchDonorsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<DonorsBloc>().add(const LoadMoreDonorsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<DonorsBloc>().add(SearchDonorsEvent(searchText: query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          _SearchBar(controller: _searchController, onChanged: _onSearchChanged),
          // Patron mode toggle
          const _PatronModeToggle(),
          // Donor list
          Expanded(
            child: BlocBuilder<DonorsBloc, DonorsState>(
              builder: (context, state) {
                if (state.status == DonorsStatus.loading || state.status == DonorsStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == DonorsStatus.error && state.donors.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage,
                    onRetry: () =>
                        context.read<DonorsBloc>().add(SearchDonorsEvent(searchText: _searchController.text)),
                  );
                }

                if (state.donors.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DonorsBloc>().add(SearchDonorsEvent(searchText: _searchController.text));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: state.donors.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.donors.length) {
                        return _buildBottomWidget(state);
                      }
                      return _DonorCard(donor: state.donors[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Donor screen
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Donor - Coming soon')));
        },
        backgroundColor: AppColors.successColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomWidget(DonorsState state) {
    if (state.hasReachedLimit) {
      return const _LimitReachedMessage();
    }
    if (state.hasReachedMax) {
      return const SizedBox.shrink();
    }
    if (state.status == DonorsStatus.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }
}

// --- Search Bar ---
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Mobile Number/ Donor Name/ Donor ID',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          filled: true,
          fillColor: AppColors.accentColor.withValues(alpha: 0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// --- Patron Mode Toggle ---
class _PatronModeToggle extends StatelessWidget {
  const _PatronModeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonorsBloc, DonorsState>(
      buildWhen: (previous, current) => previous.isPatronMode != current.isPatronMode,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Patron Mode', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Switch(
                value: state.isPatronMode,
                onChanged: (_) {
                  context.read<DonorsBloc>().add(const TogglePatronModeEvent());
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Donor Card ---
class _DonorCard extends StatelessWidget {
  final DonorModel donor;

  const _DonorCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primaryColor.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Patron/Donor ID + Donor ID
                  Row(
                    children: [
                      if (donor.patronId != null && donor.patronId!.isNotEmpty)
                        Expanded(
                          child: Text(
                            donor.patronId!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      Text(
                        donor.donorId,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.errorColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Donor Name
                  Text(
                    donor.donorName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  if (donor.emailId != null && donor.emailId!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            donor.emailId!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  // Phone
                  if (donor.mobileNumber != null && donor.mobileNumber!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          donor.mobileNumber!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  // Total Amount
                  Text(
                    donor.formattedAmount,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.successColor),
                  ),
                ],
              ),
            ),
            // Right: VIEW button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to donor details
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View ${donor.donorName}')));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Limit Reached Message ---
class _LimitReachedMessage extends StatelessWidget {
  const _LimitReachedMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Showing first 100 results. Please use the search bar to find specific donors.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Empty View ---
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No donors found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or toggle patron mode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Error View ---
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
