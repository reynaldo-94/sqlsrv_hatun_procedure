select *from SGF_AsistenteConvenio
update SGF_AsistenteConvenio set bancoId = 11 where bancoId = 8

CREATE proc [dbo].[SGC_TOKEN](               
 @Email varchar(100)               
)               
as               
 declare @rolId int         
 declare @listVioTutorialId varchar(50)   
 declare @bancoId int   
                
 set @rolId = (select top 1 su.CargoId from SGF_USER su where su.EmailEmpresa = @Email);         
           
 -- Obtener lista VioTutorial         
 select @listVioTutorialId = STRING_AGG(vt.VentanaId, ',')         
 from SGF_USER su         
 inner join SGF_User_VioTutorial vt on su.UserId = vt.userId         
 where LOWER(su.EmailEmpresa) = @Email;             
                
 begin               
                 
  IF(@rolId = 29)               
   begin               
    select               
     su.UserId,               
     ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,                
     sr.RolId,               
     sr.RolDes,               
     ss.LocalId,               
     ss.ZonaId,               
     su.EmpleadoId,   
  ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
  0 as BancoId   
    from               
     SGF_USER su               
    inner join               
     SGF_ROL sr                
    on               
     su.CargoId = sr.RolId                
    inner join               
     SGF_Supervisor ss               
    on               
     ss.IdSupervisor = su.EmpleadoId               
    where               
     LOWER(su.EmailEmpresa) = @Email;               
   end               
                  
  IF(@rolId = 2)               
   begin               
    select               
     su.UserId,               
     ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,             
     sr.RolId,               
     sr.RolDes,               
     0 LocalId,               
     sjz.ZonaId,               
     su.EmpleadoId,         
  ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
  0 as BancoId   
    from               
     SGF_USER su               
    inner join               
     SGF_ROL sr                
    on               
     su.CargoId = sr.RolId                
    inner join               
     SGF_JefeZona sjz                
    on               
     sjz.JefeZonaId = su.EmpleadoId               
    where               
     LOWER(su.EmailEmpresa) = @Email;               
   end               
                  
  IF(@rolId = 4)               
    begin               
     select               
      su.UserId,               
      ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,               
      sr.RolId,               
      sr.RolDes,         
   sa.LocalId ,               
      sa.ZonaId,               
      su.EmpleadoId,         
   ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
   0 as BancoId   
     from               
      SGF_USER su               
     inner join               
      SGF_ROL sr                
     on               
      su.CargoId = sr.RolId                
     inner join               
      SGF_ADV sa               
     on               
      sa.AdvId = su.EmpleadoId               
     where               
      LOWER(su.EmailEmpresa) = @Email               
     -- and               
     -- su.Nombres is not null;               
    end               
               
   IF(@rolId = 52)               
    begin               
     select                 
       su.UserId,                 
       ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,             
       sr.RolId,                 
       sr.RolDes,                 
       0 LocalId ,                 
       0 ZonaId,                 
       su.EmpleadoId,      
       sjr.RegionId,         
    ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
 0 as BancoId   
      from                 
       SGF_USER su                 
      inner join                 
       SGF_ROL sr                  
      on                 
       su.CargoId = sr.RolId                
      inner join               
      SGF_JefeRegional sjr               
      on               
      sjr.JefeRegionalId = su.EmpleadoId               
      where                 
       LOWER(su.EmailEmpresa) = @Email                 
      -- and               
      -- su.Nombres is not null;                 
   END   
      
   IF(@rolId = 27)                 
    begin               
     select               
      su.UserId,             
      ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,             
      sr.RolId,               
      sr.RolDes,         
      0 LocalId ,               
      0 ZonaId,               
      su.EmpleadoId,               
  -- ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
   ac.BancoId   
     from               
      SGF_USER su               
     inner join               
      SGF_ROL sr                
     on               
      su.CargoId = sr.RolId   
   inner join SGF_AsistenteConvenio ac ON su.EmpleadoId = ac.AsistenteId   
     where               
      LOWER(su.EmailEmpresa) = 'surgir@hatun.com.pe'             
     -- and               
     -- su.Nombres is not null;               
    end               
                 
                     
   IF(@rolId != 4 and @rolId != 29 and @rolId != 2  and @rolId != 52 and @rolId != 27)                 
    begin               
     select               
      su.UserId,             
      ISNULL(su.Nombres, '') + ' ' +           
      ISNULL(su.ApePaterno, '') + ' ' +           
      ISNULL(su.ApeMaterno, '') as Name,             
      sr.RolId,               
      sr.RolDes,         
      0 LocalId ,               
      0 ZonaId,               
      su.EmpleadoId,               
   ISNULL(@listVioTutorialId, '') as listaVioTutorialId,   
    0 as BancoId   
     from               
      SGF_USER su               
     inner join               
      SGF_ROL sr                
     on               
      su.CargoId = sr.RolId                
     where               
      LOWER(su.EmailEmpresa) = @Email             
     -- and               
     -- su.Nombres is not null;               
    end               
                 
end