/*--------------------------------------------------------------------------------------                                                                                                       
' Nombre          : [dbo].[SGC_SP_USERS_BY_ROL_L]                                                                                                                        
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LOS USUARIO POR ROLES                                                                              
' Creado Por      :                                                                                      
' Día de Creación :                                                                                                                   
' Requerimiento   : SGC                                                                                                                 
' Modificado por  : REYNALDO CAUCHE                                                                                                
' Día de Modificación : 12-04-2022                                                                                                             
'--------------------------------------------------------------------------------------*/                                               
                                             
CREATE PROCEDURE [dbo].[SGC_SP_USERS_BY_ROL_L]             
(@rolId int
,@zonaId int)
  as                                             
  begin  
    if(@rolId = 52)
      begin
        SELECT JefeZonaId as Id, Nombre Name                                            
        FROM SGF_JefeZona                             
        WHERE ZonaId = @zonaId      
      end
  end;

  exec SGC_SP_USERS_BY_ROL_L 52,1