/*--------------------------------------------------------------------------------------                                                                                                   
' Nombre          : [dbo].[SGC_SP_NUEVO_CONTACTO_DATA]                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA DESCRIPCION PARA EL ENVIO DE CORREO                                  
' Creado Por      : REYNALDO CAUCHE                                                                               
' Día de Creación : 26-01-2022                                                                                                                
' Requerimiento   : SGC   
' Modificado por  : REYNALDO CAUCHE                                                                                           
' Día de Modificación : 18-07-2022      
'--------------------------------------------------------------------------------------*/             
CREATE PROCEDURE SGC_SP_NUEVO_CONTACTO_DATA(           
 @PersonaId int,       
 @ParametroId int,       
 @Name varchar(8000) OUTPUT,          
 @Email varchar(8000) OUTPUT,         
 @Content varchar(max) OUTPUT,   
 @TemplateId varchar(100) OUTPUT     
)             
AS           
begin           
 set @Name = (Select Nombre FROM SGF_Persona WHERE PersonaId = @PersonaId);  
 set @Email = (Select Correo FROM SGF_Persona WHERE PersonaId = @PersonaId); 
 set @TemplateId = (Select ValorParam from SGF_Parametro sp where sp.DominioId = 123 and sp.ParametroId = @ParametroId); 
end