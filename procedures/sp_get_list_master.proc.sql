/*--------------------------------------------------------------------------------------                                                                                                                                                        
' Nombre          : [dbo].[sp_get_list_master]                                                                                                                                                                                                        
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LOS LOCALES                                                                                                                                                              
' Creado Por      :                                                                                                                                                                      
' Día de Creación :                                                                                                                                                                                                   
' Requerimiento   : SGC                                                                                                                                                                                                 
' Modificado por  : REYNALDO CAUCHE                                                                 
' Cambios  :                                                                 
  - 20/12/2022 - cristian silva - ORDER BY nombre en @listId = 30                                               
  - 25/01/2023 - cristian silva & richard angulo  - list 42 supervisor                                              
  - 26/01/2023 - cristian silva & richard angulo  - list 35 canal venta                            
  - 24/04/2023 - Francisco Lazaro - list 12,13,14 dpto prov dist por local                            
  - 30/05/2023 - Reynaldo Cauche - Para los distritos list 8, agregar el campo departamento                       
  - 13/06/2023 - Reynaldo Cauche - Cambiar la consulta para los locales (19)                     
  - 27/07/2023 - Reynaldo Cauche - Se agrego condicion en bancos (36) para que no muestre alfin              
  - 09/08/2023 - Reynaldo Cauche - Para los locales, rol = 2 se cambio la consulta      
  - 09/10/2023 - Reynaldo Cauche - Se agrego isActive = 1 para motivo rechazo (26)
  - develop-tracking - Reynaldo Cauche - Se agrego listId = 48 para listar los roles           
'--------------------------------------------------------------------------------------*/                                                                                                    
                                                                                                                             
ALTER PROCEDURE [dbo].[sp_get_list_master]                            
(@id varchar(10),                                                                                                                                                 
 @listId int,                                                                                                                                     
 @parameter int,                                                                                                                                     
 @rolId int,                                                                                                                           
 @empleadoId int)                                                                                                                                                 
