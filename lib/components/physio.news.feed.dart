import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PhysioNewsFeed extends StatelessWidget {
  final String apiKey;
  const PhysioNewsFeed({super.key, required this.apiKey});

  Future<List<dynamic>> fetchPortuguesePhysioNews(String apiKey) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=fisioterapia&language=pt&apiKey=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'ok' && data['articles'] != null) {
        return data['articles'];
      } else {
        throw Exception('Nenhum artigo encontrado');
      }
    } else {
      print('Erro na requisição a API: ${response.statusCode}');
      print('Detalhes do erro: ${response.body}');
      throw Exception('Falha ao carregar notícias: ${response.reasonPhrase}');
    }
  }

  Future<void> openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchPortuguesePhysioNews(apiKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF0E382C)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar notícias'));
        }
        final items = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length.clamp(0, 5),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: Color(0xFFF4F7F6),
              child: ListTile(
                title: Text(item['title']),
                subtitle: Text(item['source']['name'] ?? ''),
                onTap: () async {
                  final url = item['url'] ?? '';
                  if (url.isNotEmpty) {
                    openUrl(url);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('URL inválido')));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
