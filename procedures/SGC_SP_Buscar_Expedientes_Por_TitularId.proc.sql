/*--------------------------------------------------------------------------------------                                                                                                                          
' Nombre          : [dbo].[SGC_SP_Buscar_Expedientes_Por_TitularId]                                                                                                                                    
' Objetivo        : Busca Expedientes filtrado por el titularId a traves del expediente Id                                                                                   
' Creado Por      : Reynaldo Cauche                                                                                                       
' Día de Creación : 03/11/2023                                                                                                                                     
' Requerimiento   : SGC                        
' Cambios:                                  
  - develop-refilter 03/11/2023 - Reynaldo Cauche - Se creo el procedimiento  
'--------------------------------------------------------------------------------------*/    
ALTER PROCEDURE SGC_SP_Buscar_Expedientes_Por_TitularId(  
    @ExpedienteCreditoId int = 0  
)  
AS  
DECLARE @TitularId int;  
BEGIN  
  
    SET @TitularId = (SELECT TitularId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId);  
  
    SELECT ex.ExpedienteCreditoId,pr.DocumentoNum, ex.EstadoProcesoId,pr.ApePaterno,dd.Ubigeo,ex.BancoId,ex.CanalVentaId,   
    (SELECT TOP(1) TipoPersonaId FROM SGF_Evaluaciones WHERE ExpedienteCreditoId = ex.ExpedienteCreditoId) as TipoPersonaId,
    (SELECT ISNULL(Observacion,'') FROM SGF_Evaluaciones WHERE ExpedienteCreditoId = ex.ExpedienteCreditoId AND BancoId = 13) as ObservacionOfertasAnterior  
    FROM SGF_ExpedienteCredito as ex  
    INNER JOIN SGF_Persona as pr on ex.TitularId = pr.PersonaId  
    LEFT JOIN SGF_DatosDireccion as dd on pr.PersonaId=dd.PersonaId AND dd.EsFijo = 1  
    WHERE ex.TitularId = @TitularId  
  
END 