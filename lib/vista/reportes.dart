import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Importa el paquete intl
import '../controlador/reportes_controller.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  _ReportesPageState createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  final ReportesController _controller = ReportesController();

  void _mostrarMensajeEmergente(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
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

  void _mostrarDialogoConfirmacionEliminacion(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este reporte?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.eliminarReporte(id);
                Navigator.of(context).pop();
                setState(() {});
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
            const Text('Reportes'),
            const Text(
              'Visualización de reportes de tu empresa',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _controller.obtenerReportes(),
        builder: (context, AsyncSnapshot<List<Reporte>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Reporte> reportes = snapshot.data!;

          return reportes.isEmpty
              ? const Center(child: Text('No hay reportes disponibles'))
              : ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    Reporte reporte = reportes[index];
                    String formattedDate = DateFormat('yyyy-MM-dd').format(reporte.fecha.toDate());  // Formatea solo la fecha
                    String formattedTime = DateFormat('HH:mm:ss').format(reporte.fecha.toDate());  // Formatea solo la hora
                    return ListTile(
                      title: Text(reporte.tipo),
                      subtitle: Text('${reporte.descripcion}\nFecha: $formattedDate\nHora: $formattedTime'),
                      onTap: () {
                        _mostrarDialogoConfirmacionEliminacion(reporte.id);
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}