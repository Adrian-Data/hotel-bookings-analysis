#CARGA DE DATOS

-- PROBLEMA 1: El Import Wizard de MySQL Workbench tardaba más
-- de 30 minutos sin completar la carga de 119.390 registros.
-- SOLUCIÓN: Se utilizó LOAD DATA INFILE como alternativa
-- PROBLEMA 2: El CSV exportado desde Excel usaba punto y coma (;) como separador en lugar de coma (,).

-- Verifico la carpeta donde MySQL acepta archivos externos
SHOW VARIABLES LIKE 'secure_file_priv';

-- Importación del CSV
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/hotel_bookings_fixed.csv'
INTO TABLE hotel_bookings
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verificación de carga: debe retornar exactamente 119.390
SELECT COUNT(*) AS total_registros FROM hotel_bookings;

#LIMPIEZA DE DATOS

#ANÁLISIS DE TODAS LAS COLUMNAS EN BUSQUEDA DE NULOS (RESULTADO 0 NULOS)
SELECT 
    SUM(CASE WHEN hotel IS NULL THEN 1 ELSE 0 END) AS nulos_hotel,
    SUM(CASE WHEN is_canceled IS NULL THEN 1 ELSE 0 END) AS nulos_is_canceled,
    SUM(CASE WHEN lead_time IS NULL THEN 1 ELSE 0 END) AS nulos_lead_time,
    SUM(CASE WHEN arrival_date_year IS NULL THEN 1 ELSE 0 END) AS nulos_arrival_date_year,
    SUM(CASE WHEN arrival_date_month IS NULL THEN 1 ELSE 0 END) AS nulos_arrival_date_month,
    SUM(CASE WHEN arrival_date_week_number IS NULL THEN 1 ELSE 0 END) AS nulos_arrival_date_week_number,
    SUM(CASE WHEN arrival_date_day_of_month IS NULL THEN 1 ELSE 0 END) AS nulos_arrival_date_day_of_month,
    SUM(CASE WHEN stays_in_weekend_nights IS NULL THEN 1 ELSE 0 END) AS nulos_stays_in_weekend_nights,
    SUM(CASE WHEN stays_in_week_nights IS NULL THEN 1 ELSE 0 END) AS nulos_stays_in_week_nights,
    SUM(CASE WHEN adults IS NULL THEN 1 ELSE 0 END) AS nulos_adults,
    SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS nulos_children,
    SUM(CASE WHEN babies IS NULL THEN 1 ELSE 0 END) AS nulos_babies,
    SUM(CASE WHEN meal IS NULL THEN 1 ELSE 0 END) AS nulos_meal,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS nulos_country,
    SUM(CASE WHEN market_segment IS NULL THEN 1 ELSE 0 END) AS nulos_market_segment,
    SUM(CASE WHEN distribution_channel IS NULL THEN 1 ELSE 0 END) AS nulos_distribution_channel,
    SUM(CASE WHEN is_repeated_guest IS NULL THEN 1 ELSE 0 END) AS nulos_is_repeated_guest,
    SUM(CASE WHEN previous_cancellations IS NULL THEN 1 ELSE 0 END) AS nulos_previous_cancellations,
    SUM(CASE WHEN previous_bookings_not_canceled IS NULL THEN 1 ELSE 0 END) AS nulos_previous_bookings_not_canceled,
    SUM(CASE WHEN reserved_room_type IS NULL THEN 1 ELSE 0 END) AS nulos_reserved_room_type,
    SUM(CASE WHEN assigned_room_type IS NULL THEN 1 ELSE 0 END) AS nulos_assigned_room_type,
    SUM(CASE WHEN booking_changes IS NULL THEN 1 ELSE 0 END) AS nulos_booking_changes,
    SUM(CASE WHEN deposit_type IS NULL THEN 1 ELSE 0 END) AS nulos_deposit_type,
    SUM(CASE WHEN agent IS NULL THEN 1 ELSE 0 END) AS nulos_agent,
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS nulos_company,
    SUM(CASE WHEN days_in_waiting_list IS NULL THEN 1 ELSE 0 END) AS nulos_days_in_waiting_list,
    SUM(CASE WHEN customer_type IS NULL THEN 1 ELSE 0 END) AS nulos_customer_type,
    SUM(CASE WHEN adr IS NULL THEN 1 ELSE 0 END) AS nulos_adr,
    SUM(CASE WHEN required_car_parking_spaces IS NULL THEN 1 ELSE 0 END) AS nulos_required_car_parking_spaces,
    SUM(CASE WHEN total_of_special_requests IS NULL THEN 1 ELSE 0 END) AS nulos_total_of_special_requests,
    SUM(CASE WHEN reservation_status IS NULL THEN 1 ELSE 0 END) AS nulos_reservation_status,
    SUM(CASE WHEN reservation_status_date IS NULL THEN 1 ELSE 0 END) AS nulos_reservation_status_date
