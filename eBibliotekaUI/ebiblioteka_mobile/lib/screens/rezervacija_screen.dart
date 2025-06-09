import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/models/korisnik_izabrana_knjiga.dart';
import 'package:ebiblioteka_mobile/models/recenzija.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/korisnik_izabrana_knjiga_provider.dart';
import 'package:ebiblioteka_mobile/providers/recenzija_provider.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';
import 'package:ebiblioteka_mobile/screens/rezervacija_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RezervacijaScreen extends StatefulWidget {
  final Knjiga knjiga;

  const RezervacijaScreen({Key? key, required this.knjiga}) : super(key: key);

  @override
  State<RezervacijaScreen> createState() => _RezervacijaScreenState();
}

class _RezervacijaScreenState extends State<RezervacijaScreen> {
  final RecenzijaProvider _recenzijaProvider = RecenzijaProvider();
  final KnjigaProvider _knjigaProvider = KnjigaProvider();
  final KorisnikIzabranaKnjigaProvider _korisnikIzabranaKnjigaProvider =
      KorisnikIzabranaKnjigaProvider();
  List<Recenzija> _recenzije = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int currentPage = 1;
  int pageSize = 4;
  final ScrollController _scrollController = ScrollController();

  bool _showCalendar = false;
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDayFrom;
  DateTime? _selectedDayTo;
  Map<DateTime, bool>? _dostupnostMapa;
  bool _isLoadingDostupnost = false;
  final DateTime _datumOd = DateTime.now();
  final DateTime _datumDo = DateTime.now().add(const Duration(days: 30));
  bool _isProcessingRezervacija = false;

