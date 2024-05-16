import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class Pokemon extends StatefulWidget {
  final String url;

  const Pokemon({Key? key, required this.url}) : super(key: key);

  @override
  State<Pokemon> createState() => _PokemonState();
}

class _PokemonState extends State<Pokemon> {
  late Future<Map<String, dynamic>> _pokemonData;

  @override
  void initState() {
    super.initState();
    _pokemonData = _fetchPokemonData();
  }

  Future<Map<String, dynamic>> _fetchPokemonData() async {
    final response = await http.get(Uri.parse(widget.url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Pokémon data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _pokemonData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final pokemonData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 300,
                    child: CachedNetworkImage(
                      imageUrl: pokemonData['sprites']['other']
                          ['official-artwork']['front_default'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.fitHeight,
                    ),
                  ),

                  // Espacio entre la imagen y los datos
                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre: ${pokemonData['name']}',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Tipo(s): ${pokemonData['types'].map((type) => type['type']['name']).join(', ')}',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Peso: ${pokemonData['weight']} Kg',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Altura: ${pokemonData['height']} Ft',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Habilidades: ${pokemonData['abilities'].map((ability) => ability['ability']['name']).join(', ')}',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Text(
                          'Stats:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        // Display each stat
                        for (var stat in pokemonData['stats'])
                          Text(
                            '${stat['stat']['name']}: ${stat['base_stat']}',
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
