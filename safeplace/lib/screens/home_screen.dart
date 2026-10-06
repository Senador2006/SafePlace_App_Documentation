import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeplace/config/locationiq_chave.dart';
import 'package:safeplace/data/anuncios.dart';
import 'package:safeplace/data/local_repository.dart';
import 'package:safeplace/models/bairro.dart';
import 'package:safeplace/screens/planos_screen.dart';
import 'package:safeplace/screens/relatorio_screen.dart';
import 'package:safeplace/services/auth_controller.dart';
import 'package:safeplace/services/contorno_service.dart';
import 'package:safeplace/services/plano_controller.dart';
import 'package:safeplace/services/relatorio_service.dart';
import 'package:safeplace/services/risk_service.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:safeplace/widgets/anuncio_card.dart';
import 'package:safeplace/widgets/brand_logo.dart';
import 'package:safeplace/widgets/risk_badge.dart';
import 'package:safeplace/widgets/tendencia_indicador.dart';
import 'package:url_launcher/url_launcher.dart';

const _saoPaulo = LatLng(-23.5505, -46.6333);
const _bairrosVisiveisNoCelular = 2;
const _alturaTileBairro = 72.0;
const _espacoEntreBairros = 4.0;
const _alturaListaCompacta =
    _bairrosVisiveisNoCelular * _alturaTileBairro +
    (_bairrosVisiveisNoCelular - 1) * _espacoEntreBairros;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = const LocalRepository();
  final _contornoService = ContornoService();
  final _searchController = TextEditingController();
  final _mapController = MapController();

  List<Bairro> _bairros = const [];
  Bairro? _selecionado;
  ContornoBairro? _contorno;
  String _query = '';
  bool _carregando = true;
  bool _contornoCarregando = false;
  String? _avisoContorno;
  var _pedidoContorno = 0;

  List<Bairro> get _filtrados {
    final termo = _query.trim().toLowerCase();
    if (termo.isEmpty) return _bairros;
    return _bairros.where((b) => b.nome.toLowerCase().contains(termo)).toList();
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

  Future<void> _selecionar(Bairro bairro) async {
    final pedido = ++_pedidoContorno;
    FocusScope.of(context).unfocus();
    setState(() {
      _selecionado = bairro;
      _contorno = null;
      _contornoCarregando = _contornoService.temChave;
      _avisoContorno = _contornoService.temChave
          ? null
          : 'Cole o token da LocationIQ para desenhar o contorno.';
    });
    _mapController.move(LatLng(bairro.latitude, bairro.longitude), 14);
    if (!_contornoService.temChave) return;

    try {
      final contorno = await _contornoService.buscar(bairro.nome);
      if (!mounted || pedido != _pedidoContorno) return;
      setState(() {
        _contorno = contorno;
        _contornoCarregando = false;
        _avisoContorno = contorno == null
            ? 'A LocationIQ não devolveu o contorno deste bairro.'
            : null;
      });
      final pontos = contorno?.pontos ?? const <LatLng>[];
      if (pontos.length >= 3) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(pontos),
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 180),
            maxZoom: 15,
          ),
        );
      }
    } on ContornoException catch (erro) {
      if (!mounted || pedido != _pedidoContorno) return;
      setState(() {
        _contornoCarregando = false;
        _avisoContorno = erro.mensagem;
      });
    } catch (_) {
      if (!mounted || pedido != _pedidoContorno) return;
      setState(() {
        _contornoCarregando = false;
        _avisoContorno = 'Não foi possível buscar o contorno agora.';
      });
    }
  }

  void _abrirPlanos() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PlanosScreen()),
    );
  }

  Future<void> _sair() async {
    final plano = PlanoScope.of(context);
    final auth = AuthScope.of(context);
    await plano.desvincular();
    await auth.sair();
    if (!mounted) return;
    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  void _abrirRelatorio(Bairro bairro) {
    final plano = PlanoScope.of(context);
    final acesso = plano.acessoRelatorio();
    if (acesso == AcessoRelatorio.planos) {
      _abrirPlanos();
      return;
    }

    final avisoGratis = acesso == AcessoRelatorio.gratis;
    if (avisoGratis) {
      plano.marcarRelatorioGratisUsado();
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RelatorioScreen(
          bairro: bairro,
          bairros: _bairros,
          avisoGratis: avisoGratis,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plano = PlanoScope.of(context);

    return Scaffold(
      backgroundColor: SafePlaceColors.nightBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ladoALado = constraints.maxWidth >= 840;
            final reservaChrome = 150.0 +
                (plano.ehPro ? 0 : 88) +
                (_contornoService.temChave ? 0 : 100);
            final reservaMapa = constraints.maxHeight * 0.42;
            final listaDisponivel =
                constraints.maxHeight - reservaChrome - reservaMapa;
            final alturaLista = listaDisponivel < _alturaListaCompacta
                ? (listaDisponivel < 0 ? 0.0 : listaDisponivel)
                : _alturaListaCompacta;
            final busca = _SearchPanel(
              controller: _searchController,
              carregando: _carregando,
              resultados: _filtrados,
              selecionado: _selecionado,
              mostrarAnuncio: !plano.ehPro,
              ehPro: plano.ehPro,
              temChaveContorno: _contornoService.temChave,
              compacto: !ladoALado,
              alturaLista: alturaLista,
              onQuery: (value) => setState(() => _query = value),
              onSelect: _selecionar,
              onPlanos: _abrirPlanos,
              onSair: _sair,
            );
            final mapa = _MapPanel(
              mapController: _mapController,
              bairros: _bairros,
              selecionado: _selecionado,
              contorno: _contorno,
              avisoContorno: _contornoCarregando
                  ? 'Buscando o contorno do bairro...'
                  : _avisoContorno,
              tiles: _contornoService.urlTiles,
              subdominiosTiles: _contornoService.subdominiosTiles,
              usaLocationIq: _contornoService.temChave,
              onSelect: _selecionar,
              onRelatorio: _abrirRelatorio,
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
                busca,
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
    required this.mostrarAnuncio,
    required this.ehPro,
    required this.temChaveContorno,
    required this.compacto,
    required this.alturaLista,
    required this.onQuery,
    required this.onSelect,
    required this.onPlanos,
    required this.onSair,
  });

  final TextEditingController controller;
  final bool carregando;
  final List<Bairro> resultados;
  final Bairro? selecionado;
  final bool mostrarAnuncio;
  final bool ehPro;
  final bool temChaveContorno;
  final bool compacto;
  final double alturaLista;
  final ValueChanged<String> onQuery;
  final ValueChanged<Bairro> onSelect;
  final VoidCallback onPlanos;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    final lista = carregando
        ? const Center(
            child: CircularProgressIndicator(color: SafePlaceColors.safeBlue),
          )
        : ListView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, compacto ? 0 : 12),
            children: [
              if (!compacto && !temChaveContorno) ...[
                const _AvisoChaveContorno(),
                const SizedBox(height: 8),
              ],
              if (!compacto && mostrarAnuncio) ...[
                AnuncioCard(anuncio: Anuncios.principal),
                const SizedBox(height: 8),
              ],
              if (resultados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhum bairro encontrado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SafePlaceColors.mediumGray),
                  ),
                )
              else
                for (final bairro in resultados) ...[
                  SizedBox(
                    height: _alturaTileBairro,
                    child: _BairroTile(
                      bairro: bairro,
                      ativo: selecionado?.id == bairro.id,
                      onSelect: () => onSelect(bairro),
                    ),
                  ),
                  const SizedBox(height: _espacoEntreBairros),
                ],
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
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
          );

    return ColoredBox(
      color: SafePlaceColors.nightBlue,
      child: Column(
        mainAxisSize: compacto ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const SafePlaceLogo(size: 40),
                const SizedBox(width: 12),
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SafePlaceWordmark(fontSize: 22),
                  ),
                ),
                TextButton(
                  onPressed: onSair,
                  style: TextButton.styleFrom(
                    foregroundColor: SafePlaceColors.mediumGray,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Sair'),
                ),
                TextButton.icon(
                  onPressed: onPlanos,
                  icon: Icon(
                    ehPro
                        ? Icons.verified_outlined
                        : Icons.workspace_premium_outlined,
                    size: 18,
                  ),
                  label: Text(ehPro ? 'Pro' : 'Planos'),
                  style: TextButton.styleFrom(
                    foregroundColor: SafePlaceColors.safeBlue,
                  ),
                ),
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
          if (compacto && !temChaveContorno) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _AvisoChaveContorno(),
            ),
          ],
          if (compacto && mostrarAnuncio)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: AnuncioCard(anuncio: Anuncios.principal),
            ),
          if (compacto)
            SizedBox(height: alturaLista, child: lista)
          else
            Expanded(child: lista),
        ],
      ),
    );
  }
}

