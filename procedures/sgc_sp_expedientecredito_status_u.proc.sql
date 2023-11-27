/*--------------------------------------------------------------------------------------                                
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Status_U]                                
' Objetivo        : Este procedimiento modifica el estadoProceso de Expediente                                
' Creado Por      : SAMUEL FLORES                                
' Día de Creación : 21-04-2021                                                          
' Requerimiento   : SGC                
' Cambios                    
  - 06/12/2022 - Reynaldo Cauche: Se agrego el parametro @MessageObservacion           
  - 14/12/2022 - cristian silva : Se agrego FechaSinAtencionEEFF y se valido @EstadoProcesoId en @MessageObservacion          
'--------------------------------------------------------------------------------------*/                                
CREATE PROCEDURE SGC_SP_ExpedienteCredito_Status_U                            
(@ExpedienteCreditoId int,   
 @Observacion varchar(500),   
 @EstadoProcesoId int,   
 @TipoCambioId int,   
 @MotivoCambioId int,   
 @UsuarioCodigo int,   
 @Success int OUTPUT,   
 @Message varchar(8000) OUTPUT,   
 @PersonaIdOutput int OUTPUT,   
 @MessageObservacion varchar(8000) OUTPUT)                                
AS                                
    DECLARE @ItemIdDet int, @ItemIdObs int, @PersonaTitularId int, @EstadoProcesoFinalId int, @CategoriaMotivo varchar(200)                    
BEGIN                                
    BEGIN TRY                                    
        BEGIN TRANSACTION                                
        SET @Success = 0;                                
                                        
        SET @PersonaTitularId = ISNULL((SELECT top 1 TitularId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId), 0)                    
     -- SET @EvaluacionId = ISNULL((SELECT top 1 EvaluacionId FROM SGF_Evaluaciones WHERE ExpedienteCreditoId = @ExpedienteCreditoId AND PersonaId = @PersonaTitularId), 0)                    
        SET @EstadoProcesoFinalId = ISNULL((SELECT top 1 EstadoProcesoId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId), 0)                    
        SET @CategoriaMotivo = (SELECT Descripcion FROM SGF_Rechazo r WHERE IdRechazo = @TipoCambioId)                
                            
        UPDATE [dbo].[SGF_ExpedienteCredito]                                          
        SET UserIdActua = @UsuarioCodigo,   
            EstadoProcesoId = IIF(@EstadoProcesoId <> 15, @EstadoProcesoId, EstadoProcesoId),   
            EstadoProcesoFinalId = IIF(@EstadoProcesoId <> 15, @EstadoProcesoFinalId, EstadoProcesoFinalId),   
            EnObservacion = IIF(@EstadoProcesoId = 15, 1, EnObservacion),   
            Observacion = UPPER(@observacion),   
            FechaActua = dbo.getdate(),   
            FechaRechazado = IIF(@EstadoProcesoId = 9, dbo.getdate(), FechaRechazado),   
            FechaDesistio = IIF(@EstadoProcesoId = 10, dbo.getdate(), FechaDesistio),   
            FechaNoCalifica = IIF(@EstadoProcesoId = 11, dbo.getdate(), FechaNoCalifica),   
            FechaNoQuiere = IIF(@EstadoProcesoId = 12, dbo.getdate(), FechaNoQuiere),   
            FechaObservacion = IIF(@EstadoProcesoId = 15, dbo.getdate(), FechaObservacion),   
            FechaSinAtencionEEFF = IIF(@EstadoProcesoId = 16, dbo.getdate(), FechaSinAtencionEEFF),   
            EstadoExpedienteId = IIF(@EstadoProcesoId <> 15, 2, EstadoExpedienteId)                            
        WHERE (ExpedienteCreditoId = @ExpedienteCreditoId)       
                                  
        IF @EstadoProcesoId = 15                            
        BEGIN                            
            SET @ItemIdObs = (SELECT ISNULL(MAX(Itemid), 0) + 1 FROM SGF_ExpedienteCreditoObservaciones WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                              
            INSERT INTO [dbo].[SGF_ExpedienteCreditoObservaciones] ([ExpedienteCreditoId], ItemId, ProcesoId, EstadoObservacionId, Observacion, UserIdCrea, FechaCrea)                            
                                                            VALUES (@ExpedienteCreditoId, @ItemIdObs, @EstadoProcesoFinalId, 1, UPPER(@observacion), @UsuarioCodigo, dbo.getdate())                            
        END                            
                                                                  
        SET @ItemIdDet = (SELECT ISNULL(MAX(Itemid), 0) + 1 FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                                
        INSERT INTO [dbo].[SGF_ExpedienteCreditoDetalle] (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, TipoRechazoId, MotivoRechazoId, Observacion)                                                                        
                                                  VALUES (@ExpedienteCreditoId, @ItemIdDet, @EstadoProcesoId, dbo.getdate(), @UsuarioCodigo, @TipoCambioId, @MotivoCambioId, UPPER(@observacion))                                
                                            
        IF @EstadoProcesoId <> 15                            
        BEGIN                            
            UPDATE [dbo].[SGF_Persona]                                  
            SET EstadoPersonaId = @EstadoProcesoId,   
            UserIdActua = @UsuarioCodigo,   
            FechaActua = dbo.getdate()                                
            WHERE PersonaId = @PersonaTitularId                            
        END                            
                                      
        --UPDATE [dbo].[SGF_Evaluaciones]                                      
        --  SET ResultadoId = 3,   
        --  Observacion = UPPER(@observacion),   
        --  UserIdActua = @UsuarioCodigo,   
        --  FechaActua = dbo.getdate()                                    
        --WHERE EvaluacionId = ISNULL((SELECT top 1 EvaluacionId FROM SGF_Evaluaciones WHERE ExpedienteCreditoId = @ExpedienteCreditoId AND PersonaId = @PersonaTitularId), 0)        
                                
        SET @MessageObservacion = IIF(@EstadoProcesoId = 16, @Observacion    , '<b>CAMBIO DE ENTIDAD: ' + @CategoriaMotivo + '</b><br />' + @Observacion);                
                        
        SET @Success = 1;                                  
        SET @Message = 'OK';                  
        SET @PersonaIdOutput = @PersonaTitularId                
                        
        COMMIT;                                  
    END TRY                                    
    BEGIN CATCH                              
        SET @Success = 0;                                    
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()                
        SET @MessageObservacion = '';                 
        ROLLBACK;                                    
    END CATCH                                 
END  