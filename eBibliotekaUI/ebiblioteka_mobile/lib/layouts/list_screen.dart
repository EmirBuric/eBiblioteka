import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ebiblioteka_mobile/layouts/master_screen.dart';

class ListScreen<T> extends StatefulWidget {
  final String title;
  final Future<dynamic> Function(Map<String, dynamic>) fetchData;
  final Widget Function(T item) itemBuilder;
  final Function(String) onSearch;
  final Map<String, dynamic> Function(String)? addSearchParams;
  final int selectedIndex;

  const ListScreen({
    Key? key,
    required this.title,
    required this.fetchData,
    required this.itemBuilder,
    required this.onSearch,
    this.addSearchParams,
    this.selectedIndex = 1,
  }) : super(key: key);

  @override
  State<ListScreen<T>> createState() => _ListScreenState<T>();
}

class _ListScreenState<T> extends State<ListScreen<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<T> items = [];
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMoreData = true;
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
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
        items.clear();
      });
      widget.onSearch(searchQuery);
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (isLoading || (!hasMoreData && currentPage > 1)) return;

    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> filter = {
        'Page': currentPage,
        'PageSize': pageSize,
      };

      if (searchQuery.isNotEmpty) {
        if (widget.addSearchParams != null) {
          var searchParams = widget.addSearchParams!(searchQuery);
          filter.addAll(searchParams);
        } else {
          filter['SearchTerm'] = searchQuery;
        }
      }

      final result = await widget.fetchData(filter);

      if (!mounted) return;

      setState(() {
        if (currentPage == 1) {
          items = List<T>.from(result.result);
        } else {
          items.addAll(List<T>.from(result.result));
        }

        hasMoreData = result.result.length == pageSize;
        if (hasMoreData) {
          currentPage++;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadData();
    }
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      currentPage = 1;
      hasMoreData = true;
      items.clear();
    });
    widget.onSearch(value);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pretraži...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _onSearchChanged(),
                ),
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading && items.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : items.isEmpty
                    ? const Center(
                        child: Text(
                          'Nema rezultata',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: items.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < items.length) {
                            return widget.itemBuilder(items[index]);
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
    );

    return MasterScreen(
      selectedIndex: widget.selectedIndex,
      child: content,
    );
  }
}
