/*--------------------------------------------------------------------------------------                                                                                                                                        
' Nombre          :[dbo].[SGC_SP_PlanTrabajoDetalle_I]                                                                                                                                                      
' Objetivo        : ESTE PROCEDIMIENTA CREA PLAN DE TRABAJO                                                                 
' Creado Por      : REYNALDO CAUCHE                                                                                                             
' Día de Creación : 05-09-2022                                                                                                                                                     
' Requerimiento   : SGC                                                                                                                                                  
' Modificado por  :                                                                                                                              
' Día de Modificación :          
  - develop_rediseño - 22/09/2023 - francisco lazaro - se corrige validacion por itemid    
  - develop_rediseño - 26/09/2023 - cristian silva - se valido por itemid>0 linea 32 para que se crea el plan trabajo detalle  
'--------------------------------------------------------------------------------------*/                 
      
CREATE PROCEDURE [dbo].[SGC_SP_PlanTrabajoDetalle_I]    
(@IdPlanTrabajo int,          
 @ProveedorLocalId int,           
 @ItemId int,          
 @UserIdCrea int,              
 @Success int output,                                
 @Message varchar(8000) output)      
AS          
    DECLARE @MaxIdPlanTrabajo int          
    DECLARE @MaxIdPlanTrabajoDetalle int          
    DECLARE @validIdPlanTrabajoDetalle int        
BEGIN                                                
    BEGIN TRY                              
    BEGIN TRANSACTION                       
        SET @Success=0;                  
        SET @validIdPlanTrabajoDetalle = ISNULL((select top 1 IdPlanTrabajoDetalle from SGF_PlanTrabajo_Detalle a    
                                                 INNER JOIN SGF_PlanTrabajo b on a.IdPlan = b.IdPlan    
                                                 where a.IdPlan = @IdPlanTrabajo and a.ProveedorLocalId = @ProveedorLocalId and b.UserId = @UserIdCrea), 0)      
                
        IF (@validIdPlanTrabajoDetalle = 0  and @ItemId > 0)        
        BEGIN        
            SET @MaxIdPlanTrabajoDetalle = (SELECT MAX(IdPlanTrabajoDetalle) + 1 FROM SGF_PlanTrabajo_Detalle)          
           
            INSERT INTO SGF_PlanTrabajo_Detalle (IdPlanTrabajoDetalle, IdPlan, ProveedorLocalId, ItemId, FechaCrea, UserIdCrea, TipoLugar)          
                                            VALUES (@MaxIdPlanTrabajoDetalle, @IdPlanTrabajo, @ProveedorLocalId, @ItemId, dbo.getdate(), @UserIdCrea, 2)    
        END        
        ELSE    
        BEGIN        
            IF (@ItemId = 0)    
            BEGIN         
                DELETE FROM SGF_PlanTrabajo_Detalle      
                where IdPlanTrabajoDetalle = @validIdPlanTrabajoDetalle    
            end      
            ELSE    
            BEGIN        
                update SGF_PlanTrabajo_Detalle    
                set ItemId = @ItemId,        
                    FechaActua= dbo.getdate(),        
                    UserIdActua = @UserIdCrea        
                where IdPlan = @IdPlanTrabajo and ProveedorLocalId = @ProveedorLocalId         
            end          
        end        
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