// lib/features/home/presentation/widgets/home_dashboard.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/home/models/home_summary_model.dart';
import 'package:surabhi/features/home/presentation/bloc/home_bloc.dart';
import 'package:surabhi/injector.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const GetHomeSummaryEvent()),
      child: const _HomeDashboardContent(),
    );
  }
}

class _HomeDashboardContent extends StatelessWidget {
  const _HomeDashboardContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<HomeBloc>().add(const GetHomeSummaryEvent()),
          );
        }

        if (state is HomeLoaded) {
          return _LoadedView(summary: state.summary);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

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

class _LoadedView extends StatelessWidget {
  final HomeSummaryModel summary;

  const _LoadedView({required this.summary});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const GetHomeSummaryEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            _GreetingSection(),
            const SizedBox(height: 20),
            // Total Contribution Card
            _TotalContributionCard(grandTotal: summary.grandTotalAmount),
            const SizedBox(height: 16),
            // Source Type Breakdown Card
            if (summary.sourceTypeDonations.isNotEmpty) _SourceTypeCard(sources: summary.sourceTypeDonations),
            const SizedBox(height: 16),
            // Quarterly Donations Pie Chart
            if (summary.quarterlyDonations.isNotEmpty) _QuarterlyPieChart(quarters: summary.quarterlyDonations),
          ],
        ),
      ),
    );
  }
}

// --- Greeting Section ---
class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = (state is AuthAuthenticated) ? state.user.displayName : 'Prabhu';
        return Text(
          'Hare Krishna $name',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

// --- Total Contribution Card (Yellow/Amber) ---
class _TotalContributionCard extends StatelessWidget {
  final String grandTotal;

  const _TotalContributionCard({required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accentColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Lakshmi Contribution',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '(Last 12 months)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onAccent.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Text(
              '₹$grandTotal',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Source Type Breakdown Card (Purple) ---
class _SourceTypeCard extends StatelessWidget {
  final List<SourceTypeDonation> sources;

  const _SourceTypeCard({required this.sources});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation by Source',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...sources.map(
              (source) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      source.sourceType,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.9)),
                    ),
                    Text(
                      '₹${source.totalAmount}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Quarterly Donations Pie Chart ---
class _QuarterlyPieChart extends StatelessWidget {
  final List<QuarterlyDonation> quarters;

  const _QuarterlyPieChart({required this.quarters});

  static const List<Color> _chartColors = [
    Color(0xFF4A148C), // Deep Purple
    Color(0xFFFFC107), // Amber
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFD32F2F), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  Widget build(BuildContext context) {
    final totalAmount = quarters.fold<double>(0, (sum, q) => sum + q.amountValue);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quarterly Donations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: _buildSections(totalAmount)),
              ),
            ),
            const SizedBox(height: 20),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(quarters.length, (index) {
                final quarter = quarters[index];
                final color = _chartColors[index % _chartColors.length];
                return _LegendItem(color: color, label: quarter.label, amount: '₹${quarter.totalAmount}');
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double totalAmount) {
    return List.generate(quarters.length, (index) {
      final quarter = quarters[index];
      final color = _chartColors[index % _chartColors.length];
      final percentage = totalAmount > 0 ? (quarter.amountValue / totalAmount * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: quarter.amountValue,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }
}

// --- Legend Item ---
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;

  const _LegendItem({required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: $amount', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
