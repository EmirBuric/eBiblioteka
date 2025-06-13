import 'dart:convert';
import 'package:ebiblioteka_mobile/layouts/master_screen.dart';
import 'package:ebiblioteka_mobile/models/clanarina.dart';
import 'package:ebiblioteka_mobile/models/tip_clanarine.dart';
import 'package:ebiblioteka_mobile/providers/auth_provider.dart';
import 'package:ebiblioteka_mobile/providers/clanarina_provider.dart';
import 'package:ebiblioteka_mobile/providers/tip_clanarine_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PayPalScreen extends StatefulWidget {
  final int tipClanarineId;

  const PayPalScreen({Key? key, required this.tipClanarineId})
      : super(key: key);

  @override
  State<PayPalScreen> createState() => _PayPalScreenState();
}

class _PayPalScreenState extends State<PayPalScreen> {
  final TipClanarineProvider _tipClanarineProvider = TipClanarineProvider();
  final ClanarinaProvider _clanarinaProvider = ClanarinaProvider();
  bool isLoading = true;
  TipClanarine? tipClanarine;
  Clanarina? trenutnaClanarina;
  WebViewController? _controller;

  final String clientId = dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['PAYPAL_SECRET_KEY'] ?? '';
  final String _paypalBaseUrl = dotenv.env['PAYPAL_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      tipClanarine = await _tipClanarineProvider.getById(widget.tipClanarineId);

      var korisnikId = AuthProvider.trenutniKorisnikId;
      if (korisnikId != null) {
        trenutnaClanarina =
            await _clanarinaProvider.getClanarinaByKorisnikId(korisnikId);
      }

      setState(() {
        isLoading = false;
      });

      if (tipClanarine != null) {
        _startPaymentProcess();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

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

  Future<void> _startPaymentProcess() async {
    try {
      final accessToken = await _getAccessToken();
      final orderUrl =
          await _createOrder(accessToken, tipClanarine!.cijena!.toDouble());
      _redirectToPayPal(orderUrl);
    } catch (e) {
      print("Greška tokom PayPal procesa plaćanja: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Greška prilikom iniciranja plaćanja: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_paypalBaseUrl/v1/oauth2/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else if (response.statusCode >= 400) {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = jsonDecode(response.body);
        } catch (_) {}

        String errorMessage = errorResponse['error_description'] ??
            errorResponse['message'] ??
            'Neuspješno dobijanje PayPal pristupnog tokena';
        throw Exception(errorMessage);
      } else {
        throw Exception('Neuspješno dobijanje PayPal pristupnog tokena');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Problem pri komunikaciji s PayPal servisom: $e');
    }
  }

  Future<String> _createOrder(String accessToken, double total) async {
    try {
      final response = await http.post(
        Uri.parse('$_paypalBaseUrl/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'amount': {
                'currency_code': 'EUR',
                'value': total.toString(),
              },
              'description':
                  'Članarina eBiblioteka - ${tipClanarine!.vrijemeTrajanja} mjeseci',
            },
          ],
          'application_context': {
            'return_url': 'https://ebiblioteka.com/success',
            'cancel_url': 'https://ebiblioteka.com/cancel',
          }
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final approvalUrl = data['links']
            .firstWhere((link) => link['rel'] == 'approve')['href'];
        return approvalUrl;
      } else if (response.statusCode >= 400) {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = jsonDecode(response.body);
        } catch (_) {}

        String errorMessage = errorResponse['message'] ??
            (errorResponse['details']?.isNotEmpty == true
                ? errorResponse['details'][0]['description']
                : null) ??
            'Neuspješno kreiranje PayPal narudžbe';
        throw Exception(errorMessage);
      } else {
        throw Exception('Neuspješno kreiranje PayPal narudžbe');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Problem pri komunikaciji s PayPal servisom: $e');
    }
  }

  void _redirectToPayPal(String approvalUrl) {
    final webviewController = _createWebViewController(approvalUrl);

    setState(() {
      _controller = webviewController;
    });
  }

  WebViewController _createWebViewController(String approvalUrl) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith('https://ebiblioteka.com/success')) {
              print("Plaćanje uspješno");
              _processClanarina();
              return NavigationDecision.prevent;
            }

            if (url.startsWith('https://ebiblioteka.com/cancel')) {
              print("Plaćanje otkazano");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Plaćanje otkazano'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(approvalUrl));
  }

  Future<void> _processClanarina() async {
    try {
      final korisnikId = AuthProvider.trenutniKorisnikId;
      if (korisnikId == null) {
        throw Exception("Korisnik nije prijavljen");
      }

      if (tipClanarine == null) {
        throw Exception("Tip članarine nije učitan");
      }

      final now = DateTime.now();

      if (trenutnaClanarina == null) {
        final novaClanarina = Clanarina(
          korisnikId: korisnikId,
          tipClanarineId: tipClanarine!.tipClanarineId,
          statusClanarine: true,
          datumUplate: now,
          datumIsteka: DateTime(now.year,
              now.month + (tipClanarine!.vrijemeTrajanja ?? 1), now.day),
        );

        await _clanarinaProvider.insert(novaClanarina);
      } else {
        DateTime noviDatumIsteka;

        if (trenutnaClanarina!.datumIsteka!.isBefore(now)) {
          noviDatumIsteka = DateTime(now.year,
              now.month + (tipClanarine!.vrijemeTrajanja ?? 1), now.day);
        } else {
          final datumIsteka = trenutnaClanarina!.datumIsteka!;
          noviDatumIsteka = DateTime(
              datumIsteka.year,
              datumIsteka.month + (tipClanarine!.vrijemeTrajanja ?? 1),
              datumIsteka.day);
        }

        trenutnaClanarina!.datumUplate = now;
        trenutnaClanarina!.datumIsteka = noviDatumIsteka;
        trenutnaClanarina!.statusClanarine = true;
        trenutnaClanarina!.tipClanarineId = tipClanarine!.tipClanarineId;

        await _clanarinaProvider.update(
            trenutnaClanarina!.clanarinaId!, trenutnaClanarina);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Članarina je uspješno obnovljena!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      selectedIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plati sa PayPal'),
          backgroundColor: const Color.fromARGB(255, 101, 85, 143),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tipClanarine == null
                ? const Center(
                    child: Text('Greška prilikom učitavanja podataka'))
                : _controller != null
                    ? WebViewWidget(controller: _controller!)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Plati sa PayPal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cijena: ${tipClanarine!.cijena} KM',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(200, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _startPaymentProcess,
                              child: const Text('Plati'),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
