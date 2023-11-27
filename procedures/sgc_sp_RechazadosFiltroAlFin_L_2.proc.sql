exec  SGC_SP_RechazadosFiltroAlFin_L_Paginado 8,2023,30,1,0   

67
709780
43

709811, 709788
SELECT * FROM                              
        (SELECT FechaActua,                                   
                EX.*,                                   
                EXPC.TitularId FROM                                    
        (SELECT A.DocumentoNum,                                          
                MAX(B.ExpedienteCreditoId)[ExpedienteCreditoId]                                 
        FROM SGF_Persona A                                     
        INNER JOIN SGF_ExpedienteCredito B ON A.PersonaId = B.TitularId                        
        INNER JOIN SGF_DatosDireccion C ON A.PersonaId = C.PersonaId                             
        WHERE Len(A.DocumentoNum) = 8 and (C.Ubigeo like '1501%' or C.Ubigeo like '0701%') and C.TipoDireccionId = 1                                  
        GROUP BY A.DocumentoNum) EX                                    
        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId                              
        WHERE EstadoProcesoId in (9, 10, 11, 12, 16) and Month(EXPC.FechaActua) = 8 and Year(EXPC.FechaActua) = 2023                        
        and (EXPC.CreadoAlfinLa != 1 or EXPC.CreadoAlfinLa is null)                        
        ) EXCER                
  ORDER BY FechaActua desc 

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
        WHERE Len(A.DocumentoNum) = 8 and (C.Ubigeo like '1501%' or C.Ubigeo like '0701%') and C.TipoDireccionId = 1                                  
        GROUP BY A.DocumentoNum) EX                                    
        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId                              
        WHERE EstadoProcesoId in (9, 10, 11, 12, 16) and Month(EXPC.FechaActua) = @Mes and Year(EXPC.FechaActua) = @Anio                        
        and (EXPC.CreadoAlfinLa != 1 or EXPC.CreadoAlfinLa is null)                        
        ) EXCER                
  ORDER BY FechaActua desc                
  OFFSET (@Pagina-1) * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                
END 