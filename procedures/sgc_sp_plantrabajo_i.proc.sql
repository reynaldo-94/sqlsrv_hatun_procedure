/*--------------------------------------------------------------------------------------                                                                                                                                     
' Nombre          :[dbo].[SGC_SP_PlanTrabajo_I]                                                                                                                                                   
' Objetivo        : ESTE PROCEDIMIENTO CREA PLAN DE TRABAJO                                                              
' Creado Por      : REYNALDO CAUCHE                                                                                                          
' Día de Creación : 05-09-2022                                                                                                                                                  
' Requerimiento   : SGC                                                                                                                                               
' Modificado por  :                                                                                                                           
' Día de Modificación :             
'--------------------------------------------------------------------------------------*/              
                                                                             
CREATE PROCEDURE [dbo].[SGC_SP_PlanTrabajo_I]                   
(@IdPlanTrabajo int,           
 @Fecha varchar(15),        
 @UserId int,       
 @UserIdCrea int,       
 @Success int output,       
 @Message varchar(8000) output,       
 @IdPlanTrabajoOutput varchar(8000) output)  
AS       
    DECLARE @MaxIdPlanTrabajo int       
    DECLARE @IdSupervisor int            
BEGIN                                             
    BEGIN TRY                           
    BEGIN TRANSACTION                    
    SET @Success=0;       
    SET @IdPlanTrabajoOutput = 0;               
           
    DECLARE @validIdPlanTrabajo int = ISNULL((select top 1 isnull(idPlan, 0) from SGF_PlanTrabajo  
                                              where convert(varchar(10), FechaVisita, 23) = @Fecha and UserId = @UserId), 0)  
        
    IF (@IdPlanTrabajo = 0)       
    BEGIN             
        IF (@validIdPlanTrabajo = 0)  
        begin    
            SET @MaxIdPlanTrabajo = (SELECT MAX(IdPlan) + 1 FROM SGF_PlanTrabajo)  
            SET @IdSupervisor = (SELECT ISNULL(EmpleadoId,0) FROM SGF_USER where UserId = @UserId);      
     
            INSERT INTO SGF_PlanTrabajo (IdPlan,UserId,FechaVisita,FechaCrea,UserIdCrea,IdSupervisor, EstadoPlanTrabajo)       
                                 VALUES (@MaxIdPlanTrabajo,@UserId,@Fecha,dbo.getdate(),@UserIdCrea,@IdSupervisor, 1)       
                   
            SET @IdPlanTrabajoOutput = @MaxIdPlanTrabajo;    
            SET @Success = 1;                                                        
            SET @Message = 'OK';      
        end    
            
        if(@validIdPlanTrabajo != 0)    
        begin    
            SET @IdPlanTrabajoOutput = @validIdPlanTrabajo;    
            SET @Success = 1;                                                        
            SET @Message = 'OK';     
        end    
    END               
    if(@IdPlanTrabajo != 0)  
    begin    
        SET @IdPlanTrabajoOutput = @IdPlanTrabajo;    
        SET @Success = 1;                                                        
        SET @Message = 'OK';            
    end    
                                                               
    COMMIT;                           
    END TRY                           
    BEGIN CATCH                           
        SET  @Success = 0;       
        SET @IdPlanTrabajoOutput = 0;                           
        SET @Message = 'LINEA:' + CAST(ERROR_LINE() AS VARCHAR(1000)) + 'ERROR' + ERROR_MESSAGE()                           
        ROLLBACK                           
    END CATCH             
END