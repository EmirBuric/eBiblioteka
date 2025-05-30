import 'dart:async';
import 'package:ebiblioteka_mobile/screens/knjiga_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/knjiga.dart';
import 'package:ebiblioteka_mobile/providers/utils.dart';

class DetailsScreen<T> extends StatefulWidget {
  final T item;
  final String title;
  final Widget Function(T item) detailsBuilder;
  final Future<dynamic> Function(Map<String, dynamic>) fetch;
  final Map<String, dynamic> Function(String) addSearchParams;

  // Add these new properties
  final String filterField;
  final int filterId;

  const DetailsScreen({
    Key? key,
    required this.item,
    required this.title,
    required this.detailsBuilder,
    required this.fetch,
    required this.addSearchParams,
    required this.filterField, // Add this
    required this.filterId, // Add this
  }) : super(key: key);

  @override
  State<DetailsScreen<T>> createState() => _DetailsScreenState<T>();
}

class _DetailsScreenState<T> extends State<DetailsScreen<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Knjiga> books = [];
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 3;
  bool hasMoreData = true;
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchController.text;
        currentPage = 1;
        hasMoreData = true;
        books.clear();
      });
      _loadData();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    debugPrint('Starting _loadData');
    if (isLoading || (!hasMoreData && currentPage > 1)) {
      return;
    }

    try {
      setState(() => isLoading = true);

      Map<String, dynamic> filter = {
        'Page': currentPage,
        'PageSize': pageSize,
        widget.filterField: widget.filterId,
      };

      if (searchQuery.isNotEmpty) {
        filter.addAll(widget.addSearchParams(searchQuery));
      }

      final result = await widget.fetch(filter);

      setState(() {
        if (currentPage == 1) {
          books = List<Knjiga>.from(result.result);
        } else {
          books.addAll(List<Knjiga>.from(result.result));
        }

        hasMoreData = result.result.length >= pageSize;
        if (hasMoreData) {
          currentPage++;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              widget.detailsBuilder(widget.item),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pretraži knjige...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: books.isEmpty
                    ? Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Nema rezultata',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: books.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < books.length) {
                            final knjiga = books[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: knjiga.slika != null
                                      ? imageFromString(knjiga.slika!)
                                      : const Icon(Icons.book),
                                ),
                                title: Text(knjiga.naziv ?? ''),
                                subtitle: Text(
                                    'Godina: ${knjiga.godinaIzdanja ?? 'Nepoznato'}'),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => KnjigaDetailsScreen(
                                        knjiga: knjiga,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
