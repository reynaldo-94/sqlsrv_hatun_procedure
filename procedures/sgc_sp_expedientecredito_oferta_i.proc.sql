/*--------------------------------------------------------------------------------------                                                                                                                                     
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Oferta_I]                                                                                                                                                      
' Objetivo        : ESTE PROCEDIMIENTO INSERTA LAS OFERTAS DE ALFIN                                                             
' Creado Por      : REYNALDO CAUCHE                                                                                                                 
' Día de Creación : 14-07-2023                                                                                                                                                  
' Requerimiento   : SGC                                                                                                                                               
' cambios  :
'                                                                                                                                         
'--------------------------------------------------------------------------------------*/  

DROP PROCEDURE SGC_SP_ExpedienteCredito_Oferta_I(  
	@ExpedienteCreditoId int,
    @BancoId int,
    @Oferta text,
    @PersonaId int,
    @UserIdCrea int,
    @Success INT OUTPUT,                                                                          
    @Message varchar(8000) OUTPUT
)  
as 
BEGIN
	declare @EvaluacionId int
	begin TRY  
		BEGIN TRANSACTION 
			SET @Success = 0

            SET @EvaluacionId = (Select MAX(EvaluacionId) + 1 from SGF_Evaluaciones)    

            INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, BancoId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId, Ofertas)                              
            VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @BancoId, 2, 'Califica para una oferta', 1, @UserIdCrea, dbo.GETDATE(), 1,
            '[{"monto": 5000, "cuota": "500.34", "plazo": 12, "tasa": "50.23"},{"monto": 6000, "cuota": "1000.34", "plazo": 6, "tasa": "75.67"}]')                            
            SET @Success = 1
		COMMIT;    
	END TRY    
	BEGIN CATCH  
		SET @Success = 0;  
		SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()  
		ROLLBACK;  
	END CATCH;
END