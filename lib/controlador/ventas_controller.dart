import 'package:cloud_firestore/cloud_firestore.dart';
import '../vista/productos.dart';
import 'reportes_controller.dart';  // Importa el controlador de reportes

class VentasController {
  final CollectionReference productosRef = FirebaseFirestore.instance.collection('productos');
  final CollectionReference ventasRef = FirebaseFirestore.instance.collection('ventas');
  final CollectionReference clientesRef = FirebaseFirestore.instance.collection('clientes');
  final ReportesController reportesController = ReportesController();  // Instancia del controlador de reportes

  Future<List<Producto>> obtenerProductos() async {
    QuerySnapshot snapshot = await productosRef.get();
    return snapshot.docs.map((doc) => Producto.fromFirestore(doc)).toList();
  }

  Future<List<Cliente>> obtenerClientes() async {
    QuerySnapshot snapshot = await clientesRef.get();
    return snapshot.docs.map((doc) => Cliente.fromFirestore(doc)).toList();
  }

  Future<void> crearVenta(Producto producto, int cantidadVendida, Cliente cliente) async {
    if (producto.cantidad < cantidadVendida) {
      throw Exception('Cantidad insuficiente en inventario');
    }

    // Actualizar la cantidad del producto en Firestore
    producto.cantidad -= cantidadVendida;
    await productosRef.doc(producto.id).update(producto.toFirestore());

    // Crear un nuevo documento de venta en Firestore
    await ventasRef.add({
      'productoId': producto.id,
      'nombre': producto.nombre,
      'cantidadVendida': cantidadVendida,
      'clienteId': cliente.id,
      'clienteNombre': cliente.nombre,
      'precio': producto.precio,
      'total': producto.precio * cantidadVendida,
      'fecha': Timestamp.now(),
    }).then((_) {
      reportesController.agregarReporte('Nueva Venta', 'Venta de ${cantidadVendida} unidades de ${producto.nombre} a ${cliente.nombre}.');
    });
  }
}

class Cliente {
  String nombre;
  int edad;
  String domicilio;
  String id;

  Cliente({required this.nombre, required this.edad, required this.domicilio, required this.id});

  factory Cliente.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Cliente(
      nombre: data['nombre'] ?? '',
      edad: int.tryParse(data['edad'].toString()) ?? 0,  // Convertir edad a int
      domicilio: data['domicilio'] ?? '',
      id: doc.id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'edad': edad,
      'domicilio': domicilio,
    };
  }
}