# Hotel Bookings

## Descripción del Proyecto

Proyecto de análisis de datos end-to-end sobre reservas hoteleras, desarrollado como proyecto final de Bootcamp de Análisis de Datos. Se trabajó con un dataset real de 119.390 reservas de dos hoteles (City Hotel y Resort Hotel) entre 2015 y 2017.

El proyecto abarca desde la carga y limpieza de datos en MySQL, pasando por la normalización en un modelo estrella, hasta la visualización de insights clave en un dashboard interactivo en Power BI.

\---

## Objetivos

El objetivo principal fue analizar el comportamiento de las reservas hoteleras para responder preguntas de negocio reales:

* ¿En qué períodos se concentran más reservas?
* ¿Cuál es la tasa de cancelación por hotel y por mes?
* ¿Qué países generan más reservas?
* ¿Cuál es el ingreso promedio por noche?
* ¿Qué canales de distribución son más efectivos?

El proyecto busca proporcionar información accionable para la toma de decisiones estratégicas en la gestión hotelera.

\---

## Herramientas y Tecnologías

|Herramienta|Uso|
|-|-|
|**MySQL Workbench**|Carga, limpieza, normalización y análisis con SQL|
|**Power BI Desktop**|Modelado de datos, DAX y dashboard interactivo|
|**SQL**|Lenguaje principal de análisis y transformación|
|**DAX**|Métricas calculadas en Power BI|

\---

## Conjunto de Datos

* **Fuente:** Dataset público `hotel\\\_bookings.csv`
* **Registros:** 119.390 reservas
* **Columnas originales:** 32
* **Período:** 2015 - 2017
* **Hoteles:** City Hotel y Resort Hotel

### Proceso de limpieza realizado:

* Detección y corrección de valores nulos y vacíos en columnas `children` (4), `country` (488), `agent` (16.340) y `company` (112.593)
* Verificación de valores inconsistentes con `DISTINCT`
* Detección de duplicados con `GROUP BY` + `HAVING`
* Corrección de tipos de datos (`children` a INT, `reservation\\\_status\\\_date` a DATE)
* Detección de valores imposibles (reservas sin huéspedes, ADR negativo)

\---

## Código y Presentación

### FASE 1 — Carga en MySQL

Importación del CSV mediante `LOAD DATA INFILE` en la tabla `hotel\\\_bookings` con 119.390 registros.

### FASE 2 — Limpieza de Datos

```sql
-- Búsqueda de nulos y vacíos en todas las columnas
SELECT 
    COUNT(CASE WHEN TRIM(hotel) = '' THEN 1 END) AS vacios\\\_hotel,
    COUNT(CASE WHEN TRIM(country) = '' THEN 1 END) AS vacios\\\_country,
    COUNT(CASE WHEN TRIM(agent) = '' THEN 1 END) AS vacios\\\_agent
FROM hotel\\\_bookings;

-- Corrección de vacíos
UPDATE hotel\\\_bookings SET children = 0 WHERE children = '';
UPDATE hotel\\\_bookings SET country = 'SIN DATO' WHERE country = '';
UPDATE hotel\\\_bookings SET agent = 0 WHERE agent = '';
UPDATE hotel\\\_bookings SET company = 0 WHERE company = '';
```

### FASE 3 — Normalización (Modelo Estrella)

El dataset original fue dividido en 4 tablas normalizadas:

* `hotel` → Información del hotel y habitaciones
* `guest` → Información del huésped
* `date` → Información de fechas y estadía
* `booking` → Tabla principal con Foreign Keys a las otras 3

```sql
-- Migración de datos a tabla hotel
INSERT INTO hotel (hotel, reserved\\\_room\\\_type, assigned\\\_room\\\_type, meal, deposit\\\_type)
SELECT DISTINCT hotel, reserved\\\_room\\\_type, assigned\\\_room\\\_type, meal, deposit\\\_type
FROM hotel\\\_bookings;

-- Migración a booking con INNER JOIN para obtener IDs
INSERT INTO booking (hotel\\\_id, guest\\\_id, date\\\_id, is\\\_canceled, lead\\\_time, adr, ...)
SELECT h.hotel\\\_id, g.guest\\\_id, d.date\\\_id, hb.is\\\_canceled, hb.lead\\\_time, hb.adr, ...
FROM hotel\\\_bookings hb
JOIN hotel h ON hb.hotel = h.hotel AND hb.meal = h.meal ...
JOIN guest g ON hb.country = g.country ...
JOIN date d ON hb.arrival\\\_date\\\_year = d.arrival\\\_date\\\_year ...
```

### FASE 4 — Columnas Calculadas

```sql
-- Total de noches por estadía
UPDATE date SET total\\\_nights = stays\\\_in\\\_weekend\\\_nights + stays\\\_in\\\_week\\\_nights;

-- Fecha completa de llegada
UPDATE date SET arrival\\\_date = STR\\\_TO\\\_DATE(
    CONCAT(arrival\\\_date\\\_day\\\_of\\\_month, ' ', arrival\\\_date\\\_month, ' ', arrival\\\_date\\\_year),
    '%d %M %Y'
);

-- Total de huéspedes
UPDATE guest SET total\\\_guests = adults + children + babies;
```

