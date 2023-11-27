/*--------------------------------------------------------------------------------------                                                                                                                              
' Nombre          :[dbo].[SGC_SP_ListWorkPlan_Day_L]                                                                                                                                            
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA LISTA DE ASISTENCIA POR DIA                                                        
' Creado Por      : cristian silva                                                                                                    
' Día de Creación : 19-08-2022                                                                                                                                           
' Requerimiento   : SGC                                                                                                                                        
' Modificado por  :                                                                                                                    
' Día de Modificación :            
 - 29-11-2022 -cristian silva  -- add :[LatitudInicio],[LongitudIncio],[LongitudTermino],[LatitudTermino], modify: FechaInicio, FechaInicio (YYYY-MM-dd hh:mm:ss:000)          
 - 01-12-2022 -cristian silva  -- add :[FechaVisita]         
 - 02-12-2022 -cristian silva  -- add : @Success
 - 06-10-2023 - Reynaldo - Se agrego el filtro de estadoPlanTrabajo = 2    
'--------------------------------------------------------------------------------------*/                      
                                                                 
ALTER PROCEDURE [dbo].[SGC_SP_ListWorkPlan_Day_L]                  
(@UserId int,      
@Success INT OUTPUT)       
AS                        
BEGIN        
      
 set @Success = (      
   SELECT                         
    ISNULL(COUNT(ptd.IdPlanTrabajoDetalle),0)                             
   FROM SGF_PlanTrabajo_Detalle ptd                                  
    inner join SGF_PlanTrabajo pt on ptd.IdPlan=pt.IdPlan                                  
    inner join SGF_ProveedorLocal pl on ptd.ProveedorLocalId=pl.ProveedorLocalId and ptd.TipoLugar=2                           
    inner join SGF_Proveedor p on pl.ProveedorId=p.ProveedorId                                  
    inner join SGF_Supervisor s on pl.IdSupervisor=s.IdSupervisor                                  
    inner join SGF_Local l on l.LocalId=pl.LocalId                          
   WHERE pt.UserId=@UserId                      
    and cast(pt.FechaVisita as date) = cast(dbo.getdate() as date)                                  
    and ptd.IdPlanTrabajoDetalle in (select max(PtdAux.IdPlanTrabajoDetalle) from SGF_PlanTrabajo_Detalle PtdAux                 
    inner join SGF_PlanTrabajo PtAux ON PtAux.IdPlan=PtdAux.IdPlan and PtAux.IdPlan=ptd.IdPlan where PtdAux.ProveedorLocalId= ptd.ProveedorLocalId                 
    and day(PtAux.FechaVisita)= day(dbo.getdate() ) group by PtdAux.ProveedorLocalId,PtdAux.TipoLugar) and pt.EstadoPlanTrabajo = 2                
   )      
      
 SELECT                         
  ptd.IdPlanTrabajoDetalle,                              
  p.ProveedorId,                              
  pl.ProveedorLocalId,                              
  pt.IdPlan,                              
  pl.NombreComercial,                            
  s.Nombre+' '+s.ApePaterno+' '+s.ApeMaterno as Supervisor,                              
  l.NombreCorto as NombreLocal,              
  p.DocumentoNum,                                             
  ptd.ItemId,              
  pl.Latitud,              
  pl.Longitud,                            
  convert(varchar(100),ptd.FechaInicio,21)[FechaInicio],                                
  convert(varchar(100),ptd.FechaTermino,21)[FechaTermino],           
  ptd.Latitud [LatitudInicio],          
  ptd.Longitud [LongitudInicio],          
  ptd.LatitudTermino [LatitudTermino],          
  ptd.LongitudTermino [LongitudTermino],           
  ptd.FechaCrea,              
  pl.Direccion,              
  pt.UserIdCrea,              
  ptd.TipoLugar,        
  --convert(VARCHAR,DATEADD(DAY,-1, convert(date,pt.FechaVisita,23)))[FechaVisita]       
  convert(varchar(10),pt.FechaVisita,23)[FechaVisita]       
 FROM SGF_PlanTrabajo_Detalle ptd                                  
  inner join SGF_PlanTrabajo pt on ptd.IdPlan=pt.IdPlan                                  
  inner join SGF_ProveedorLocal pl on ptd.ProveedorLocalId=pl.ProveedorLocalId and ptd.TipoLugar=2 and pl.Latitud is not null and pl.Longitud is not null                           
  inner join SGF_Proveedor p on pl.ProveedorId=p.ProveedorId                                  
  inner join SGF_Supervisor s on pl.IdSupervisor=s.IdSupervisor                                  
  inner join SGF_Local l on l.LocalId=pl.LocalId                          
 WHERE pt.UserId=@UserId                      
  and cast(pt.FechaVisita as date) =  cast(dbo.getdate() as date)                                  
  and ptd.IdPlanTrabajoDetalle in ( select max(PtdAux.IdPlanTrabajoDetalle) from SGF_PlanTrabajo_Detalle PtdAux                 
  inner join SGF_PlanTrabajo PtAux ON PtAux.IdPlan=PtdAux.IdPlan and PtAux.IdPlan=ptd.IdPlan where PtdAux.ProveedorLocalId= ptd.ProveedorLocalId                 
  and day(PtAux.FechaVisita)= day(dbo.getdate() ) group by PtdAux.ProveedorLocalId,PtdAux.TipoLugar) and pt.EstadoPlanTrabajo = 2        
 ORDER BY IdPlanTrabajoDetalle              
END 