FROM hotel_bookings;

#ANÁLISIS DE TODAS LAS COLUMNAS EN BUSQUEDA DE CELDAS VACÍAS '', ADEMÁS SUMO "TRIM" PARA DETECTAR ESPACIOS ADELANTE O ATRÁS.
SELECT 
    COUNT(CASE WHEN TRIM(hotel) = '' THEN 1 END) AS vacios_hotel,
    COUNT(CASE WHEN TRIM(is_canceled) = '' THEN 1 END) AS vacios_is_canceled,
    COUNT(CASE WHEN TRIM(lead_time) = '' THEN 1 END) AS vacios_lead_time,
    COUNT(CASE WHEN TRIM(arrival_date_year) = '' THEN 1 END) AS vacios_arrival_date_year,
    COUNT(CASE WHEN TRIM(arrival_date_month) = '' THEN 1 END) AS vacios_arrival_date_month,
    COUNT(CASE WHEN TRIM(arrival_date_week_number) = '' THEN 1 END) AS vacios_arrival_date_week_number,
    COUNT(CASE WHEN TRIM(arrival_date_day_of_month) = '' THEN 1 END) AS vacios_arrival_date_day_of_month,
    COUNT(CASE WHEN TRIM(stays_in_weekend_nights) = '' THEN 1 END) AS vacios_stays_in_weekend_nights,
    COUNT(CASE WHEN TRIM(stays_in_week_nights) = '' THEN 1 END) AS vacios_stays_in_week_nights,
    COUNT(CASE WHEN TRIM(adults) = '' THEN 1 END) AS vacios_adults,
    COUNT(CASE WHEN TRIM(children) = '' THEN 1 END) AS vacios_children,
    COUNT(CASE WHEN TRIM(babies) = '' THEN 1 END) AS vacios_babies,
    COUNT(CASE WHEN TRIM(meal) = '' THEN 1 END) AS vacios_meal,
    COUNT(CASE WHEN TRIM(country) = '' THEN 1 END) AS vacios_country,
    COUNT(CASE WHEN TRIM(market_segment) = '' THEN 1 END) AS vacios_market_segment,
    COUNT(CASE WHEN TRIM(distribution_channel) = '' THEN 1 END) AS vacios_distribution_channel,
    COUNT(CASE WHEN TRIM(is_repeated_guest) = '' THEN 1 END) AS vacios_is_repeated_guest,
    COUNT(CASE WHEN TRIM(previous_cancellations) = '' THEN 1 END) AS vacios_previous_cancellations,
    COUNT(CASE WHEN TRIM(previous_bookings_not_canceled) = '' THEN 1 END) AS vacios_previous_bookings_not_canceled,
    COUNT(CASE WHEN TRIM(reserved_room_type) = '' THEN 1 END) AS vacios_reserved_room_type,
    COUNT(CASE WHEN TRIM(assigned_room_type) = '' THEN 1 END) AS vacios_assigned_room_type,
    COUNT(CASE WHEN TRIM(booking_changes) = '' THEN 1 END) AS vacios_booking_changes,
    COUNT(CASE WHEN TRIM(deposit_type) = '' THEN 1 END) AS vacios_deposit_type,
    COUNT(CASE WHEN TRIM(agent) = '' THEN 1 END) AS vacios_agent,
    COUNT(CASE WHEN TRIM(company) = '' THEN 1 END) AS vacios_company,
    COUNT(CASE WHEN TRIM(days_in_waiting_list) = '' THEN 1 END) AS vacios_days_in_waiting_list,
    COUNT(CASE WHEN TRIM(customer_type) = '' THEN 1 END) AS vacios_customer_type,
    COUNT(CASE WHEN TRIM(adr) = '' THEN 1 END) AS vacios_adr,
    COUNT(CASE WHEN TRIM(required_car_parking_spaces) = '' THEN 1 END) AS vacios_required_car_parking_spaces,
    COUNT(CASE WHEN TRIM(total_of_special_requests) = '' THEN 1 END) AS vacios_total_of_special_requests,
    COUNT(CASE WHEN TRIM(reservation_status) = '' THEN 1 END) AS vacios_reservation_status,
    COUNT(CASE WHEN TRIM(reservation_status_date) = '' THEN 1 END) AS vacios_reservation_status_date
