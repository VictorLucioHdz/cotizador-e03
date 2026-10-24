import { describe, it, expect } from 'vitest';
import { POLITICAS, recargo, documentoRequerido, etiqueta } from '../src/despacho.js';
import type { Tipo } from '../src/despacho.js';

describe('paso 2 · los cuatro tipos de siempre', () => {
  it('recargo: mismo resultado que condicionales.ts', () => {
    expect(recargo('general', 100000)).toBe(0);
    expect(recargo('refrigerada', 100000)).toBe(33000);
    expect(recargo('peligrosa', 100000)).toBe(95000);
    expect(recargo('sobredimensionada', 100000)).toBe(185000);
  });

  it('recargo: redondea el medio centavo hacia arriba', () => {
    expect(recargo('refrigerada', 150)).toBe(15027);
  });

  it('documentoRequerido', () => {
    expect(documentoRequerido('general')).toBeNull();
    expect(documentoRequerido('refrigerada')).toBeNull();
    expect(documentoRequerido('peligrosa')).toBe('numeroUn');
    expect(documentoRequerido('sobredimensionada')).toBe('permiso');
  });

  it('etiqueta', () => {
    expect(etiqueta('general')).toBe('General');
    expect(etiqueta('refrigerada')).toBe('Refrigerada · cadena de frío');
  });
});

describe('paso 3 · un tipo nuevo: perecedera', () => {
  const perecedera = 'perecedera' as Tipo;

  it('existe en la tabla', () => {
    expect(Object.keys(POLITICAS)).toContain('perecedera');
  });

  it('paga 12 % + $200, no pide documento, y tiene su etiqueta', () => {
    expect(recargo(perecedera, 100000)).toBe(32000);
    expect(documentoRequerido(perecedera)).toBeNull();
    expect(etiqueta(perecedera)).toBe('Perecedera · caduca en 72 h');
  });
});
