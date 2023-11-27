    
-- eNERO FEBRERO pasar de nuevo el 8
-- Marzo pasar con los cambios nuevo 

ALTER PROCEDURE SGC_SP_RechazadosFiltroAlFin_L_Paginado                    
(@Mes int = 0,    
 @Anio int = 0,    
 @Tamanio int = 0,    
 @Pagina int = 1,    
 @Success int OUTPUT)                                  
AS                                  
BEGIN                                 
    SELECT * FROM                                  
        (SELECT FechaActua,                                       
                EX.*,                                       
                EXPC.TitularId FROM                                        
        (SELECT A.DocumentoNum,                                              
                MAX(B.ExpedienteCreditoId)[ExpedienteCreditoId]                                     
        FROM SGF_Persona A                                         
        INNER JOIN SGF_ExpedienteCredito B ON A.PersonaId = B.TitularId                            
        INNER JOIN SGF_DatosDireccion C ON A.PersonaId = C.PersonaId                                 
        WHERE Len(A.DocumentoNum) = 8 
        -- and (C.Ubigeo like '1501%' or C.Ubigeo like '0701%')
        -- and C.Ubigeo NOT LIKE '1501%' AND C.Ubigeo NOT LIKE '0701%'
        and C.TipoDireccionId = 1                                      
        GROUP BY A.DocumentoNum) EX                                        
        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId                                  
        -- WHERE EstadoProcesoId in (9, 10, 11, 12, 16) 
        -- WHERE EstadoProcesoId in (9,10,16)
        WHERE EstadoProcesoId in (8,9,10,16)
        and Month(EXPC.FechaActua) = @Mes and Year(EXPC.FechaActua) = @Anio                            
        and (EXPC.CreadoAlfinLa != 1 or EXPC.CreadoAlfinLa is null)                            
        ) EXCER                    
  ORDER BY FechaActua desc                    
  OFFSET (@Pagina-1) * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                    
END 