FROM hotel_bookings;

#DESACTIVO SAFE MODE PARA PODER REALIZAR UPDATES
SET SQL_SAFE_UPDATES = 0;

#COMPLETANDO ESPACIOS VACIOS (children 4, country 488, agent 16340, company 112593)
UPDATE hotel_bookings
SET children = 0
WHERE children = '';

UPDATE hotel_bookings
SET country = 'SIN DATO'
WHERE country = '';

UPDATE hotel_bookings
SET agent = 0
WHERE agent = '';

UPDATE hotel_bookings
SET company = 0
WHERE company = '';

#BUSQUEDA DE DUPLICADOS. UTILIZO HAVING PARA FILTRAR DESPUÉS DE AGRUPAR (WHERE ANTES DE AGRUPAR)
SELECT 
    hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month,
    arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights,
    stays_in_week_nights, adults, children, babies, meal, country, market_segment,
    distribution_channel, is_repeated_guest, previous_cancellations,
    previous_bookings_not_canceled, reserved_room_type, assigned_room_type,
    booking_changes, deposit_type, agent, company, days_in_waiting_list,
    customer_type, adr, required_car_parking_spaces, total_of_special_requests,
    reservation_status, reservation_status_date,
    COUNT(*) AS repeticiones
FROM hotel_bookings
 GROUP BY 
    hotel, is_canceled, lead_time, arrival_date_year, arrival_date_month,
    arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights,
    stays_in_week_nights, adults, children, babies, meal, country, market_segment,
    distribution_channel, is_repeated_guest, previous_cancellations,
    previous_bookings_not_canceled, reserved_room_type, assigned_room_type,
    booking_changes, deposit_type, agent, company, days_in_waiting_list,
    customer_type, adr, required_car_parking_spaces, total_of_special_requests,
    reservation_status, reservation_status_date
    HAVING COUNT(*) > 1;
    
    
#BUSQUEDA DE VALORES INCONSISTENTES (MAL ESCRITOS) con DISTINCT (Hotel, HoTel, HO T el, etc.)
SELECT DISTINCT hotel FROM hotel_bookings;
SELECT DISTINCT arrival_date_month FROM hotel_bookings;
SELECT DISTINCT meal FROM hotel_bookings;
SELECT DISTINCT country FROM hotel_bookings;
SELECT DISTINCT market_segment FROM hotel_bookings;
SELECT DISTINCT distribution_channel FROM hotel_bookings;
SELECT DISTINCT reserved_room_type FROM hotel_bookings;
SELECT DISTINCT assigned_room_type FROM hotel_bookings;
SELECT DISTINCT deposit_type FROM hotel_bookings;
SELECT DISTINCT customer_type FROM hotel_bookings;
SELECT DISTINCT reservation_status FROM hotel_bookings;

