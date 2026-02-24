import 'package:flutter/material.dart';

import '../../theme/app_theme_colors.dart';
import 'search_category_chip.dart';

enum SearchCategory { all, documents, images, videos }

class SearchHeaderLabels {
  const SearchHeaderLabels({
    required this.all,
    required this.documents,
    required this.images,
    required this.videos,
  });

  final String all;
  final String documents;
  final String images;
  final String videos;
}

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.labels,
    required this.selectedCategory,
    required this.onQueryChanged,
    required this.onClearTap,
    required this.onCategoryChanged,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final SearchHeaderLabels labels;
  final SearchCategory selectedCategory;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearTap;
  final ValueChanged<SearchCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      color: colors.headerBackground,
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.inputBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xA700040A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: colors.hintText, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onQueryChanged,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: colors.hintText),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    onPressed: onClearTap,
                    icon: Icon(Icons.close, color: colors.hintText),
                    style: IconButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SearchCategoryChip(
                  label: labels.all,
                  isActive: selectedCategory == SearchCategory.all,
                  onTap: () => onCategoryChanged(SearchCategory.all),
                ),
                SearchCategoryChip(
                  label: labels.documents,
                  isActive: selectedCategory == SearchCategory.documents,
                  onTap: () => onCategoryChanged(SearchCategory.documents),
                ),
                SearchCategoryChip(
                  label: labels.images,
                  isActive: selectedCategory == SearchCategory.images,
                  onTap: () => onCategoryChanged(SearchCategory.images),
                ),
                SearchCategoryChip(
                  label: labels.videos,
                  isActive: selectedCategory == SearchCategory.videos,
                  onTap: () => onCategoryChanged(SearchCategory.videos),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
