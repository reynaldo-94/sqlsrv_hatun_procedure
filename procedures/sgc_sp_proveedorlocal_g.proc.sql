/*--------------------------------------------------------------------------------------                                                                                     
' Nombre          : [dbo].[SGC_SP_ProveedorLocal_G]                                                                                                     
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE DATOS DEL PROVEEDOR LOCAL                                                   
' Creado Por      : REYNALDO CAUCHE                                                                   
' Día de Creación : 07-01-2022                                                                                             
' Requerimiento   : SGC                                                                                               
' cambios  :      
 - 21-09-2022 - REYNALDO CAUCHE - Se cambio el valor de retorno de la variable IdSupervisor, se devuelve pl.idsupervisor                                                                                    
'--------------------------------------------------------------------------------------*/     
ALTER PROCEDURE [dbo].[SGC_SP_ProveedorLocal_G]           
(           
 @ProveedorLocalId int,        
 @Content varchar(100) OUTPUT           
)           
AS         
 DECLARE @IdSupervisor INT   
 DECLARE @AdvIdSupervisor INT   
 DECLARE @ZonaIdSupervisor INT   
 DECLARE @LocalIdSupervisor INT   
BEGIN            
 SELECT       
   @IdSupervisor=PL.IdSupervisor,
   @AdvIdSupervisor=SP.AdvId,   
   @ZonaIdSupervisor=SP.ZonaId,   
   @LocalIdSupervisor=SP.LocalId   
 FROM SGF_ProveedorLocal PL   
 INNER JOIN SGF_Supervisor SP ON SP.IdSupervisor = PL.IdSupervisor    
 WHERE ProveedorLocalId=@ProveedorLocalId        
 SET @Content=(SELECT CONCAT(IIF(@IdSupervisor IS NULL,0,@IdSupervisor),'/**/',IIF(@AdvIdSupervisor IS NULL,0,@AdvIdSupervisor),'/**/',IIF(@ZonaIdSupervisor IS NULL,0,@ZonaIdSupervisor),'/**/',IIF(@LocalIdSupervisor IS NULL,0,@LocalIdSupervisor)));       
 
 PRINT @Content           
END