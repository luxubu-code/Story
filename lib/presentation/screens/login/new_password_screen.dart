import 'package:flutter/material.dart';

class NewCredentialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.message, size: 50, color: Colors.black),
            SizedBox(height: 20),
            Text(
              'NEW\nCREDENTIALS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your identity has been verified.\nSet up your new credentials',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField('New Password'),
            SizedBox(height: 20),
            _buildTextField('Confirm Password'),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('UPDATE'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.visibility_off),
        border: OutlineInputBorder(),
      ),
    );
  }
}
