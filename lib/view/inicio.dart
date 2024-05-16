import 'dart:convert';
import 'package:api_pokedesk/view/pokmon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

//en Inicio.dart se listaran los Pokemones segun la
//api se podra seleccionar un pokemon y al hacer se
//cambiara a pokemon.dart

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokemones"),
        backgroundColor: Colors.blue,
      ),
      body: const Pokemones(),
    );
  }
}

class Pokemones extends StatefulWidget {
  const Pokemones({Key? key}) : super(key: key);

  @override
  State<Pokemones> createState() => _PokemonesState();
}

class _PokemonesState extends State<Pokemones> {
  Map<String, dynamic> json_Poke = {};
  bool estado = true;
  int offset = 20;
  int totalPokemons = 0;
  List<Map<String, dynamic>> pokemonList = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _cargarData();
    _scrollController
        .addListener(_scrollListener); 
    super.initState();
  }

  void _cargarData() async {
    Map<String, dynamic> _json_poke = {};
    var api = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/'));
    if (api.statusCode == 200) {
      _json_poke = json.decode(api.body);
    } else {
      print("api no carga");
    }
    setState(() {
      json_Poke = _json_poke;
      estado = false;
      // print(json_Poke['pokemon'].length);
    });
  }

  Future<void> cargarMasPokemons() async {
    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/?offset=$offset&limit=20'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> newPokemons = data['results'];

      // Agregar los nuevos resultados a la lista existente en json_Poke['results']
      setState(() {
        json_Poke['results'].addAll(newPokemons);
      });
      print("cargando mas pokemones");

      // Incrementar el valor de offset para la próxima solicitud
      offset += 20;
    } else {
      print('Error al cargar más Pokémon');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      cargarMasPokemons();
    }
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (estado) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Pokemon(url: json_Poke['results'][index]['url']),
                ),
              );
            },
            child: FutureBuilder<String>(
              future:
                  obtenerURLImagenPokemon(json_Poke['results'][index]['name']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la imagen'));
                } else if (snapshot.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(60, 230, 222, 222),
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(66, 34, 48, 54),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        height: 25,
                        alignment: Alignment.topCenter,
                        child: Text(json_Poke['results'][index]['name']),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                      child: Text('No se pudo cargar la imagen'));
                }
              },
            ),
          );
        },
        itemCount: json_Poke['results'].length,
      );
    }
  }
}

Future<String> obtenerURLImagenPokemon(String nombrePokemon) async {
  final response = await http
      .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$nombrePokemon'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    String urlImagen =
        data['sprites']['other']['official-artwork']['front_default'];
    return urlImagen;
  } else {
    print('Error al obtener detalles del Pokémon');
    return '';
  }
}
