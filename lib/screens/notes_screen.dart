import 'package:flutter/material.dart';
import '../models/law.dart';
import '../services/storage_service.dart';
import '../data/laws.dart' show allLaws;

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /// Charge toutes les notes depuis StorageService et met à jour l'UI.
  Future<void> _loadNotes() async {
    final notes = await StorageService.getAllNotes();
    // Trie les notes par numéro de loi pour un affichage plus cohérent
    notes.sort((a, b) => a['lawNumber'].compareTo(b['lawNumber']));
    setState(() {
      _notes = notes;
    });
  }

  /// Affiche un pop-up pour ajouter ou modifier une note.
  /// Si [initialLawNumber] et [initialNoteText] sont fournis, c'est une modification.
  Future<void> _showNoteFormPopup({
    int? initialLawNumber,
    String? initialNoteText,
  }) async {
    // IMPORTANT : selectedLaw doit être initialized correctement en fonction de initialLawNumber
    Law? selectedLaw = initialLawNumber != null
        ? allLaws.firstWhere(
            (law) => law.numero == initialLawNumber,
            orElse: () => allLaws.first, // Fallback si la loi n'est pas trouvée (peu probable)
          )
        : null; // Pour une nouvelle note, initialLawNumber est null, donc selectedLaw commence à null

    final TextEditingController noteController =
        TextEditingController(text: initialNoteText ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInsideDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A), // Couleur de fond du dialogue
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        initialLawNumber != null ? 'Modifier la Note' : 'Ajouter une Nouvelle Note',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 95, 114, 236),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Sélecteur de loi
                      DropdownButtonFormField<Law>(
                        // Assurez-vous que la valeur affichée est la bonne lors de la modification
                        value: selectedLaw,
                        dropdownColor: const Color(0xFF1A1A1A),
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Choisir une loi',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF8090FF)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        // Affichage correct du texte dans le Dropdown
                        selectedItemBuilder: (BuildContext context) {
                          return allLaws.map<Widget>((Law law) {
                            return Text(
                              'Loi ${law.numero} - ${law.titre}',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis, // Gérer le débordement
                            );
                          }).toList();
                        },
                        items: allLaws.map((Law law) {
                          return DropdownMenuItem<Law>(
                            value: law,
                            child: Text(
                                'Loi ${law.numero} - ${law.titre}',
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: initialLawNumber != null // Désactiver si c'est une modification
                            ? null // Empêche de changer la loi si on modifie une note existante
                            : (Law? newValue) {
                                setStateInsideDialog(() {
                                  selectedLaw = newValue;
                                });
                              },
                        // Afficher un texte indicatif si le Dropdown est désactivé
                        hint: initialLawNumber != null
                            ? Text('Loi ${selectedLaw?.numero} - ${selectedLaw?.titre}', style: const TextStyle(color: Colors.white))
                            : const Text('Sélectionnez une loi', style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 20),
                      // Champ de texte pour la note
                      TextField(
                        controller: noteController,
                        maxLines: null,
                        minLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Note/Commentaire',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Saisissez votre note ici...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF8090FF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Si c'est une modification, utilise initialLawNumber pour la sauvegarde
                              // Si c'est un ajout, utilise selectedLaw.numero
                              final int lawToSave = initialLawNumber ?? selectedLaw!.numero;

                              if (noteController.text.trim().isEmpty) {
                                // Si le champ de note est vide, supprime la note
                                await StorageService.deleteNoteForLaw(lawToSave);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Note supprimée (vide) !')),
                                  );
                                }
                              } else if (selectedLaw != null || initialLawNumber != null) {
                                await StorageService.saveNoteForLaw(lawToSave, noteController.text);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(initialLawNumber != null
                                            ? 'Note modifiée !'
                                            : 'Note ajoutée !')),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Veuillez sélectionner une loi.')),
                                  );
                                }
                              }
                              if (context.mounted) {
                                Navigator.pop(context); // Ferme le pop-up
                              }
                              _loadNotes(); // Recharger les notes pour mettre à jour la liste
                            },
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text('Enregistrer',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8090FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context); // Ferme le pop-up
                            },
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: const Text('Annuler',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Affiche un pop-up avec les détails d'une note.
  void _showNoteDetailsPopup(Map<String, dynamic> note) {
    final law = allLaws.firstWhere(
      (l) => l.numero == note['lawNumber'],
      orElse: () =>
          Law(numero: note['lawNumber'], titre: 'Loi inconnue', texte: '', explication: ''),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Couleur de fond du dialogue
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Loi ${law.numero}: ${law.titre}',
                    style: const TextStyle(
                      color: Color(0xFF8090FF),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white38),
                  const SizedBox(height: 10),
                  Text(
                    note['note'],
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Ferme le pop-up de détails
                          _showNoteFormPopup(
                            initialLawNumber: law.numero, // C'est crucial ici !
                            initialNoteText: note['note'],
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Modifier',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 6, 197),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context); // Ferme le pop-up de détails
                          // Afficher une confirmation avant de supprimer
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF1A1A1A),
                                title: const Text('Confirmer la suppression', style: TextStyle(color: Color(0xFF8090FF))),
                                content: Text('Voulez-vous vraiment supprimer la note pour la Loi ${law.numero} ?', style: const TextStyle(color: Colors.white70)),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            await StorageService.deleteNoteForLaw(law.numero);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Note pour la loi ${law.numero} supprimée !')),
                            );
                            _loadNotes(); // Recharger les notes
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text('Supprimer',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 6, 3, 179),
                Color.fromARGB(255, 6, 3, 179),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Mes Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 6, 3, 179),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Image.asset(
                  'assets/images/logo2.png',
                  fit: BoxFit.contain,
                  opacity: const AlwaysStoppedAnimation(0.2),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: _notes.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune note pour l\'instant. Cliquez sur le bouton "+" pour ajouter une note !',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            final law = allLaws.firstWhere(
                              (l) => l.numero == note['lawNumber'],
                              orElse: () => Law(numero: note['lawNumber'], titre: 'Loi inconnue', texte: '', explication: ''),
                            );

                            return GestureDetector(
                              onTap: () => _showNoteDetailsPopup(note),
                              child: Card(
                                color: const Color(0xFF1A1A1A).withOpacity(0.8),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: const Color.fromARGB(255, 3, 30, 211).withOpacity(0.5)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Loi ${law.numero}: ${law.titre}',
                                        style: const TextStyle(color: Color(0xFF8090FF), fontWeight: FontWeight.bold, fontSize: 17),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note['note'],
                                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          'Cliquer pour voir les détails',
                                          style: TextStyle(color: Colors.blueGrey[300], fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteFormPopup(), // Aucun paramètre = nouvelle note
        backgroundColor: const Color.fromARGB(255, 2, 27, 189),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}