/*--------------------------------------------------------------------------------------                                            
' Nombre          : [dbo].[SGC_SP_Oficina_Banco_G]                                                             
' Objetivo        : Este procedimiento me obtiene las oficinas del banco seleccionado                                        
' Creado Por      : Reynaldo Cauche                                                                                                                             
' Día de Creación : 13-01-2023                                                                                                                                                              
' Requerimiento   : SGC                                                                                                                                      
' Cambios  :         
'--------------------------------------------------------------------------------------*/  

ALTER PROCEDURE [dbo].[SGC_SP_Oficina_Banco_G]
(
  @BancoId int
)
AS
BEGIN
  select o.IdOficina, O.Nombre
  from sgf_agencia as ag
  inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId
  where ag.BancoId = @BancoId and ag.Activo  = 1
END