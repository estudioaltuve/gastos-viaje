# Gastos de viaje

App web para dividir gastos de viaje entre varias personas. Uso personal.

Funciona sin conexión y **no envía datos a ningún lado**: no hay backend, no hay cuentas,
no hay analítica. Todo lo que cargás vive en el almacenamiento del navegador de tu
dispositivo. El código no contiene una sola llamada de red a un servidor externo.

## Cómo lleva las cuentas

A diferencia de otras apps del rubro, **cada moneda lleva su propia cuenta**. Un gasto en
euros genera deuda en euros y se salda en euros; nunca se convierte nada para calcular
saldos. Así ninguno de los participantes gana o pierde plata por el tipo de cambio.
Hay un total equivalente opcional, marcado como informativo, que no interviene en los saldos.

## Qué hace

- Gastos en cualquier moneda, con reparto en partes iguales, por partes, por porcentaje o
  por montos exactos. El reparto usa el método del mayor resto sobre enteros: las partes
  suman siempre exactamente el total, sin centavos perdidos ni inventados.
- Saldos por moneda, con el detalle de lo que puso cada uno y lo que le corresponde.
- Liquidación con la mínima cantidad de transferencias: cruza primero las deudas que
  coinciden exactamente y después empareja al que más debe con el que más le deben.
  Nunca más de N−1 pagos por moneda.
- Reembolsos entre personas, que descuentan del saldo.
- Envío de la liquidación de cada participante por WhatsApp, con el mensaje ya armado.
- Varios viajes, exportación e importación en JSON y exportación a CSV.

## Cómo usarla

**En la compu:** abrí `index.html`.

**En el celular:** entrá a la dirección publicada desde el navegador y agregala a la
pantalla de inicio. Queda instalada como app, con su ícono, y funciona en modo avión.

**En la red local, sin publicar nada:** ejecutá `servir.ps1` en Windows y entrá desde el
celular a la dirección que te muestra, con ambos equipos en el mismo WiFi.

## Copias de seguridad

Los datos viven solo en el dispositivo. Si borrás los datos del navegador o cambiás de
equipo, se pierden. En Ajustes tenés *Exportar copia (JSON)*, que en el celular abre el
menú de compartir para mandarla a Drive, mail o donde prefieras.
