import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool cargando = false;

  Future<void> login() async {

    try {

      setState(() {
        cargando = true;
      });

      await Supabase.instance.client.auth
          .signInWithPassword(
        email: emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(25),
          child: Column(
            children: [

              const Icon(
                Icons.factory,
                size: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                'Producción Preforsa',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    emailController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Correo',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Contraseña',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                  onPressed:
                      cargando
                          ? null
                          : login,

                  child: Text(
                    cargando
                        ? 'Ingresando...'
                        : 'Ingresar',
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