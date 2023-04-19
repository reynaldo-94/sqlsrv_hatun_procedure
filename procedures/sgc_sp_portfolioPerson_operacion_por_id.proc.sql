/*--------------------------------------------------------------------------------------                                                                                                                                  
' Nombre          : [dbo].[SGC_SP_PortfolioPerson_Por_Id]                                                                                                                                                  
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA OPERACION POR PERSONA                                                                                                     
' Creado Por      : CRISTIAN SILVA                                                                                                                
' Día de Creación : 09/02/2023                                                                                                                                           
' Requerimiento   : SGC                                                                                                                                            
' Modificado por  :                                                                                                                         
' Cambios  :                                   
  - 18-04-2023 - Reynaldo Cauche - Se agrego los campos NombreSupervisor, CelularSupervisor y DocumentoNum
'--------------------------------------------------------------------------------------*/                 
         
ALTER PROC [dbo].[SGC_SP_PortfolioPerson_Operacion_Por_Id]                                      
(@Id int)                                                                            
AS                                                                            
BEGIN    
 
    SELECT EXPE.ExpedienteCreditoId,     
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
        PER.DocumentoNum [DocumentoNum]
    FROM SGF_ExpedienteCredito EXPE     
    LEFT JOIN SGF_Solicitud SOL ON SOL.SolicitudId = EXPE.SolicitudId     
    INNER JOIN SGF_Persona PER ON PER.PersonaId = EXPE.TitularId     
    LEFT JOIN SGF_Parametro PAR ON PAR.ParametroId = EXPE.EstadoProcesoId AND PAR.DominioId = 38     
    LEFT JOIN SGB_Banco BA ON BA.BancoId = EXPE.BancoId
    LEFT JOIN SGF_Supervisor SP ON SP.IdSupervisor = EXPE.IdSupervisor
    LEFT JOIN SGF_User USR ON USR.EmpleadoId = SP.IdSupervisor and USR.CargoId = 29
    WHERE EXPE.TitularId = @Id     
    ORDER BY EXPE.ExpedienteCreditoId DESC   
 
END 