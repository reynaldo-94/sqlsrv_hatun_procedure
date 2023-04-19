/*--------------------------------------------------------------------------------------                                                                                                                                                                   
' Nombre          : [dbo].[SGC_SP_BancoInforme_L]                                                                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE DATOS DE INFORME SEGUN BANCO                                                                                              
' Creado Por      : FRANCISCO LAZARO                                                                                                                                             
' Día de Creación : 01-02-2023                                                                                                                                                                                
' Requerimiento   : SGC                                                                                                                                                                             
' Cambios  :     
  13/02/2023 - Reynaldo Cauche - Se cambiaron el formato de todas las fechas a 103 (dd/mm/YY) 
  17/02/2023 - Reynaldo Cauche - Se agrego el campo EstadoSolicitud  
  01/03/2023 - Reynaldo Cauche - Se quito el filtro estado = 16 (Sin atencion de IF)    
'--------------------------------------------------------------------------------------*/                      
           
ALTER PROCEDURE SGC_SP_BancoInforme_L       
(@BancoId int = 0,       
 @Success int output)       
AS       
BEGIN       
    SET @Success = (SELECT count(*)           
                    FROM SGF_ExpedienteCredito EXPC       
                    INNER JOIN SGF_Persona PERS on EXPC.TitularId = PERS.PersonaId  
                    INNER JOIN SGF_Parametro pr on pr.ParametroId = expc.BancoId and pr.DominioId = 38      
                    WHERE (@BancoId = 0 or EXPC.BancoId = @BancoId) AND       
                           ISNULL(fechaInforme, '') = '' AND       
                           EXPC.EstadoProcesoId in (9, 10))       
       
    SELECT EXPC.ExpedienteCreditoId [NOP],       
           PERS.DocumentoNum [DNI],     
     PERS.Nombre + ' ' + PERS.ApePaterno + ' ' + PERS.ApeMaterno [NombreCompleto],     
           CONVERT(varchar,EXPC.FechaEvaluacion,103) [FechaDeriv],       
           CONVERT(varchar,EXPC.FechaInforme,103) [FechaInforme],     
     ISNULL(  
       CONVERT(varchar,EXPC.FechaRechazado,103),   
       ISNULL(CONVERT(varchar,EXPC.FechaDesistio,103),   
       CONVERT(varchar,EXPC.FechaSinAtencionEEFF,103))  
     )[FechaBaja],     
     ISNULL(EXPC.Observacion, '') [Comentario],     
     EXPC.BancoId, 
     pr.NombreLargo [EstadoSolicitud] 
    FROM SGF_ExpedienteCredito EXPC       
    INNER JOIN SGF_Persona PERS on EXPC.TitularId = PERS.PersonaId 
    INNER JOIN SGF_Parametro pr on pr.ParametroId = expc.EstadoProcesoId and pr.DominioId = 38  
    WHERE (@BancoId = 0 or EXPC.BancoId = @BancoId) AND       
          ISNULL(fechaInforme, '') = '' AND       
          EXPC.EstadoProcesoId in (9, 10) 
    ORDER BY PERS.Nombre ASC 
END

-- exec SGC_SP_BancoInforme_L 3,0

select FechaInforme,FechaDescarga, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 1063841

update SGF_ExpedienteCredito
set FechaInforme = '2023-03-02 08:00:56.573'
where ExpedienteCreditoId = 1063841