#CORRIGIENDO TIPO DE DATOS DE LAS COLUMNAS
DESCRIBE hotel_bookings;

ALTER TABLE hotel_bookings
MODIFY COLUMN children INT;

ALTER TABLE hotel_bookings
MODIFY COLUMN reservation_status_date DATE;

#NORMALIZACION

#CREACION DE NUEVAS TABLAS PARA DIVIDIR (hotel_bookings) A TRAVES DE FORWARD ENGINEER AL CREAR EL DIAGRAMA DE TABLAS. LAS MUESTRO CON SHOW CREATE TABLE:
SHOW CREATE TABLE hotel;
SHOW CREATE TABLE guest;
SHOW CREATE TABLE date;
SHOW CREATE TABLE booking;

#INSERTANDO DATOS DE TABLA (hotel_bookings) A NUEVAS TABLAS CON DIAGRAMA - MODELO ESTRELLA (booking, date, guest, hotel)
INSERT INTO hotel (hotel, reserved_room_type, assigned_room_type, meal, deposit_type)
SELECT DISTINCT hotel, reserved_room_type, assigned_room_type, meal, deposit_type
FROM hotel_bookings;

INSERT INTO guest (country, customer_type, is_repeated_guest, previous_cancellations, previous_bookings_not_canceled, adults, children, babies)
SELECT DISTINCT country, customer_type, is_repeated_guest, previous_cancellations, previous_bookings_not_canceled, adults, children, babies
FROM hotel_bookings;

INSERT INTO date (arrival_date_year, arrival_date_month, arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights)
SELECT DISTINCT arrival_date_year, arrival_date_month, arrival_date_week_number, arrival_date_day_of_month, stays_in_weekend_nights, stays_in_week_nights
FROM hotel_bookings;

# INSERTANDO DATOS A TABLA BOOKING UTILIZANDO INNER JOIN
INSERT INTO booking (hotel_id, guest_id, date_id, is_canceled, lead_time, market_segment, distribution_channel, agent, company, booking_changes, days_in_waiting_list, required_car_parking_spaces, total_of_special_requests, reservation_status, reservation_status_date, adr)
SELECT h.hotel_id, g.guest_id, d.date_id,
    hb.is_canceled, hb.lead_time, hb.market_segment, hb.distribution_channel,
    hb.agent, hb.company, hb.booking_changes, hb.days_in_waiting_list,
    hb.required_car_parking_spaces, hb.total_of_special_requests,
    hb.reservation_status, hb.reservation_status_date, hb.adr
FROM hotel_bookings hb
JOIN hotel h ON hb.hotel = h.hotel 
    AND hb.reserved_room_type = h.reserved_room_type
    AND hb.assigned_room_type = h.assigned_room_type
    AND hb.meal = h.meal
    AND hb.deposit_type = h.deposit_type
JOIN guest g ON hb.country = g.country
    AND hb.customer_type = g.customer_type
    AND hb.is_repeated_guest = g.is_repeated_guest
    AND hb.previous_cancellations = g.previous_cancellations
    AND hb.previous_bookings_not_canceled = g.previous_bookings_not_canceled
    AND hb.adults = g.adults
    AND hb.children = g.children
    AND hb.babies = g.babies
JOIN date d ON hb.arrival_date_year = d.arrival_date_year
    AND hb.arrival_date_month = d.arrival_date_month
    AND hb.arrival_date_week_number = d.arrival_date_week_number
    AND hb.arrival_date_day_of_month = d.arrival_date_day_of_month
    AND hb.stays_in_weekend_nights = d.stays_in_weekend_nights
    AND hb.stays_in_week_nights = d.stays_in_week_nights;
    
