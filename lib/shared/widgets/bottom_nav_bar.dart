import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gamehub/core/gen/assets/assets.gen.dart';
import 'package:gamehub/generated/locale_keys.g.dart';

import '../../core/theme/app_colors.dart';

class GameHubBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GameHubBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GameHubBottomNavBar> createState() => _GameHubBottomNavBarState();
}

class _GameHubBottomNavBarState extends State<GameHubBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bgDark,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          enableFeedback: false,
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Assets.icons.home2.svg(
                colorFilter: ColorFilter.mode(
                  widget.currentIndex == 0
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              label: LocaleKeys.dashboard_home.tr(),
            ),
            BottomNavigationBarItem(
              icon: Assets.icons.cup.svg(
                colorFilter: ColorFilter.mode(
                  widget.currentIndex == 1
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              label: LocaleKeys.dashboard_tournaments.tr(),
            ),
            BottomNavigationBarItem(
              icon: Assets.icons.addCircle.svg(
                colorFilter: ColorFilter.mode(
                  widget.currentIndex == 2
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              label: LocaleKeys.dashboard_create.tr(),
            ),
            BottomNavigationBarItem(
              icon: Assets.icons.people.svg(
                colorFilter: ColorFilter.mode(
                  widget.currentIndex == 3
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              label: LocaleKeys.dashboard_teams.tr(),
            ),
            BottomNavigationBarItem(
              icon: Assets.icons.profileCircle.svg(
                colorFilter: ColorFilter.mode(
                  widget.currentIndex == 4
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
              label: LocaleKeys.dashboard_profile.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
