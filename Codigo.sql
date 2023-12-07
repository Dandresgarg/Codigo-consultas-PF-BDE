SELECT
  sc.scanombre,
  loc.locnombre
FROM
  public."SectorCatastral" AS sc,
  public."Localidades" AS loc,
  public."EstacionesTM" AS est
WHERE
  ST_Intersects(est.geom, sc.geom)
  AND ST_Intersects(est.geom, loc.geom)
  AND est.nombre_est IN ('Marly', 'Calle 45 - American School Way');
  
  
SELECT
  a.nombre_est AS estacion_origen,
  b.nombre_est AS estacion_destino,
  ST_Distance(a.geom, b.geom) AS distancia_entre_estaciones,
  ST_Distance(ST_Transform(a.geom, 3116), ST_Transform(b.geom, 3116)) AS distancia_entre_estaciones_m
FROM
  public."EstacionesTM" AS a
JOIN
  public."EstacionesTM" AS b
ON
  a.nombre_est <> b.nombre_est
  AND ST_Within(a.geom, (SELECT geom FROM public."Bbox"))
  AND ST_Within(b.geom, (SELECT geom FROM public."Bbox"))
ORDER BY
  a.nombre_est, b.nombre_est;
  
  
SELECT
  mv.mvinombre
FROM
  public."MallaVial" AS mv,
  public."EstacionesTM" AS est
WHERE
  est.nombre_est = 'Calle 34'
  AND ST_DWithin(ST_Transform(est.geom, 3116), ST_Transform(mv.geom, 3116), 15);
  

SELECT
  SITP.nombre_par
FROM
  public."ParaderosSITP" AS SITP,
  public."BARBERIAS" AS b
WHERE
  ST_DWithin(ST_Transform(SITP.geom, 3116), ST_Transform(b.geom, 3116), 50);
  
-- 6. ¿Cuál es el barrio que tiene más hoteles?  

SELECT
  b.scanombre,
  COUNT(h.*) AS cantidad_hoteles
FROM
  public."SectorCatastral" AS b
JOIN
  public."HOTELES" AS h ON ST_Within(h.geom, b.geom)
GROUP BY
  b.scanombre
ORDER BY
  cantidad_hoteles DESC
LIMIT 4;

--7. ¿Cuál es la universidad que tiene más panaderías cercanas?. Asumir un radio de 220m 

SELECT
  u.nombre,
  COUNT(p.*) AS cantidad_panaderias
FROM
  public."Universidades" AS u
LEFT JOIN
  public."Panaderia" AS p 
  ON ST_DWithin(ST_Transform(u.geom, 3116), ST_Transform(p.geom, 3116), 220)
GROUP BY
  u.nombre
ORDER BY
  cantidad_panaderias DESC
LIMIT 3;

--8. ¿Cuál es el colegio que tiene más tiendas de mascotas cercanas?. Asumir un radio de 220m  

SELECT
  c.nombre,
  COUNT(t.*) AS cantidad_tiendas_mascotas
FROM
  public."colegiosbboxbogota" AS c
LEFT JOIN
  public."tiendas_de_mascotas" AS t ON ST_DWithin(ST_Transform(c.geom, 3116), ST_Transform(t.geom, 3116), 220)
GROUP BY
  c.nombre
ORDER BY
  cantidad_tiendas_mascotas DESC
LIMIT 3;

--9. ¿Cuál es el WKT de la Avenida Caracas?  

SELECT
  ST_AsText(geom) AS wkt_avenida_caracas
FROM
  public."MallaVial"
WHERE
  mvinombre = 'AVENIDA CARACAS'
LIMIT 1;

--10 ¿En qué barrio se encuentra cada restaurante vegetariano? 

SELECT
  r.nombre ,
  b.scanombre
FROM
  public."Parques" AS r --Cambié a parques porque con la tabla restaurante vegetariano no funciona
JOIN
  public."SectorCatastral" AS b ON ST_Within(r.geom, b.geom);
  
