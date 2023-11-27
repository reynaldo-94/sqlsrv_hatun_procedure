/*--------------------------------------------------------------------------------------                                                                                                                              
' Nombre          : [dbo].[SGF_SP_NotificationPush_Users_G]                                                                                                                                               
' Objetivo        : obtiene los usuarios                                                                                         
' Creado Por      : cristian silva                                                                                                        
' Día de Creación : 20/03/2023                                                                                                                                   
' Requerimiento   : SGC                                                                                                                                        
                                
'--------------------------------------------------------------------------------------*/                                 
CREATE PROCEDURE [dbo].[SGC_SP_NotificationPush_Users_G]                                
(                                
 @ExpedienteCreditoId  int = 0,            
 @UserId int =0            
)                                
AS                                
BEGIN            
            
            
   select distinct             
      per.Nombre+' '+per.ApePaterno+' '+per.ApeMaterno [NombresPer]  ,          
      per.DocumentoNum [Documento]  ,          
      (select top 1 Nombres+' '+ApePaterno+' '+ApeMaterno  from SGF_USER where UserId = @UserId) [NombresUser],            
      convert(varchar, isnull(us.UserId,0))+'/**/' --su              
      +convert(varchar, isnull(us2.UserId ,0))+'/**/' --adv              
      +convert(varchar, isnull(us4.UserId ,0)) [UserIds]--re              
      --+convert(varchar, isnull(us3.UserId ,0)) [UserIds]--zo              
   from SGF_ExpedienteCredito ex        
      left join SGF_Supervisor supe on supe.IdSupervisor = ex.IdSupervisor        
      left join SGF_USER us on supe.IdSupervisor = us.EmpleadoId and us.CargoId=29        
      left join SGF_ADV adv on adv.AdvId = ex.AdvId              
      left join SGF_USER us2 on us2.EmpleadoId = adv.AdvId and us2.CargoId = 4 and us2.IsActive = 1              
      left join SGF_Local lo on lo.LocalId = ex.ExpedienteCreditoLocalId              
      --left join SGF_Zona zon on zon.ZonaId = ex.ExpedienteCreditoZonaId and zon.ZonaId = lo.ZonaId              
      --left join SGF_JefeZona jezo on jezo.ZonaId = zon.ZonaId              
      --left join SGF_USER us3 on us3.EmpleadoId = jezo.JefeZonaId and us3.CargoId = 2 and us3.IsActive = 1              
      --left join SGF_JefeRegional jere on jere.RegionId = zon.RegionZonaId     
      --left join SGF_JefeRegional jere on jere.RegionId = lo.RegionalId     
      --left join SGF_USER us4 on us4.EmpleadoId = jere.JefeRegionalId and us4.CargoId = 52  and us4.IsActive = 1      
      left join SGF_USER us4 on us4.CargoId = 52  and us4.IsActive = 1 and lo.RegionalId = us4.EmpleadoId --add    
      inner join SGF_Persona per on per.PersonaId = ex.TitularId          
   where  ex.ExpedienteCreditoId = @ExpedienteCreditoId              
END 