import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prova CRUD 202310213',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(secondary: Colors.cyanAccent),
        useMaterial3: false, // Facilita visibilidade das cores primárias
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _tarefas = [];
  bool _isLoading = true;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _prioridadeController = TextEditingController();
  final TextEditingController _etapaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTarefas();
  }

  void _refreshTarefas() async {
    final data = await _dbHelper.getTarefas();
    setState(() {
      _tarefas = data;
      _isLoading = false;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingTarefa = _tarefas.firstWhere(
        (element) => element['id'] == id,
      );
      _tituloController.text = existingTarefa['titulo'];
      _descController.text = existingTarefa['descricao'];
      _prioridadeController.text = existingTarefa['prioridade'].toString();
      _etapaController.text = existingTarefa['etapaFluxo']; // Campo Extra
    } else {
      _tituloController.clear();
      _descController.clear();
      _prioridadeController.clear();
      _etapaController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(hintText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(hintText: 'Descrição'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _prioridadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Prioridade (1-5)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _etapaController,
              decoration: const InputDecoration(
                hintText: 'Etapa do Fluxo (ex: Planejamento)',
                labelText: 'Etapa Fluxo (Campo Extra)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty) return;

                if (id == null) {
                  await _dbHelper.insertTarefa({
                    'titulo': _tituloController.text,
                    'descricao': _descController.text,
                    'prioridade': int.tryParse(_prioridadeController.text) ?? 1,
                    'criadoEm': DateTime.now().toString(),
                    'etapaFluxo': _etapaController.text, // Campo Extra
                  });
                } else {
                  await _dbHelper.updateTarefa({
                    'id': id,
                    'titulo': _tituloController.text,
                    'descricao': _descController.text,
                    'prioridade': int.tryParse(_prioridadeController.text) ?? 1,
                    'criadoEm': DateTime.now().toString(),
                    'etapaFluxo': _etapaController.text,
                  });
                }
                _tituloController.clear();
                _descController.clear();
                _prioridadeController.clear();
                _etapaController.clear();
                Navigator.of(context).pop();
                _refreshTarefas();
              },
              child: Text(id == null ? 'Criar Nova' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  // DELETE (Excluir)
  void _deleteItem(int id) async {
    await _dbHelper.deleteTarefa(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa deletada com sucesso!')),
    );
    _refreshTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas Profissionais - RA 202310213')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) => Card(
                color: Colors.teal[50], // Leve toque da cor do tema
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    _tarefas[index]['titulo'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tarefas[index]['descricao']),
                      Text(
                        "Etapa: ${_tarefas[index]['etapaFluxo']}",
                        style: TextStyle(color: Colors.teal[800]),
                      ),
                      Text("Prioridade: ${_tarefas[index]['prioridade']}"),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_tarefas[index]['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(_tarefas[index]['id']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent, // Cor Secundária do tema
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
