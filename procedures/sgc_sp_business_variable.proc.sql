/*--------------------------------------------------------------------------------------                                                                                                                              
' Nombre          : [dbo].[SGC_SP_Business_Variable]                                                                                                                                           
' Objetivo        : ESTE PROCEDIMIENTO TRAE EL VALOR ANDROID_VERSION_CODE                                                     
' Creado Por      : cristian silva                                                                                                          
' Día de Creación : 24-11-2022                                                                                                                                          
' Requerimiento   : SGC                                                                                                                                        
' Cambios:                
 
'--------------------------------------------------------------------------------------*/                                                                                  
                                                                              
CREATE PROCEDURE [dbo].[SGC_SP_Business_Variable]     
(@Ruc VARCHAR(25), 
 @Success INT OUTPUT)  
as 
BEGIN 
set @Success = (select  count(Android_VersionCode) from SGF_VariablesNegocio where Ruc =@Ruc ); 
select  Android_VersionCode [AndroidVersionCode]from SGF_VariablesNegocio where Ruc = @Ruc 
 
END

select * from sgf_a