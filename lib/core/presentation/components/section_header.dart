import 'package:flutter/material.dart';

import 'package:movies_app/core/resources/app_colors.dart';
import 'package:movies_app/core/resources/app_strings.dart';
import 'package:movies_app/core/resources/app_values.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Function()? onSeeAllTap;

  const SectionHeaderWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onSeeAllTap,
  }) : super(key: key);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
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

@Deprecated('Use SectionHeaderWidget instead')
class SectionHeader extends SectionHeaderWidget {
  const SectionHeader({
    Key? key,
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Function()? onSeeAllTap,
  }) : super(
          key: key,
          title: title,
          subtitle: subtitle,
          leadingIcon: leadingIcon,
          onSeeAllTap: onSeeAllTap,
        );
}
