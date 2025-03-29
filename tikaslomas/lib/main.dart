import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AppMuebles());
}

class AppMuebles extends StatelessWidget {
  const AppMuebles({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Muebles',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.indigo[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigoAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PantallaListaMuebles(),
    );
  }
}

class PantallaListaMuebles extends StatefulWidget {
  const PantallaListaMuebles({super.key});

  @override
  _PantallaListaMueblesState createState() => _PantallaListaMueblesState();
}

class _PantallaListaMueblesState extends State<PantallaListaMuebles> {
  List<Map<String, dynamic>> listaMuebles = [];
  final TextEditingController controladorNombre = TextEditingController();
  String? tipoSeleccionado;
  String? estadoSeleccionado;
  final List<String> tipos = ['Asiento', 'Mesa', 'Armario', 'Cama'];
  final List<String> estados = ['Usado', 'Buen Estado', 'Nuevo'];

  final String baseUrl = 'http://localhost:3000'; // Para web

  @override
  void initState() {
    super.initState();
    _cargarListaMuebles();
  }

  Future<void> _cargarListaMuebles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/muebles'));
      if (response.statusCode == 200) {
        setState(() {
          listaMuebles = List<Map<String, dynamic>>.from(
            jsonDecode(response.body),
          );
        });
        print('Datos cargados: $listaMuebles');
      } else {
        throw Exception('Error al cargar los muebles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  Future<void> _agregarMueble() async {
    if (controladorNombre.text.isNotEmpty &&
        tipoSeleccionado != null &&
        estadoSeleccionado != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/muebles'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombre': controladorNombre.text,
            'tipo': tipoSeleccionado!,
            'estado': estadoSeleccionado!,
          }),
        );
        if (response.statusCode == 200) {
          await _cargarListaMuebles();
          _reiniciarFormulario();
        } else {
          throw Exception('Error al agregar el mueble: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al agregar mueble: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar mueble: $e')),
          );
        }
      }
    }
  }

  Future<void> _actualizarMueble(int id) async {
    if (controladorNombre.text.isNotEmpty &&
        tipoSeleccionado != null &&
        estadoSeleccionado != null) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/muebles/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombre': controladorNombre.text,
            'tipo': tipoSeleccionado!,
            'estado': estadoSeleccionado!,
          }),
        );
        if (response.statusCode == 200) {
          await _cargarListaMuebles();
          _reiniciarFormulario();
        } else {
          throw Exception(
            'Error al actualizar el mueble: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('Error al actualizar mueble: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar mueble: $e')),
          );
        }
      }
    }
  }

  Future<void> _eliminarMueble(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/muebles/$id'));
      if (response.statusCode == 200) {
        await _cargarListaMuebles();
      } else {
        throw Exception('Error al eliminar el mueble: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al eliminar mueble: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar mueble: $e')));
      }
    }
  }

  void _reiniciarFormulario() {
    controladorNombre.clear();
    tipoSeleccionado = null;
    estadoSeleccionado = null;
  }

  void mostrarDialogoMueble({int? id}) {
    if (id != null) {
      final mueble = listaMuebles.firstWhere((item) => item['id'] == id);
      controladorNombre.text = mueble['nombre'];
      tipoSeleccionado = mueble['tipo'];
      estadoSeleccionado = mueble['estado'];
    } else {
      _reiniciarFormulario();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              id == null ? 'Agregar Mueble' : 'Actualizar Mueble',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controladorNombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    hint: const Text('Selecciona Tipo'),
                    items:
                        tipos.map((String tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => tipoSeleccionado = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: estadoSeleccionado,
                    hint: const Text('Selecciona Estado'),
                    items:
                        estados.map((String estado) {
                          return DropdownMenuItem<String>(
                            value: estado,
                            child: Text(estado),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() => estadoSeleccionado = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (id == null) {
                    _agregarMueble();
                  } else {
                    _actualizarMueble(id);
                  }
                  Navigator.pop(context);
                },
                child: Text(id == null ? 'Agregar' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Muebles',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body:
          listaMuebles.isEmpty
              ? const Center(
                child: Text(
                  'No hay muebles en la lista',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: listaMuebles.length,
                itemBuilder: (context, index) {
                  final mueble = listaMuebles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        mueble['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tipo: ${mueble['tipo']} | Estado: ${mueble['estado']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 28,
                            ),
                            onPressed:
                                () => mostrarDialogoMueble(id: mueble['id']),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () => _eliminarMueble(mueble['id']),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarDialogoMueble(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
