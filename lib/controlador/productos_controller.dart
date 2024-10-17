import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../vista/productos.dart';
import '../controlador/reportes_controller.dart';  // Importa el controlador de reportes

class ProductosController {
  final CollectionReference productosRef = FirebaseFirestore.instance.collection('productos');
  final ReportesController reportesController = ReportesController();  // Instancia del controlador de reportes

  void agregarProducto(BuildContext context, TextEditingController nombreController, TextEditingController proveedorController, TextEditingController cantidadController, TextEditingController precioController) {
    Producto nuevoProducto = Producto(
      nombre: nombreController.text,
      id: '',  // La ID será asignada por Firestore
      proveedor: proveedorController.text,
      visualId: 0,  // El visualId se asignará después
      cantidad: int.parse(cantidadController.text), 
      precio: double.parse(precioController.text),  // Asignar cantidad y precio
    );
    productosRef.add(nuevoProducto.toFirestore()).then((docRef) {
      actualizarVisualIds();
      reportesController.agregarReporte('Agregar Producto', 'Producto ${nuevoProducto.nombre} agregado con éxito.');
    });
    Navigator.of(context).pop();
  }

  void editarProducto(BuildContext context, Producto producto, TextEditingController nombreController, TextEditingController proveedorController, TextEditingController cantidadController, TextEditingController precioController) {
    producto.nombre = nombreController.text;
    producto.proveedor = proveedorController.text;
    producto.cantidad = int.parse(cantidadController.text);
    producto.precio = double.parse(precioController.text);
    productosRef.doc(producto.id).update(producto.toFirestore()).then((_) {
      reportesController.agregarReporte('Editar Producto', 'Producto ${producto.nombre} editado con éxito.');
    });
    Navigator.of(context).pop();
  }

  void eliminarProducto(BuildContext context, String id) {
    productosRef.doc(id).get().then((doc) {
      if (doc.exists) {
        Producto producto = Producto.fromFirestore(doc);
        productosRef.doc(id).delete().then((_) {
          actualizarVisualIds();
          reportesController.agregarReporte('Eliminar Producto', 'Producto ${producto.nombre} eliminado con éxito.');
        });
      }
    });
    Navigator.of(context).pop();
  }

  void actualizarVisualIds() async {
    QuerySnapshot snapshot = await productosRef.get();
    List<Producto> productos = snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList();
    productos.sort((a, b) => a.visualId.compareTo(b.visualId));

    for (int i = 0; i < productos.length; i++) {
      productos[i].visualId = i + 1;
      productosRef.doc(productos[i].id).update(productos[i].toFirestore());
    }
  }
}