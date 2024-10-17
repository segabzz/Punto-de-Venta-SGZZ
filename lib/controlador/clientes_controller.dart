import 'package:cloud_firestore/cloud_firestore.dart';
import 'reportes_controller.dart';  // Importa el controlador de reportes

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

class ClientesController {
  final CollectionReference clientesRef = FirebaseFirestore.instance.collection('clientes');
  final ReportesController reportesController = ReportesController();  // Instancia del controlador de reportes

  Future<List<Cliente>> obtenerClientes() async {
    QuerySnapshot snapshot = await clientesRef.get();
    return snapshot.docs.map((doc) => Cliente.fromFirestore(doc)).toList();
  }

  Future<void> agregarCliente(Cliente cliente) async {
    await clientesRef.add(cliente.toFirestore()).then((_) {
      reportesController.agregarReporte('Agregar Cliente', 'Cliente ${cliente.nombre} agregado con éxito.');
    });
  }

  Future<void> editarCliente(Cliente cliente) async {
    await clientesRef.doc(cliente.id).update(cliente.toFirestore()).then((_) {
      reportesController.agregarReporte('Editar Cliente', 'Cliente ${cliente.nombre} editado con éxito.');
    });
  }

  Future<void> eliminarCliente(String id) async {
    clientesRef.doc(id).get().then((doc) {
      if (doc.exists) {
        Cliente cliente = Cliente.fromFirestore(doc);
        clientesRef.doc(id).delete().then((_) {
          reportesController.agregarReporte('Eliminar Cliente', 'Cliente ${cliente.nombre} eliminado con éxito.');
        });
      }
    });
  }
}