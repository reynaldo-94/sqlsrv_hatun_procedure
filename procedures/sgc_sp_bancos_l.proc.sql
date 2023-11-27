/*--------------------------------------------------------------------------------------                                                                                                                                      
' Nombre          : [dbo].[SGC_SP_Bancos_L]                                                                                                                                                   
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE TODOS LOS BANCOS ACTIVOS                                                        
' Creado Por      : Reynaldo Cauche                                                                                                                 
' Día de Creación : 02-02-2023                                                                                                                                                  
' Requerimiento   : SGC      
' Día de Modifica : 10-03-2023       
' Cambios         : - Se agrega campos NombreSSFF y varParametrosSentinel      
         
'--------------------------------------------------------------------------------------*/          
        
CREATE PROCEDURE [dbo].[SGC_SP_Bancos_L]         
AS         
BEGIN         
  SELECT BancoId,    
         Nombre,    
         MailResponsable,    
         RespConvenio,    
         NombreSSFF,    
         varParametrosSentinel,     
         logo    
  FROM SGB_Banco         
  WHERE Activo = 1  
  ORDER BY BancoId desc  
END 