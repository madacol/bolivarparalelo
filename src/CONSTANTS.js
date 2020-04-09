export const _1M_in_ms = 1000*60;
export const _1H_in_ms = _1M_in_ms*60;
export const _1D_in_ms = _1H_in_ms*24;

export const SHOW_CONFIG = [
    {showGraph: true, name: "gráfico", showRateCalcWhenGraph: false}, // Default
    {showGraph: false, name: "tasa/calculadora"},
    {showGraph: true, name: "ambos", showRateCalcWhenGraph: true}
];

// Tutorial Parameters
export const TUTORIAL_INTERVAL_DELAY = 5000;
// export const TUTORIAL_DELAY = 10000 - TUTORIAL_INTERVAL;
export const WRITE_DELAY = 300;
export const FAKE_CURSOR_BLINK_DELAY = 500;
export const RANDOM_NUMBER_RANGE = [1, 300];
