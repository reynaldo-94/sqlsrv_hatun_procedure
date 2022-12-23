/*--------------------------------------------------------------------------------------                                                      
' Nombre          : [dbo].[SGC_SP_Reconfirmaciones_I]                                                                       
' Objetivo        : Este procedimiento inserta el lote de reconfirmaciones                                               
' Creado Por      : Reynaldo Cauche                                        
' Día de Creación : 21-07-2022                                                                   
' Requerimiento   : SGC                                                                
' Modificado por  :                                         
' Día de Modificación :                                                  
'--------------------------------------------------------------------------------------*/   
ALTER PROCEDURE [dbo].[SGC_SP_Reconfirmaciones_I]   
    @ExpedienteCreditoId int   
    ,@EstadoCliente varchar(50)   
    ,@ResultadoGestion varchar(50)   
    ,@MarcaContabilidad varchar(50)   
    ,@Estado int   
    ,@Contador int
    ,@Success int OUTPUT           
    ,@Message varchar(8000) OUTPUT   
AS   
BEGIN   
    DECLARE @IdReconfirmacion int;   
    DECLARE @Lote int;   
    BEGIN TRY           
        BEGIN TRANSACTION             
            SET @Success=0;   
            SET @IdReconfirmacion = (select ISNULL(MAX(IdReconfirmacion),0)+1 FROM dbo.SGF_ExpedienteCredito_Reconfirmacion);   
            SET @Lote = (select ISNULL(MAX(Lote),0) FROM dbo.SGF_ExpedienteCredito_Reconfirmacion)   
   
               
            IF (@Contador = 1)    
                SET @Lote = (select ISNULL(MAX(Lote),0) + 1 FROM dbo.SGF_ExpedienteCredito_Reconfirmacion);   
            ELSE    
                SET @Lote = (select MAX(Lote) FROM dbo.SGF_ExpedienteCredito_Reconfirmacion);   
               
            INSERT INTO SGF_ExpedienteCredito_Reconfirmacion(IdReconfirmacion,Lote,ExpedienteCreditoId,EstadoCliente,ResultadoGestion,MarcaContactabilidad,FechaCrea,Estado)   
            VALUES (@IdReconfirmacion,@Lote,@ExpedienteCreditoId,@EstadoCliente,@ResultadoGestion,@MarcaContabilidad,dbo.getdate(),@Estado)   
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