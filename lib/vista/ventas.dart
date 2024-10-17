import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controlador/ventas_controller.dart';
import 'productos.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final VentasController _controller = VentasController();

  void _mostrarDialogoSeleccionarCliente(Producto producto) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: _controller.obtenerClientes(),
          builder: (context, AsyncSnapshot<List<Cliente>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Cliente> clientes = snapshot.data!;

            return AlertDialog(
              title: const Text('Seleccionar Cliente'),
              content: clientes.isEmpty
                  ? const Text('No hay clientes disponibles')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: clientes.map((cliente) {
                        return ListTile(
                          title: Text(cliente.nombre),
                          subtitle: Text('Domicilio: ${cliente.domicilio}'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _mostrarDialogoVenta(producto, cliente);
                          },
                        );
                      }).toList(),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoVenta(Producto producto, Cliente cliente) {
    TextEditingController cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Producto a vender: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(producto.nombre),
                ],
              ),
              Row(
                children: [
                  const Text('Cantidad en inventario: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${producto.cantidad}'),
                ],
              ),
              Row(
                children: [
                  const Text('Precio unitario: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${producto.precio.toStringAsFixed(2)}'),
                ],
              ),
              Row(
                children: [
                  const Text('Venta para el cliente: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(cliente.nombre),
                ],
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad a vender'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                int cantidadVendida = int.parse(cantidadController.text);
                try {
                  await _controller.crearVenta(producto, cantidadVendida, cliente);
                  Navigator.of(context).pop();
                  _mostrarTicketVenta(producto, cantidadVendida, cliente);
                } catch (e) {
                  Navigator.of(context).pop();
                  _mostrarError(e.toString());
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarTicketVenta(Producto producto, int cantidadVendida, Cliente cliente) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm:ss');
    final String formattedDate = dateFormatter.format(DateTime.now());
    final String formattedTime = timeFormatter.format(DateTime.now());
    final double total = producto.precio * cantidadVendida;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ticket de Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Producto:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(producto.nombre),
              SizedBox(height: 8),
              Text(
                'Cantidad vendida:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('$cantidadVendida'),
              SizedBox(height: 8),
              Text(
                'Cliente:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(cliente.nombre),
              SizedBox(height: 8),
              Text(
                'Fecha:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(formattedDate),
              SizedBox(height: 8),
              Text(
                'Hora:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(formattedTime),
              SizedBox(height: 8),
              Text(
                'Precio unitario:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('\$${producto.precio.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('\$${total.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ventas'),
            const Text(
              'Selecciona un producto a vender',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _controller.productosRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Producto> productos = snapshot.data!.docs.map((doc) => Producto.fromFirestore(doc)).toList();
          productos.sort((a, b) => a.visualId.compareTo(b.visualId));

          return productos.isEmpty
              ? const Center(child: Text('No hay productos disponibles'))
              : ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    Producto producto = productos[index];
                    return ListTile(
                      title: Text('${producto.visualId}. ${producto.nombre}'),  // Mostrar visualId
                      subtitle: Text('Proveedor: ${producto.proveedor}\nCantidad: ${producto.cantidad}\nPrecio: \$${producto.precio.toStringAsFixed(2)}'),  // Mostrar cantidad y precio
                      onTap: () {
                        _mostrarDialogoSeleccionarCliente(producto);
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}