#COLUMNAS CALCULADAS

#AGREGO 3 NUEVAS COLUMNAS EN date y guest
ALTER TABLE date 
ADD COLUMN total_nights INT;

ALTER TABLE date 
ADD COLUMN arrival_date DATE;

ALTER TABLE guest 
ADD COLUMN total_guests INT;

#UPGRADEO LAS 3 NUEVAS COLUMNAS
UPDATE date
SET total_nights = stays_in_weekend_nights + stays_in_week_nights;

#UTILIZO STR_TO_DATE PARA CONVERTIR COLUMNA arrival_date_month QUE ES STR EN TIPO DATE 
#AGREGO CONCAT PARA UNIR LAS 3 COLUMNAS Y CONFORMAR LA FECHA COMPLETA
UPDATE date
SET arrival_date = STR_TO_DATE(
    CONCAT(arrival_date_day_of_month, ' ', arrival_date_month, ' ', arrival_date_year),
    '%d %M %Y'
);

UPDATE guest
SET total_guests = adults + children + babies;

#PREGUNTAS DE NEGOCIO

#1. A lo largo de los años, ¿En qué mes se realizaron más reservas?
SELECT d.arrival_date_month, d.arrival_date_year, COUNT(b.booking_id) AS total_reservas
FROM booking b
JOIN date d ON b.date_id = d.date_id
GROUP BY d.arrival_date_month, d.arrival_date_year
ORDER BY total_reservas DESC;

#2. ¿En qué año se realizaron más reservas?
SELECT d.arrival_date_year, COUNT(b.booking_id) AS total_reservas
FROM booking b
JOIN date d ON b.date_id = d.date_id
GROUP BY d.arrival_date_year
ORDER BY total_reservas DESC;

#3. ¿Cuál es el hotel mas elegido?
SELECT h.hotel, COUNT(b.booking_id) AS total_reservas
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel
ORDER BY total_reservas DESC;

#4. ¿Cuál es la tasa de cancelación por hotel? Aplico ROUND para recudir 2 decimales
SELECT h.hotel, ROUND(AVG(b.is_canceled),2) AS tasa_cancelacion
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel
ORDER BY tasa_cancelacion DESC;

#5. ¿Cuáles son los 10 países con más reservas?
SELECT g.country, COUNT(b.booking_id) AS pais_reservas
FROM booking b
JOIN guest g ON b.guest_id = g.guest_id
GROUP BY g.country
ORDER BY pais_reservas DESC
LIMIT 10;

#6. ¿Cuál es el ingreso promedio por noche (columna ADR) por tipo de hotel?
SELECT h.hotel, ROUND(AVG(b.adr), 2) AS ingreso_promedio
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel
ORDER BY ingreso_promedio DESC;

#7. ¿Qué canal de distribución genera más reservas?
SELECT COUNT(booking_id) AS cantidad_reservas, distribution_channel
FROM booking
GROUP BY distribution_channel
ORDER BY cantidad_reservas DESC;

#8. ¿Cuántos son los huéspedes que más veces se repiten?
SELECT COUNT(guest_id) AS cantidad_huespedes, is_repeated_guest
FROM guest
GROUP BY is_repeated_guest
ORDER BY is_repeated_guest DESC;

#9. ¿Cuántas reservas hicieron los huéspedes repetidos vs no repetidos?
SELECT COUNT(b.booking_id) AS reservas, g.is_repeated_guest AS huespedes_repetidos
FROM booking  b
JOIN guest g ON b.guest_id = g.guest_id
GROUP BY is_repeated_guest
ORDER BY is_repeated_guest DESC;

#10. ¿Cuál es la estadía promedio en noches por tipo de cliente?
SELECT g.customer_type, ROUND(AVG(d.total_nights),2) AS promedio_noches
FROM booking b
JOIN date d ON b.date_id = d.date_id
JOIN guest g ON b.guest_id = g.guest_id
GROUP BY customer_type
ORDER BY promedio_noches DESC;

