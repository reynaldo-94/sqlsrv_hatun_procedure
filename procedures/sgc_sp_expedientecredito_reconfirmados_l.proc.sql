/*------------------------------------------------------------------------------------                                 
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Reconfirmados_L]                         
' Objetivo        : Este procedure nos permite listar creditos reconfirmados                        
' Creado Por      : REYNALDO CAUCHE                   
' Día de Creación : 06-10-2022           
' Requerimiento   : SGC
' Cambios:                    
'-------------------------------------------------------------------------------------*/                         
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Reconfirmados_L                       
(                          
@SupervisorId INT
,@EstadoId INT
,@Pagina INT                                                                          
,@Tamanio INT
,@Success INT OUTPUT
)                        
AS
BEGIN
    SET @Success = (
       SELECT COUNT(EXPER.ExpedienteCreditoId)
        FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                     
        INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId           
        INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId                       
        WHERE (EXPCRED.IdSupervisor = @SupervisorId and EXPER.Estado = @EstadoId)
    );          
    SELECT
        EXPER.IdReconfirmacion as ReconfirmacionId,               
        EXPER.ExpedienteCreditoId,           
        EXPCRED.IdSupervisor,            
        PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno [NombreCompleto],                      
        PER.DocumentoNum,                  
        ISNULL(EXPER.ResultadoGestion,'') ResultadoGestion,           
        ISNULL(EXPER.MarcaContactabilidad,'') MarcaContactabilidad,           
        ISNULL(PER.Horario,'') Horario,           
        ISNULL(PER.Celular,'') Celular,      
        ISNULL(PER.Celular2,'') Celular2,      
        ISNULL(PER.Telefonos,'') Telefono,      
        ISNULL((DATEDIFF(DAY,EXPCRED.FechaEvaluacion,dbo.getdate())),'') [Dias],         
        ISNULL(PER.DiaLlamada,'') [DiaLlamada]     
    FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                     
    INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId           
    INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId                       
    WHERE (EXPCRED.IdSupervisor = @SupervisorId and EXPER.Estado = @EstadoId)              
    ORDER BY Dias DESC   
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY
END