as                                                                                                                                          
DECLARE @userId int                                                                                                                                     
DECLARE @localId int        
DECLARE @zonaId int                                                                         
DECLARE @regionId int                                      
DECLARE @rolIds int                                                          
BEGIN                    
  --Tipo Documento(1) --Grado Académico(2) --Parentesco(3) --Bancos(4)                                    
    --Nivel de Educación(5) --Procedencia(9) --Categoría Empleado(10)                                                                  
    --Tipo Pantalón(12) --Talla Camisa(13) --Modalidad(14) --Afp(15)                                                                              
    --Estado Civil(16) --Tipo Crédito(21) --IndepENDiente(22) --Formalidad(23)                                                                                
    --Sustento Ingreso(24) --Tipo Documento Adjunto(25) --Tipo Cambio Tckets(37) -- Estados tickets(38) -- Motivio Injustificacion (39)                                                                
    IF(@listId = 1 or @listId = 2 or @listId = 3 or @listId = 4 or                                                                                       
       @listId = 5 or @listId = 9 or @listId = 10 or @listId = 12 or                                                                                                 
       @listId = 13 or @listId = 14 or @listId = 15 or @listId = 16 or                                                                                                            
       @listId = 22 or @listId = 23 or @listId = 24 or @listId = 25 or                                                   
       @listId = 38)                                                                            
    BEGIN                                                                                                          
        SELECT sp.ParametroId [ID],                                                                           
               sp.NombreLargo [NAME]                                                                                                                 
        FROM SGF_Parametro sp                                                                                           
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                       
        WHERE sd.DominioId = @id AND sp.IndicadorActivo  = 1                                                                              
    END                                                                        
                                                                                                                                                  
    IF(@listId = 21)                                                                                                                                             
    BEGIN                                                                                                                                     
        SELECT sp.ParametroId [ID],                                                                                                                                                 
               sp.NombreLargo [NAME]                                                                                                                                                 
        FROM SGF_Parametro sp                                                                                                                                                  
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                                                
        WHERE sd.DominioId = @id AND sp.IndicadorActivo  = 1                                                                                                                                  
        ORDER BY sp.ValorEntero asc                                                                                     
 END                                  
                             
   --Departamento                                                                                                                                            
    IF(@listId = 6)                                                
    BEGIN                                                               
        SELECT concat(su.CodDpto,'0000') [ID],                                                                                                         
    su.Nombre [NAME]                                                                                     
        FROM SGF_UBIGEO su                           
        WHERE su.CodDist = '00' AND                                                        
           su.CodProv = '00'                                                                                                                        
    END                            
                            
    --Provincia                                    
    IF(@listId = 7)                                              
    BEGIN                                                          
        SELECT concat(su.CodDpto,su.CodProv,'00') [ID],                                       
               su.Nombre [NAME]                                                                
        FROM SGF_UBIGEO su                                           
        WHERE su.CodProv <> '00' AND                                                         
              su.CodDpto = left(@id,2) AND                                                              
              su.CodDist = '00'                                                                                                                                                 
    END                                
                             
    --Distrito                                                                    
    IF(@listId = 8)                                                                                   
     BEGIN                                                                            
         /*SELECT concat(su.CodDpto,su.CodProv,su.CodDist) [ID],                                                                               
                  su.Nombre [NAME]                                                                                                                               
         FROM SGF_UBIGEO su                                                                    
         WHERE su.CodDpto = left(@id,2) AND                                                                                                                                                 
               su.CodProv = right(left(@id,4),2)*/                                                                                      
         SELECT DIST.CodUbigeo [Id],                                                                                            
                IIF(LEN(@id) < 6, DPTO.Nombre + '-' + PROV.Nombre + '-' + DIST.Nombre, DIST.Nombre) [Name]                                                                            
         From SGF_UBIGEO DIST                                                                                                                                              
         OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                                                                                                              
                      WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV                       
         OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO DPTO                                                                                                                                              
            WHERE DPTO.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,2) + '0000') DPTO                                                                                              
         WHERE (LEN(@id) < 6 AND                         
          DIST.CodDpto <> 0 AND                        
          DIST.CodProv <> 00 AND                         
                DIST.CodDist <> 00) OR                  
               (LEN(@id) = 6 AND                        
       DIST.CodDpto = left(@id, 2) AND                                                                                                                                                 
     DIST.CodProv = right(left(@id, 4), 2) AND                           
             DIST.CodDist <> 00)                        
    END                             
                        
    --País                                                                                                                                             
    IF(@listId = 11)                                                    
    BEGIN                                                                                                                                 
        SELECT sp2.PaisId [ID],                     
        sp2.PaisDes [NAME]                                                                                                                       
        FROM SGF_Pais sp2                                                                                                                            
    END                                  
                             
    --Área                                                                                                                 
    IF(@listId = 17)                                                                                                           
    BEGIN                                                                                                                                                 
        SELECT                                                                                           
        sea.AreaId [ID],                                                                                                                                            
        sea.Descripcion [NAME]                                                                                              
       FROM SGF_Empleado_Area sea                                                      
    END                             
                             
    --Cargo                                                                                          
    IF(@listId = 18)                                                                                                        
    BEGIN                                                       
      SELECT                                                                                                         
        sec.CargoId [ID],                                                                                                                    
        sec.Descripcion [NAME]                                                                                         
        FROM SGF_Empleado_Cargo sec                                                                                                                                                   
    END                            
                            
    --Local                                                                 
    IF(@listId = 19)                                                                                                       
    BEGIN                                                                      
        -- JEFE ZONAL                                                                                                                           
        IF(@rolId = 2)                                                                                                           
        BEGIN            
            select LC.LocalId [ID], LC.Descripcion [NAME]                         
            FROM sgf_local as LC                       
            where RegionalId = @empleadoId and esActivo = 1                   
            -- SELECT LC.LocalId [ID], LC.Descripcion [NAME]                                                                                                          
            -- FROM SGF_JefeZona JZ                                                                                                           
            -- INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                                                                                           
            -- INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                                                                           
         -- WHERE JefeZonaId = @empleadoId AND LC.esActivo = 1                                        
            -- ORDER BY LC.Descripcion asc                                
        END                                                                                                                                                                                  
       ELSE IF(@rolId = 52)                                                                                                            
       BEGIN                                                            
           IF (@empleadoId=5)                                          
           BEGIN                                          
                SELECT LC.LocalId [ID],                             
                LC.Descripcion [NAME]                             
                FROM SGF_LOCAL LC                             
                WHERE  LC.esActivo = 1                             
                ORDER BY LC.Descripcion asc                                             
           END                                          
           ELSE                                            
           BEGIN                                                                                        
                declare @ValidRegion int  = (select rz.RegionZonaId from SGF_JefeRegional jr inner join SGF_RegionZona rz on rz.RegionZonaId = jr.RegionId where jr.JefeRegionalId   = @empleadoId )           
                --if(@ValidRegion = 6)           
                --begin           
                --    select LC.LocalId [ID], LC.Descripcion [NAME]                         
                --    FROM sgf_local as LC                       
                --    where  esActivo = 1              
                --end           
                --else   
    --if(@ValidRegion != 6)           
    --            begin           
                    select LC.LocalId [ID], LC.Descripcion [NAME]                         
                    FROM sgf_local as LC                       
                    where RegionalId = @empleadoId and esActivo = 1              
                --end                        
           END   
       END                                             
        ELSE IF(@rolId = 1)                                                                                                            
        BEGIN                                                                       
            SELECT LocalId [ID],                            
                   Descripcion [NAME]                                                                                                                           
            FROM  SGF_LOCAL                                                                                                                             
            WHERE esActivo = 1                                    
            ORDER BY descripcion asc                                
        END                                              
        -- TODOS LOS LOCALES              
        ELSE                                                                                      
        BEGIN                                                                                                                        
            -- SELECT sl.LocalId [ID],                                                       
            --        sl.Descripcion [NAME]                                                                                       
       -- FROM SGF_Local sl                                                                              
            -- INNER JOIN SGF_Zona sz ON sl.ZonaId = sz.ZonaId                                                                                                                                     
            -- WHERE sz.ZonaId = CAST(@id AS INT)                                                            
            -- OR 0 = CAST(@id AS INT) AND sl.esActivo = 1                                   
            -- ORDER BY sl.Descripcion asc                      
                    
            select  LocalId [ID],                             
                    Descripcion [NAME]                    
            from sgf_local                    
            where esActivo = 1                    
            ORDER BY Descripcion asc                  
        END                                                       
    END                              
                             
    --Proveedores                                                                                                                             
    IF(@listId = 20)                                                                                    
    BEGIN                                                                                                        
        SELECT p.ProveedorId [ID],                                                                                                      
       p.RazonSocial [NAME]                                                                                                                                                 
        FROM SGF_Proveedor p                                                                                            
        WHERE UPPER(p.RazonSocial) LIKE '%'+@id+'%'                                                                                                                                                 
    END                             
                             
    --Tipo Rechazo                                                                                                                
    IF(@listId = 26)                                                                                             
    BEGIN                                                                                                                                               
        SELECT IdRechazo [ID],                                  
               Descripcion [NAME]                                  
        FROM SGF_Rechazo r                                                                                                                                               
        WHERE EstadoProcesoId = @id and IsActive = 1                                              
    END                              
                             
    --Motivo Rechazo                                                                                
    IF(@listId = 27)                                  
    BEGIN                                                                                                                                           
        SELECT IdMotivo [ID],                                                                                                                                             
               Descripcion [NAME]                                                                               
        FROM SGF_Motivo                                                                                                                  
        WHERE (IdRechazo=@id)                                             
    END                               
                             
    -- Asesor de Banco                                     
    IF(@listId = 28)                                                       
    BEGIN                                                                                                                
        SELECT sac.IdAsesor [ID],                                                                                                                                 
        sac.Nombres [NAME]                                                                                                                    
        FROM SGF_AsesorBanco sac                                                                              
    END                                    
                             
    -- Proveedores                                                                                                                                     
    IF(@listId = 29)                                                                 
    BEGIN                        
        SET @rolIds = (SELECT TOP 1 su2.CargoId FROM SGF_USER su2 WHERE su2.UserId = @rolId);                                                              
        SET @userId = (SELECT TOP 1 su2.EmpleadoId FROM SGF_USER su2 WHERE su2.UserId = @rolId);                             
                              
        -- Supervisor                                                                                        
        IF(@rolIds = 29)                                                                       
        BEGIN                                                                                                                                    
            SELECT DISTINCT TOP 15 spl.ProveedorLocalId [ID],                                                                                                  
                       sp3.RazonSocial +                                                                                                                                     
                                   ' /**/ ' +                                                                                                                                     
                                   sp3.DocumentoNum +                                                                                       
                                   ' /**/ ' +                                                                                                                                     
                                   spl.NombreComercial +                                                                                              
                                   ' /**/ ' +                                                                                                                                     
                                   spl.Direccion [NAME]                                                                                     
            FROM SGF_Proveedor sp3                                                                                                
            INNER JOIN SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                                                                                      
            WHERE spl.IndicadorActivo  = 1 AND                                                                                                                                     
                  spl.IdSupervisor = @userId AND                                                                       
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') AND                                                                                                          
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) AND                                                                                                         
                  (spl.LocalId = @parameter or @parameter = 0)                                                                                                         
            GROUP BY spl.ProveedorLocalId,                                                                 
                     sp3.RazonSocial,sp3.DocumentoNum,                                                                                                                                     
                     spl.NombreComercial,spl.Direccion                                                                                                                                      
        END                                                                      
        -- Jefe Zonal                                                                                                           
        ELSE IF(@rolIds = 2)                                                                                                                               
        BEGIN                                                                                                      
            SET @zonaId = (SELECT TOP 1 sjz.ZonaId FROM SGF_JefeZona sjz WHERE sjz.JefeZonaId = @userId)                              
                               
            SELECT DISTINCT TOP 15 spl.ProveedorLocalId [ID],                                                             
                                   sp3.RazonSocial +                                                                 
                                   ' /**/ ' +                          
                                   sp3.DocumentoNum +                                                                                                                                     
          ' /**/ ' +                                                                                                                                     
                                   spl.NombreComercial +                                                                                   
                                  ' /**/ ' +                                                                                                                                     
                       spl.Direccion [NAME]                                                                                                                                    
            FROM SGF_Proveedor sp3                                                                                                          
            INNER JOIN SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                                                                                  
            WHERE spl.IndicadorActivo  = 1 AND                                                                                     
                  spl.ZonaId = @zonaId AND                                                                                                                                     
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') AND                                                                                    
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) AND                                                               
                  (spl.LocalId = @parameter or @parameter = 0)                                                                                                         
            GROUP BY spl.ProveedorLocalId,                                      
                     sp3.RazonSocial,sp3.DocumentoNum,                                             
                     spl.NombreComercial,spl.Direccion                                                                                        
        END                     
        -- ADV                                                                                                            
        ELSE IF(@rolIds = 4)                                   
        BEGIN                                                                                                               
            SET @localId = (SELECT TOP 1 adv.localId FROM SGF_ADV adv WHERE adv.AdvId = @userId)                        
                                
            SELECT DISTINCT TOP 15 spl.ProveedorLocalId [ID],                                                                                                                         
                                   sp3.RazonSocial +                                                        
                       ' /**/ ' +                                                                                                        
                                   sp3.DocumentoNum +                                                                                                                                         
              ' /**/ ' +                                                                                                                                   
                                   spl.NombreComercial +                                                                  
                                   ' /**/ ' +                                                                                                                                         
                                   spl.Direccion [NAME]                                                  
            FROM SGF_Proveedor sp3                                                                                                                                         
            INNER JOIN SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                                                     
            INNER JOIN SGF_Supervisor ss2 on ss2.IdSupervisor = spl.IdSupervisor                                                                                                                        
            INNER JOIN SGF_ADV sa on sa.AdvId = ss2.AdvId                                                                                                               
            INNER JOIN SGF_Local lo on sa.LocalId = lo.LocalId                                                                                                               
            WHERE spl.IndicadorActivo  = 1 AND                                                                                                         
                  sa.AdvId = @userId AND                                                                                                               
                  lo.LocalId = @localId AND                                                                                                               
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') AND                                                                                                                         
  
   
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0)               
      --AND (spl.LocalId = @parameter or @parameter = 0)                                                                       
            GROUP BY spl.ProveedorLocalId, sp3.RazonSocial,sp3.DocumentoNum,                                                                                                               
                     spl.NombreComercial,spl.Direccion                                                                                                             
        END                                                                                                               
        -- Call Center       
        ELSE IF (@rolIds = 11)                                                                                                          
        BEGIN                                            
            SELECT DISTINCT TOP 15 prl.ProveedorLocalId [ID],                                                                                                                                             
                                   pr.RazonSocial +                                                                                                                      
                     ' /**/ ' +                                                       
                                   pr.DocumentoNum +                                                                                                                                     
                   ' /**/ ' +                                                                                                  
                                   prl.NombreComercial +                                                                                                 
                               ' /**/ ' +                                                                   
                                   prl.Direccion [NAME]                                                                                                                                              
            FROM SGF_Agente ag                                                                                          
            INNER JOIN SGF_Agente_Local agl ON agl.IdAgente = ag.IdAgente                                                                              
            INNER JOIN SGF_ProveedorLocal prl ON prl.LocalId = agl.IdLocal                                                                                         
            INNER JOIN SGF_Proveedor pr ON pr.ProveedorId = prl.ProveedorId                                                                                                              
            WHERE agl.IdAgente = @userId AND                                                                                                                 
                  prl.IndicadorActivo  = 1 AND                                                                                    
                  (prl.NombreComercial LIKE '%'+@id+'%' or pr.RazonSocial LIKE '%'+@id+'%' or pr.DocumentoNum LIKE '%'+@id+'%') AND                                                                 
                  (prl.idSupervisor = @empleadoId or @empleadoId = 0) AND                                                                                                         
                  (prl.LocalId = @parameter or @parameter = 0)                                                                              
            GROUP BY prl.ProveedorLocalId,                                                                        
                     pr.RazonSocial,pr.DocumentoNum,                                                                                                                                     
                     prl.NombreComercial,prl.Direccion                                                                                                                   
        END                                                                                                                 
        --Jefe Regional                                                                                                                 
        ELSE IF (@rolIds = 52)                                                                                                                     
        BEGIN                 
               
            --SET @regionId = (SELECT TOP 1 sjr.RegionId FROM SGF_JefeRegional sjr WHERE sjr.JefeRegionalId = @userId)                  
             
             
            SELECT DISTINCT TOP 15 spl.ProveedorLocalId [ID],          
                                   sp3.RazonSocial +                                                                                                                                      
                                   ' /**/ ' +                                                                           
                                   sp3.DocumentoNum +                                                                                                   
                                   ' /**/ ' +                                                 spl.NombreComercial +                    
                                   ' /**/ ' +                           
                                   spl.Direccion [NAME]                                                                                                                                                
            FROM SGF_Proveedor sp3                                                                                                  
            INNER JOIN SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                     
   --         INNER JOIN SGF_Zona ZN ON spl.ZonaId = ZN.ZonaId                                                                                      
   --INNER JOIN SGF_RegionZona srz ON srz.RegionZonaId = zn.RegionZonaId AND srz.EsActivo = 1                                                                                                               
            WHERE spl.IndicadorActivo  = 1 AND                                                                               
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') AND                                                                                                   
                  --srz.RegionZonaId = @regionId AND                                                                                                                                         
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) AND                                                                                                             
                  (spl.LocalId = @parameter or @parameter = 0)                                                                                                             
            GROUP BY spl.ProveedorLocalId,                                                                                                                                         
                     sp3.RazonSocial,sp3.DocumentoNum,                                                                                                       
                     spl.NombreComercial,spl.Direccion                
                   
             
        END                                                                                                             
        -- IF(@rolIds != 4 AND @rolIds != 2 AND @rolIds != 29)                                                                           
        ELSE                             
        BEGIN                                                                                                               
            SELECT DISTINCT TOP 15 spl.ProveedorLocalId [ID],                                                                                                                   
                                   sp3.RazonSocial + ' /**/ ' + sp3.DocumentoNum + ' /**/ ' + spl.NombreComercial + ' /**/ ' + spl.Direccion [NAME]                                                                           
            FROM SGF_Proveedor sp3                                                                                           
            INNER JOIN SGF_ProveedorLocal spl on spl.ProveedorId = sp3.ProveedorId                                                                                                                                      
  WHERE spl.IndicadorActivo  = 1 AND                                                                                                                                     
                  (spl.NombreComercial LIKE '%'+@id+'%' or sp3.RazonSocial LIKE '%'+@id+'%' or sp3.DocumentoNum LIKE '%'+@id+'%') AND                                      
                  (spl.idSupervisor = @empleadoId or @empleadoId = 0) AND                                                                                                         
   (spl.LocalId = @parameter or @parameter = 0)                                                 
            GROUP BY spl.ProveedorLocalId,                                                                   
                     sp3.RazonSocial,sp3.DocumentoNum,                                                        
                     spl.NombreComercial,spl.Direccion                                                                                                               
        END                                                                                     
    END                                                
    --Supervisor                             
    IF(@listId = 30)                                                                                        
    BEGIN                                                            
        -- Opcion Todos                                                                                                                     
        IF (@parameter = 0)                                                                                                   
        BEGIN                                                                                                           
            -- Jefe Zonal                                
            IF (@rolId = 2)                                                                                                         
         BEGIN                                                                                                           
         SELECT SPV.IdSupervisor [ID],                       
                       SPV.Nombre + ' ' +                                                                                                                             
                       SPV.ApePaterno + ' ' +                                                                                                                                       
                       SPV.ApeMaterno [NAME]                                                                                                           
                FROM SGF_JefeZona JZ                                                                                                                  
                INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                                                                                           
                INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                                                                          
                INNER JOIN SGF_Supervisor SPV ON SPV.LocalId = LC.LocalId                                             
                WHERE JZ.JefeZonaId = @empleadoId AND SPV.EsActivo = 1                                                                                                         
            END                                                                                         
            -- Call Center                                                                                                                         
         ELSE IF (@rolId = 11)                                                                                                         
            BEGIN                                                                                                           
                SELECT SPV.IdSupervisor [ID],                                           
                       SPV.Nombre + ' ' +                                                                             
                       SPV.ApePaterno + ' ' +                                                                                                             
                       SPV.ApeMaterno  [NAME]                                                                                                 
                FROM SGF_Agente AG                                                                               
