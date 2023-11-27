/*--------------------------------------------------------------------------------------                                                                                                                                  
' Nombre          : [dbo].[SGC_SP_Client_Operacion]                                                                                                                                                  
' Objetivo        : Este procedimiento sirve para la otra web, me trae los datos del ultimo credito de la persona                                                                                            
' Creado Por      : Reynaldo Cauche                                                                                                                                 
' Requerimiento   : SGC                                                                                                             
' Cambios  :                                   
  - 25-04-2023 - Reynaldo Cauche - Se creo el procedimiento
'--------------------------------------------------------------------------------------*/                 
         
ALTER PROC [dbo].[SGC_SP_Client_Operacion]                                      
(@DocumentoNum varchar(20))                                                                            
AS
    DECLARE @PersonaId int                                                                       
BEGIN    
    SET @PersonaId = (SELECT TOP(1) PersonaId FROM SGF_Persona WHERE DocumentoNum = @DocumentoNum)

    SELECT TOP(1) EXPE.ExpedienteCreditoId,     
        IIF( isnull(SOL.MontoAprobado,0)=0,isnull(SOL.MontoPropuesto,0),MontoAprobado) [Monto],    
        EXPE.EstadoProcesoId [EstadoId],     
        PAR.NombreLargo [NombreEstado],  
        convert(VARCHAR,EXPE.FechaActua,3) [FechaActua],         
        convert(VARCHAR,EXPE.FechaCrea,3) [FechaCrea],        
        EXPE.BancoId,     
        BA.Nombre [NombreBanco],        
        PER.Nombre +' '+ PER.ApePaterno+' '+PER.ApeMaterno [Nombres],
        ISNULL(SP.Nombre +' '+ SP.ApePaterno+' '+SP.ApeMaterno, 'CONTACT CENTER') [NombreSupervisor],        
        ISNULL(USR.Celular,'966575476') [CelularSupervisor],
        PER.DocumentoNum [DocumentoNum],
        PER.PersonaId,
        CASE 
            WHEN EXPE.EstadoProcesoId = 2 
                OR EXPE.EstadoProcesoId = 3
                OR EXPE.EstadoProcesoId = 5
                OR EXPE.EstadoProcesoId = 6
                OR EXPE.EstadoProcesoId = 8 
                    THEN '#77D132'
            WHEN EXPE.EstadoProcesoId = 9
                OR EXPE.EstadoProcesoId = 10
                OR EXPE.EstadoProcesoId = 11
                OR EXPE.EstadoProcesoId = 12
                OR EXPE.EstadoProcesoId = 16 
                    THEN '#77D132'
            ELSE '#77D132'
        END AS [ColorHex],
        CASE 
            WHEN EXPE.EstadoProcesoId = 2 THEN 25
            WHEN EXPE.EstadoProcesoId = 3 THEN 50
            WHEN EXPE.EstadoProcesoId = 5 THEN 75
            WHEN EXPE.EstadoProcesoId = 6
                OR EXPE.EstadoProcesoId = 8 
                OR EXPE.EstadoProcesoId = 9
                OR EXPE.EstadoProcesoId = 10
                OR EXPE.EstadoProcesoId = 11
                OR EXPE.EstadoProcesoId = 12
                OR EXPE.EstadoProcesoId = 16 
                    THEN 100
            ELSE '#77D132'
        END AS [Porcentaje]
    FROM SGF_ExpedienteCredito EXPE     
    LEFT JOIN SGF_Solicitud SOL ON SOL.SolicitudId = EXPE.SolicitudId     
    INNER JOIN SGF_Persona PER ON PER.PersonaId = EXPE.TitularId     
    LEFT JOIN SGF_Parametro PAR ON PAR.ParametroId = EXPE.EstadoProcesoId AND PAR.DominioId = 38     
    LEFT JOIN SGB_Banco BA ON BA.BancoId = EXPE.BancoId
    LEFT JOIN SGF_Supervisor SP ON SP.IdSupervisor = EXPE.IdSupervisor
    LEFT JOIN SGF_User USR ON USR.EmpleadoId = SP.IdSupervisor and USR.CargoId = 29
    WHERE EXPE.TitularId = @PersonaId     
    ORDER BY EXPE.ExpedienteCreditoId DESC   
 
END 