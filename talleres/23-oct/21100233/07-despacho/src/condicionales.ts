// Taller 4 · De condicionales a despacho
// La versión "de siempre": cada función pregunta por el tipo de carga con un switch.

export type Tipo = 'general' | 'refrigerada' | 'peligrosa' | 'sobredimensionada'|'precedera';

const pct = (monto: number, p: number): number => Math.floor((monto * p + 50) / 100);

export function recargo(tipo: Tipo, base: number): number {
  switch (tipo) {
    case 'refrigerada':
      return pct(base, 18) + 15000;
    case 'peligrosa':
      return pct(base, 20) + 75000;
    case 'sobredimensionada':
      return pct(base, 35) + 150000;
    case 'precedera':
      return pct(base, 12) + 200;
    default:
      return 0;
  }
}

export function documentoRequerido(tipo: Tipo): string | null {
  switch (tipo) {
    case 'peligrosa':
      return 'numeroUn';
    case 'sobredimensionada':
      return 'permiso';
    default:
      return null;
  }
}

export function etiqueta(tipo: Tipo): string {
  switch (tipo) {
    case 'refrigerada':
      return 'Refrigerada · cadena de frío';
    case 'peligrosa':
      return 'Peligrosa · material regulado';
    case 'sobredimensionada':
      return 'Sobredimensionada · requiere escolta';
    case 'precedera':
      return 'precedera · caduca en 72 hrs';
    default:
      return 'General';
  }
}

// ------------------------------------------------------------------ demostración
// npm run condicionales
const tipos: Tipo[] = ['general', 'refrigerada', 'peligrosa', 'sobredimensionada','precedera'];
for (const t of tipos) {
  console.log(t.padEnd(18), recargo(t, 100000), documentoRequerido(t), etiqueta(t));
}
