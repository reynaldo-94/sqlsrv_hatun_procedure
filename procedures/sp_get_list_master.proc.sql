 
/*--------------------------------------------------------------------------------------                                                                                                                      
' Nombre          : [dbo].[sp_get_list_master]                                                                                                                                       
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LOS LOCALES                                                                                             
' Creado Por      :                                                                                                     
' Día de Creación :                                                                                                                                  
' Requerimiento   : SGC                                                                                                                                
' Modificado por  : REYNALDO CAUCHE
' Cambios  :          
 - 11-10-2022  REYNALDO CAUCHE - Se agrego nuevas caso de uso con el parametro listId, nuevos casos: 42,43,44,45,46,47
'--------------------------------------------------------------------------------------*/                                   
                                                            
ALTER PROCEDURE [dbo].[sp_get_list_master]     
(@id varchar(10),                                                                                
 @listId int,                                                                    
 @parameter int,                                                                    
 @rolId int,                                                          
 @empleadoId int)                                                                                
as                                                                         
    declare @userId int                                                                    
    declare @localId int                                                                    
    declare @zonaId int                                                                    
    declare @regionId int                                                                    
    declare @rolIds int                                                                    
begin                                                                                
    --Tipo Documento(1) --Grado Académico(2) --Parentesco(3) --Bancos(4)                                                                                
    --Nivel de Educación(5) --Procedencia(9) --Categoría Empleado(10)                                                                                
    --Tipo Pantalón(12) --Talla Camisa(13) --Modalidad(14) --Afp(15)                                                                                
    --Estado Civil(16) --Tipo Crédito(21) --Independiente(22) --Formalidad(23)                                                                                
    --Sustento Ingreso(24) --Tipo Documento Adjunto(25) --Tipo Cambio Tckets(37) -- Estados tickets(38) -- Motivio Injustificacion (39) -- ReconfirmacionesContactado (42) -- ReconfirmacionesInteresado(43) -- ReconfirmacionesResultado(44) -- ReconfirmacionesMotivo(45) -- ReconfirmacionesSubMotivo(46) -- ReconfirmacionesBancos(47)
    IF(@listId = 1 or @listId = 2 or @listId = 3 or @listId = 4 or                                           
       @listId = 5 or @listId = 9 or @listId = 10 or @listId = 12 or                                           
       @listId = 13 or @listId = 14 or @listId = 15 or @listId = 16 or                                           
       @listId = 22 or @listId = 23 or @listId = 24 or @listId = 25 or             
       @listId = 38 or @listId = 42 or @listId = 43 or @listId = 44 or @listId = 45 or @listId = 46 or @listId = 47)                                            
   begin                                                                                 
        select sp.ParametroId Id,          
               sp.NombreLargo Name                                                     
        from SGF_Parametro sp                          
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                                               
        where sd.DominioId = @id and sp.IndicadorActivo  = 1             
    end       
       
                                                                                 
    IF(@listId = 21)                                                                            
    BEGIN                                                                    
        select sp.ParametroId Id,                                                                                
               sp.NombreLargo Name                                                                                
        from SGF_Parametro sp                                                                                 
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                               
        where sd.DominioId = @id and sp.IndicadorActivo  = 1                                                                 
        order by sp.ValorEntero asc                                                      
    END                                                                            
    --Departamento                                                                           
    IF(@listId = 6)                                          
    begin                                                                                
        select concat(su.CodDpto,'0000') Id,                                                                                
               su.Nombre Name                                                
        from SGF_UBIGEO su                                                                                 
        where su.CodDist = '00' and                                           
           su.CodProv = '00'                                                                                
    end                                                       
    --Provincia                                                                                
    IF(@listId = 7)                                                                                
    begin                                                                  
        select concat(su.CodDpto,su.CodProv,'00') Id,                                                                   
               su.Nombre Name                                                                                
        from SGF_UBIGEO su                                                              
        where su.CodProv <> '00' and                                                                                
              su.CodDpto = left(@id,2) and                                                                                
              su.CodDist = '00'                                                                                
    end                                                                                
    --Distrito                                                                                
    IF(@listId = 8)                                                                                
     begin                                                                                
         /*select concat(su.CodDpto,su.CodProv,su.CodDist) Id,                                                                                
                  su.Nombre Name                                                                                
         from SGF_UBIGEO su   
         where su.CodDpto = left(@id,2) and                                                                                
               su.CodProv = right(left(@id,4),2)*/                                            
         Select DIST.CodUbigeo [Id],                           
                PROV.Nombre + '-' + DIST.Nombre [Name]           
         From SGF_UBIGEO DIST                                                                             
         OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                                             
                   WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV                   
         Where DIST.CodDpto<>00 and DIST.CodProv<>00 and DIST.CodDist<>00 -- AND DIST.LocalId > 0                                                    
    end                        
    --País                                                                                
    IF(@listId = 11)                       
    begin                                                                                
        select sp2.PaisId Id,                                                                                
        sp2.PaisDes Name                                                                                
        from SGF_Pais sp2                                                                                
    end                                                                                
    --Área                                                                   
    IF(@listId = 17)                                          
    begin                                                                                
        select                                                                                
        sea.AreaId Id,                                                                           
        sea.Descripcion Name                                                                                
        from SGF_Empleado_Area sea                                                                                 
    end                                                                                
    --Cargo                                                                                
    IF(@listId = 18)                                                                                
    begin                                                                                
      select                                                                                
        sec.CargoId Id,                                                                              
        sec.Descripcion Name                                                       
        from SGF_Empleado_Cargo sec                                                                                  
    end                                           
    --Local                                                                                
    IF(@listId = 19)                                                                                
    begin                                                          
        -- JEFE ZONAL                                                          
        IF(@rolId = 2)                                          
        BEGIN                                          
            SELECT LC.LocalId Id, LC.Descripcion Name                                                           
            FROM SGF_JefeZona JZ                                                          
            INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                          
            INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                          
            WHERE JefeZonaId = @empleadoId AND LC.esActivo = 1                                           
        END                                          
        --AGENTE CALL CENTER                                                          
        --ELSE IF(@rolId = 11)                                            
        --BEGIN           
        --    SELECT LC.LocalId Id, LC.Descripcion Name                                                          
        --    FROM SGF_Agente AG                                 
        --    INNER JOIN SGF_Agente_Local AGL ON AG.IdAgente = AGL.IdAgente                                                          
        --    INNER JOIN SGF_Local LC ON LC.LocalId = AGL.IdLocal                                                          
        --    WHERE AG.IdAgente = @empleadoId AND LC.esActivo = 1                                           
        --END                                                       
        -- Regional                                                          
        ELSE IF(@rolId = 52)                                           
        BEGIN                                               
            SELECT LC.LocalId Id, LC.Descripcion Name                                                          
            FROM SGF_JEFEREGIONAL JFR                                                 
            INNER JOIN SGF_ZONA ZN ON ZN.RegionZonaId = JFR.RegionId                                                          
            INNER JOIN SGF_LOCAL LC ON LC.ZonaId = ZN.ZonaId                                                           
            WHERE JFR.JefeRegionalId = @empleadoId  AND LC.esActivo = 1                                                
        END                                                  
        -- TODOS LOS LOCALES                                                          
        ELSE                     
        BEGIN                                                       
            SELECT                                                                                
            sl.LocalId Id,                                                                                
            sl.Descripcion Name                                      
            FROM                                                                              
            SGF_Local sl                                                        
            INNER JOIN SGF_Zona sz ON sl.ZonaId = sz.ZonaId                                                                    
            WHERE sz.ZonaId = CAST(@id AS INT)                                                                    
            OR 0 = CAST(@id AS INT) AND sl.esActivo = 1                                                                
        end                                          
    end                                          
    --Proveedores                                                            
    IF(@listId = 20)                                                                                
    begin                                                                                
        select p.ProveedorId Id,                                                                                
               p.RazonSocial Name                                                                                
        from SGF_Proveedor p                                
        where UPPER(p.RazonSocial) LIKE '%'+@id+'%'                                                                                
    end                                                                              
    --Tipo Rechazo                                                                              
    IF(@listId = 26)                                                             
    begin                                                                              
        select IdRechazo Id,                                                                              
               Descripcion Name                                                        
        from SGF_Rechazo r                                                                              
        where EstadoProcesoId = @id                                                                              
    end                                                   
    --Motivo Rechazo                                                                            
    IF(@listId = 27)                                                                   
    begin                                                                          
        Select IdMotivo Id,                                                                            
               Descripcion Name              
        from SGF_Motivo                                                                               
        where (IdRechazo=@id)                                                                            
    end                                                                       
    -- Asesor de Banco                                                           
    IF(@listId = 28)                                                                              
    begin                                               
        Select                                                                             
        sac.IdAsesor Id,                                                                            
        sac.Nombres Name                                                                             
        from SGF_AsesorBanco sac                                                                            
    end                                    
    -- Proveedores                                                                    
    IF(@listId = 29)                                            
    begin                            
        set @rolIds = (select top 1 su2.CargoId from SGF_USER su2 where su2.UserId = @rolId);                                          
        set @userId = (select top 1 su2.EmpleadoId from SGF_USER su2 where su2.UserId = @rolId);                                                                    
        -- Supervisor                                                
        IF(@rolIds = 29)                                                                    
        begin                                                                   
            Select DISTINCT top 15 spl.ProveedorLocalId Id,                                 
                                   sp3.RazonSocial +                                                                    
                                   ' /**/ ' +                                                                    
                                   sp3.DocumentoNum +                                                                    
                                   ' /**/ ' +                                                                    
                                   spl.NombreComercial +                                                             
                                   ' /**/ ' +                                                                    
                                   spl.Direccion Name                                                                           
            from SGF_Proveedor sp3                                                                    
            inner join SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                     
            where spl.IndicadorActivo  = 1 and                                                                    
                  spl.IdSupervisor = @userId and                                    
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') and                                            
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                  (spl.LocalId = @parameter or @parameter = 0)                                        
            group by spl.ProveedorLocalId,         
                     sp3.RazonSocial,sp3.DocumentoNum,                                                                    
                     spl.NombreComercial,spl.Direccion                                                                     
        end                                                        
  -- Jefe Zonal                                          
        ELSE IF(@rolIds = 2)                                                                    
        begin                                                                    
            set @zonaId = (select top 1 sjz.ZonaId from SGF_JefeZona sjz where sjz.JefeZonaId = @userId)                                                                     
            Select distinct top 15 spl.ProveedorLocalId Id,                                                                         
                                   sp3.RazonSocial +                                                                 
                                   ' /**/ ' +                                                           
             sp3.DocumentoNum +                                                                    
                                   ' /**/ ' +                                                                    
                                   spl.NombreComercial +                                                                    
                                  ' /**/ ' +                                                                    
                                   spl.Direccion Name                                                                   
            from SGF_Proveedor sp3                                                                    
            inner join SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                 
            where spl.IndicadorActivo  = 1 and                                                                    
                  spl.ZonaId = @zonaId and                                                                    
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') and                                                                    
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                 (spl.LocalId = @parameter or @parameter = 0)                                        
            group by spl.ProveedorLocalId,                                                                    
                     sp3.RazonSocial,sp3.DocumentoNum,                                                
                     spl.NombreComercial,spl.Direccion                                                                  
        end                                                 
        -- ADV                                                
        ELSE IF(@rolIds = 4)                                                                    
        begin                                          
            set @localId = (select top 1 adv.localId from SGF_ADV adv where adv.AdvId = @userId)                                          
            Select distinct top 15 spl.ProveedorLocalId Id,                                                                   
                                   sp3.RazonSocial +                                                                    
                                   ' /**/ ' +                                                                    
           sp3.DocumentoNum +                                                                    
                                   ' /**/ ' +                                                                    
                                   spl.NombreComercial +                                                                    
                                   ' /**/ ' +                                                                    
                                   spl.Direccion Name                                                                             
            from SGF_Proveedor sp3                                                                    
            inner join SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                 
            inner join SGF_Supervisor ss2 on ss2.IdSupervisor = spl.IdSupervisor                                                                     
            inner join SGF_ADV sa on sa.AdvId = ss2.AdvId                                          
            inner join SGF_Local lo on sa.LocalId = lo.LocalId                                          
            where spl.IndicadorActivo  = 1 and                                                                    
                  sa.AdvId = @userId and                                          
                  lo.LocalId = @localId and                                          
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') and                                                       
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                  (spl.LocalId = @parameter or @parameter = 0)                                        
            group by spl.ProveedorLocalId, sp3.RazonSocial,sp3.DocumentoNum,                                          
                     spl.NombreComercial,spl.Direccion                                        
        end                                                                    
        -- Call Center                                                
        ELSE IF (@rolIds = 11)                                         
        BEGIN                                                
            Select distinct top 15 prl.ProveedorLocalId Id,                                                                            
                                   pr.RazonSocial +                                                     
                                   ' /**/ ' +                                                                    
                                   pr.DocumentoNum +                                                                    
                                   ' /**/ ' +                                 
                                   prl.NombreComercial +                                                                    
                                   ' /**/ ' +                                       
                                   prl.Direccion Name                                                                             
            FROM SGF_Agente ag                                                
            INNER JOIN SGF_Agente_Local agl ON agl.IdAgente = ag.IdAgente                                                
            INNER JOIN SGF_ProveedorLocal prl ON prl.LocalId = agl.IdLocal                                                
            INNER JOIN SGF_Proveedor pr ON pr.ProveedorId = prl.ProveedorId                                                
            WHERE agl.IdAgente = @userId and                                                
                  prl.IndicadorActivo  = 1 and                                                                    
                  (prl.NombreComercial LIKE '%'+@id+'%' or pr.RazonSocial LIKE '%'+@id+'%' or pr.DocumentoNum LIKE '%'+@id+'%') and                                                                    
                  (prl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                  (prl.LocalId = @parameter or @parameter = 0)                                        
            group by prl.ProveedorLocalId,       
                     pr.RazonSocial,pr.DocumentoNum,                                                                    
                     prl.NombreComercial,prl.Direccion                                                  
        END                                                
        --Jefe Regional                                                
        ELSE IF (@rolIds = 52)                                                
        BEGIN                                
            set @regionId = (select top 1 sjr.RegionId from SGF_JefeRegional sjr where sjr.JefeRegionalId = @userId)                                                           
            Select distinct top 15 spl.ProveedorLocalId Id,                                                                         
                                   sp3.RazonSocial +                                                                 
                                   ' /**/ ' +                                                           
                                   sp3.DocumentoNum +                                                                    
                                   ' /**/ ' +                                                                    
                                   spl.NombreComercial +                                                                    
                                   ' /**/ ' +                                
                                   spl.Direccion Name                                                                           
            from SGF_Proveedor sp3                                                                    
            inner join SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                          
            INNER JOIN SGF_Zona ZN ON spl.ZonaId = ZN.ZonaId                                          
            INNER JOIN SGF_RegionZona srz ON srz.RegionZonaId = zn.RegionZonaId and srz.EsActivo = 1                                          
            where spl.IndicadorActivo  = 1 and                            
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') and                              
                  srz.RegionZonaId = @regionId and                                                                    
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                  (spl.LocalId = @parameter or @parameter = 0)                                        
            group by spl.ProveedorLocalId,                                                                    
                     sp3.RazonSocial,sp3.DocumentoNum,                                                                    
                     spl.NombreComercial,spl.Direccion                                                    
        END                                            
        -- IF(@rolIds != 4 and @rolIds != 2 and @rolIds != 29)                                                                    
        ELSE                                                
        begin                                              
            Select distinct top 15 spl.ProveedorLocalId Id,                                                  
                                   sp3.RazonSocial + ' /**/ ' + sp3.DocumentoNum + ' /**/ ' + spl.NombreComercial + ' /**/ ' + spl.Direccion Name          
            from SGF_Proveedor sp3                                                                    
            inner join SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                     
            where spl.IndicadorActivo  = 1 and                                                                    
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') and                                                                    
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) and                                        
                  (spl.LocalId = @parameter or @parameter = 0)                                        
            group by spl.ProveedorLocalId,                                                                    
                     sp3.RazonSocial,sp3.DocumentoNum,                                              
                     spl.NombreComercial,spl.Direccion                                                                     
        end                                          
    end                                                                      
    --Supervisor                                                                      
    IF(@listId = 30)                                                                              
    begin                                                        
        -- Opcion Todos                                                        
        IF (@parameter = 0)                                            
        BEGIN                                          
            -- Jefe Zonal                                                        
            IF (@rolId = 2)                                        
            BEGIN                                          
                SELECT SPV.IdSupervisor Id,                                                                            
                       SPV.Nombre + ' ' +                                                            
                       SPV.ApePaterno + ' ' +                                                                      
                       SPV.ApeMaterno Name                                                       
                FROM SGF_JefeZona JZ                                                          
                INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                          
                INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                         
                INNER JOIN SGF_Supervisor SPV ON SPV.LocalId = LC.LocalId            
                WHERE JZ.JefeZonaId = @empleadoId AND SPV.EsActivo = 1                                        
            END                                         
            -- Call Center                                                        
            ELSE IF (@rolId = 11)                                        
            BEGIN                                          
                SELECT SPV.IdSupervisor Id,                                                                            
                       SPV.Nombre + ' ' +                                                            
                       SPV.ApePaterno + ' ' +                                                     
                       SPV.ApeMaterno  Name                                
                FROM SGF_Agente AG                                                        
                INNER JOIN SGF_Agente_Local AGL ON AGL.IdAgente = AG.IdAgente                                                        
                INNER JOIN SGF_Supervisor SPV ON SPV.LocalId = AGL.IdLocal                                                        
                WHERE AG.IdAgente = @empleadoId  AND SPV.EsActivo = 1                                        
            END                                         
            -- Regional                                                        
            ELSE IF (@rolId = 52)                 
            BEGIN                                          
                SELECT SPV.IdSupervisor Id,                                            
                       SPV.Nombre + ' ' +                                                            
                       SPV.ApePaterno + ' ' +                                                 
                       SPV.ApeMaterno  Name                                                         
                FROM SGF_JefeRegional JFR                                                        
                INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                        
                INNER JOIN SGF_Supervisor SPV ON SPV.ZonaId = ZN.ZonaId                                                        
                WHERE JFR.JefeRegionalId = @empleadoId AND SPV.EsActivo = 1                           
            END                                         
            -- ADV                                                    
            ELSE IF (@rolId = 4)                                    
            BEGIN                                          
                SELECT ss.IdSupervisor Id,                                                                            
                       ss.Nombre + ' ' +                                                            
                       ss.ApePaterno + ' ' +                                                                      
                       ss.ApeMaterno  Name                                                 
                FROM SGF_Supervisor ss                                                              
                WHERE (advid=@empleadoId or @empleadoId=0) AND EsActivo = 1                                        
            END                                         
            ELSE                                          
       BEGIN                                          
                SELECT IdSupervisor Id,                                                                            
                       Nombre + ' ' +                                                            
                       ApePaterno + ' ' +                                                                      
                       ApeMaterno  Name                                                                    
                FROM SGF_Supervisor                                                         
                WHERE EsActivo = 1                                           
            END                                          
        END                                          
        ELSE                                          
        BEGIN                                          
            -- ADV                                                        
            IF (@rolId = 4)                                        
            BEGIN                                         
                SELECT ss.IdSupervisor Id,                                       
                       ss.Nombre + ' ' +                                                            
                       ss.ApePaterno + ' ' +                                                                      
                       ss.ApeMaterno  Name                                                                     
                FROM SGF_Supervisor ss                                                              
                WHERE (advid=@empleadoId or @empleadoId=0) AND EsActivo = 1                                        
            END                                         
            ELSE                                        
            BEGIN                                        
               SELECT IdSupervisor Id,                                                                            
                      Nombre + ' ' +                                                            
                      ApePaterno + ' ' +                                                                      
                      ApeMaterno  Name                                                                    
               FROM SGF_Supervisor                                                         
               WHERE (localId = @parameter OR @parameter = 0) AND EsActivo = 1                                        
            END                                         
        END                                          
    END                                          
    --Agencias                                                                          
    IF (@listId = 31)                                                                              
    begin                                                                      
        Select ac.AgenciaId Id,                                                                            
               ac.Descripcion Name                        
        from SGF_Agencia ac                                  
        WHERE ac.BancoId = @id AND                         
              ac.Activo = 1                        
    end                                                                        
    --Oficinas                                                                          
    IF(@listId = 32)                                                                           
    begin                                                               
        Select ofc.IdOficina Id,                                         
               ofc.Nombre Name,                                                                    
               ofc.CorreoA                                                                    
        from SGF_Oficina ofc                                  
        where (AgenciaId=@id) AND Activo = 1                                                                        
    end                                                                  
    --Tipo de Producto                                                                  
    IF(@listId = 33)                                                                  
    begin                                                                  
        Select pr.ParametroId Id,                                                                  
               pr.NombreLargo Name                                                                  
        from SGF_Parametro pr                                                                  
        where (DominioId = @id)                                                 
    end                              
    -- Giro                              
    IF(@listId = 34)                                                                  
    begin                          
        Select giroId Id,                                                                  
               Nombre Name                                                                  
        from SGF_Giro                                                                  
        where EsActivo = 1                                                                  
    end                          
    --Canal de Venta                          
    IF(@listId = 35)                          
    BEGIN                          
           select ParametroId Id,                          
                  NombreLargo Name                          
           from SGF_Parametro                           
           where DominioId = @id and                          
                 IndicadorActivo = 1 and                        
        (@rolId = 0 or ValorParam like '%/'+ ltrim(str(@rolId)) + '/%')                        
    END                    
    -- Lista de bancos de operadores                    
    IF(@listId = 36)                                                                            
    BEGIN                                                                             
        select BancoId Id,                                                                                
               Nombre Name                                                                                
        from SGB_Banco                    
        where Activo = 1                          
    END                
    IF(@listId = 37)                                              
    begin                
        select sp.ParametroId Id,                                                                                
               sp.NombreLargo Name                                                                                
        from SGF_Parametro sp                                                                                 
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                 
        where sd.DominioId = @id and sp.IndicadorActivo  = 1 and ((@rolId <> 2 and sp.ParametroId <> 3) or (@rolId = 2))  and ((@rolId <> 4 and sp.ParametroId <> 1) or (@rolId = 4))           
    end       
    IF(@listId = 39)                                                                            
    BEGIN                                                                    
        select sp.NombreLargo Id,                                                                                
            sp.NombreLargo Name                                                                                
        from SGF_Parametro sp                                                                                 
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                               
        where sd.DominioId = @id and sp.IndicadorActivo  = 1                                                   
    END     
    IF(@listId = 40)                                                                            
    BEGIN                                                                    
        select RegionZonaId Id,     
               Descripcion Name     
        from SGF_RegionZona     
  where EsActivo = 1     
    END 
	  IF(@listId = 41)                                                                            
    BEGIN                                                                    
        select    
  sp.ParametroId Id,                                                                                
            sp.NombreLargo Name                                                                                
        from SGF_Parametro sp                                                                                 
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                               
        where sd.DominioId = @id and sp.IndicadorActivo  = 1                             
    END    
end;