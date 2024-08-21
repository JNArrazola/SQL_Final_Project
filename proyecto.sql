-- Tablas: 
SELECT * FROM WF_COUNTRIES;
SELECT * FROM WF_WORLD_REGIONS;
SELECT * FROM WF_CURRENCIES;
SELECT * FROM WF_SPOKEN_LANGUAGES;
SELECT * FROM WF_LANGUAGES;


-- PAQUETE 1: PROVEER INFORMACIÓN BÁSICA A LOS VIAJEROS

-- PACKAGE HEADER
CREATE OR REPLACE PACKAGE traveler_assistance_package AS

    -- Procedimiento 1
    TYPE country_record IS RECORD (
        country_name WF_COUNTRIES.COUNTRY_NAME%TYPE,
        location WF_COUNTRIES.LOCATION%TYPE,
        capitol WF_COUNTRIES.CAPITOL%TYPE,
        population WF_COUNTRIES.POPULATION%TYPE,
        airports WF_COUNTRIES.AIRPORTS%TYPE,
        climate WF_COUNTRIES.CLIMATE%TYPE
    );

    -- Procedimiento 2
    TYPE country_type IS RECORD(
        country_name WF_COUNTRIES.country_name%TYPE,
        region WF_WORLD_REGIONS.REGION_NAME%TYPE,
        currency WF_CURRENCIES.currency_name%TYPE
    );
    TYPE countries_type IS TABLE OF country_type INDEX BY PLS_INTEGER;

    TYPE country_language_type IS RECORD(
        country_name WF_COUNTRIES.country_name%TYPE,
        language_name WF_LANGUAGES.language_name%TYPE,
        official_language WF_SPOKEN_LANGUAGES.official%TYPE
    );
    TYPE country_languages_type IS TABLE OF country_language_type INDEX BY PLS_INTEGER;

    PROCEDURE country_demographics(v_country_name VARCHAR2); -- Procedimiento 1
    PROCEDURE find_region_and_currency(v_country_name IN VARCHAR2, country OUT country_type); -- Procedimiento 2
    PROCEDURE countries_in_same_region(v_region_name IN VARCHAR2, countries OUT countries_type); --Procedimiento 3
    PROCEDURE print_region_array(countries countries_type); -- Procedimiento 4 
    PROCEDURE country_languages(v_country_name IN VARCHAR2, country_lang OUT country_languages_type ); -- Procedimiento 5
    PROCEDURE print_language_array(country_language country_languages_type); -- Procedimiento 6
END;

