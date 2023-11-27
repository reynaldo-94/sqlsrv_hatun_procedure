/*--------------------------------------------------------------------------------------                                                                                                                  
' Nombre          : [dbo].[SGC_SP_List_Office_Ubigeo_L]                                                                                                                              
' Objetivo        : ESTE PROCEDIMIENTO me trae de la tabla oficina por ubigeo y banco                                                                           
' Creado Por      :                                                                                                 
' Día de Creación : 12-07-2023                                                                                                                          
' Requerimiento   : SGC                                                                                                                            
' Modificado por  : cristian silva                                                                                                        
' Cambios :                       
                 
'--------------------------------------------------------------------------------------*/                                      
CREATE PROCEDURE [dbo].[SGC_SP_List_Office_Ubigeo_L]    
(@Ubigeo varchar(10),    
 @Bank int,    
 @Success int output)                                        
AS                     
BEGIN    
    set  @Success = (select count(*) from SGF_Oficina where CodUbigeo = @Ubigeo and BancoId = @Bank )                
                    
    select IIF(BancoId = 11, IdOficina, CodTopaz) [Id],    
           Nombre[Name],    
           Direccion            
    from SGF_Oficina            
    where CodUbigeo = @Ubigeo and    
          BancoId = @Bank    
END