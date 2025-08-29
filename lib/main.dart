import 'package:flutter/material.dart';
import 'package:projet1/redacteur_interface.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine Infos',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const PageAccueil(),
    );
  }
}

/* ----------------------------- DATA MODELS ----------------------------- */

class Article {
  final String title;
  final String subtitle;
  final IconData icon;
  final String category;

  Article({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
  });
}

class Rubrique {
  final String tag; // for Hero
  final String image;
  final String title;

  Rubrique({required this.tag, required this.image, required this.title});
}

/* ------------------------------- ACCUEIL ------------------------------- */

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key});

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  // Articles (egzanp done)
  final List<Article> allArticles = [
    Article(
      title: "La mode en 2025",
      subtitle: "Tendances, matériaux et créateurs à suivre",
      icon: Icons.checkroom,
      category: "Mode",
    ),
    Article(
      title: "Nouvelles technologies",
      subtitle: "Du quantique à l’edge AI",
      icon: Icons.computer,
      category: "Tech",
    ),
    Article(
      title: "Musique & Culture",
      subtitle: "Scènes locales et sons globaux",
      icon: Icons.music_note,
      category: "Culture",
    ),
    Article(
      title: "Voyage à travers le monde",
      subtitle: "Itinéraires, sécurité, budgets",
      icon: Icons.flight_takeoff,
      category: "Voyage",
    ),
    Article(
      title: "L’avenir de l’IA",
      subtitle: "Impacts, éthique et métiers",
      icon: Icons.smart_toy,
      category: "Tech",
    ),
  ];

  late List<Article> filteredArticles;

  // Rubriques (imaj yo dwe egziste nan assets ou)
  final List<Rubrique> rubriques = [
    Rubrique(tag: "rub1", image: "assets/images/rubrique1.png", title: "Lifestyle"),
    Rubrique(tag: "rub2", image: "assets/images/rubrique2.png", title: "Tech"),
    Rubrique(tag: "rub3", image: "assets/images/magazineInfo.jpg", title: "Culture"),
    Rubrique(tag: "rub4", image: "assets/images/autreImage.jpg", title: "Voyage"),
  ];

  @override
  void initState() {
    super.initState();
    filteredArticles = List.of(allArticles);
  }

  void _filterArticles(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        filteredArticles = List.of(allArticles);
      } else {
        filteredArticles = allArticles.where((a) {
          return a.title.toLowerCase().contains(q) ||
              a.subtitle.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _resetSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filteredArticles = List.of(allArticles);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Rechercher un article…',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _filterArticles,
        )
            : const Text('Magazine Infos'),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (isSearching) {
                _resetSearch();
              } else {
                setState(() => isSearching = true);
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header image + title block
            const _Header(),
            const SizedBox(height: 8),
            const PartieTitre(),
            const PartieTexte(),
            const SizedBox(height: 8),
            const PartieIcone(),
            const SizedBox(height: 8),

            // Rubriques en Grid (Hero + navigation)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _RubriqueGrid(rubriques: rubriques),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Articles list + AnimatedSwitcher sou chanjman
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.article),
                  SizedBox(width: 8),
                  Text(
                    "Articles disponibles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: filteredArticles.isEmpty
                  ? Padding(
                key: const ValueKey("empty"),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: const [
                    Icon(Icons.search_off, size: 48),
                    SizedBox(height: 8),
                    Text("Aucun article trouvé"),
                  ],
                ),
              )
                  : ListView.builder(
                key: ValueKey(filteredArticles.length),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final a = filteredArticles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    elevation: 0.5,
                    child: ListTile(
                      leading: Icon(a.icon, color: cs.primary),
                      title: Text(a.title),
                      subtitle: Text(a.subtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Ou te chwazi: ${a.title}"),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Magazine Infos"),
            accountEmail: const Text("contact@magazineinfos.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/magazineInfo.jpg"),
            ),
            decoration: BoxDecoration(color: cs.primary),
          ),
          ListTile(
            leading: Icon(Icons.home, color: cs.primary),
            title: const Text("Accueil"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.article, color: cs.primary),
            title: const Text("Articles"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.photo, color: cs.primary),
            title: const Text("Galerie"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.contact_mail, color: cs.primary),
            title: const Text("Contact"),
            onTap: () => Navigator.pop(context),
          ),
          // --------- NOUVO BOUTON REDACTEUR ---------
          ListTile(
            leading: Icon(Icons.person, color: cs.primary),
            title: const Text("Gestion des Rédacteurs"),
            onTap: () {
              Navigator.pop(context); // fèmen drawer la
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RedacteurInterface()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text("Paramètres"),
          ),
        ],
      ),
    );
  }

//rive la
}

/* ----------------------------- HEADER WIDGET ---------------------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        const Image(
          image: AssetImage('assets/images/magazineInfo.jpg'),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, cs.surface.withOpacity(0.85)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Row(
              children: [
                Icon(Icons.public, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  "L’info à portée de main",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* --------------------------- BLOCS DE CONTENU --------------------------- */

class PartieTitre extends StatelessWidget {
  const PartieTitre({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue sur Magazine Infos",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "L’information à portée de main",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class PartieTexte extends StatelessWidget {
  const PartieTexte({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Magazine Infos est une application numérique internationale qui offre à ses "
            "lecteurs des articles variés : mode, technologie, musique, voyages, culture, et bien plus encore.",
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}

class PartieIcone extends StatelessWidget {
  const PartieIcone({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _IconeItem(icon: Icons.phone, label: "TEL", color: cs.secondary),
          _IconeItem(icon: Icons.email, label: "MAIL", color: cs.secondary),
          _IconeItem(icon: Icons.share, label: "PARTAGE", color: cs.secondary),
        ],
      ),
    );
  }
}

class _IconeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _IconeItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

/* ---------------------------- RUBRIQUE GRID ----------------------------- */

class _RubriqueGrid extends StatelessWidget {
  final List<Rubrique> rubriques;
  const _RubriqueGrid({required this.rubriques});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 500 ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: rubriques.map((r) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RubriqueDetailPage(rubrique: r),
              ),
            );
          },
          child: Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: r.tag,
                  child: Image.asset(r.image, fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/* -------------------------- RUBRIQUE DETAIL PAGE ------------------------ */

class RubriqueDetailPage extends StatelessWidget {
  final Rubrique rubrique;
  const RubriqueDetailPage({super.key, required this.rubrique});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(rubrique.title),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Column(
        children: [
          Hero(
            tag: rubrique.tag,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(rubrique.image, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Découvrez la rubrique « ${rubrique.title} » : sélection d’articles, "
                  "idées, interviews et tendances pour vous inspirer.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Bientôt disponible: plus d’articles « ${rubrique.title} »")),
              ),
              icon: const Icon(Icons.explore),
              label: const Text("Explorer la rubrique"),
            ),
          ),
        ],
      ),
    );
  }
}
