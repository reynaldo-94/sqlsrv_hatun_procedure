/*--------------------------------------------------------------------------------------                                                                                                                   
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Reconfirmacion_U]                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO SE ENCARGA DE RECONFIRMAR UNA OPERACION                                                   
' Creado Por      : REYNALDO CAUCHE                                                                                               
' Día de Creación : 06-10-2022                                                                                                                                
' Requerimiento   : SGC                                                                                                                             
' Cambios  :
'                                                                                                                        
'--------------------------------------------------------------------------------------*/ 
CREATE PROCEDURE SGC_SP_ExpedienteCredito_Reconfirmacion_U                                                       
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