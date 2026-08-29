import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeplace/data/local_repository.dart';
import 'package:safeplace/models/bairro.dart';
import 'package:safeplace/services/risk_service.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:safeplace/widgets/brand_logo.dart';

const _saoPaulo = LatLng(-23.5505, -46.6333);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = const LocalRepository();
  final _searchController = TextEditingController();
  final _mapController = MapController();

  List<Bairro> _bairros = const [];
  Bairro? _selecionado;
  String _query = '';
  bool _carregando = true;

  List<Bairro> get _filtrados {
    final termo = _query.trim().toLowerCase();
    if (termo.isEmpty) return _bairros;
    return _bairros
        .where((b) => b.nome.toLowerCase().contains(termo))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final dados = await _repository.loadBairros();
    if (!mounted) return;
    setState(() {
      _bairros = dados;
      _carregando = false;
    });
  }

  void _selecionar(Bairro bairro) {
    FocusScope.of(context).unfocus();
    setState(() => _selecionado = bairro);
    _mapController.move(LatLng(bairro.latitude, bairro.longitude), 14);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ladoALado = constraints.maxWidth >= 840;
            final busca = _SearchPanel(
              controller: _searchController,
              carregando: _carregando,
              resultados: _filtrados,
              selecionado: _selecionado,
              onQuery: (value) => setState(() => _query = value),
              onSelect: _selecionar,
            );
            final mapa = _MapPanel(
              mapController: _mapController,
              bairros: _bairros,
              selecionado: _selecionado,
              onSelect: _selecionar,
            );

            if (ladoALado) {
              return Row(
                children: [
                  SizedBox(width: 380, child: busca),
                  Expanded(child: mapa),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.42, child: busca),
                Expanded(child: mapa),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.carregando,
    required this.resultados,
    required this.selecionado,
    required this.onQuery,
    required this.onSelect,
  });

  final TextEditingController controller;
  final bool carregando;
  final List<Bairro> resultados;
  final Bairro? selecionado;
  final ValueChanged<String> onQuery;
  final ValueChanged<Bairro> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SafePlaceColors.nightBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                SafePlaceLogo(size: 40),
                SizedBox(width: 12),
                SafePlaceWordmark(fontSize: 22),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: controller,
              onChanged: onQuery,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: SafePlaceColors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar bairro em São Paulo',
                hintStyle: const TextStyle(color: SafePlaceColors.mediumGray),
                prefixIcon: const Icon(
                  Icons.search,
                  color: SafePlaceColors.safeBlue,
                ),
                filled: true,
                fillColor: SafePlaceColors.panel,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: SafePlaceColors.safeBlue,
                    ),
                  )
                : resultados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum bairro encontrado.',
                          style: TextStyle(color: SafePlaceColors.mediumGray),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        itemCount: resultados.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final bairro = resultados[index];
                          final risco = RiskService.of(bairro);
                          final ativo = selecionado?.id == bairro.id;
                          return Material(
                            color: ativo
                                ? SafePlaceColors.panel
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              onTap: () => onSelect(bairro),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: risco.color,
                              ),
                              title: Text(
                                bairro.nome,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: SafePlaceColors.white,
                                ),
                              ),
                              subtitle: Text(
                                'Risco ${risco.label.toLowerCase()} · ${bairro.furtos} furtos',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: SafePlaceColors.mediumGray,
                                ),
                              ),
                              trailing: _RiskBadge(risco: risco),
                            ),
                          );
                        },
                      ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Fonte: SSP/SP (microdados). Agregação acadêmica — não substitui estatística oficial.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: SafePlaceColors.mediumGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.mapController,
    required this.bairros,
    required this.selecionado,
    required this.onSelect,
  });

  final MapController mapController;
  final List<Bairro> bairros;
  final Bairro? selecionado;
  final ValueChanged<Bairro> onSelect;

  @override
  Widget build(BuildContext context) {
    final risco = selecionado == null ? null : RiskService.of(selecionado!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: selecionado == null
                    ? _saoPaulo
                    : LatLng(selecionado!.latitude, selecionado!.longitude),
                initialZoom: selecionado == null ? 11.4 : 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.edu.fiap.safeplace',
                ),
                MarkerLayer(
                  markers: [
                    for (final bairro in bairros)
                      Marker(
                        point: LatLng(bairro.latitude, bairro.longitude),
                        width: selecionado?.id == bairro.id ? 48 : 36,
                        height: selecionado?.id == bairro.id ? 48 : 36,
                        child: GestureDetector(
                          onTap: () => onSelect(bairro),
                          child: Icon(
                            Icons.location_on,
                            size: selecionado?.id == bairro.id ? 44 : 32,
                            color: selecionado?.id == bairro.id
                                ? SafePlaceColors.safeBlue
                                : RiskService.of(bairro).color,
                          ),
                        ),
                      ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: const [
                    TextSourceAttribution('OpenStreetMap'),
                    TextSourceAttribution('CARTO'),
                  ],
                ),
              ],
            ),
            if (selecionado != null && risco != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _NeighborhoodCard(bairro: selecionado!, risco: risco),
              ),
          ],
        ),
      ),
    );
  }
}

class _NeighborhoodCard extends StatelessWidget {
  const _NeighborhoodCard({required this.bairro, required this.risco});

  final Bairro bairro;
  final RiskResult risco;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SafePlaceColors.nightBlue.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bairro.nome,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: SafePlaceColors.white,
                    ),
                  ),
                ),
                _RiskBadge(risco: risco),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(label: 'Furtos', value: bairro.furtos),
                _Stat(label: 'Roubos', value: bairro.roubos),
                _Stat(label: 'Homicídios', value: bairro.homicidios),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: SafePlaceColors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: SafePlaceColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.risco});

  final RiskResult risco;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: risco.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: risco.color),
      ),
      child: Text(
        risco.label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: risco.color,
        ),
      ),
    );
  }
}
