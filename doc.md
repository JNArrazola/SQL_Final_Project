# Documentación
El primer paso para empezar el proyecto, como es lógico, fue leer las instrucciones, donde nos dimos cuenta que durante el proyecto debiamos trabajar en dos paquetes, `traveler_assistance_package` y `traveler_admin_package`.

## Paquete **TRAVELER ASSISTANCE**.
Para empezar, creamos el *package header* del paquete **traveler_assistance_package**:
```sql
-- PACKAGE HEADER
CREATE OR REPLACE PACKAGE traveler_assistance_package
```
Así como también el *package body*:
```sql
-- PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY traveler_assistance_package
```

El paquete `traveler_assistance_package` debe contener 6 procedimientos:
1. country_demographics
2. find_region_and_currency
3. countries_in_same_region
4. print_region_array
5. country_languages
6. print_language_array

Donde a continuación se documenta cada uno: 

### 1. **country_demographics**
Se nos pide programar un *procedimiento* llamado **country_demographics**, que nos permita mostrar información específica acerca de un país. Además, en la siguiente instrucción, se nos pide pasar `COUNTRY_NAME` como parámetro de entrada.

El primer paso para empezar a programar cada procedimiento dentro de un paquete es colocarlo en el *package header*, por lo cual colocamos el nombre del procedimiento junto con el parámetro que recibe:
```sql
PROCEDURE country_demographics(v_country_name VARCHAR2); -- Procedimiento 1 // Esto va en el PACKAGE HEADER
``` 

Posterior a ello, empezamos a escribir el cuerpo del procedimiento dentro del *package body*:
```sql
PROCEDURE country_demographics(v_country_name VARCHAR2) IS
```
> Donde atendemos la instrucción que nos pide que enviemos como parámetro el `country_name`.

Después, la instrucción nos pide que mostremos las columnas `COUNTRY_NAME`, `LOCATION`, `CAPITOL`, `POPULATION`, `AIRPORTS` Y `CLIMATE`. Sin embargo, la instrucción **no** especifica directamente de cual tabla es de la que tenemos que obtener todos estos datos, por lo cual el uso de la sentencia **DESCRIBE** nos puede ser útil para estos casos:
```sql
SQL>   DESCRIBE WF_countries;
Name	Null?	Type
COUNTRY_ID	NOT NULL	NUMBER(4)
REGION_ID	NOT NULL	NUMBER(3)
COUNTRY_NAME	NOT NULL VARCHAR2(70) -- COUNTRY_NAME
COUNTRY_TRANSLATED_NAME		VARCHAR2(40)
LOCATION		VARCHAR2(90) -- LOCATION
CAPITOL		VARCHAR2(50) -- CAPITOL
AREA		NUMBER(15)
COASTLINE		NUMBER(8)
LOWEST_ELEVATION		NUMBER(6)
LOWEST_ELEV_NAME		VARCHAR2(70)
HIGHEST_ELEVATION		NUMBER(6)
HIGHEST_ELEV_NAME		VARCHAR2(50)
DATE_OF_INDEPENDENCE		VARCHAR2(30)
NATIONAL_HOLIDAY_NAME		VARCHAR2(200)
NATIONAL_HOLIDAY_DATE		VARCHAR2(30)
POPULATION		NUMBER(12) -- POPULATION
POPULATION_GROWTH_RATE		VARCHAR2(10)
LIFE_EXPECT_AT_BIRTH		NUMBER(6,2)
MEDIAN_AGE		NUMBER(6,2)
AIRPORTS		NUMBER(6) -- AIRPORTS
CLIMATE		VARCHAR2(1000) -- CLIMATE
FIPS_ID		CHAR(2)
INTERNET_EXTENSION		VARCHAR2(3)
FLAG		BLOB
CURRENCY_CODE	NOT NULL	VARCHAR2(7)
```