#11. ¿Qué mes tiene mayor tasa de cancelación a lo largo de los años?
SELECT ROUND(AVG(b.is_canceled),2) AS tasa_cancelacion, d.arrival_date_month
FROM booking b
JOIN date d ON b.date_id = d.date_id
GROUP BY arrival_date_month
ORDER BY tasa_cancelacion DESC;

#12. ¿Qué mes tiene mayor tasa de cancelación en 2016?
SELECT ROUND(AVG(b.is_canceled),2) AS tasa_cancelacion, d.arrival_date_month
FROM booking b
JOIN date d ON b.date_id = d.date_id
WHERE d.arrival_date_year = 2016
GROUP BY arrival_date_month
ORDER BY tasa_cancelacion DESC;

#13. ¿Cuáles son los meses que tienen tasa de cancelación mayor a 0.40 del año 2016? (Aplico HAVING para filtrar por una agregación AVG después del GROUP BY)
SELECT ROUND(AVG(b.is_canceled),2) AS tasa_cancelacion, d.arrival_date_month
FROM booking b
JOIN date d ON b.date_id = d.date_id
WHERE d.arrival_date_year = 2016
GROUP BY arrival_date_month
HAVING tasa_cancelacion > 0.40
ORDER BY tasa_cancelacion DESC;

#CTE (Common Table Expression) Consulta con nombre que usás después como si fuera una tabla.
#¿Cuál es el país con mayor ingreso total (adr × total_nights) por año?
WITH ingresos AS (
    SELECT 
        g.country,
        d.arrival_date_year,
        ROUND(SUM(b.adr * d.total_nights), 2) AS ingreso_total
    FROM booking b
    JOIN date d ON b.date_id = d.date_id
    JOIN guest g ON b.guest_id = g.guest_id
    GROUP BY g.country, d.arrival_date_year
)
SELECT *
FROM ingresos
ORDER BY ingreso_total DESC
LIMIT 10;

#WINDOW FUNCTION
#Ranking de países por reservas dentro de cada año
SELECT g.country, d.arrival_date_year, COUNT(b.booking_id) AS reservas,
RANK() OVER (PARTITION BY d.arrival_date_year ORDER BY COUNT(b.booking_id) DESC) AS ranking
FROM booking b
JOIN date d ON b.date_id = d.date_id
JOIN guest g ON b.guest_id = g.guest_id
GROUP BY g.country, d.arrival_date_year
ORDER BY d.arrival_date_year, ranking
LIMIT 20;


#VISTA
#Vista general de reservas combinando tablas con JOIN
CREATE VIEW general_reservas AS
SELECT h.hotel, g.country, d.arrival_date, d.total_nights, b.adr, b.is_canceled, g.customer_type, b.distribution_channel
FROM booking b
JOIN hotel h ON b.hotel_id = h.hotel_id
JOIN guest g ON b.guest_id = g.guest_id
JOIN date d ON b.date_id = d.date_id;

#VERIFICANDO VIEW
SELECT * FROM general_reservas;

#STORE PROCEDURE
#Ingresos por año
DELIMITER //
CREATE PROCEDURE reporte_ingresos(IN anio INT)
BEGIN
    SELECT g.country, 
           d.arrival_date_year,
           ROUND(SUM(b.adr * d.total_nights), 2) AS ingreso_total
    FROM booking b
    JOIN date d ON b.date_id = d.date_id
    JOIN guest g ON b.guest_id = g.guest_id
    WHERE d.arrival_date_year = anio
    GROUP BY g.country, d.arrival_date_year
    ORDER BY ingreso_total DESC;
END //
DELIMITER ;

#Llamada al Store Procedure para calcular ingresos del año 2016
CALL reporte_ingresos(2016);

