import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'vista/productos.dart';
import 'vista/ventas.dart';
import 'vista/clientes.dart';
import 'vista/reportes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonSize = (MediaQuery.of(context).size.width / 2) - 32;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Punto de Venta SGZZ'),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Este es el Punto de Venta creado por Sergio Gabriel Zertuche Zamora (SGZZ)',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 20,
                    left: 16,
                    child: SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProductosPage()),
                              );
                            },
                            child: const Text('Productos'),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 16,
                    child: SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VentasPage()),
                              );
                            },
                            child: const Text('Ventas'),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: 16,
                    child: SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ClientesPage()),
                              );
                            },
                            child: const Text('Clientes'),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Builder(
                        builder: (context) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ReportesPage()),
                              );
                            },
                            child: const Text('Reportes'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(28.0),
              child: Center(
                child: Text(
                  'Selecciona una opción para continuar',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}