DESCRIBE WF_countries;
CREATE OR REPLACE PACKAGE BODY traveler_assistance_package AS
    -- 1. Crea un procedimiento llamado country_demographics para mostrar información específica acerca
    -- de un país.
    -- • Pasa COUNTRY_NAME como un parámetro de entrada. Muestra las columnas
    -- COUNTRY_NAME, LOCATION, CAPITOL, POPULATION, AIRPORTS, CLIMATE. Usa una
    -- estructura de registro definido por el Usuario para la cláusula INTO de tu sentencia Select. Lanza
    -- una excepción si el país indicado no existe.
    PROCEDURE country_demographics(v_country_name VARCHAR2) IS
    v_country_information country_record;
    BEGIN
        SELECT COUNTRY_NAME, LOCATION, CAPITOL, POPULATION, AIRPORTS, CLIMATE
        INTO v_country_information
        FROM WF_COUNTRIES
        WHERE UPPER(COUNTRY_NAME) = UPPER(v_country_name);

        DBMS_OUTPUT.PUT_LINE('Country Name: ' || v_country_information.country_name);
        DBMS_OUTPUT.PUT_LINE('Location: ' || v_country_information.location);
        DBMS_OUTPUT.PUT_LINE('Capitol: ' || v_country_information.capitol);
        DBMS_OUTPUT.PUT_LINE('Population: ' || TO_CHAR(v_country_information.population));
        DBMS_OUTPUT.PUT_LINE('Airports: ' || TO_CHAR(v_country_information.airports));
        DBMS_OUTPUT.PUT_LINE('Climate: ' || v_country_information.climate);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontró información para el país: ' || v_country_name);
    END country_demographics;


    -- 2. Crea un procedimiento llamado find_region_and_currency para leer y regresar la moneda y región
    -- en la cual un país está localizado.
    -- • Pasa COUNTRY_NAME como un parámetro de entrada y usa un registro definido por el Usuario
    -- como un parámetro de salida que devuelva el nombre del país, su región y su moneda
    PROCEDURE find_region_and_currency(v_country_name IN VARCHAR2, country OUT country_type) IS
    BEGIN
        SELECT c.country_name, wr.region_name, cu.currency_name INTO country
        FROM WF_COUNTRIES c, WF_WORLD_REGIONS wr, WF_CURRENCIES cu
        WHERE LOWER(c.COUNTRY_NAME) = LOWER(v_country_name) AND
                c.REGION_ID = wr.REGION_ID AND
                c.CURRENCY_CODE = cu.CURRENCY_CODE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontraron ciudades para ' || v_country_name);
    END;

    -- 3. Crea un procedimiento countries_in_same_region para leer y devolver todos los países en la misma 
    -- región.  
    -- • Pasa REGION_NAME como un parámetro de entrada y un arreglo asociativo de registros 
    -- (una tabla INDEX BY ) como parámetro de salida. Devuelve REGION_NAME, 
    -- COUNTRY_NAME, y  CURRENCY_NAME  por medio del parámetro de salida para todos los 
    -- países en la región solicitada.
    PROCEDURE countries_in_same_region(v_region_name IN VARCHAR2, countries OUT countries_type) IS
        v_country country_type;
        i PLS_INTEGER := 1;
    BEGIN
        FOR r IN (SELECT c.country_name, r.region_name, cu.currency_name
                  FROM WF_COUNTRIES c
                  JOIN WF_WORLD_REGIONS r ON c.region_id = r.region_id
                  JOIN WF_CURRENCIES cu ON c.currency_code = cu.currency_code
                  WHERE LOWER(r.region_name) = LOWER(v_region_name)) LOOP
            
            v_country.country_name := r.country_name;
            v_country.region := r.region_name;
            v_country.currency := r.currency_name;
    
            countries(i) := v_country;
            i := i + 1;
        END LOOP;
    
        IF i = 1 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontraron ciudades para ' || v_region_name);
    END;

    -- 4. Crea un procedimiento print_region_array para mostrar el contenido de un arreglo de registros que
    -- es pasado a él.
    -- • Pasa un arreglo asociativo de registro que fue declarado en el procedimiento
    -- countries_in_same_region, como un parámetro de entrada. El procedimiento debe mostrar su
    -- contenido. 
    PROCEDURE print_region_array(countries countries_type) IS
    BEGIN
        FOR i IN countries.FIRST .. countries.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Country Name : ' || countries(i).country_name);
            DBMS_OUTPUT.PUT_LINE('Region       : ' || countries(i).region);
            DBMS_OUTPUT.PUT_LINE('Currency     : ' || countries(i).currency);
            DBMS_OUTPUT.PUT_LINE('----------------------------------');
        END LOOP;
    END;

    -- 5. Crea un procedimiento country_languages para leer y devolver todos los idiomas hablados, así como
    -- el idioma oficial de un país.
    -- • Pasa COUNTRY_NAME como un parámetro de entrada. El parámetro de salida será un arreglo
    -- asociativo que devolverá las columnas COUNTRY_NAME, LANGUAGE_NAME and
    -- OFFICIAL. 
    PROCEDURE country_languages(v_country_name IN VARCHAR2, country_lang OUT country_languages_type) IS
        v_language country_language_type;
        i PLS_INTEGER := 1;
    BEGIN
        FOR r IN (SELECT c.country_name, l.language_name, sl.official
                  FROM WF_COUNTRIES c
                  JOIN WF_SPOKEN_LANGUAGES sl ON c.country_id = sl.country_id
                  JOIN WF_LANGUAGES l ON sl.language_id = l.language_id
                  WHERE UPPER(c.country_name) = UPPER(v_country_name)) LOOP

            v_language.country_name := r.country_name;
            v_language.language_name := r.language_name;
            v_language.official_language := r.official;
            
            country_lang(i) := v_language;
            i := i + 1;
        END LOOP;

        IF i = 1 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontraron idiomas para el país: ' || v_country_name);
    END;

    -- 6. Crea un procedimiento print_language_array para mostrar el contenido de un arreglo asociativo de
    -- registros que es pasado a él.
    -- • Pasa un arreglo asociativo de registros que fue declarado en el procedimiento countries_languages,
    -- como un parámetro de entrada. El procedimiento debe mostrar su contenido. 
    PROCEDURE print_language_array(country_language country_languages_type) IS
    BEGIN
        FOR i IN country_language.FIRST .. country_language.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Country Name      : ' || country_language(i).country_name);
            DBMS_OUTPUT.PUT_LINE('Language Name     : ' || country_language(i).language_name);
            DBMS_OUTPUT.PUT_LINE('Official Language : ' || country_language(i).official_language);
            DBMS_OUTPUT.PUT_LINE('--------------------------');
        END LOOP;
    END;
