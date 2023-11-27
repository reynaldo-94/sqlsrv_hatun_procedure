 /*--------------------------------------------------------------------------------------                                                                                                                              
' Nombre          :[dbo].[SGC_SP_WorkPlan_RegisterAssistance_I]                                                                                                                                            
' Objetivo        : ESTE PROCEDIMIENTO ACTUALIZA LA LISTA DE ASISTENCIA DEL SUPERVISOR                                                       
' Creado Por      : cristian silva                                                                                                    
' Día de Creación : 17-11-2022                                                                                                                                           
' Requerimiento   : SGC                                                                                                                                        
' Modificado por  :                                                                                                                    
' Día de Modificación :      
'--------------------------------------------------------------------------------------*/                                                                             
CREATE PROCEDURE [dbo].[SGC_SP_MultipleWorkPlan_RegisterAssistance_I]            
@IdPlanTrabajoDetalle int,    
@FechaInicio varchar(150),    
@LatitudInicio varchar(150),              
@LongitudInicio varchar(150),  
@FechaTermino varchar(150),    
@LatitudTermino varchar(150),              
@LongitudTermino varchar(150),  
@UserIdCrea int,                   
@Success int output,                      
@Message varchar(8000) output                    
AS                      
BEGIN                                      
 BEGIN TRY                    
  BEGIN TRANSACTION             
  SET @Success=0;              
      
   update SGF_PlanTrabajo_Detalle                
   set FechaInicio = convert(datetime,@FechaInicio),   
    Latitud = @LatitudInicio,                
    Longitud = @LongitudInicio,  
    FechaTermino =convert(datetime, @FechaTermino),   
    LatitudTermino = @LatitudTermino,                
    LongitudTermino = @LongitudTermino,      
    UserIdActua = @UserIdCrea ,                                
    FechaActua = dbo.getdate()    
   where IdPlanTrabajoDetalle=@IdPlanTrabajoDetalle         
                 
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
  