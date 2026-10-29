export type Puente = 'comercio_mundial' | 'colombia';

// ---------------------------------------------------------------------------
// 2. La carga, como unión discriminada por `tipo`
// ---------------------------------------------------------------------------
export type CargaGeneral = {
  tipo: 'general';
};

export type CargaRefrigerada = {
  tipo: 'refrigerada';
};

export type CargaPeligrosa = {
  tipo: 'peligrosa';
  numeroUn: string;
};

export type CargaSobredimensionada = {
  tipo: 'sobredimensionada';
  permiso: string;
};

export type Carga =
  | CargaGeneral
  | CargaRefrigerada
  | CargaPeligrosa
  | CargaSobredimensionada;

// ---------------------------------------------------------------------------
// 3. El embarque: datos comunes + carga
// ---------------------------------------------------------------------------
export type DatosEmbarque = {
  id: string;
  pesoKg: number;
  distanciaKm: number;
  puente: Puente;
};

export type Embarque = DatosEmbarque & Carga;

// ---------------------------------------------------------------------------
// 4. Cotizacion
// ---------------------------------------------------------------------------
export type Cotizacion = {
  id: string;
  fleteBruto: number;
  descuento: number;
  flete: number;
  cuotaPuente: number;
  recargo: number;
  ajusteMinimo: number;
  total: number;
};

// ---------------------------------------------------------------------------
// 5. Motivo: solo los 3 motivos de validación en tiempo de ejecución
// ---------------------------------------------------------------------------
export type Motivo = 'peso_invalido' | 'distancia_invalida' | 'excede_peso_maximo';

// ---------------------------------------------------------------------------
// 1. Los cuatro estados, como unión discriminada por `estado`
// ---------------------------------------------------------------------------
export type Borrador = {
  estado: 'borrador';
  embarque: Embarque;
};

export type Cotizado = {
  estado: 'cotizado';
  embarque: Embarque;
  cotizacion: Cotizacion;
};

export type Rechazado = {
  estado: 'rechazado';
  embarque: Embarque;
  motivo: Motivo;
};

export type Despachado = {
  estado: 'despachado';
  embarque: Embarque;
  cotizacion: Cotizacion;
  folio: string;
};

export type EstadoEmbarque = Borrador | Cotizado | Rechazado | Despachado;

// ---------------------------------------------------------------------------
// 6. Reglas
// ---------------------------------------------------------------------------
export type CriterioDescuento = 'a_partir_de' | 'mas_de';
export type BaseRecargo = 'flete' | 'subtotal';

export type Reglas = {
  tarifaKm: number;
  cuotaPuente: Record<Puente, number>;
  descuento: {
    umbralKg: number;
    pct: number;
    criterio: CriterioDescuento;
  };
  recargo: Record<Carga['tipo'], { pct: number; fija: number }>;
  baseRecargo: BaseRecargo;
  minimo: number;
  pesoMaximoKg: number;
};

// ---------------------------------------------------------------------------
// 7. Resultado<T, E> (equivalente a {:ok, valor} | {:error, motivo} de Elixir)
// ---------------------------------------------------------------------------
export type Resultado<T, E> =
  | { ok: true; valor: T }
  | { ok: false; error: E };

// ---------------------------------------------------------------------------
// TABLA DE POLÍTICAS POR TIPO DE CARGA (Taller 4: Cero switch/if sobre el tipo)
// ---------------------------------------------------------------------------
type PoliticaCarga = {
  aplicaPesoMaximo: boolean;
};

const POLITICAS_CARGA: Record<Carga['tipo'], PoliticaCarga> = {
  general: { aplicaPesoMaximo: true },
  refrigerada: { aplicaPesoMaximo: true },
  peligrosa: { aplicaPesoMaximo: true },
  sobredimensionada: { aplicaPesoMaximo: false },
};

// ---------------------------------------------------------------------------
// FUNCIONES AUXILIARES DE CÁLCULO (Composición, funciones puras)
// ---------------------------------------------------------------------------

/** Redondeo entero idéntico a div(monto * p + 50, 100) de Elixir */
function pct(monto: number, p: number): number {
  return Math.floor((monto * p + 50) / 100);
}

function calcularDescuento(
  pesoKg: number,
  fleteBruto: number,
  descuento: Reglas['descuento']
): number {
  const aplica =
    descuento.criterio === 'a_partir_de'
      ? pesoKg >= descuento.umbralKg
      : pesoKg > descuento.umbralKg;

  return aplica ? pct(fleteBruto, descuento.pct) : 0;
}

function calcularRecargo(
  embarque: Embarque,
  reglas: Reglas,
  flete: number,
  cuotaPuente: number
): number {
  const { pct: p, fija } = reglas.recargo[embarque.tipo];
  const base = reglas.baseRecargo === 'flete' ? flete : flete + cuotaPuente;
  return pct(base, p) + fija;
}

function calcular(embarque: Embarque, reglas: Reglas): Cotizacion {
  const fleteBruto = embarque.distanciaKm * reglas.tarifaKm;
  const descuento = calcularDescuento(embarque.pesoKg, fleteBruto, reglas.descuento);
  const flete = fleteBruto - descuento;
  const cuotaPuente = reglas.cuotaPuente[embarque.puente];
  const recargo = calcularRecargo(embarque, reglas, flete, cuotaPuente);

  const subtotal = flete + cuotaPuente + recargo;
  const ajusteMinimo = Math.max(reglas.minimo - subtotal, 0);
  const total = subtotal + ajusteMinimo;

  return {
    id: embarque.id,
    fleteBruto,
    descuento,
    flete,
    cuotaPuente,
    recargo,
    ajusteMinimo,
    total,
  };
}

// ---------------------------------------------------------------------------
// VALIDACIÓN (Regresa Resultado<Embarque, Motivo>)
// ---------------------------------------------------------------------------
function validar(embarque: Embarque, reglas: Reglas): Resultado<Embarque, Motivo> {
  // 1. Peso inválido
  if (embarque.pesoKg <= 0) {
    return { ok: false, error: 'peso_invalido' };
  }

  // 2. Distancia inválida
  if (embarque.distanciaKm <= 0) {
    return { ok: false, error: 'distancia_invalida' };
  }

  // 3. Peso máximo (consultando la tabla de políticas, sin if sobre el tipo)
  if (
    POLITICAS_CARGA[embarque.tipo].aplicaPesoMaximo &&
    embarque.pesoKg > reglas.pesoMaximoKg
  ) {
    return { ok: false, error: 'excede_peso_maximo' };
  }

  return { ok: true, valor: embarque };
}

// FUNCIÓN PÚBLICA: cotizar/2
export function cotizar(b: Borrador, r: Reglas): Cotizado | Rechazado {
  const res = validar(b.embarque, r);

  if (!res.ok) {
    return {
      estado: 'rechazado',
      embarque: b.embarque,
      motivo: res.error,
    };
  }

  return {
    estado: 'cotizado',
    embarque: b.embarque,
    cotizacion: calcular(b.embarque, r),
  };
}

// FUNCIÓN PÚBLICA: despachar/2 (Pendiente para Etapa 3)
export function despachar(c: Cotizado, folio: string): Despachado {
  return {
    estado: 'despachado',
    embarque: c.embarque,
    cotizacion: c.cotizacion,
    folio,
  };
}
