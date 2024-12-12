import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
          Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.green),
            title: Text('Privacy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text('Adjust your privacy settings'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy settings page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette, color: Colors.green),
            title: Text('Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text('Switch between light and dark mode'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle theme toggle
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help, color: Colors.green),
            title: Text('Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            subtitle: Text('Get assistance and FAQs'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help & support page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red)),
            onTap: () {
              authProvider.logout();
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
