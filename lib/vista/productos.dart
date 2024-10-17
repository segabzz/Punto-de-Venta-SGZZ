import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controlador/productos_controller.dart';

class Producto {
  String nombre;
  String id;
  String proveedor;
  int visualId;  // Nueva propiedad para la ID visual
  int cantidad;  // Nueva propiedad para la cantidad
  double precio;  // Nueva propiedad para el precio

  Producto({required this.nombre, required this.id, required this.proveedor, required this.visualId, required this.cantidad, required this.precio});

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Producto(
      nombre: data['nombre'] ?? '',
      id: doc.id,
      proveedor: data['proveedor'] ?? '',
      visualId: data['visualId'] ?? 0,  // Asignar visualId desde Firestore
      cantidad: data['cantidad'] ?? 0,  // Asignar cantidad desde Firestore
      precio: data['precio']?.toDouble() ?? 0.0,  // Asignar precio desde Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'proveedor': proveedor,
      'visualId': visualId,  // Incluir visualId en Firestore
      'cantidad': cantidad,  // Incluir cantidad en Firestore
      'precio': precio,  // Incluir precio en Firestore
    };
  }
}

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductosController _controller = ProductosController();

  void _mostrarDialogoAgregarProducto() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController proveedorController = TextEditingController();
    TextEditingController cantidadController = TextEditingController();
    TextEditingController precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: proveedorController,
                decoration: const InputDecoration(labelText: 'Proveedor'),
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
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
              onPressed: () {
                _controller.agregarProducto(context, nombreController, proveedorController, cantidadController, precioController);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarProducto(Producto producto) {
    TextEditingController nombreController = TextEditingController(text: producto.nombre);
    TextEditingController proveedorController = TextEditingController(text: producto.proveedor);
    TextEditingController cantidadController = TextEditingController(text: producto.cantidad.toString());
    TextEditingController precioController = TextEditingController(text: producto.precio.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: proveedorController,
                decoration: const InputDecoration(labelText: 'Proveedor'),
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
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
              onPressed: () {
                _controller.editarProducto(context, producto, nombreController, proveedorController, cantidadController, precioController);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminarProducto(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _controller.eliminarProducto(context, id);
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
            const Text('Productos'),
            const Text(
              'Agrega, Modifica o Elimina tus productos',
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
                      subtitle: Text('Proveedor: ${producto.proveedor}\nCantidad: ${producto.cantidad}\nPrecio Unitario: \$${producto.precio.toStringAsFixed(2)}'),  // Mostrar cantidad y precio
                      onTap: () {
                        _mostrarDialogoEditarProducto(producto);
                      },
                      onLongPress: () {
                        _mostrarDialogoEliminarProducto(producto.id);
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarProducto,
        child: const Icon(Icons.add),
      ),
    );
  }
}