END;

-- =======
-- PRUEBAS
-- =======
SET SERVEROUTPUT ON;

-- Procedimiento 1
SELECT COUNTRY_NAME, LOCATION, CAPITOL, POPULATION, AIRPORTS, CLIMATE FROM WF_COUNTRIES WHERE COUNTRY_NAME = 'Mongolia';

BEGIN
    TRAVELER_ASSISTANCE_PACKAGE.COUNTRY_DEMOGRAPHICS('Mongolia');
END;

-- Procedimiento 2

SELECT c.country_name, wr.region_name, cu.currency_name 
        FROM WF_COUNTRIES c, WF_WORLD_REGIONS wr, WF_CURRENCIES cu
        WHERE LOWER(c.COUNTRY_NAME) = LOWER('Mongolia') AND
                c.REGION_ID = wr.REGION_ID AND
                c.CURRENCY_CODE = cu.CURRENCY_CODE;

DECLARE
    country_name VARCHAR2(50) := 'Mongolia';
    country TRAVELER_ASSISTANCE_PACKAGE.country_type;
BEGIN
    TRAVELER_ASSISTANCE_PACKAGE.FIND_REGION_AND_CURRENCY(country_name, country);
    DBMS_OUTPUT.PUT_LINE(country.country_name || ', ' || country.region || ', ' || country.currency);
END;

-- Procedimiento 3 y procedimiento 4
SELECT c.country_name, r.region_name, cu.currency_name
FROM WF_COUNTRIES c
JOIN WF_WORLD_REGIONS r ON c.region_id = r.region_id
JOIN WF_CURRENCIES cu ON c.currency_code = cu.currency_code
WHERE LOWER(r.region_name) = LOWER('Central America');

DECLARE
    region_name VARCHAR2(50) := 'Central America';
    countries TRAVELER_ASSISTANCE_PACKAGE.countries_type;
BEGIN
    TRAVELER_ASSISTANCE_PACKAGE.COUNTRIES_IN_SAME_REGION(region_name, countries);
    TRAVELER_ASSISTANCE_PACKAGE.PRINT_REGION_ARRAY(countries);
END;

-- Procedimiento 5 y procedimiento 6
DECLARE
    country_name VARCHAR2(50) := 'Belize';
    country_langs TRAVELER_ASSISTANCE_PACKAGE.country_languages_type;
BEGIN
    TRAVELER_ASSISTANCE_PACKAGE.COUNTRY_LANGUAGES(country_name, country_langs);
    TRAVELER_ASSISTANCE_PACKAGE.PRINT_LANGUAGE_ARRAY(country_langs);
END;

-- ===============================================
-- PAQUETE 2: Administración del sistema de viajeros
-- ===============================================

