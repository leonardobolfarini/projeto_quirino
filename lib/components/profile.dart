import 'package:flutter/material.dart';
import 'package:projeto_quirino/components/login.dart';
import 'package:projeto_quirino/services/auth_service.dart';
import 'package:projeto_quirino/components/success_toaster.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  void _logout() {
    _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TelaLogin()),
    );
  }

  void _updateProfile() {
    _authService.userUpdate(
      _emailController.text,
      _nameController.text,
      _passwordController.text,
    );

    SuccessToaster(message: 'Perfil atualizado com sucesso');
  }

  @override
  void initState() {
    super.initState();
    _authService.userChanges.listen((user) {
      _emailController.text = user?.email ?? '';
      _nameController.text = user?.displayName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfil',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: _nameController.text,
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                  ),
                  SizedBox(height: 16),

                  TextField(
                    decoration: InputDecoration(
                      labelText: _emailController.text,
                      border: OutlineInputBorder(),
                    ),
                    controller: _emailController,
                  ),
                  SizedBox(height: 16),

                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    controller: _passwordController,
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: TextButton(
                          onPressed: () {
                            _updateProfile();
                          },
                          child: Text(
                            'Atualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: _logout,
                        child: Icon(Icons.logout, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