  @override
  void initState() {
    super.initState();
    _loadRecenzije();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreRecenzije();
    }
  }

  Future<void> _loadRecenzije() async {
    try {
      var filter = {
        'KnjigaId': widget.knjiga.knjigaId,
        'Odobrena': true,
        'Page': currentPage,
        'PageSize': pageSize,
      };
      var result = await _recenzijaProvider.get(filter: filter);

      setState(() {
        if (currentPage == 1) {
          _recenzije = result.result;
        } else {
          _recenzije.addAll(result.result);
        }
        _isLoading = false;
        _isLoadingMore = false;
        _hasMoreData = result.result.length >= pageSize;
      });
    } catch (e) {
      print('Greška prilikom učitavanja recenzija: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreRecenzije() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      currentPage++;
    });

    await _loadRecenzije();
  }

  Future<void> _loadDostupnost() async {
    if (widget.knjiga.knjigaId == null) return;

    setState(() {
      _isLoadingDostupnost = true;
    });

    try {
      final dostupnostKnjige = await _knjigaProvider.getDostupnostZaPeriod(
          widget.knjiga.knjigaId!, _datumOd, _datumDo);

      setState(() {
        _dostupnostMapa = dostupnostKnjige.dostupnost;
        _isLoadingDostupnost = false;
      });
    } catch (e) {
      print('Greška prilikom učitavanja dostupnosti: $e');
      setState(() {
        _isLoadingDostupnost = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom učitavanja dostupnosti: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isKnjigaDostupnaUPeriodu() {
    if (_dostupnostMapa == null || _selectedDayFrom == null) return false;

    if (_selectedDayTo == null) {
      DateTime currentDate = DateTime(_selectedDayFrom!.year,
          _selectedDayFrom!.month, _selectedDayFrom!.day);
      final endDate = currentDate.add(const Duration(days: 7));

      while (currentDate.isBefore(endDate)) {
        final formattedDate =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        final isDostupna = _dostupnostMapa![formattedDate] ?? true;

        if (!isDostupna) {
          return false;
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
      return true;
    }

    DateTime currentDate = DateTime(
        _selectedDayFrom!.year, _selectedDayFrom!.month, _selectedDayFrom!.day);
    final endDate = DateTime(
        _selectedDayTo!.year, _selectedDayTo!.month, _selectedDayTo!.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final formattedDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      final isDostupna = _dostupnostMapa![formattedDate] ?? true;

      if (!isDostupna) {
        return false;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return true;
  }

  Future<void> _dodajUListuRezervacija() async {
    if (widget.knjiga.knjigaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška: Knjiga nema ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (AuthProvider.trenutniKorisnikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Morate biti prijavljeni da biste rezervisali knjigu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDayFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Molimo odaberite barem datum od'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isKnjigaDostupnaUPeriodu()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Knjiga nije dostupna u odabranom periodu. Molimo odaberite drugi period.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingRezervacija = true;
    });

    try {
      final rezervacija = KorisnikIzabranaKnjiga(
        korisnikId: AuthProvider.trenutniKorisnikId,
        knjigaId: widget.knjiga.knjigaId,
        datumRezervacije: _selectedDayFrom,
        datumVracanja: _selectedDayTo,
      );

      await _korisnikIzabranaKnjigaProvider.insert(rezervacija);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedDayTo != null
              ? 'Knjiga dodana u listu rezervacija za period od ${formatDateToLocal(_selectedDayFrom!)} do ${formatDateToLocal(_selectedDayTo!)}'
              : 'Knjiga dodana u listu rezervacija za datum ${formatDateToLocal(_selectedDayFrom!)} do ${formatDateToLocal(_selectedDayFrom!.add(const Duration(days: 7)))}'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _showCalendar = false;
        _isProcessingRezervacija = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RezervacijaListScreen()),
      );
    } catch (e) {
      print('Greška prilikom rezervacije knjige: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška prilikom rezervacije knjige: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isProcessingRezervacija = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Knjiga'),
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    _buildKnjigaHeader(),
                    if (_showCalendar)
                      Expanded(
                        child: _buildCalendarSection(),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatusBar(),
                            Expanded(child: _buildRecenzijeList()),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: _showCalendar
                            ? ElevatedButton(
                                onPressed: (_selectedDayFrom != null &&
                                        !_isProcessingRezervacija)
                                    ? _dodajUListuRezervacija
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isProcessingRezervacija
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Dodaj u listu za rezervaciju',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  _showAddRecenzijaDialog();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.purple),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Ocjenite ovu knjigu',
                                  style: TextStyle(color: Colors.purple),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildKnjigaHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: widget.knjiga.slika != null
          ? BoxDecoration(
              image: DecorationImage(
                image: memoryImageFromString(widget.knjiga.slika!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            )
          : BoxDecoration(
              color: Colors.grey[300],
            ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.knjiga.naziv ?? 'Nepoznat naslov',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: widget.knjiga.dostupna == true
                    ? () {
                        setState(() {
                          _showCalendar = !_showCalendar;
                          if (_showCalendar) {
                            _selectedDayFrom = null;
                            _selectedDayTo = null;
                            _loadDostupnost();
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_showCalendar ? 'Recenzije' : 'Odaberi datum'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekdayOfMonth; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);

      final isSelectedFrom = _selectedDayFrom != null &&
          _selectedDayFrom!.year == date.year &&
          _selectedDayFrom!.month == date.month &&
          _selectedDayFrom!.day == date.day;

      final isSelectedTo = _selectedDayTo != null &&
          _selectedDayTo!.year == date.year &&
          _selectedDayTo!.month == date.month &&
          _selectedDayTo!.day == date.day;

      final isInRange = _selectedDayFrom != null &&
          _selectedDayTo != null &&
          date.isAfter(_selectedDayFrom!) &&
          date.isBefore(_selectedDayTo!);

      bool isDostupna = true;
      if (_dostupnostMapa != null) {
        final formattedDate = DateTime(date.year, date.month, date.day);
        isDostupna = _dostupnostMapa![formattedDate] ?? true;
      }

      final bool isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final bool isPast =
          date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      final bool isOutOfRange =
          date.isBefore(_datumOd) || date.isAfter(_datumDo);

      Color dayColor;
      if (isSelectedFrom) {
        dayColor = Colors.purple;
      } else if (isSelectedTo) {
        dayColor = Colors.deepPurple;
      } else if (isInRange) {
        dayColor = Colors.purpleAccent;
      } else if (isToday) {
        dayColor = Colors.blue;
      } else if (isPast || isOutOfRange) {
        dayColor = Colors.grey;
      } else if (isDostupna) {
        dayColor = Colors.green;
      } else if (!isDostupna) {
        dayColor = Colors.red;
      } else {
        dayColor = Colors.grey;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: (isPast || isOutOfRange || !isDostupna)
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isPast
                          ? 'Ne možete odabrati datum koji je prošao'
                          : isOutOfRange
                              ? 'Možete odabrati datum samo između ${DateFormat('dd.MM.yyyy').format(_datumOd)} i ${DateFormat('dd.MM.yyyy').format(_datumDo)}'
                              : 'Knjiga nije dostupna na odabrani datum'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              : () {
                  setState(() {
                    if (_selectedDayFrom == null) {
                      _selectedDayFrom = date;
                    } else if (_selectedDayTo == null) {
                      if (date.isAfter(_selectedDayFrom!)) {
                        _selectedDayTo = date;
                      } else {
                        _selectedDayTo = _selectedDayFrom;
                        _selectedDayFrom = date;
                      }
                    } else {
                      _selectedDayFrom = date;
                      _selectedDayTo = null;
                    }
                  });
                },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dayColor,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kalendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        _isLoadingDostupnost
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
            : Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text('Pon',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Uto',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Sri',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Čet',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Pet',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Sub',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Ned',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 7,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: 1.0,
                          children: dayWidgets,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedDayFrom != null)
                          Text(
                            'Datum od: ${DateFormat('dd.MM.yyyy').format(_selectedDayFrom!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (_selectedDayTo != null)
                          Text(
                            'Datum do: ${DateFormat('dd.MM.yyyy').format(_selectedDayTo!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildLegendItem(Colors.green, 'Dostupno'),
                            _buildLegendItem(Colors.blue, 'Danas'),
                            _buildLegendItem(Colors.purple, 'Datum od'),
                            _buildLegendItem(Colors.deepPurple, 'Datum do'),
                            _buildLegendItem(Colors.purpleAccent, 'Period'),
                            _buildLegendItem(Colors.red, 'Nedostupno'),
                            _buildLegendItem(Colors.grey, 'Nedostupan period'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Odaberite datum od i datum do za rezervaciju',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusBar() {
    final bool isDostupna = widget.knjiga.dostupna == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDostupna ? Colors.purple : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isDostupna
                      ? const Icon(Icons.check_circle,
                          color: Colors.purple, size: 18)
                      : const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Dostupna',
                    style: TextStyle(
                      color: isDostupna ? Colors.purple : Colors.grey,
                      fontWeight:
                          isDostupna ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isDostupna ? Colors.purple : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !isDostupna
                      ? const Icon(Icons.check_circle,
                          color: Colors.purple, size: 18)
                      : const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Nedostupna',
                    style: TextStyle(
                      color: !isDostupna ? Colors.purple : Colors.grey,
                      fontWeight:
                          !isDostupna ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecenzijeList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Recenzije',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _recenzije.isEmpty
                  ? _buildNoRecenzijeWidget()
                  : Column(
                      children: [
                        ..._recenzije
                            .map((recenzija) => _buildRecenzijaItem(recenzija))
                            .toList(),
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRecenzijeWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          'Nema recenzija',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildRecenzijaItem(Recenzija recenzija) {
    String korisnikInfo = 'Nepoznati korisnik';
    if (recenzija.korisnik != null) {
      if (recenzija.korisnik!.ime != null &&
          recenzija.korisnik!.prezime != null) {
        korisnikInfo =
            '${recenzija.korisnik!.ime} ${recenzija.korisnik!.prezime}';
      } else if (recenzija.korisnik!.korisnickoIme != null) {
        korisnikInfo = recenzija.korisnik!.korisnickoIme!;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        korisnikInfo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < (recenzija.ocjena ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recenzija.opis ?? 'Nema opisa',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecenzijaDialog() {
    int ocjena = 3;
    final opisController = TextEditingController();

    if (AuthProvider.trenutniKorisnikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Morate biti prijavljeni da biste dodali recenziju'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova recenzija'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ocjena:'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < ocjena ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          ocjena = index + 1;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Opis:'),
              const SizedBox(height: 8),
              TextField(
                controller: opisController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Unesite vaše mišljenje o knjizi',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (opisController.text.isNotEmpty) {
                try {
                  final recenzija = Recenzija(
                    knjigaId: widget.knjiga.knjigaId,
                    korisnikId: AuthProvider.trenutniKorisnikId,
                    opis: opisController.text,
                    ocjena: ocjena,
                  );

                  await _recenzijaProvider.insert(recenzija);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Recenzija je uspješno poslana i čeka odobrenje'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadRecenzije();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Greška: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Molimo unesite opis recenzije')),
                );
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}