### FASE 5 — Preguntas de Negocio con SQL Avanzado

**JOINs y agregaciones:**

```sql
-- Tasa de cancelación por hotel
SELECT h.hotel, ROUND(AVG(b.is\\\_canceled), 2) AS tasa\\\_cancelacion
FROM booking b
JOIN hotel h ON b.hotel\\\_id = h.hotel\\\_id
GROUP BY h.hotel
ORDER BY tasa\\\_cancelacion DESC;
```

**CTE:**

```sql
-- País con mayor ingreso total por año
WITH ingresos AS (
    SELECT g.country, d.arrival\\\_date\\\_year,
           ROUND(SUM(b.adr \\\* d.total\\\_nights), 2) AS ingreso\\\_total
    FROM booking b
    JOIN date d ON b.date\\\_id = d.date\\\_id
    JOIN guest g ON b.guest\\\_id = g.guest\\\_id
    GROUP BY g.country, d.arrival\\\_date\\\_year
)
SELECT \\\* FROM ingresos ORDER BY ingreso\\\_total DESC LIMIT 10;
```

**Window Function:**

```sql
-- Ranking de países por reservas dentro de cada año
SELECT g.country, d.arrival\\\_date\\\_year, COUNT(b.booking\\\_id) AS reservas,
RANK() OVER (PARTITION BY d.arrival\\\_date\\\_year ORDER BY COUNT(b.booking\\\_id) DESC) AS ranking
FROM booking b
JOIN date d ON b.date\\\_id = d.date\\\_id
JOIN guest g ON b.guest\\\_id = g.guest\\\_id
GROUP BY g.country, d.arrival\\\_date\\\_year
ORDER BY d.arrival\\\_date\\\_year, ranking;
```

**Vista:**

```sql
CREATE VIEW general\\\_reservas AS
SELECT h.hotel, g.country, d.arrival\\\_date, d.total\\\_nights, 
       b.adr, b.is\\\_canceled, g.customer\\\_type, b.distribution\\\_channel
FROM booking b
JOIN hotel h ON b.hotel\\\_id = h.hotel\\\_id
JOIN guest g ON b.guest\\\_id = g.guest\\\_id
JOIN date d ON b.date\\\_id = d.date\\\_id;
```

**Stored Procedure:**

```sql
DELIMITER //
CREATE PROCEDURE reporte\\\_ingresos(IN anio INT)
BEGIN
    SELECT g.country, d.arrival\\\_date\\\_year,
           ROUND(SUM(b.adr \\\* d.total\\\_nights), 2) AS ingreso\\\_total
    FROM booking b
    JOIN date d ON b.date\\\_id = d.date\\\_id
    JOIN guest g ON b.guest\\\_id = g.guest\\\_id
    WHERE d.arrival\\\_date\\\_year = anio
    GROUP BY g.country, d.arrival\\\_date\\\_year
    ORDER BY ingreso\\\_total DESC;
END //
DELIMITER ;
```

### FASE 6 — Dashboard en Power BI

Conexión MySQL → Power BI con modelo estrella y 4 páginas:

* **Resumen General:** KPIs, reservas por mes y por hotel
* **Cancelaciones:** Tasa de cancelación por hotel y por mes
* **Ingresos:** ADR promedio por hotel y por año
* **Geografía:** Top 10 países y canales de distribución

**Métricas DAX creadas:**

```dax
Total Reservas = COUNT('hotel booking'\\\[booking\\\_id])
Tasa Cancelacion = ROUND(AVERAGE('hotel booking'\\\[is\\\_canceled]), 2)
ADR Promedio = AVERAGE('hotel booking'\\\[adr])
Total Noches = SUM('hotel date'\\\[total\\\_nights])
```

\---

## Principales Insights

* **City Hotel** es el más elegido con 79.330 reservas vs 40.060 del Resort Hotel
* La tasa de cancelación de **City Hotel (42%)** es significativamente mayor a la del Resort Hotel (28%)
* **Agosto** es el mes con más reservas históricamente, pero **Mayo 2017** fue el pico máximo con 6.313 reservas
* **Portugal (PRT)** lidera con 48.590 reservas — más del triple que el segundo país (GBR)
* El **82%** de las reservas llegan a través de agencias de viaje (TA/TO)
* El ADR promedio creció año a año: 2015 → 2016 → 2017

\---

## Estructura del Repositorio

```
hotel-bookings-analysis/
│
├── bookings\\\_hotel.sql        # Código SQL completo del proyecto

├── diagrama.mwb               # Diagrama
├── booking\\\_hotel\\\_PBI.pbix    # Dashboard de Power BI
└── README.md                 # Documentación del proyecto
```

