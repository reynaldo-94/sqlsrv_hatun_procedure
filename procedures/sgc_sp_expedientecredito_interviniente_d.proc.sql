/*--------------------------------------------------------------------------------------                                                                                                                                     
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Interviniente_D]                                                                                                                                                      
' Objetivo        : ESTE PROCEDIMIENTO ELIMINA UN INTERVINIENTE                                                                       
' Creado Por      : REYNALDO CAUCHE                                                                                                                 
' Día de Creación : 20-12-2022                                                                                                                                                  
' Requerimiento   : SGC                                                                                                                                               
' cambios  :                        
 - 01-03-2022  REYNALDO CAUCHE - Se creo el procedimiento 
'                                                                                                                                         
'--------------------------------------------------------------------------------------*/  
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Interviniente_D(  
	@ExpedienteCreditoId int,--  
    @PersonaId int, 
	@Success INT OUTPUT ,  
	@Message varchar(8000) OUTPUT  
)  
as 
BEGIN
	declare @EstadoProcesoId int
	begin TRY  
		BEGIN TRANSACTION 
			SET @EstadoProcesoId = (SELECT EstadoProcesoId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId)
			SET @Success = 0;
			IF (@EstadoProcesoId = 1 OR @EstadoProcesoId = 2)
				BEGIN
					DELETE SGF_Evaluaciones where ExpedienteCreditoId = @ExpedienteCreditoId and PersonaId = @PersonaId; 
					SET @Success = 1;
				END
			ELSE
				SET @Success = 2;
		COMMIT;    
	END TRY    
	BEGIN CATCH  
		SET @Success = 0;  
		SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()  
		ROLLBACK;  
	END CATCH;
END