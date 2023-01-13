/*--------------------------------------------------------------------------------------                                            
' Nombre          : [dbo].[SGC_SP_Oficina_Ubigeo_G]                                                             
' Objetivo        : Este procedimiento me obtiene la oficina por ubigeo                                        
' Creado Por      : Reynaldo Cauche                             
' Día de Creación : 12-05-2022                                                         
' Requerimiento   : SGC                                                      
' Modificado por  :                                     
' Día de Modificación :                                                  
'--------------------------------------------------------------------------------------*/                                  
                              
CREATE PROCEDURE [dbo].[SGC_SP_Oficina_Ubigeo_G] 
(@UbigeoId int) 
AS 
BEGIN 
    SELECT ofc.IdOficina, ofc.Nombre  
    FROM sgf_oficina_ubigeo oub  
    INNER JOIN sgf_oficina ofc ON oub.IdOficina = ofc.IdOficina  
    WHERE oub.CodUbigeo = @UbigeoId 
END