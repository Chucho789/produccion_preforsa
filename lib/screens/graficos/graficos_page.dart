import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GraficosPage extends StatefulWidget {
  const GraficosPage({super.key});

  @override
  State<GraficosPage> createState() => _GraficosPageState();
}

class _GraficosPageState extends State<GraficosPage> {
  final supabase = Supabase.instance.client;

  List maquinas = [];
  List variables = [];
  List datos = [];

  int? maquinaSeleccionada;
  int? variableSeleccionada;

  bool cargando = true;

  double promedio = 0;
  double minimo = 0;
  double maximo = 0;
  double actual = 0;

  @override
  void initState() {
    super.initState();
    cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    final maquinasData =
        await supabase.from('maquinas').select();

    final variablesData =
        await supabase.from('variables').select();

    setState(() {
      maquinas = maquinasData;
      variables = variablesData;
      cargando = false;
    });
  }

  Future<void> generarGrafico() async {
    if (maquinaSeleccionada == null ||
        variableSeleccionada == null) {
      return;
    }

    final resultado = await supabase
        .from('vw_graficos')
        .select()
        .eq('maquina_id', maquinaSeleccionada!)
        .eq('variable_id', variableSeleccionada!)
        .order('fecha');

    if (resultado.isEmpty) {
      setState(() {
        datos = [];
      });
      return;
    }

    final valores = resultado
        .map<double>((e) =>
            (e['valor'] as num).toDouble())
        .toList();

    setState(() {
      datos = resultado;

      minimo =
          valores.reduce((a, b) => a < b ? a : b);

      maximo =
          valores.reduce((a, b) => a > b ? a : b);

      promedio =
          valores.reduce((a, b) => a + b) /
              valores.length;

      actual = valores.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField<int>(
              value: maquinaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Máquina',
                border: OutlineInputBorder(),
              ),
              items: maquinas.map((m) {
                return DropdownMenuItem<int>(
                  value: m['id'],
                  child: Text(m['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  maquinaSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              value: variableSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Variable',
                border: OutlineInputBorder(),
              ),
              items: variables.map((v) {
                return DropdownMenuItem<int>(
                  value: v['id'],
                  child: Text(v['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  variableSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: generarGrafico,
                child: const Text(
                  'Generar Gráfico',
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (datos.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Actual: $actual',
                      ),
                      Text(
                        'Promedio: ${promedio.toStringAsFixed(2)}',
                      ),
                      Text(
                        'Mínimo: $minimo',
                      ),
                      Text(
                        'Máximo: $maximo',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 350,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              true,
                        ),
                      ),
                      bottomTitles:
                          AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              true,
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: List.generate(
                          datos.length,
                          (index) {
                            return FlSpot(
                              index.toDouble(),
                              (datos[index]
                                          ['valor']
                                      as num)
                                  .toDouble(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}