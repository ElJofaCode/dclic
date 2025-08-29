import 'package:flutter/material.dart';
import 'database/database_manager.dart';
import 'modele/redacteur.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({Key? key}) : super(key: key);

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager dbManager = DatabaseManager();
  List<Redacteur> redacteurs = [];

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Redacteur? editingRedacteur;

  @override
  void initState() {
    super.initState();
    loadRedacteurs();
  }

  Future<void> loadRedacteurs() async {
    final list = await dbManager.getAllRedacteurs();
    setState(() {
      redacteurs = list;
    });
  }

  void resetForm() {
    nomController.clear();
    prenomController.clear();
    emailController.clear();
    editingRedacteur = null;
  }

  void saveRedacteur() async {
    final nom = nomController.text.trim();
    final prenom = prenomController.text.trim();
    final email = emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) return;

    if (editingRedacteur != null) {
      // Update
      final r = Redacteur(
          id: editingRedacteur!.id, nom: nom, prenom: prenom, email: email);
      await dbManager.updateRedacteur(r);
    } else {
      // Insert
      final r = Redacteur(nom: nom, prenom: prenom, email: email);
      await dbManager.insertRedacteur(r);
    }

    resetForm();
    await loadRedacteurs();
  }

  void editRedacteur(Redacteur r) {
    setState(() {
      editingRedacteur = r;
      nomController.text = r.nom;
      prenomController.text = r.prenom;
      emailController.text = r.email;
    });
  }

  void deleteRedacteur(int id) async {
    await dbManager.deleteRedacteur(id);
    await loadRedacteurs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Rédacteurs"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(labelText: "Prénom"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: saveRedacteur,
                child: Text(editingRedacteur != null ? "Mettre à jour" : "Ajouter")),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Liste des Rédacteurs", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: redacteurs.length,
                  itemBuilder: (context, index) {
                    final r = redacteurs[index];
                    return Card(
                      child: ListTile(
                        title: Text("${r.nom} ${r.prenom}"),
                        subtitle: Text(r.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => editRedacteur(r),
                                icon: const Icon(Icons.edit, color: Colors.blue)),
                            IconButton(
                                onPressed: () => deleteRedacteur(r.id!),
                                icon: const Icon(Icons.delete, color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
