/*--------------------------------------------------------------------------------------                                                                                                                    
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Reconfirmacion_U]                                                                                                                                     
' Objetivo        : ESTE PROCEDIMIENTO SE ENCARGA DE RECONFIRMAR UNA OPERACION                                                    
' Creado Por      : REYNALDO CAUCHE                                                                                                
' Día de Creación : 06-10-2022                                                                                                                                 
' Requerimiento   : SGC                                                                                                                              
' Cambios  : 
' 21/11/2022 - REYNALDO CAUCHE - Se agrego el insert a la tabla ExpedienteCreditoDetalle                                                                                                                          
'--------------------------------------------------------------------------------------*/  
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Reconfirmacion_U                                                 
( 
@ReconfirmacionId int      
,@ExpedienteCreditoId int 
,@ContactadoId int                                                    
,@InteresadoId int                
,@ResultadoId int      
,@MotivoId int      
,@SubMotivoId int      
,@Comentario varchar(500)           
,@EstadoId int
,@UserIdCrea int
,@Success int OUTPUT         
,@Message varchar(8000) OUTPUT) 
AS  
BEGIN 
    BEGIN TRY         
      BEGIN TRANSACTION 
        SET @Success=0;                                                       
         
        UPDATE SGF_ExpedienteCredito_Reconfirmacion                                                        
        SET        
        ExpedienteCreditoId = @ExpedienteCreditoId,        
        Contactado = @ContactadoId,        
        Interesado = @InteresadoId,        
        Resultado = @ResultadoId,      
        Motivo = @MotivoId,      
        SubMotivo = @SubMotivoId,      
        Comentario = @Comentario,        
        FechaReconfirmacion = dbo.getdate(),      
        Estado = @EstadoId                         
        WHERE IdReconfirmacion = @ReconfirmacionId  

        IF (@ExpedienteCreditoId != 0)
          BEGIN
            DECLARE @ItemId int, @ProcesoId int
            SET @ItemId = (SELECT TOP(1) ISNULL(ItemId + 1,1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId order by ItemId DESC);
            SET @ProcesoId = (SELECT ISNULL(EstadoProcesoId,0) FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId);
            INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                                   
            values(@ExpedienteCreditoId,@ItemId,@ProcesoId,dbo.getdate(),@UserIdCrea,@Comentario)    
          END
 
        SET @Success = 1;         
        SET @Message = 'OK';         
      COMMIT;         
  END TRY         
  BEGIN CATCH         
    SET @Success = 0;         
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();         
    ROLLBACK;         
  END CATCH 
END