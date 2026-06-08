class RegistroVariable {
  final int variableId;
  final String nombre;
  final double min;
  final double max;

  String valor;

  RegistroVariable({
    required this.variableId,
    required this.nombre,
    required this.min,
    required this.max,
    this.valor = '',
  });
}