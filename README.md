Hotel Bookings Analysis
Descripción del Proyecto
Proyecto de análisis de datos end-to-end sobre reservas hoteleras, desarrollado como proyecto final de Bootcamp de Análisis de Datos. Se trabajó con un dataset real de 119.390 reservas de dos hoteles (City Hotel y Resort Hotel) entre 2015 y 2017.
El proyecto abarca desde la carga y limpieza de datos en MySQL, pasando por la normalización en un modelo estrella, hasta la visualización de insights clave en un dashboard interactivo en Power BI.
---
Objetivos
El objetivo principal fue analizar el comportamiento de las reservas hoteleras para responder preguntas de negocio reales:
¿En qué períodos se concentran más reservas?
¿Cuál es la tasa de cancelación por hotel y por mes?
¿Qué países generan más reservas?
¿Cuál es el ingreso promedio por noche?
¿Qué canales de distribución son más efectivos?
El proyecto busca proporcionar información accionable para la toma de decisiones estratégicas en la gestión hotelera.
---
Herramientas y Tecnologías
Herramienta	Uso
MySQL Workbench	Carga, limpieza, normalización y análisis con SQL
Power BI Desktop	Modelado de datos, DAX y dashboard interactivo
SQL	Lenguaje principal de análisis y transformación
DAX	Métricas calculadas en Power BI
---
Conjunto de Datos
Fuente: Dataset público `hotel_bookings.csv`
Registros: 119.390 reservas
Columnas originales: 32
Período: 2015 - 2017
Hoteles: City Hotel y Resort Hotel
Proceso de limpieza realizado:
Detección y corrección de valores nulos y vacíos en columnas `children` (4), `country` (488), `agent` (16.340) y `company` (112.593)
Verificación de valores inconsistentes con `DISTINCT`
Detección de duplicados con `GROUP BY` + `HAVING`
Corrección de tipos de datos (`children` a INT, `reservation_status_date` a DATE)
Detección de valores imposibles (reservas sin huéspedes, ADR negativo)
---
Código y Presentación
FASE 1 — Carga en MySQL
Importación del CSV mediante `LOAD DATA INFILE` en la tabla `hotel_bookings` con 119.390 registros.
FASE 2 — Limpieza de Datos
```sql
-- Búsqueda de nulos y vacíos en todas las columnas
SELECT 
    COUNT(CASE WHEN TRIM(hotel) = '' THEN 1 END) AS vacios_hotel,
    COUNT(CASE WHEN TRIM(country) = '' THEN 1 END) AS vacios_country,
    COUNT(CASE WHEN TRIM(agent) = '' THEN 1 END) AS vacios_agent
FROM hotel_bookings;

-- Corrección de vacíos
UPDATE hotel_bookings SET children = 0 WHERE children = '';
UPDATE hotel_bookings SET country = 'SIN DATO' WHERE country = '';
UPDATE hotel_bookings SET agent = 0 WHERE agent = '';
UPDATE hotel_bookings SET company = 0 WHERE company = '';
```
FASE 3 — Normalización (Modelo Estrella)
El dataset original fue dividido en 4 tablas normalizadas:
`hotel` → Información del hotel y habitaciones
`guest` → Información del huésped
`date` → Información de fechas y estadía
`booking` → Tabla principal con Foreign Keys a las otras 3
```sql
-- Migración de datos a tabla hotel
INSERT INTO hotel (hotel, reserved_room_type, assigned_room_type, meal, deposit_type)
SELECT DISTINCT hotel, reserved_room_type, assigned_room_type, meal, deposit_type
FROM hotel_bookings;

-- Migración a booking con INNER JOIN para obtener IDs
INSERT INTO booking (hotel_id, guest_id, date_id, is_canceled, lead_time, adr, ...)
SELECT h.hotel_id, g.guest_id, d.date_id, hb.is_canceled, hb.lead_time, hb.adr, ...
FROM hotel_bookings hb
JOIN hotel h ON hb.hotel = h.hotel AND hb.meal = h.meal ...
JOIN guest g ON hb.country = g.country ...
JOIN date d ON hb.arrival_date_year = d.arrival_date_year ...
```
FASE 4 — Columnas Calculadas
```sql
-- Total de noches por estadía
UPDATE date SET total_nights = stays_in_weekend_nights + stays_in_week_nights;

-- Fecha completa de llegada
UPDATE date SET arrival_date = STR_TO_DATE(
    CONCAT(arrival_date_day_of_month, ' ', arrival_date_month, ' ', arrival_date_year),
    '%d %M %Y'
);

-- Total de huéspedes
UPDATE guest SET total_guests = adults + children + babies;
```
FASE 5 — Preguntas de Negocio con SQL Avanzado
JOINs y agregaciones:
```sql
-- Tasa de cancelación por hotel
SELECT h.hotel, ROUND(AVG(b.is_canceled), 2) AS tasa_cancelacion
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel
ORDER BY tasa_cancelacion DESC;
```
CTE:
```sql
-- País con mayor ingreso total por año
WITH ingresos AS (
    SELECT g.country, d.arrival_date_year,
           ROUND(SUM(b.adr * d.total_nights), 2) AS ingreso_total
    FROM booking b
    JOIN date d ON b.date_id = d.date_id
    JOIN guest g ON b.guest_id = g.guest_id
    GROUP BY g.country, d.arrival_date_year
)
SELECT * FROM ingresos ORDER BY ingreso_total DESC LIMIT 10;
```
Window Function:
```sql
-- Ranking de países por reservas dentro de cada año
SELECT g.country, d.arrival_date_year, COUNT(b.booking_id) AS reservas,
RANK() OVER (PARTITION BY d.arrival_date_year ORDER BY COUNT(b.booking_id) DESC) AS ranking
FROM booking b
JOIN date d ON b.date_id = d.date_id
JOIN guest g ON b.guest_id = g.guest_id
GROUP BY g.country, d.arrival_date_year
ORDER BY d.arrival_date_year, ranking;
```
Vista:
```sql
CREATE VIEW general_reservas AS
SELECT h.hotel, g.country, d.arrival_date, d.total_nights, 
       b.adr, b.is_canceled, g.customer_type, b.distribution_channel
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
JOIN guest g ON b.guest_id = g.guest_id
JOIN date d ON b.date_id = d.date_id;
```
Stored Procedure:
```sql
DELIMITER //
CREATE PROCEDURE reporte_ingresos(IN anio INT)
BEGIN
    SELECT g.country, d.arrival_date_year,
           ROUND(SUM(b.adr * d.total_nights), 2) AS ingreso_total
    FROM booking b
    JOIN date d ON b.date_id = d.date_id
    JOIN guest g ON b.guest_id = g.guest_id
    WHERE d.arrival_date_year = anio
    GROUP BY g.country, d.arrival_date_year
    ORDER BY ingreso_total DESC;
END //
DELIMITER ;
```
FASE 6 — Dashboard en Power BI
Conexión MySQL → Power BI con modelo estrella y 4 páginas:
Resumen General: KPIs, reservas por mes y por hotel
Cancelaciones: Tasa de cancelación por hotel y por mes
Ingresos: ADR promedio por hotel y por año
Geografía: Top 10 países y canales de distribución
Métricas DAX creadas:
```dax
Total Reservas = COUNT('hotel booking'[booking_id])
Tasa Cancelacion = ROUND(AVERAGE('hotel booking'[is_canceled]), 2)
ADR Promedio = AVERAGE('hotel booking'[adr])
Total Noches = SUM('hotel date'[total_nights])
```
---
Principales Insights
City Hotel es el más elegido con 79.330 reservas vs 40.060 del Resort Hotel
La tasa de cancelación de City Hotel (42%) es significativamente mayor a la del Resort Hotel (28%)
Agosto es el mes con más reservas históricamente, pero Mayo 2017 fue el pico máximo con 6.313 reservas
Portugal (PRT) lidera con 48.590 reservas — más del triple que el segundo país (GBR)
El 82% de las reservas llegan a través de agencias de viaje (TA/TO)
El ADR promedio creció año a año: 2015 → 2016 → 2017
---
Estructura del Repositorio
```
hotel-bookings-analysis/
│
├── bookings_hotel.sql        # Código SQL completo del proyecto
├── booking_hotel_PBI.pbix    # Dashboard de Power BI
└── README.md                 # Documentación del proyecto
```
