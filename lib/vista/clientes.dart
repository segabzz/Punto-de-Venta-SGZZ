import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controlador/clientes_controller.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesController _controller = ClientesController();

  void _mostrarDialogoAgregarCliente({Cliente? cliente}) {
    TextEditingController nombreController = TextEditingController(text: cliente?.nombre ?? '');
    TextEditingController edadController = TextEditingController(text: cliente?.edad.toString() ?? '');
    TextEditingController domicilioController = TextEditingController(text: cliente?.domicilio ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cliente == null ? 'Agregar Cliente' : 'Editar Cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: domicilioController,
                decoration: const InputDecoration(labelText: 'Domicilio'),
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
                Cliente nuevoCliente = Cliente(
                  nombre: nombreController.text,
                  edad: int.tryParse(edadController.text) ?? 0,
                  domicilio: domicilioController.text,
                  id: cliente?.id ?? '',  // La ID será asignada por Firestore si es un nuevo cliente
                );
                if (cliente == null) {
                  await _controller.agregarCliente(nuevoCliente);
                } else {
                  await _controller.editarCliente(nuevoCliente);
                }
                Navigator.of(context).pop();
              },
              child: Text(cliente == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminarCliente(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Cliente'),
          content: const Text('¿Estás seguro de que deseas eliminar este cliente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.eliminarCliente(id);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
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
            const Text('Clientes'),
            const Text(
              'Agrega, Modifica o Elimina tus clientes',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _controller.clientesRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Cliente> clientes = snapshot.data!.docs.map((doc) => Cliente.fromFirestore(doc)).toList();

          return clientes.isEmpty
              ? const Center(child: Text('No hay clientes disponibles'))
              : ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    Cliente cliente = clientes[index];
                    return ListTile(
                      leading: const Icon(Icons.person),  // Agregar ícono de usuario
                      title: Text(cliente.nombre),
                      subtitle: Text('Edad: ${cliente.edad}\nDomicilio: ${cliente.domicilio}'),
                      onTap: () {
                        _mostrarDialogoAgregarCliente(cliente: cliente);
                      },
                      onLongPress: () {
                        _mostrarDialogoEliminarCliente(cliente.id);
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoAgregarCliente();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}