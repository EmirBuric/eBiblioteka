import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../layouts/master_screen.dart';
import '../providers/knjiga_provider.dart';
import '../models/izvjestaj_knjiga.dart';
import '../models/knjiga.dart';
import '../providers/utils.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class IzvjestajScreen extends StatefulWidget {
  const IzvjestajScreen({super.key});

  @override
  State<IzvjestajScreen> createState() => _IzvjestajScreenState();
}

class _IzvjestajScreenState extends State<IzvjestajScreen> {
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  IzvjestajKnjiga? izvjestaj;
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  List<Knjiga> _searchResults = [];
  Knjiga? _selectedKnjiga;
  DateTimeRange? _dateRange;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchKnjige(String query) async {
    setState(() => _isSearching = true);
    try {
      final data = await _knjigaProvider.get(filter: {'NazivGTE': query});
      setState(() {
        _searchResults = data.result;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange ?? DateTimeRange(start: monthAgo, end: now),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 400,
            height: 500,
            child: child,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _tryLoadReport();
    }
  }

  Future<void> _tryLoadReport() async {
    if (_selectedKnjiga != null && _dateRange != null) {
      setState(() => isLoading = true);
      try {
        final data = await _knjigaProvider.getKnjigaIzvjestaj(
            _selectedKnjiga!.knjigaId!, _dateRange!.start, _dateRange!.end);
        setState(() {
          izvjestaj = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
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
  }

  Widget _buildPieChart() {
    if (izvjestaj == null) {
      return const Center(
        child: Text(
          'Molimo odaberite knjigu i period za prikaz izvještaja',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (izvjestaj?.recenzijePoOcjeni == null ||
        izvjestaj!.recenzijePoOcjeni!.isEmpty) {
      return const Center(
        child: Text(
          'Nema podataka o recenzijama za odabrani period',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final recenzije = izvjestaj!.recenzijePoOcjeni!;

    bool sveNule = true;
    for (var vrijednost in recenzije.values) {
      if (vrijednost > 0) {
        sveNule = false;
        break;
      }
    }

    if (sveNule) {
      return const Center(
        child: Text(
          'Nema podataka o recenzijama za odabrani period',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.lightGreen,
      Colors.blueAccent,
    ];

    final ukupnoRecenzija =
        recenzije.values.fold<int>(0, (sum, broj) => sum + broj);
    //final maxRecenzija = recenzije.values.reduce((a, b) => a > b ? a : b);
    //final scaleFactor = maxRecenzija > 0 ? 100.0 / maxRecenzija : 1.0;

    return PieChart(
      PieChartData(
        sections: List.generate(5, (i) {
          final ocjena = i + 1;
          final broj = recenzije[ocjena] ?? 0;
          final procenat = broj > 0
              ? (broj / ukupnoRecenzija * 100).toStringAsFixed(1)
              : '0';
          return PieChartSectionData(
            color: colors[i],
            value: broj.toDouble(),
            title: broj > 0 ? 'Ocjena $ocjena\n$broj ($procenat%)' : '',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }),
        sectionsSpace: 2,
        centerSpaceRadius: 20,
      ),
    );
  }

  Widget _buildBarChart() {
    if (izvjestaj == null) {
      return const Center(
        child: Text(
          'Molimo odaberite knjigu i period za prikaz izvještaja',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (izvjestaj?.rezervacijePoMjesecu == null ||
        izvjestaj!.rezervacijePoMjesecu!.isEmpty) {
      return const Center(
        child: Text(
          'Nema podataka o rezervacijama za odabrani period',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final rezervacije = izvjestaj!.rezervacijePoMjesecu!;

    bool sveNule = true;
    for (var vrijednost in rezervacije.values) {
      if (vrijednost > 0) {
        sveNule = false;
        break;
      }
    }

    if (sveNule) {
      return const Center(
        child: Text(
          'Nema podataka o rezervacijama za odabrani period',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final mjeseci = rezervacije.keys.toList()..sort();
    final data = mjeseci
        .map((mjesec) => rezervacije[mjesec]?.toDouble() ?? 0.0)
        .toList();

    final maxY = data.reduce((a, b) => a > b ? a : b);
    final yAxisMax = (maxY * 1.2).ceil().toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: yAxisMax,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= mjeseci.length) return const Text('');
                return Text(
                  mjeseci[value.toInt()],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: Colors.blueAccent,
                width: 28,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _generatePdf() async {
    if (izvjestaj == null || _dateRange == null) return;

    setState(() => isLoading = true);

    try {
      final pdf = pw.Document();

      final ByteData logoData = await rootBundle.load('assets/Logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      Uint8List? knjigaImageBytes;
      if (_selectedKnjiga?.slika != null) {
        try {
          final ui.Image knjigaImage =
              await imageFromStringAsUiImage(_selectedKnjiga!.slika!);
          knjigaImageBytes = await knjigaImageToBytes(knjigaImage);
        } catch (e) {
          print('Greška pri učitavanju slike knjige: $e');
        }
      }

      bool hasPieChartData = izvjestaj?.recenzijePoOcjeni != null &&
          izvjestaj!.recenzijePoOcjeni!.isNotEmpty &&
          izvjestaj!.recenzijePoOcjeni!.values.any((v) => v > 0);

      bool hasBarChartData = izvjestaj?.rezervacijePoMjesecu != null &&
          izvjestaj!.rezervacijePoMjesecu!.isNotEmpty &&
          izvjestaj!.rezervacijePoMjesecu!.values.any((v) => v > 0);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 50,
                    height: 50,
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'eBiblioteka',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Izvjestaj za knjigu',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                izvjestaj?.naziv ?? 'Knjiga',
                style: pw.TextStyle(
                  fontSize: 16,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Period: ${formatDateToLocal(_dateRange!.start)} - ${formatDateToLocal(_dateRange!.end)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),
              if (knjigaImageBytes != null)
                pw.Center(
                  child: pw.Container(
                    width: 100,
                    height: 140,
                    child: pw.Image(
                      pw.MemoryImage(knjigaImageBytes),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              if (knjigaImageBytes != null) pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Recenzije',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (hasPieChartData) ...[
                      pw.Text(
                          'Prosjecna ocjena: ${izvjestaj?.prosjecnaOcjena?.toStringAsFixed(2) ?? "N/A"}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Distribucija ocjena:'),
                      pw.SizedBox(height: 5),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text('Ocjena',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text('Broj recenzija',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...List.generate(5, (i) {
                            final ocjena = i + 1;
                            final broj =
                                izvjestaj?.recenzijePoOcjeni?[ocjena] ?? 0;
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('$ocjena'),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('$broj'),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ] else
                      pw.Text('Nema podataka o recenzijama za odabrani period'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Rezervacije',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (hasBarChartData) ...[
                      pw.Text(
                          'Ukupno rezervacija: ${izvjestaj!.rezervacijePoMjesecu!.values.fold<int>(0, (sum, value) => sum + value)}'),
                      pw.SizedBox(height: 5),
                      pw.Text('Rezervacije po mjesecima:'),
                      pw.SizedBox(height: 5),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text('Mjesec',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text('Broj rezervacija',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...izvjestaj!.rezervacijePoMjesecu!.entries
                              .map((entry) => pw.TableRow(
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(5),
                                        child: pw.Text(entry.key),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(5),
                                        child: pw.Text('${entry.value}'),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ],
                      ),
                    ] else
                      pw.Text(
                          'Nema podataka o rezervacijama za odabrani period'),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/izvjestaj_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      OpenFile.open(file.path);

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Greška'),
          content: Text('Došlo je do greške prilikom generiranja PDF-a: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<ui.Image> imageFromStringAsUiImage(String base64String) async {
    final Uint8List bytes = base64Decode(base64String);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<Uint8List> knjigaImageToBytes(ui.Image image) async {
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Izvještaj",
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SEARCH BAR
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Pretraži knjige po nazivu...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _isSearching
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2)),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length >= 2) {
                                  _searchKnjige(value);
                                } else {
                                  setState(() {
                                    _searchResults = [];
                                  });
                                }
                              },
                            ),
                            if (_searchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final knjiga = _searchResults[index];
                                    return ListTile(
                                      title: Text(knjiga.naziv ?? ''),
                                      onTap: () {
                                        setState(() {
                                          _selectedKnjiga = knjiga;
                                          _searchController.text =
                                              knjiga.naziv ?? '';
                                          _searchResults = [];
                                          izvjestaj = null;
                                          _dateRange = null;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (_selectedKnjiga != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton.icon(
                                  onPressed: _pickDateRange,
                                  icon: const Icon(Icons.date_range),
                                  label: Text(_dateRange == null
                                      ? 'Odaberi period izvještaja'
                                      : '${formatDateToLocal(_dateRange!.start)} - ${formatDateToLocal(_dateRange!.end)}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_selectedKnjiga == null || _dateRange == null)
                        Card(
                          margin: const EdgeInsets.all(32),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Molimo odaberite knjigu i period za prikaz izvještaja',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Koristite polje za pretragu iznad da odaberete knjigu i kliknite na dugme za odabir perioda',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                const Icon(
                                  Icons.menu_book,
                                  size: 150,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_selectedKnjiga != null &&
                          _dateRange != null &&
                          izvjestaj != null)
                        Column(
                          children: [
                            Container(
                              width: 220,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _selectedKnjiga?.slika != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: imageFromString(
                                          _selectedKnjiga!.slika!),
                                    )
                                  : const Icon(Icons.book,
                                      size: 100, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              izvjestaj?.naziv ?? 'Knjiga',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 101, 85, 143),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Izvještaj',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text('Recenzije',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: 180,
                                              child: _buildPieChart()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text('Rezervacije',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: 180,
                                              child: _buildBarChart()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 101, 85, 143),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Nazad',
                                      style: TextStyle(fontSize: 18)),
                                ),
                                const SizedBox(width: 32),
                                ElevatedButton(
                                  onPressed: () {
                                    _generatePdf();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Printaj',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