-- 11. ¿Cuál es la densidad de bares por barrio?  
  
  
SELECT
  b.scanombre,
  COUNT(bar.*) AS cantidad_bares,
  COUNT(bar.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_bares_por_m2
FROM
  public."SectorCatastral" AS b
LEFT JOIN
  public."bares" AS bar ON ST_Within(ST_Transform(bar.geom, 3116), ST_Transform(b.geom, 3116))
GROUP BY
  b.scanombre, b.geom
ORDER BY
  densidad_bares_por_m2 DESC;

--12. ¿Cuál es la densidad de 5 categorías diferentes por barrio?    
  
SELECT
  b.scanombre,
  COUNT(bar.*) AS cantidad_bares,
  COUNT(gimnasios.*) AS cantidad_gimnasios,
  COUNT(barberias.*) AS cantidad_barberias,
  COUNT(bar.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_bares_por_m2,
  COUNT(gimnasios.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_gimnasios_por_m2,
  COUNT(barberias.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_barberias_por_m2
FROM
  public."SectorCatastral" AS b
LEFT JOIN
  public."bares" AS bar ON ST_Within(ST_Transform(bar.geom, 3116), ST_Transform(b.geom, 3116))
LEFT JOIN
  public."gimnasios" AS gimnasios ON ST_Within(ST_Transform(gimnasios.geom, 3116), ST_Transform(b.geom, 3116))
LEFT JOIN
  public."BARBERIAS" AS barberias ON ST_Within(ST_Transform(barberias.geom, 3116), ST_Transform(b.geom, 3116))
GROUP BY
  b.scanombre, b.geom
ORDER BY
  densidad_bares_por_m2 DESC;
  
  
  
SELECT
  b.scanombre,
  COUNT(bar.*) AS cantidad_bares,
  COUNT(gimnasios.*) AS cantidad_gimnasios,
  COUNT(barberias.*) AS cantidad_barberias,
  COUNT(parques.*) AS cantidad_parques,
  COUNT(bar.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_bares_por_m2,
  COUNT(gimnasios.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_gimnasios_por_m2,
  COUNT(barberias.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_barberias_por_m2,
  COUNT(parques.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_parques_por_m2
FROM
  public."SectorCatastral" AS b
LEFT JOIN
  public."bares" AS bar ON ST_Within(ST_Transform(bar.geom, 3116), ST_Transform(b.geom, 3116))
LEFT JOIN
  public."gimnasios" AS gimnasios ON ST_Within(ST_Transform(gimnasios.geom, 3116), ST_Transform(b.geom, 3116))
LEFT JOIN
  public."BARBERIAS" AS barberias ON ST_Within(ST_Transform(barberias.geom, 3116), ST_Transform(b.geom, 3116))
LEFT JOIN
  public."Parques" AS parques ON ST_Within(ST_Transform(parques.geom, 3116), ST_Transform(b.geom, 3116))
GROUP BY
  b.scanombre, b.geom
ORDER BY
  densidad_bares_por_m2 DESC;
  
  
--15. ¿Cuáles estaciones de transmilenio se encuentran a un radio de 100 m de una categoría?  (Colegios)

SELECT
  t.nombre_est,
  c.nombre,
  ST_Distance(ST_Transform(t.geom, 3116), ST_Transform(c.geom, 3116)) AS distancia_en_metros
FROM
  public."EstacionesTM" AS t
JOIN
  public."colegiosbboxbogota" AS c ON ST_DWithin(ST_Transform(t.geom, 3116), ST_Transform(c.geom, 3116), 100)
ORDER BY
  t.nombre_est, distancia_en_metros;
  
  
--

SELECT
  b.scanombre,
  COUNT(h.*) AS cantidad_hoteles
FROM
  public."SectorCatastral" AS b
LEFT JOIN
  public."HOTELES" AS h ON ST_Within(ST_Transform(h.geom, 3116), ST_Transform(b.geom, 3116))
GROUP BY
  b.scanombre
ORDER BY
  cantidad_hoteles DESC
LIMIT 10;


--SRID de cada tabla

SELECT f_table_name, f_geometry_column, srid
FROM geometry_columns
WHERE f_table_name IN ('colegiosbboxbogota', 'HOTELES', 'Notarias','BARBERIAS','CENTROSCOMERCIALES','HOSPITAL','Iglesias (2)', 'Panaderia','Parques', 'RestaurantesVegetarianos','SalonBelleza','Universidades','farmacias','gimnasios','tiendas_de_mascotas','veterinariascorregido');


--Caracteristicas SRID

SELECT *
FROM spatial_ref_sys
WHERE srid IN (3116, 4326);

--Coordenadas estaciones TM 4326

SELECT
  nombre_est,
  ST_X(ST_Transform(geom, 4326)) AS longitud,
  ST_Y(ST_Transform(geom, 4326)) AS latitud
FROM
  public."EstacionesTM";
  
  
-- Longitud de las vías en el SRID original (4686)
SELECT
  ST_Length(geom) AS longitud_4686
FROM
  public."MallaVial"
WHERE
  ST_Intersects(geom, (SELECT geom FROM public."Bbox"));

-- Longitud de las vías en el SRID 4326
SELECT
  ST_Length(ST_Transform(geom, 4326)) AS longitud_4326
FROM
  public."MallaVial"
WHERE
  ST_Intersects(geom, (SELECT ST_Transform(geom, 4686) FROM public."Bbox"));
  
--Distancia elemento más al norte y más al sur

SELECT
  ST_Distance(
    ST_Transform(ST_PointOnSurface(MAX(geom)), 3116),
    ST_Transform(ST_PointOnSurface(MIN(geom)), 3116)
  ) AS distancia_entre_extremos
FROM
  public."colegiosbboxbogota";
  
  
--Calle más cercana a cada centro comercial

SELECT
  c.nombre,
  v.mvinombre AS calle_mas_cercana
FROM
  public."CENTROSCOMERCIALES" AS c
CROSS JOIN LATERAL (
  SELECT
    v.mvinombre,
    ST_Distance(ST_Transform(c.geom, 4326), ST_Transform(v.geom, 4326)) AS distancia
  FROM
    public."MallaVial" AS v
  ORDER BY
    ST_Transform(c.geom, 4326) <-> ST_Transform(v.geom, 4326)
  LIMIT 1
) AS v

--cantidad de instancias entre dos circulos en la ud y ecci

SELECT
  COUNT(*) AS cantidad_colegios_en_interseccion
FROM
  public."colegiosbboxbogota" AS c
WHERE
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Ecci'), 3116),
    800
  )
  AND
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Distrital-Francisco Jose De Caldas'), 3116),
    800
  );
  
  
SELECT
  COUNT(*) AS cantidad_bares
FROM
  public."bares" AS c
WHERE
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Ecci'), 3116),
    800
  )
  AND
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Distrital-Francisco Jose De Caldas'), 3116),
    800
  );


SELECT
  COUNT(*) AS cantidad_farmacias
FROM
  public."farmacias" AS c
WHERE
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Ecci'), 3116),
    800
  )
  AND
  ST_DWithin(
    ST_Transform(c.geom, 3116),
    ST_Transform((SELECT ST_Centroid(geom) FROM public."Universidades" WHERE nombre = 'Universidad Distrital-Francisco Jose De Caldas'), 3116),
    800
  );



--Barrios por los que pasa la ruta K309

SELECT
  b.scanombre,
  ST_AsText(r.geom) AS ruta_polilinea
FROM
  public."SectorCatastral" AS b,
  public."k309" AS r
WHERE
  ST_Intersects(b.geom, r.geom)
  AND r.id = '1';

--Densidad colegios ruta K309
SELECT
  b.scanombre,
  COUNT(c.*) AS cantidad_colegios,
  COUNT(c.*) / ST_Area(ST_Transform(b.geom, 3116)) AS densidad_colegios_por_m2,
  ST_AsText(r.geom) AS ruta_polilinea
FROM
  public."SectorCatastral" AS b
JOIN
  public."k309" AS r ON ST_Intersects(b.geom, r.geom)
LEFT JOIN
  public."colegiosbboxbogota" AS c ON ST_DWithin(ST_Transform(c.geom, 3116), ST_Transform(b.geom, 3116), 800)
WHERE
  r.id = '1'
GROUP BY
  b.scanombre, r.geom, b.geom
ORDER BY
  densidad_colegios_por_m2 DESC;














  
  



 