class _AvisoChaveContorno extends StatelessWidget {
  const _AvisoChaveContorno();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SafePlaceColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafePlaceColors.safeBlue),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O contorno do bairro usa a LocationIQ. A chave gratuita aparece na hora, sem pedido de aprovação.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.35,
                color: SafePlaceColors.lightGray,
              ),
            ),
            TextButton(
              onPressed: () => launchUrl(Uri.parse(urlCadastroLocationIq)),
              style: TextButton.styleFrom(
                foregroundColor: SafePlaceColors.safeBlue,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Obter chave grátis'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BairroTile extends StatelessWidget {
  const _BairroTile({
    required this.bairro,
    required this.ativo,
    required this.onSelect,
  });

  final Bairro bairro;
  final bool ativo;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final risco = RiskService.of(bairro);
    return Material(
      color: ativo ? SafePlaceColors.panel : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onSelect,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(Icons.location_on_outlined, color: risco.color),
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
        trailing: RiskBadge(risco: risco),
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.mapController,
    required this.bairros,
    required this.selecionado,
    required this.contorno,
    required this.avisoContorno,
    required this.tiles,
    required this.subdominiosTiles,
    required this.usaLocationIq,
    required this.onSelect,
    required this.onRelatorio,
  });

  final MapController mapController;
  final List<Bairro> bairros;
  final Bairro? selecionado;
  final ContornoBairro? contorno;
  final String? avisoContorno;
  final String tiles;
  final List<String> subdominiosTiles;
  final bool usaLocationIq;
  final ValueChanged<Bairro> onSelect;
  final ValueChanged<Bairro> onRelatorio;

  @override
  Widget build(BuildContext context) {
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
                  urlTemplate: tiles,
                  subdomains: subdominiosTiles,
                  userAgentPackageName: 'br.edu.fiap.safeplace',
                ),
                if (contorno != null)
                  PolygonLayer(
                    polygons: [
                      for (final anel in contorno!.aneis)
                        Polygon(
                          points: anel.externo,
                          holePointsList:
                              anel.furos.isEmpty ? null : anel.furos,
                          color: SafePlaceColors.safeBlue.withValues(alpha: 0.22),
                          borderColor: SafePlaceColors.safeBlue,
                          borderStrokeWidth: 2,
                        ),
                    ],
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
                  attributions: [
                    const TextSourceAttribution('OpenStreetMap'),
                    if (usaLocationIq)
                      const TextSourceAttribution('LocationIQ'),
                  ],
                ),
              ],
            ),
            if (selecionado != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _NeighborhoodCard(
                  bairro: selecionado!,
                  bairros: bairros,
                  avisoContorno: avisoContorno,
                  onRelatorio: () => onRelatorio(selecionado!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NeighborhoodCard extends StatelessWidget {
  const _NeighborhoodCard({
    required this.bairro,
    required this.bairros,
    required this.avisoContorno,
    required this.onRelatorio,
  });

  final Bairro bairro;
  final List<Bairro> bairros;
  final String? avisoContorno;
  final VoidCallback onRelatorio;

  @override
  Widget build(BuildContext context) {
    final risco = RiskService.of(bairro);
    final relatorio = RelatorioService.of(bairro, bairros);

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
                RiskBadge(risco: risco),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Criminalidade ${relatorio.indice}%',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: SafePlaceColors.lightGray,
              ),
            ),
            if (avisoContorno != null) ...[
              const SizedBox(height: 4),
              Text(
                avisoContorno!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: SafePlaceColors.mediumGray,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(label: 'Furtos', value: bairro.furtos),
                _Stat(label: 'Roubos', value: bairro.roubos),
                _Stat(label: 'Homicídios', value: bairro.homicidios),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                for (final crime in relatorio.maisComuns)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        crime.nome,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: SafePlaceColors.mediumGray,
                        ),
                      ),
                      const SizedBox(width: 2),
                      TendenciaIndicador(
                        tendencia: crime.tendencia,
                        size: 14,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRelatorio,
                style: FilledButton.styleFrom(
                  backgroundColor: SafePlaceColors.safeBlue,
                  foregroundColor: SafePlaceColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Ver relatório detalhado',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    _ProSelo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProSelo extends StatelessWidget {
  const _ProSelo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SafePlaceColors.alertPurple,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.4,
          color: SafePlaceColors.white,
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
