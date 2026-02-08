// lib/core/widgets/pagination_widget.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/theme/app_colors.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalRecords;
  final int pageSize;
  final List<int> availablePageSizes;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalRecords,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
    this.availablePageSizes = const [5, 10, 20, 50],
  });

  int get totalPages => totalRecords <= 0 ? 1 : (totalRecords / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _PageSizeDropdown(
                pageSize: pageSize,
                availablePageSizes: availablePageSizes,
                onChanged: onPageSizeChanged,
              ),
              const Spacer(),
              Text(_recordRangeText, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavButton(icon: Icons.first_page, onPressed: currentPage > 1 ? () => onPageChanged(1) : null),
              _NavButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              ),
              ..._buildPageButtons(context),
              _NavButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              ),
              _NavButton(
                icon: Icons.last_page,
                onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _recordRangeText {
    if (totalRecords == 0) return '0 records';
    final start = ((currentPage - 1) * pageSize) + 1;
    final end = (currentPage * pageSize).clamp(1, totalRecords);
    return '$start-$end of $totalRecords';
  }

  List<Widget> _buildPageButtons(BuildContext context) {
    final pages = <int>[];
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (startPage + 4).clamp(1, totalPages);
    startPage = (endPage - 4).clamp(1, totalPages);
    for (int i = startPage; i <= endPage; i++) {
      pages.add(i);
    }
    return pages.map((page) {
      final isActive = page == currentPage;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Material(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isActive ? null : () => onPageChanged(page),
              child: Center(
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// --- Page Size Dropdown ---
class _PageSizeDropdown extends StatelessWidget {
  final int pageSize;
  final List<int> availablePageSizes;
  final ValueChanged<int> onChanged;

  const _PageSizeDropdown({required this.pageSize, required this.availablePageSizes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Show', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: pageSize,
              isDense: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[800]),
              items: availablePageSizes.map((size) => DropdownMenuItem(value: size, child: Text('$size'))).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// --- Navigation Button ---
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
        color: onPressed != null ? AppColors.primaryColor : Colors.grey[400],
        onPressed: onPressed,
        splashRadius: 18,
      ),
    );
  }
}
