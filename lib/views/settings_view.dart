import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userAuthViewModel = Provider.of<UserAuthViewModel>(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.green),
            title: Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text('Manage notification preferences'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.green),
            title: const Text('Privacy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: const Text('Adjust your privacy settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy settings page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.green),
            title: const Text('Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: const Text('Switch between light and dark mode'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle theme toggle
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.green),
            title: const Text('Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text('Get assistance and FAQs'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help & support page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red)),
            onTap: () {
              userAuthViewModel.logout();
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
