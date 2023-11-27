 /*--------------------------------------------------------------------------------------                                                                                                                              
' Nombre          :[dbo].[SGC_SP_PlanTrabajo_Aprobar_U]                                                                                                                                            
' Objetivo        : ESTE PROCEDIMIENTA Aprueba el plan de trabajo                                       
' Creado Por      : REYNALDO CAUCHE                                                                                                   
' Día de Creación : 06-09-2022                                                                                                                                           
' Requerimiento   : SGC                                                                                                                                        
' Modificado por  :                                                                                                                    
' Día de Modificación :      
'--------------------------------------------------------------------------------------*/       
                                                                      
ALTER PROCEDURE [dbo].[SGC_SP_PlanTrabajo_Aprobar_U]            
@Anio int,    
@Mes int, 
@IdSupervisor int,
@UserIdActua int,
@Success int output,
@Message varchar(8000) output

AS    
BEGIN                                      
    BEGIN TRY                    
    BEGIN TRANSACTION             
        SET @Success=0;

        UPDATE SGF_PlanTrabajo
        SET EstadoPlanTrabajo = 2, UserIdActua = @UserIdActua, FechaActua = dbo.getDate()
        WHERE YEAR(FechaVisita) = @Anio AND MONTH(FechaVisita) = @Mes AND IdSupervisor = @IdSupervisor
                 
        SET @Success = 1;                                                 
        SET @Message = 'OK';
                
    COMMIT;                    
    END TRY                    
    BEGIN CATCH                    
        SET  @Success = 0;                 
        SET @Message = 'LINEA:' + CAST(ERROR_LINE() AS VARCHAR(1000)) + 'ERROR' + ERROR_MESSAGE()                    
        ROLLBACK                    
    END CATCH      
END