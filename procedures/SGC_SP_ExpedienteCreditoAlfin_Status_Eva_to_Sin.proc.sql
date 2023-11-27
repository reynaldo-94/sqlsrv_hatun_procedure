/*--------------------------------------------------------------------------------------                                     
' Nombre          : [dbo].[SGC_SP_ExpedienteCreditoAlfin_Status_Eva_to_Sin]                                     
' Objetivo        : Este procedimiento modifica el estadoProceso de Expediente de evaluacion a sin atencionIf de Alfin                                    
' Creado Por      : cristian silva                                    
' Día de Creación : 11-10-2023                                                               
' Requerimiento   : SGC                     
' Cambios                         
          
'--------------------------------------------------------------------------------------*/                                     
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCreditoAlfin_Status_Eva_to_Sin]                                
(    
@ExpedienteCreditoId int,     
@EstadoProcesoId INT,    
@Success int OUTPUT,        
@Message varchar(8000) OUTPUT    
 )                                     
AS                                     
    DECLARE @ItemIdDet int, @PersonaTitularId int                      
BEGIN                                     
    BEGIN TRY                                         
        BEGIN TRANSACTION                                     
        SET @Success = 0;                                     
                                             
        SET @PersonaTitularId = ISNULL((SELECT top 1 TitularId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId), 0)                                       
               
            if(@PersonaTitularId > 0)    
            begin    
                
              UPDATE SGF_ExpedienteCredito                                               
              SET        
                 EstadoProcesoId = @EstadoProcesoId,       
                 Observacion = 'BAJA AUTOMATICA - OPERACION NO ATENDIDA POR ALFIN BANCO',        
                 FechaActua = dbo.getdate(),        
                 FechaSinAtencionEEFF = dbo.getdate(),    
                 UserIdActua = 1    
              WHERE ExpedienteCreditoId = @ExpedienteCreditoId            
                                                                                                                                                
            SET @ItemIdDet = (SELECT ISNULL(MAX(Itemid), 0) + 1 FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                                     
            INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, Observacion,UsuarioId)                                                                             
            VALUES (@ExpedienteCreditoId, @ItemIdDet, @EstadoProcesoId, dbo.getdate(), 'BAJA AUTOMATICA - OPERACION NO ATENDIDA POR ALFIN BANCO',1)                                     
                                                             
                UPDATE SGF_Persona                                      
                SET EstadoPersonaId = @EstadoProcesoId,           
                 FechaActua = dbo.getdate() ,    
                 UserIdActua = 1    
                WHERE PersonaId = @PersonaTitularId                                                                              
                                         
            SET @Success = 1;                                       
            SET @Message = 'OK';          
            end     
                
            if(@PersonaTitularId= 0)    
            begin    
            SET @Success = 2;                                       
            SET @Message =  'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()             
            end    
    
        COMMIT;                                       
    END TRY                                         
    BEGIN CATCH                                   
        SET @Success = 0;                                         
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()                     
                     
        ROLLBACK;                                         
    END CATCH                                      
END   