// lib/features/donors/presentation/pages/donors_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/pagination_widget.dart';
import 'package:surabhi/features/donors/models/donor_model.dart';
import 'package:surabhi/features/donors/presentation/bloc/donors_bloc.dart';

class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});

  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trigger initial load
    context.read<DonorsBloc>().add(const SearchDonorsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<DonorsBloc>().add(SearchDonorsEvent(searchText: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          _SearchBar(controller: _searchController, onSearch: _onSearch),
          // Add button + Patron mode toggle row
          const _ActionRow(),
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

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<DonorsBloc>().add(SearchDonorsEvent(searchText: _searchController.text));
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: state.donors.length,
                          itemBuilder: (context, index) {
                            return _DonorCard(donor: state.donors[index]);
                          },
                        ),
                      ),
                    ),
                    PaginationWidget(
                      currentPage: state.currentPage,
                      totalRecords: state.totalRecordsCount,
                      pageSize: state.pageSize,
                      onPageChanged: (page) {
                        context.read<DonorsBloc>().add(GoToPageEvent(page));
                      },
                      onPageSizeChanged: (newSize) {
                        context.read<DonorsBloc>().add(ChangePageSizeEvent(newSize));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Search Bar ---
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'Mobile Number/ Donor Name/ Donor ID',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryColor),
            onPressed: onSearch,
          ),
          filled: true,
          fillColor: AppColors.accentColor.withValues(alpha: 0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// --- Action Row: Add Button + Patron Toggle ---
class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Add Donor button
          SizedBox(
            height: 36,
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to Add Donor screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Donor - Coming soon')));
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add', style: TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.successColor,
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
            ),
          ),
          const Spacer(),
          // Patron Mode toggle
          BlocBuilder<DonorsBloc, DonorsState>(
            buildWhen: (previous, current) => previous.isPatronMode != current.isPatronMode,
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Patron Mode',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                  ),
                  Switch(
                    value: state.isPatronMode,
                    onChanged: (_) {
                      context.read<DonorsBloc>().add(const TogglePatronModeEvent());
                    },
                    activeColor: AppColors.primaryColor,
                    inactiveTrackColor: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Donor Card ---
class _DonorCard extends StatelessWidget {
  final DonorModel donor;

  const _DonorCard({required this.donor});

  bool get _hasPatronId => donor.patronId != null && donor.patronId!.isNotEmpty && donor.patronId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primaryColor.withValues(alpha: 0.06),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to donor details
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View ${donor.donorName}')));
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: PatronID if available, otherwise DonorID
                      Text(
                        _hasPatronId ? donor.patronId! : donor.donorId,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryColor),
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
              ),
              // Right: EnrolledBy (rotated 90° anti-clockwise, vertically centered, primary bg)
              if (donor.enrolledBy != null && donor.enrolledBy!.isNotEmpty)
                Container(
                  color: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      donor.enrolledBy!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
