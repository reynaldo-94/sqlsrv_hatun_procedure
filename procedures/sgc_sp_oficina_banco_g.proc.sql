/*--------------------------------------------------------------------------------------                                             
' Nombre          : [dbo].[SGC_SP_Oficina_Banco_G]                                                              
' Objetivo        : Este procedimiento me obtiene las oficinas del banco seleccionado                                         
' Creado Por      : Reynaldo Cauche                                                                                                                              
' Día de Creación : 13-01-2023                                                                                                                                                               
' Requerimiento   : SGC                                                                                                                                       
' Cambios  :  
    13/01/2023 - Reynaldo Cauche - Se creo el procedimiento 
    19/01/2023 - Reynaldo Cauche - Se agrego las columnas correo y nombre  
'--------------------------------------------------------------------------------------*/   
 
ALTER PROCEDURE [dbo].[SGC_SP_Oficina_Banco_G] 
( 
  @BancoId int 
) 
AS 
BEGIN 
  select o.IdOficina as OficinaId, ag.BancoId, O.Nombre, O.CorreoA as Correo, O.CorreoA as CorreosCopia 
  from sgf_agencia as ag 
  inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId 
  where ag.BancoId = @BancoId and ag.Activo  = 1 and o.Activo = 1 
END