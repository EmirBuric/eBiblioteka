import 'package:flutter/material.dart';
import 'package:ebiblioteka_admin/layouts/master_screen.dart';
import '../providers/autor_provider.dart';
import '../models/autor.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../providers/utils.dart';

class AutorDodajScreen extends StatefulWidget {
  final Function? onAutorAdded;
  final Autor? autor;

  const AutorDodajScreen({super.key, this.onAutorAdded, this.autor});

  @override
  State<AutorDodajScreen> createState() => _AutorDodajScreenState();
}

class _AutorDodajScreenState extends State<AutorDodajScreen> {
  final _formKey = GlobalKey<FormState>();
  final AutorProvider _autorProvider = AutorProvider();
  DateTime? _selectedDate;

  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _biografijaController = TextEditingController();

  File? _image;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    if (widget.autor != null) {
      _imeController.text = widget.autor!.ime ?? '';
      _prezimeController.text = widget.autor!.prezime ?? '';
      _biografijaController.text = widget.autor!.biografija ?? '';
      _selectedDate = widget.autor!.datumRodjenja;
      _base64Image = widget.autor!.slika;
    }
  }

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _image = File(result.files.single.path!);
        _base64Image = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _biografijaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final autor = {
          'ime': _imeController.text,
          'prezime': _prezimeController.text,
          'datumRodjenja': _selectedDate?.toIso8601String(),
          'biografija': _biografijaController.text,
          'slika': _base64Image,
        };

        if (_selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datum rođenja je obavezno polje'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (widget.autor != null) {
          await _autorProvider.update(widget.autor!.autorId!, autor);
        } else {
          await _autorProvider.insert(autor);
        }

        if (widget.onAutorAdded != null) {
          widget.onAutorAdded!();
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Greška"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      widget.autor != null ? "Uredi autora" : "Dodaj autora",
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.autor != null
                          ? 'Uredi autora'
                          : 'Dodaj novog autora',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 101, 85, 143),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _base64Image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: imageFromString(_base64Image!),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: getImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('Dodaj sliku'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 101, 85, 143),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (_image != null || _base64Image != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                  _base64Image = null;
                                });
                              },
                              child: const Text(
                                'Ukloni sliku',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imeController,
                            decoration: InputDecoration(
                              labelText: 'Ime',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ovo polje ne može biti prazno';
                              }
                              if (value.length < 2) {
                                return 'Ime mora imati najmanje 2 karaktera';
                              }
                              if (value.length > 50) {
                                return 'Ime ne može imati više od 50 karaktera';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            controller: _prezimeController,
                            decoration: InputDecoration(
                              labelText: 'Prezime',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ovo polje ne može biti prazno';
                              }
                              if (value.length < 2) {
                                return 'Prezime mora imati najmanje 2 karaktera';
                              }
                              if (value.length > 50) {
                                return 'Prezime ne može imati više od 50 karaktera';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Datum rođenja',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Odaberite datum'
                                  : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}.',
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _biografijaController,
                      decoration: InputDecoration(
                        labelText: 'Biografija',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Biografija je obavezno polje';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 101, 85, 143),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Spremi autora',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
