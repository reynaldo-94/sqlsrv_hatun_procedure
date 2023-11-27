/*------------------------------------------------------------------------------------                                          
' Nombre              : SGC_SP_RechazadosFiltroAlFin_L                                          
' Objetivo            :                                       
' Creado Por          : 02/09/2023                        
' Día de Creación     :                          
' Modificado por      :                                                        
' Dia de Modificacion :                
' Cambios             :     
  - 02/09/2023 - cristian silva - nuevo fue alcansado por Francisco  
'-------------------------------------------------------------------------------------*/       
     
ALTER PROCEDURE SGC_SP_RechazadosFiltroAlFin_L      
(@topRange int = 1000,      
 @limitFiltro int = 7,      
 @Success int OUTPUT)      
AS      
BEGIN      
    DECLARE @currentDate datetime = dbo.GETDATE()      
      
 SET @Success = (SELECT COUNT(*) FROM      
                (SELECT TOP (@topRange) * FROM      
                        (SELECT FechaActua,      
                                -- DATEDIFF(DAY, FechaActua, dbo.GETDATE())[Dias],           
                                EX.*,           
                                EXPC.TitularId FROM            
                        (SELECT A.DocumentoNum,                  
                                MAX(B.ExpedienteCreditoId)[ExpedienteCreditoId]             
                        FROM SGF_Persona A             
                        INNER JOIN SGF_ExpedienteCredito B ON A.PersonaId = B.TitularId     
                        WHERE Len(A.DocumentoNum) = 8         
                        GROUP BY A.DocumentoNum) EX            
                        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId      
                        WHERE EstadoProcesoId in (9, 10, 11, 12, 16) and DATEDIFF(DAY, EXPC.FechaActua, @currentDate) <= @limitFiltro  
                        and (EXPC.CreadoAlfinLa != 1 or EXPC.CreadoAlfinLa is null)) EXCER) Query)      
          
 SELECT TOP (@topRange) * FROM      
        (SELECT FechaActua,      
                -- DATEDIFF(DAY, FechaActua, dbo.GETDATE())[Dias],           
                EX.*,           
                EXPC.TitularId FROM            
        (SELECT A.DocumentoNum,                  
                MAX(B.ExpedienteCreditoId)[ExpedienteCreditoId]             
        FROM SGF_Persona A             
        INNER JOIN SGF_ExpedienteCredito B ON A.PersonaId = B.TitularId     
        WHERE Len(A.DocumentoNum) = 8           
        GROUP BY A.DocumentoNum) EX            
        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId      
        WHERE EstadoProcesoId in (9, 10, 11, 12, 16) and DATEDIFF(DAY, EXPC.FechaActua, @currentDate) <= @limitFiltro  
        and (EXPC.CreadoAlfinLa != 1 or EXPC.CreadoAlfinLa is null)) EXCER      
        ORDER BY FechaActua DESC  
END  