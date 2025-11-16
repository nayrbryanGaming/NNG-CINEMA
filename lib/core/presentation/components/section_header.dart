import 'package:flutter/material.dart';

import 'package:movies_app/core/resources/app_colors.dart';
import 'package:movies_app/core/resources/app_strings.dart';
import 'package:movies_app/core/resources/app_values.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final Function()? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppPadding.p4,
        horizontal: AppPadding.p16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (leadingIcon != null)
                Icon(
                  leadingIcon,
                  size: 22,
                  color: textTheme.titleSmall?.color,
                ),
              if (leadingIcon != null) const SizedBox(width: AppPadding.p8),
              Text(
                title,
                style: textTheme.titleSmall,
              ),
            ],
          ),
          if (onSeeAllTap != null)
            InkWell(
              onTap: onSeeAllTap,
              child: Row(
                children: [
                  Text(
                    AppStrings.seeAll,
                    style: textTheme.bodyLarge,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppSize.s12,
                    color: AppColors.primaryText,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
