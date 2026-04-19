const _mesesAbrev = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

const _mesesCompletos = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// R$ 1.247,80
String formatBRL(double valor) {
  final parts = valor.abs().toStringAsFixed(2).split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'R\$ $intPart,${parts[1]}';
}

/// + R$ 650,00  ou  - R$ 50,68
String formatBRLSigned(double valor) =>
    '${valor >= 0 ? '+' : '-'} ${formatBRL(valor)}';

const String kValorOculto = 'R\$ •••••';

/// 26 abr
String formatDataCurta(DateTime data) =>
    '${data.day} ${_mesesAbrev[data.month - 1]}';

/// Abril 2026
String formatMesAno(DateTime data) =>
    '${_mesesCompletos[data.month - 1]} ${data.year}';

/// 18/04/2026
String formatDataDDMMYYYY(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
