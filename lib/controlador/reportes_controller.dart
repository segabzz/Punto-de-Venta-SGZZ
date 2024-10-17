import 'package:cloud_firestore/cloud_firestore.dart';

class ReportesController {
  final CollectionReference reportesRef = FirebaseFirestore.instance.collection('reportes');

  Future<void> agregarReporte(String tipo, String descripcion) async {
    await reportesRef.add({
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha': Timestamp.now(),
    });
  }

  Future<void> eliminarReporte(String id) async {
    await reportesRef.doc(id).delete();
  }

  Future<List<Reporte>> obtenerReportes() async {
    QuerySnapshot snapshot = await reportesRef.orderBy('fecha', descending: true).get();
    return snapshot.docs.map((doc) => Reporte.fromFirestore(doc)).toList();
  }
}

class Reporte {
  String id;
  String tipo;
  String descripcion;
  Timestamp fecha;

  Reporte({required this.id, required this.tipo, required this.descripcion, required this.fecha});

  factory Reporte.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Reporte(
      id: doc.id,
      tipo: data['tipo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fecha: data['fecha'] ?? Timestamp.now(),
    );
  }
}