INNER JOIN SGF_Agente_Local AGL ON AGL.IdAgente = AG.IdAgente                                                                                                                     
                INNER JOIN SGF_Supervisor SPV ON SPV.LocalId = AGL.IdLocal                                                                                                     
                WHERE AG.IdAgente = @empleadoId  AND SPV.EsActivo = 1                                    
            END                                                      
            -- Regional                                                                                                                         
            ELSE IF (@rolId = 52)                                    
            BEGIN                                                                                              
                SELECT SPV.IdSupervisor [ID],            
                       SPV.Nombre + ' ' +                                                                                                                             
                       SPV.ApePaterno + ' ' +                                                                                                                  
                       SPV.ApeMaterno  [NAME]                                                                                                                          
                FROM SGF_JefeRegional JFR                
                INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                                                                                     
                INNER JOIN SGF_Supervisor SPV ON SPV.ZonaId = ZN.ZonaId                                                                                                                         
                WHERE JFR.JefeRegionalId = @empleadoId AND SPV.EsActivo = 1                                            
                                              
                                              
                                                                                              
            END                                                                                           
            -- ADV                                                                                                                     
            ELSE IF (@rolId = 4)                                                                                                     
            BEGIN                                                                                             
                SELECT ss.IdSupervisor [ID],                                                                                                                                             
                       ss.Nombre + ' ' +                                                               
                       ss.ApePaterno + ' ' +                                                                                                                                       
                       ss.ApeMaterno  [NAME]                                                                    
                FROM SGF_Supervisor ss                                                                                                                               
                WHERE (advid=@empleadoId or @empleadoId=0) AND EsActivo = 1                                                                         
            END                                                                           
            ELSE                                                                                                        
            BEGIN                                                                                                           
                SELECT IdSupervisor [ID],                                                                                                                   
                       Nombre + ' ' +              
                 ApePaterno + ' ' +                                                                                                                                       
                       ApeMaterno  [NAME]                                        
                FROM SGF_Supervisor                                                                         
                WHERE EsActivo = 1                                                         
                ORDER BY nombre asc                                                              
            END                                                                                            
        END                          
        ELSE                                                                                                           
       BEGIN                     
            -- ADV                                 
           IF (@rolId = 4)                                                                                                         
            BEGIN                                                                                                          
                SELECT ss.IdSupervisor [ID],                                                                                             
                       ss.Nombre + ' ' +                                                                                                                             
                       ss.ApePaterno + ' ' +                                                                               
                       ss.ApeMaterno  [NAME]                                      
           FROM SGF_Supervisor ss                                                                                                                               
                WHERE (advid=@empleadoId or @empleadoId=0) AND EsActivo = 1                                                                             
            END                                                                        
            ELSE                                                                                 
            BEGIN                                                                                                         
               SELECT IdSupervisor [ID],                                                                                                                                             
                      Nombre + ' ' +                                                                                                                             
                      ApePaterno + ' ' +                                                                                                            
                      ApeMaterno  [NAME]                                                                                                                                     
               FROM SGF_Supervisor                           
               WHERE (localId = @parameter OR @parameter = 0) AND EsActivo = 1                                                                                                         
            END                                                        
   END           
    END                                   
                             
    --Agencias                                                                                                                                 
    IF (@listId = 31)                                                                                                                                               
    BEGIN                                                                                                                                       
        SELECT ac.AgenciaId [ID],                                   
               ac.Descripcion [NAME]                                                                     
        FROM SGF_Agencia ac                                                                                                   
        WHERE ac.BancoId = @id AND                                                                                  
              ac.Activo = 1                                                           
        ORDER BY ac.Descripcion                                                           
    END                                   
                             
    --Oficinas                                               
    IF(@listId = 32)               
    BEGIN                                                                                         
        SELECT ofc.IdOficina [ID],                                                                         
               ofc.Nombre [NAME],                          
               ofc.CorreoA                                                                                                                                     
        FROM SGF_Oficina ofc                                                                                      
        WHERE (AgenciaId=@id) AND Activo = 1                                                          
        ORDER BY ofc.Nombre                                                          
    END                                 
                             
    --Tipo de Producto                                                           
    IF(@listId = 33)                                                                                             
    BEGIN                                                                                                                                   
        SELECT pr.ParametroId [ID],                                                                                                       
               pr.NombreLargo [NAME]                                                                                                                                   
        FROM SGF_Parametro pr                                                                                             
        WHERE (DominioId = @id)                        
    END                                 
                             
    -- Giro                                                                                               
    IF(@listId = 34)                                                                                                         
    BEGIN                                                                                           
        SELECT giroId [ID],                                                                                                                                   
               Nombre [NAME]                                                           
        FROM SGF_Giro                                                                                                             
        WHERE EsActivo = 1                                                                                                                       
    END                                 
                             
    --Canal de Venta                                                                                            
    IF(@listId = 35)                                                     
    BEGIN                                                                
        IF(@rolId = 29 or @rolId = 52 or @rolId = 2) -- movil                                              
        BEGIN                                              
            SELECT ParametroId [ID],                                                                                 
                   NombreLargo [NAME]                                                                                       
            FROM SGF_Parametro                                                                                        
            WHERE DominioId = @id AND                                                 
                  IndicadorActivo = 1                                               
        END                                              
        ELSE                                              
        BEGIN --web                                              
            SELECT ParametroId [ID],                                                                                       
                   NombreLargo [NAME]                                                                                       
            FROM SGF_Parametro                                                                                        
            WHERE DominioId = @id AND                                                                          
      IndicadorActivo = 1 AND                                                                                     
                  (@rolId = 0 or ValorParam like '%/'+ ltrim(str(@rolId)) + '/%')             
        END                                                                                     
    END                                  
                             
    -- Lista de bancos de operadores                                                                                  
    IF(@listId = 36)                                                                                                                        
    BEGIN                      
     DECLARE @XRolId INT = ISNULL((SELECT CargoId FROM SGF_USER WHERE UserId = @EmpleadoId), 0);    
      
     DECLARE @XRegionZonaId INT = ISNULL(IIF(@XRolId != 52, 0, (SELECT RegionZonaId FROM SGF_User US               
                                                                   LEFT JOIN SGF_JefeRegional JR ON JR.JefeRegionalId = US.EmpleadoId               
                                                                   LEFT JOIN SGF_RegionZona RZ ON RZ.RegionZonaId = JR.RegionId               
                                                                WHERE US.UserId = @EmpleadoId)), 0)       
      
     SELECT BancoId [ID],                                                                                                                               
     Nombre [NAME]                                                                                                                                                 
     FROM SGB_Banco                                  
     -- El rolId lo uso como si fuera 1 o 0, es para diferenciar en que vista va a mostrar el banco Alfin, si es uno no lo muestra, si es cero si muestra             
     WHERE Activo = 1  AND              
     ((@XRolId in (4, 11, 1, 56,48) or (@XRolId = 52 and @XRegionZonaId in (6))) or              
     ((@XRolId not in (4, 11, 1, 56,48) and not (@XRolId = 52 and @XRegionZonaId in (6)))))     
      
    END                   
                             
    IF(@listId = 37)                                          
    BEGIN                                                           
        SELECT sp.ParametroId [ID],                                                                      
               sp.NombreLargo [NAME]                                                                                                                                                 
        FROM SGF_Parametro sp                                                              
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                                
        WHERE sd.DominioId = @id AND                             
        sp.IndicadorActivo  = 1 AND                             
        ((@rolId <> 2 AND sp.ParametroId <> 3) or (@rolId = 2)) AND                             
        ((@rolId <> 4 AND sp.ParametroId <> 1) or (@rolId = 4))                                                      
    END                              
                             
    IF(@listId = 39)                                                                                
    BEGIN                                                                                                        
        SELECT sp.NombreLargo [ID],                                                                                                                                      
               sp.NombreLargo [NAME]                                                                                                                                                 
        FROM SGF_Parametro sp                                                
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                                                
        WHERE sd.DominioId = @id AND sp.IndicadorActivo  = 1                                                     
    END                             
                             
    IF(@listId = 40)                                                          
    BEGIN                                                                                                                           
        SELECT RegionZonaId [ID],                                                                 
               Descripcion [NAME]                                         
        FROM SGF_RegionZona                                                                      
        WHERE EsActivo = 1                                                                      
    END                             
                             
    IF(@listId = 41)                                                                                                                                             
    BEGIN                                                                                                                                     
        SELECT sp.ParametroId [ID],                                                                                            
               sp.NombreLargo [NAME]                                                                                      
        FROM SGF_Parametro sp                                                                                                                                  
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                                                
        WHERE sd.DominioId = @id AND sp.IndicadorActivo  = 1                                                
    END                                         
                                   
    IF(@listId = 42)                                                                
    BEGIN                                    
        DECLARE @var int = iIF(@id='',0,convert(int, @id));                                  
                
        IF (@rolId = 1)                                    
        BEGIN                            
            SELECT IdSupervisor [ID],                                                                
                   (Nombre + ' ' + ApePaterno + ' ' + ApeMaterno) [NAME]                                                                 
            FROM SGF_Supervisor                               
            WHERE esActivo= 1 AND (LocalId = @var   or @var =0)                                
            ORDER BY Nombre asc                                      
        END                                   
                                  
        IF(@rolId = 52)                                  
        BEGIN                                                 
            DECLARE @RegionZonaid int                                             
            SET @RegionZonaid = (SELECT TOP 1 RegionId FROM SGF_JefeRegional WHERE JefeRegionalId  =@empleadoId )                                                  
                                        
            SELECT su.IdSupervisor [ID],                                                                
                   (su.Nombre+' '+su.ApePaterno+' '+su.ApeMaterno) [NAME]                                                       
     FROM SGF_Supervisor su                                                   
            INNER JOIN SGF_local l on l.LocalId = su.LocalId                                                      
            INNER JOIN SGF_zona z on z.ZonaId = l.ZonaId                                             
            INNER JOIN sgf_regionzona r on r.RegionZonaId=z.RegionZonaId                                                      
            WHERE su.esActivo= 1                                                        
            AND r.RegionZonaId=@RegionZonaid                                                      
            AND (su.LocalId=@var   or @var =0)                                        
            ORDER BY su.Nombre asc                                      
        END                             
                                                    
        IF(@rolId = 2)                 
        BEGIN                                                
            DECLARE @JefezonaId int                                                  
            SET @JefezonaId = (SELECT TOP 1 JefeZonaId FROM SGF_JefeZona WHERE JefeZonaId = @empleadoId )                                                   
                                        
            SELECT su.IdSupervisor [ID],                                               
                   (su.Nombre+' '+su.ApePaterno+' '+su.ApeMaterno) [NAME]                               
            FROM SGF_Supervisor su                                                           
            INNER JOIN SGF_local l on l.LocalId = su.LocalId                                                        
            INNER JOIN SGF_zona z on z.ZonaId = l.ZonaId                                                  
            INNER JOIN sgf_jefezona jf on jf.zonaid=z.Zonaid                                                  
            WHERE su.esActivo= 1                                                          
            AND jf.jefezonaid = @JefezonaId                                                       
            AND (su.LocalId =@var   or @var =0)                                           
         ORDER BY su.Nombre asc                                      
        END                                      
    END                                    
                                   
    IF(@listId = 43)                                                                                       
    BEGIN                                                                                                                                     
        SELECT sp.ParametroId [ID],                                                    
               sp.NombreLargo [NAME]                                                          
        FROM SGF_Parametro sp                                                                                                                                  
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                                                                
        WHERE sd.DominioId = @id AND                             
        sp.IndicadorActivo  = 1                                                
    END                            
                             
    --Departamento por Local                            
    IF(@listId = 44)                                                                                                           
    BEGIN                                                       
        SELECT DISTINCT concat(DPTO.CodDpto,'0000') [ID],                            
                       DPTO.Nombre [NAME]                            
        from SGF_UBIGEO DPTO                            
        INNER JOIN SGF_ProveedorLocal PL on DPTO.CodUbigeo = LEFT(PL.Ubigeo, 2) + '0000'                                                      
    END                            
              
    --Provincia por Local                            
    IF(@listId = 45)                                              
    BEGIN                                                                                                                      
        SELECT DISTINCT concat(PROV.CodDpto,PROV.CodProv,'00') [ID],                                       
                       PROV.Nombre [NAME]                            
        FROM SGF_UBIGEO PROV                            
        INNER JOIN SGF_ProveedorLocal PL on PROV.CodUbigeo = LEFT(PL.Ubigeo, 4) + '00'                            
        WHERE PROV.CodDpto = LEFT(@id, 2)                                                              
    END                                
                             
    --Distrito por Local                            
    IF(@listId = 46)                                                                                   
    BEGIN                            
        SELECT DISTINCT DIST.CodUbigeo [ID],                                                                                            
                        DIST.Nombre [NAME]                            
        FROM SGF_UBIGEO DIST                                                                                                                                              
        OUTER APPLY (select Nombre from SGF_UBIGEO PROV                                                                                                                    
                     where PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo, 1, 4) + '00') PROV                             
        INNER JOIN SGF_ProveedorLocal PL on DIST.CodUbigeo = PL.Ubigeo                            
        WHERE DIST.CodDpto = left(@id, 2) AND                        
              DIST.CodProv = right(left(@id, 4), 2)                                                                                                                   
    END                   
   --destino credito en crear y edit credito                           
    IF(@listId = 47)                                                                                   
    BEGIN                            
        select ParametroId[ID],             
               NombreLargo [NAME]                  
        from SGF_Parametro where DominioId = 146 and IndicadorActivo = 1                                                                                                                  
    END     
    --Lista de Roles               
    IF(@listId = 48)                                                                                   
    BEGIN                            
        select RolId[ID],             
               RolDes [NAME]                  
        from SGF_Rol where IsActive = 1                                                                                                                 
    END                        
END 