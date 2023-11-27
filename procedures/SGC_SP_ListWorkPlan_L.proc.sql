          
          
            
/*--------------------------------------------------------------------------------------                                                                                                                                                    
' Nombre          : [dbo].[SGC_SP_ListWorkPlan_L]                                                                                                                                                                     
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA LISTA DE ASISTENCIA  POR MES                                                                                
' Creado Por      : CRISTIAN SILVA                                                                                                                           
' Día de Creación : 17-08-2022                                                                                                                                                                 
' Requerimiento   : SGC                                                                                                                                                              
' Modificado por  : CRISTIAN SILVA                                                                                                                                   
' Cambios:                            
  - 19-08-2022 - Cristian silva - se agrego @Rol                    
  - 08-11-2022 - Cristian silva - se modifico la date a horas AM y PM y el valor de si es null a in datos de inicio       
  - (develop-rediseño)  11-09-2023 - Reynaldo Cauche - Se cambio el formato de fechaVisita a yyyy-mm-dd 
  - (develop-rediseño) 06-10-2023 - Reynaldo - Se agrego el filtro de estadoPlanTrabajo = 2      
'--------------------------------------------------------------------------------------*/                                                           
              
ALTER PROCEDURE [dbo].[SGC_SP_ListWorkPlan_L]                                        
(@UserId int                                 
,@Anio int                              
,@Mes int                                       
,@LocalId int)                                        
AS                                        
BEGIN                                   
                                  
declare @Rol int                     
declare @FormatFecha varchar(15)                
declare @super  int  = 0            
set @Rol = 0                                  
                                  
set @Rol = (select CargoId from SGF_USER where IsActive = 1 AND UserId = @UserId and CargoId = 29)                                  
set @super = (select top 1 UserId from SGF_USER where IsActive = 1 AND EmpleadoId = @UserId and CargoId = 29)                  
              