-- PACKAGE HEADER
CREATE OR REPLACE PACKAGE traveler_admin_package AS
    TYPE obj_rec IS RECORD(
        name user_dependencies.name%TYPE,
        type user_dependencies.type%TYPE,
        referenced_name user_dependencies.referenced_name%TYPE,
        referenced_type user_dependencies.referenced_type%TYPE
    );
    TYPE obj_arr IS TABLE OF obj_rec INDEX BY PLS_INTEGER;

    -- Procedimiento 1
    PROCEDURE display_disabled_triggers;

    -- Procedimiento 2
    FUNCTION all_dependent_objects(object_name VARCHAR2) RETURN obj_arr;

    -- Procedimiento 3
    PROCEDURE print_dependent_objects(objects obj_arr);
END;

-- PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY traveler_admin_package AS
    -- 1. Crear un procedimiento display_disabled_triggers que muestre una lista de todos los triggers
    -- deshabilitados en tu esquema.
    PROCEDURE display_disabled_triggers IS
    
    CURSOR triggers IS SELECT 
    trigger_name FROM user_triggers 
    WHERE status = 'DISABLED';

    BEGIN
        FOR trigger IN triggers LOOP
            DBMS_OUTPUT.PUT_LINE( 'El trigger ' || trigger.trigger_name ||' está desactivado' );
        END LOOP;
    END;

    -- 2. Crea una función all_dependent_objects que devuelva todos los objetos dependientes de un objeto en
    -- particular.
    -- Pasa OBJECT_NAME como un parámetro de entrada y devuelve un arreglo que contenga los
    -- valores NAME , TYPE, REFERENCED_NAME AND REFERENCED_TYPE. 
    FUNCTION all_dependent_objects(object_name VARCHAR2)
    RETURN obj_arr IS
        v_objects obj_arr;
    BEGIN
        -- Usamos BULK COLLECT para llenar el arreglo de una sola vez
        SELECT name, type, referenced_name, referenced_type
        BULK COLLECT INTO v_objects
        FROM user_dependencies 
        WHERE referenced_name = UPPER(object_name);

        -- Si no se encontraron objetos, se lanza una excepción
        IF v_objects.COUNT < 1 THEN
            RAISE NO_DATA_FOUND;
        END IF;

        RETURN v_objects;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'No se encontraron datos');
    END;

    -- 3. Crea un procedimiento print_dependent_objects que muestre el arreglo de los objetos dependientes
    -- devuelto por la función all_dependent_objects. 
    PROCEDURE print_dependent_objects(objects IN obj_arr) IS
    BEGIN
        FOR i IN objects.FIRST .. objects.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Object Name        : ' || objects(i).name);
            DBMS_OUTPUT.PUT_LINE('Object Type        : ' || objects(i).type);
            DBMS_OUTPUT.PUT_LINE('Referenced Name    : ' || objects(i).referenced_name);
            DBMS_OUTPUT.PUT_LINE('Referenced Type    : ' || objects(i).referenced_type);
            DBMS_OUTPUT.PUT_LINE('------------------------------------------');
        END LOOP;
    END;
END;

-- =======
-- PRUEBAS
-- =======

-- Procedimiento 1
-- Imprimimos los triggers
SELECT trigger_name FROM user_triggers;

-- Desactivamos el trigger llamado GUNS_BEFORE_INSERT
ALTER TRIGGER GUNS_BEFORE_INSERT DISABLE;

--- Mostramos el trigger desactivado
BEGIN
    traveler_admin_package.display_disabled_triggers();
END;

--- Activamos el Trigger GUNS_BEFORE_INSERT
ALTER TRIGGER GUNS_BEFORE_INSERT ENABLE;

-- Mostramos el Trigger activado
BEGIN
    traveler_admin_package.display_disabled_triggers();
END;


-- Procedimiento 2 y 3
SELECT * FROM user_dependencies WHERE referenced_name = 'REGIONS';

DECLARE
    v_objects TRAVELER_ADMIN_PACKAGE.obj_arr;
BEGIN
    v_objects := traveler_admin_package.all_dependent_objects('regions');
    traveler_admin_package.print_dependent_objects(v_objects);
END;