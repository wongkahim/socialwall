import 'package:flutter/material.dart';
import 'package:socialwall/components/my_list_title.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onMyPostTap;
  final void Function()? onLogoutTap;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onMyPostTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              // header
              const DrawerHeader(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              // home list title
              MyListTitle(
                iconData: Icons.home_rounded,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              // My Post list title
              MyListTitle(
                iconData: Icons.message_rounded,
                text: 'M Y  P O S T',
                onTap: onMyPostTap,
              ),

              // profile list title
              MyListTitle(
                iconData: Icons.person_pin_rounded,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),
            ],
          ),
          // logout list title
          MyListTitle(
            iconData: Icons.logout_rounded,
            text: 'L O G O U T',
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}
