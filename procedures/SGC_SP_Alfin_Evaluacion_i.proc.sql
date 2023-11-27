/*--------------------------------------------------------------------------------------                                                                                                     
' Nombre          : [dbo].[SGC_SP_EvaluacionDataAd_I]                                                                                                                 
' Objetivo        : ESTE PROCEDIMIENTO ACTUALIZA EL ESTADO DE LAS OPERACIONES EN ESTADO CONTACTO                                                                  
' Creado Por      : Francisco                                                                                 
' Día de Creación : 15-12-22                                                                                                              
' Requerimiento   : SGC                                                                                         
' Cambios :          
  - 15/12/2022 - REYNALDO CAUCHE  : Se quito la condición de @COUNTEVAL 
  - 16/06/2023 - FRANCISCO GABRIEL: Se modifico lógica de registro de evaluaciones 
'--------------------------------------------------------------------------------------*/        
CREATE PROCEDURE SGC_SP_Alfin_Evaluacion_i(
    @Ofertas text,
    @ExpedienteCreditoId int,
    @EstadoProcesoId int,
    @UserIdActua int,
    @PersonaId int ,
    @BancoId int,
    @Observacion text,
    @Success int OUTPUT
)
as
DECLARE @EvaluacionId int     
begin
    BEGIN TRY             
        BEGIN TRANSACTION            
            SET @Success = 0; 

            SET @EvaluacionId = (SELECT MAX(EvaluacionId) + 1 FROM SGF_Evaluaciones)   

                INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, BancoId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId, Ofertas)                                    
                                          VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @BancoId, 2, @Observacion, 1, @UserIdActua, dbo.GETDATE(), 1, @Ofertas)                                  

        COMMIT;            
    END TRY            
    BEGIN CATCH            
        SET @Success = 0;            

        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();        
        ROLLBACK;            
    END CATCH            
END