if(@LocalId = 0 )                                      
begin                                      
  select                                      
    PTD.IdPlanTrabajoDetalle                                      
    ,PTD.ItemId                                      
    ,isnull(REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR(25), PTD.FechaInicio, 100), 7), 'AM', ' AM'), 'PM', ' PM'),'Sin datos de inicio') FechaInicio                  
    ,isnull(REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR(25), PTD.FechaTermino, 100), 7), 'AM', ' AM'), 'PM', ' PM'),'') FechaTermino                  
    ,convert(varchar,PT.FechaVisita, 103) as FechaVisita                                       
    ,US.Nombres+' '+US.ApePaterno+' '+US.ApeMaterno as Usuario                                      
    ,isnull(dbo.FN_Calcular_Distancia(PTD.Latitud                                      
    ,PTD.Longitud                                      
    ,case PTD.TipoLugar                                       
    when 1 then (select top 1 Latitud from SGF_Local where LocalId = PTD.ProveedorLocalId)                                      
    when 2 then (select top 1 Latitud from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
    when 3 then (select top 1 Latitud from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
    end                              
    ,case PTD.TipoLugar                                       
  when 1 then (select top 1 Longitud from SGF_Local where LocalId = PTD.ProveedorLocalId)                                              
    when 2 then (select top 1 Longitud from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
    when 3 then (select top 1 Longitud from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
    end                           
    ),0) as Distancia                                       
    ,case WHEN PTD.EstAsistencia = 1 then 'Justificado'                                                    
    WHEN CAST(PTD.FechaInicio as time) is null and (PTD.EstAsistencia <> 1 or PTD.EstAsistencia is NULL) and (PTD.Justificacion = '' or PTD.Justificacion is NULL) then 'Falta'                                                                                
 
   
    WHEN CAST(PTD.FechaInicio as time) >= CAST('9:01' as Time)   and PTD.ItemId = 1 then 'Tardanza'                                                        
    WHEN DATEDIFF(MINUTE, PTD.FechaInicio, PTD.FechaTermino) + 1 < 31 then 'Poco Tiempo'                       
    WHEN dbo.FN_Calcular_Distancia(PTD.Latitud                                      
    ,PTD.Longitud                                      
    ,case PTD.TipoLugar                                
    when 1 then (Select top 1 Latitud from SGF_Local where LocalId=PTD.ProveedorLocalId)                                                                                      
    when 2 then (Select top 1 Latitud from SGF_ProveedorLocal where ProveedorLocalId=PTD.ProveedorLocalId)                                                           
    when 3 then (Select top 1 Latitud from SGF_Oficina where IdOficina=PTD.ProveedorLocalId) end                                             
    ,case PTD.TipoLugar                                       
    when 1 then (Select top 1 Longitud from SGF_Local where LocalId=PTD.ProveedorLocalId)                                                                                      
    when 2 then (Select top 1 Longitud from SGF_ProveedorLocal where ProveedorLocalId=PTD.ProveedorLocalId)                                                                             
    when 3 then (Select top 1 Longitud from SGF_Oficina where IdOficina=PTD.ProveedorLocalId) end)>0.5 then 'Lejos'                                                               
    ELSE 'Asistió' END as Asistencia                                      
    , case PTD.TipoLugar                                       
    when 1 then (select top 1  Descripcion from SGF_Local where LocalId = PTD.ProveedorLocalId)                                      
    when 2 then (select top 1  NombreComercial from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
    when 3 then (select top 1  Nombre from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
    end as NombreLugar                                      
  from                                      
   sgf_plantrabajo_detalle PTD                                      
   inner join SGF_PlanTrabajo pt on pt.IdPlan = PTD.IdPlan                                      
   inner join SGF_USER us on us.UserId = PT.UserId                                      
   inner join sgf_proveedorlocal pol on pol.proveedorlocalid = PTD.proveedorlocalid and pol.Latitud is not null and pol.Longitud is not null                                     
  where              
   (PT.UserId = iif(@Rol = 29 ,@UserId,@super) )                  
   and PT.FechaVisita < dbo.getdate()                                       
   and (MONTH(pt.FechaVisita) = @Mes)                                      
   and (YEAR(pt.FechaVisita) = @Anio) 
   and pt.EstadoPlanTrabajo = 2      
   order by convert(date,pt.FechaVisita) desc , PTD.FechaInicio desc                                      
end                                      
-- rol 52 a regional                            
if(@LocalId > 0 and @Rol = 52 and @Rol = 2)                                      
begin                                      
select                       
 PTD.IdPlanTrabajoDetalle                                      
 ,PTD.ItemId                                      
 ,isnull(REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR(25), PTD.FechaInicio, 100), 7), 'AM', ' AM'), 'PM', ' PM'),'Sin datos de inicio') FechaInicio                  
 ,isnull(REPLACE(REPLACE(RIGHT(CONVERT(VARCHAR(25), PTD.FechaTermino, 100), 7), 'AM', ' AM'), 'PM', ' PM'),'') FechaTermino                                    
 ,convert(varchar(11),PT.FechaVisita, 103) as FechaVisita               
 ,US.Nombres+' '+US.ApePaterno+' '+US.ApeMaterno as Usuario                                      
 ,isnull(dbo.FN_Calcular_Distancia(PTD.Latitud                                      
        ,PTD.Longitud                                      
        ,case PTD.TipoLugar                                       
          when 1 then (select top 1 Latitud from SGF_Local where LocalId = PTD.ProveedorLocalId)                                  
          when 2 then (select top 1 Latitud from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
          when 3 then (select top 1 Latitud from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
          end                                  
        ,case PTD.TipoLugar                                       
          when 1 then (select top 1 Longitud from SGF_Local where LocalId = PTD.ProveedorLocalId)                                              
          when 2 then (select top 1 Longitud from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
          when 3 then (select top 1 Longitud from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
          end                                      
        ),0) as Distancia                                       
 ,case WHEN PTD.EstAsistencia = 1 then 'Justificado'                                                    
             WHEN CAST(PTD.FechaInicio as time) is null and (PTD.EstAsistencia <> 1 or PTD.EstAsistencia is NULL) and (PTD.Justificacion = '' or PTD.Justificacion is NULL) then 'Falta'                                                                      
            WHEN CAST(PTD.FechaInicio as time) >= CAST('9:01' as Time)   and PTD.ItemId = 1 then 'Tardanza'                                                        
          WHEN DATEDIFF(MINUTE, PTD.FechaInicio, PTD.FechaTermino) + 1 < 31 then 'Poco Tiempo'                                                      
             WHEN dbo.FN_Calcular_Distancia(PTD.Latitud                                      
           ,PTD.Longitud                                      
 ,case PTD.TipoLugar                                      
            when 1 then (Select top 1 Latitud from SGF_Local where LocalId=PTD.ProveedorLocalId)                                                       
            when 2 then (Select top 1 Latitud from SGF_ProveedorLocal where ProveedorLocalId=PTD.ProveedorLocalId)                                                           
            when 3 then (Select top 1 Latitud from SGF_Oficina where IdOficina=PTD.ProveedorLocalId) end                                                        
 ,case PTD.TipoLugar                                       
            when 1 then (Select top 1 Longitud from SGF_Local where LocalId=PTD.ProveedorLocalId)                                    
            when 2 then (Select top 1 Longitud from SGF_ProveedorLocal where ProveedorLocalId=PTD.ProveedorLocalId)                                                                                      
       when 3 then (Select top 1 Longitud from SGF_Oficina where IdOficina=PTD.ProveedorLocalId) end)>0.5 then 'Lejos'                                                               
             ELSE 'Asistió' END as Asistencia                                      
 , case PTD.TipoLugar                                       
  when 1 then (select top 1  Descripcion from SGF_Local where LocalId = PTD.ProveedorLocalId)             
  when 2 then (select top 1  NombreComercial from SGF_ProveedorLocal where ProveedorLocalId = PTD.ProveedorLocalId)                                      
  when 3 then (select top 1  Nombre from SGF_Oficina where IdOficina = PTD.ProveedorLocalId)                                      
  end as NombreLugar                                     
from                       
 sgf_plantrabajo_detalle PTD                                      
 inner join SGF_PlanTrabajo pt on pt.IdPlan = PTD.IdPlan                                      
 inner join SGF_USER us on us.UserId = PT.UserId                                      
 inner join sgf_proveedorlocal pol on pol.proveedorlocalid = PTD.proveedorlocalid  and pol.Latitud is not null and pol.Longitud is not null                                    
 inner join sgf_local lo on lo.localid =PTD.proveedorlocalid                                      
 inner join SGF_Oficina ofi on  ofi.IdOficina=PTD.ProveedorLocalId                                      
 inner join SGF_zona z on z.ZonaId = lo.ZonaId                                        
 inner join sgf_regionzona r on r.RegionZonaId=z.RegionZonaId                                      
 where PT.FechaVisita < dbo.getdate()                 
   and (MONTH(pt.FechaVisita) = @Mes)                                      
   and (YEAR(pt.FechaVisita) = @Anio)                                      
   and PTD.proveedorlocalid = @LocalId                                   
   and us.cargoid=29 and us.isactive=1      
   and pt.EstadoPlanTrabajo = 2                               
order by convert(date,pt.FechaVisita) desc , PTD.FechaInicio desc                                      
end                                    
                                  
END 