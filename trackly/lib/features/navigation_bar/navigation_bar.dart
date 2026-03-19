import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trackly/core/theme/appColors.dart';
import 'package:trackly/core/theme/appImages.dart';

import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const Navbar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: appColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: appColors.white,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            items: [
              _buildItem(AppImages.homeIcon, 24.0, 0),
              _buildItem(AppImages.graphIcon, 24.0, 1),
              _buildItem(AppImages.userIcon, 24.0, 2),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
    String assetName,
    double width,
    int index,
  ) {
    final bool isSelected = navigationShell.currentIndex == index;
    final Color iconColor = isSelected
        ? appColors.accent
        : appColors.secondaryGray;

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SvgPicture.asset(
          assetName,
          width: width,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
      label: '',
    );
  }
}
