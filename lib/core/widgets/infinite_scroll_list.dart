// lib/core/widgets/infinite_scroll_list.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';

/// Generic Infinite Scroll List Widget
class InfiniteScrollList extends StatelessWidget {
  final String category;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? scrollController;

  const InfiniteScrollList({
    super.key,
    required this.category,
    this.itemCount = 15,
    required this.itemBuilder,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('$category - Item ${index + 1}'),
            subtitle: const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Hare Krishna.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // TODO: Handle item tap
            },
          ),
        );
      },
    );
  }
}
