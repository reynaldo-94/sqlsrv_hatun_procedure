          
/*--------------------------------------------------------------------------------------                                                                                                                      
' Nombre          : [dbo].[SGC_TOKEN]                                                                                                                                       
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LOS DATOS DEL USUARIO QUE SE DEVUELVE AL INICIAR SESION                                                       
' Creado Por      : REYNALDO CAUCHE                                                                                                  
' Día de Creación :                                                                                                                                 
' Requerimiento   : SGC                                                                                                                                
' cambios  :         
 - 03-10-2022 - REYNALDO CAUCHE - Se agrego el campo LocalName para el rol Supervisor   
'                                                                                                                           
'--------------------------------------------------------------------------------------*/            
   
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
    BEGIN                
        SELECT                
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
            0 as BancoId,   
            lc.Descripcion as LocalName   
        FROM SGF_USER su                
        INNER JOIN SGF_ROL sr on su.CargoId = sr.RolId                 
        INNER JOIN SGF_Supervisor ss on ss.IdSupervisor = su.EmpleadoId    
        INNER JOIN SGF_Local as lc on ss.LocalId = lc.LocalId               
        WHERE LOWER(su.EmailEmpresa) = @Email;                
    END                
                   
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
  0 as BancoId,   
  '' as LocalName   
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
   0 as BancoId,   
   '' as LocalName   
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
	0 as BancoId,   
    '' as LocalName   
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
   ISNULL(@listVioTutorialId, '') as listaVioTutorialId,    
   ac.BancoId,   
   '' as LocalName   
     from                
      SGF_USER su                
     inner join                
      SGF_ROL sr                 
     on                
      su.CargoId = sr.RolId    
	  inner join SGF_AsistenteConvenio ac ON su.EmpleadoId = ac.AsistenteId    
     where                
      LOWER(su.EmailEmpresa) = @Email              
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
    0 as BancoId,   
    '' as LocalName   
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