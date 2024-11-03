import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const ProfilePage({
    Key? key,
    required this.userData,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE9967A)),
            onPressed: onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Profile Avatar
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF0F0F0),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                userData?['name'] ?? 'User Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                userData?['email'] ?? 'email@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Info Cards
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9967A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_android,
                        color: Color(0xFFE9967A)),
                  ),
                  title: const Text('No Handphone'),
                  subtitle: Text(userData?['phone'] ?? 'Not set'),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9967A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.location_on, color: Color(0xFFE9967A)),
                  ),
                  title: const Text('Address'),
                  subtitle: Text(userData?['address'] ?? 'Not set'),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9967A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_city,
                        color: Color(0xFFE9967A)),
                  ),
                  title: const Text('Postal Code'),
                  subtitle: Text(userData?['postalCode'] ?? 'Not set'),
                ),
              ),
              const SizedBox(height: 32),

              // Edit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add edit functionality here
                    // Navigator.pushNamed(context, '/edit-profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE9967A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onLogout,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE9967A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
