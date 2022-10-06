/*--------------------------------------------------------------------------------------                                                                                                                   
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_L]                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA LISTA DE CREDITOS                                                     
' Creado Por      : REYNALDO CAUCHE                                                                                               
' Día de Creación : 18-12-2021                                                                                                                                
' Requerimiento   : SGC                                                                                                                             
' cambios  :      
 - 01-03-2022  REYNALDO CAUCHE     
 - 07-09-2022  cristian silva - add @expedienteCredito 
 - 12-09-2022  cristian silva - modify: convert @expedienteCredito to expedienteId linea 40 
'                                                                                                                        
'--------------------------------------------------------------------------------------*/                                                                       
                                                                   
CREATE PROCEDURE SGC_SP_ExpedienteCredito_L                                  
(@EstadoProcesoId int,                                                                           
 @Pagina int,                                                                           
 @Tamanio int,                                                                           
 @DocumentoNum varchar(11),                                                                           
 @Nombres varchar(100),                                                                           
 @LocalId int,                                                                           
 @ZonalId int,                                                                           
 @UserId int,                                                                           
 @CargoId int,                                                   
 @EnObservacion bit,                                                 
 @SupervisorId int,                                       
 @TodosEstado bit,                               
 @TodosSupervisor int,                              
 @Mes int,                             
 @Anio int,                       
 @CanalVentaId int = 0,                 
 @BancoId int = 0,      
 @ExpedienteCredito varchar(11),      
 @Success INT OUTPUT)                                                                           
as                                                                           
    declare @AD INT                                                                           
    declare @SUPERVISOR INT                                                                           
    declare @JEFEZONAL INT                                                           
    declare @PROVEEDOR INT                                                       
    declare @EMPLEADOID INT      
 declare @expedienteId INT   
begin                                                                           
    SET @AD = (SELECT isnull(sa.AdvId ,0) FROM SGF_USER su INNER JOIN SGF_ADV sa on sa.AdvId = su.EmpleadoId where su.UserId = @UserId)                                                                           
    SET @SUPERVISOR = (SELECT isnull(ss.IdSupervisor ,0) FROM SGF_USER su INNER JOIN SGF_Supervisor ss on ss.IdSupervisor = su.EmpleadoId where su.UserId = @UserId)                                                                           
    SET @JEFEZONAL = (SELECT isnull(sjz.JefeZonaId ,0) FROM SGF_USER su INNER JOIN SGF_JefeZona sjz on sjz.JefeZonaId = su.EmpleadoId where su.UserId = @UserId)                                                        
    SET @EMPLEADOID = (SELECT isnull(EmpleadoId ,0) FROM SGF_USER where UserId = @UserId)          
 set @expedienteId = convert(int,@ExpedienteCredito)   
                                     
    -- ADV                                                 
    IF(@CargoId = 4)                               
    BEGIN                                                       
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                        
    FROM SGF_ExpedienteCredito EC                            
     INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                    
     INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
     INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
    WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                      
     AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                      
     AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                      
     AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                      
     --AND (EC.AdvId = @AD or (ISNULL(EC.AdvId, 0) = 0 and EC.ExpedienteCreditoLocalId = (select X.LocalId from SGF_ADV X where X.AdvId = @AD)))             
     AND (EC.AdvId = @AD)         
     AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
     AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                              
     AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
     AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
     AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
     AND (EC.BancoId = @BancoId OR @BancoId = 0)     
     AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)       
   );                             
                                  
   SELECT EC.ExpedienteCreditoId as Id,                                                          
    P.DocumentoNum as Documento,                                                                           
    UPPER(P.Nombre) Nombre,                                                   
    UPPER(P.ApePaterno) ApePaterno,                                                                           
    UPPER(P.ApeMaterno) ApeMaterno,                                                                     
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                           
    EC.FechaAgenda,                         
    EC.FechaActua                         
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                     
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                     
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)          
    AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
    AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor         
    --AND (EC.AdvId = @AD or (ISNULL(EC.AdvId, 0) = 0 and EC.ExpedienteCreditoLocalId = (select X.LocalId from SGF_ADV X where X.AdvId = @AD)))         
    AND (EC.AdvId = @AD)         
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)         
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)       
   ORDER BY EC.FechaActua DESC        
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                
   END                                                    
                                     
    -- SUPERVISOR                                            
    ELSE IF(@CargoId = 29)                                                   
    BEGIN                                                   
       SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                     
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                             
    AND P.IdSupervisor = @SUPERVISOR                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)       
   );                           
                           
   SELECT EC.ExpedienteCreditoId as Id,                                                                           
    P.DocumentoNum as Documento,                                                                           
    UPPER(P.Nombre) Nombre,                                                     
    UPPER(P.ApePaterno) ApePaterno,                                                                           
    UPPER(P.ApeMaterno) ApeMaterno,                                                                           
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                           
    EC.FechaAgenda,                         
    EC.FechaActua                         
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                        
    AND P.IdSupervisor = @SUPERVISOR                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                 
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)        
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)       
   ORDER BY EC.FechaActua DESC                                                            
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                    
   END                                                   
                                     
    -- ESTABLECIMIENTO                                                 
    ELSE IF(@CargoId = 26)                                                   
    BEGIN                                                   
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                     
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                 
    INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                         
    AND PL.ProveedorLocalId = @EMPLEADOID                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
   );                           
                           
  SELECT EC.ExpedienteCreditoId as Id,                                                                           
   P.DocumentoNum as Documento,                                                                           
   UPPER(P.Nombre) Nombre,                                                     
   UPPER(P.ApePaterno) ApePaterno,                                                                           
   UPPER(P.ApeMaterno) ApeMaterno,                                                                           
   E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                           
   EC.FechaAgenda,                         
   EC.FechaActua                         
  FROM SGF_ExpedienteCredito EC                                                      
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                 
   INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId           
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
  WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
   AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
   AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
   AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                         
   AND PL.ProveedorLocalId = @EMPLEADOID                             
   AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
   AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
   AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
   AND (EC.BancoId = @BancoId OR @BancoId = 0)         
   AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)       
  ORDER BY EC.FechaActua DESC                                                            
   OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                     
  END                                                 
                                     
     -- JEFE ZONAL                                                 
     ELSE IF(@CargoId = 2)                                                 
     BEGIN                                                 
         SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                     
    FROM SGF_JefeZona JZ                                   
     INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                      
     INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                   
     INNER JOIN SGF_ExpedienteCredito EC ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                      
     INNER JOIN SGF_Persona P on P.PersonaId=EC.TitularId                                                      
     INNER JOIN SGF_Parametro E on E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
     INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
    WHERE JZ.JefeZonaId = @EMPLEADOID                                                  
     AND LC.esActivo = 1                                                   
     AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
     AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
     AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
     AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                   
     AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                 
     AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
     AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
     AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
     AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
     AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
     AND (EC.BancoId = @BancoId OR @BancoId = 0)     
     AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
    );      
        
                           
   SELECT EC.ExpedienteCreditoId as Id,                                                                           
    P.DocumentoNum as Documento,                                                                           
    UPPER(P.Nombre) Nombre,                                                     
    UPPER(P.ApePaterno) ApePaterno,               
    UPPER(P.ApeMaterno) ApeMaterno,                                                                           
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                           
    EC.FechaAgenda,                         
    EC.FechaActua                         
   FROM SGF_JefeZona JZ                                                   
    INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                    
    INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                   
    INNER JOIN SGF_ExpedienteCredito EC ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                                   
    INNER JOIN SGF_Persona P on P.PersonaId=EC.TitularId                                            
    INNER JOIN SGF_Parametro E on E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE JZ.JefeZonaId = @EMPLEADOID                                                  
    AND LC.esActivo = 1                                                   
    AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                     
    AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                 
    AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
    AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
   ORDER BY EC.FechaActua DESC                                                            
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                 
   END                                                 
                                     
     -- CALL CENTER                                                 
     --ELSE IF(@CargoId = 11)                                                 
     --BEGIN                                                 
     --    SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                     
     --                    FROM SGF_Agente AG                                                   
     --            INNER JOIN SGF_Agente_Local AGL ON AGL.IdAgente = AG.IdAgente                                                   
     --                    INNER JOIN SGF_Local LC ON LC.LocalId = AGL.IdLocal                                                 
     --                    INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                                      
     --                    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                    
     --                    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                  
     --                    WHERE AG.IdAgente = @EMPLEADOID                                                 
     --                      AND LC.esActivo = 1                                                   
     --                      AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
     --                      AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                   
     --                      AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
     --                      AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                  
     --                      AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                 
     --                      AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
     --                      AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
     --                      AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                 
     --                      AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
     --                      AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0))                                     
                                            
     --    SELECT EC.ExpedienteCreditoId as Id,                                                                           
     --           P.DocumentoNum as Documento,                                                                           
     --           UPPER(P.Nombre) Nombre,                                 
     --           UPPER(P.ApePaterno) ApePaterno,                                                                           
     --           UPPER(P.ApeMaterno) ApeMaterno,                                                                           
     --           E.NombreCorto, LEFT(E.NombreCorto,3) NombreCortoFree ,                                              
     --           EC.FechaAgenda,                         
     --           EC.FechaActua                         
     --    FROM SGF_Agente AG                              
     --    INNER JOIN SGF_Agente_Local AGL ON AGL.IdAgente = AG.IdAgente                                                   
     --    INNER JOIN SGF_Local LC ON LC.LocalId = AGL.IdLocal                                                   
     --    INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                 
     --    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                       
     --    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                  
     --    WHERE AG.IdAgente = @EMPLEADOID                                                 
     --      AND LC.esActivo = 1                                                   
     --      AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
     --      AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
     --      AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
     --      AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                     
     -- AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                     
     --      AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
     --      AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor       
     --      AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
     --      AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
     --      AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                       
     --    ORDER BY EC.FechaActua DESC                                                            
     --    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                 
     -- END                                                 
                                     
 -- REGIONAL                                    
     ELSE IF(@CargoId = 52)                                                 
     BEGIN                                         
         SET @Success = (SELECT  ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                         
   FROM SGF_JefeRegional JFR                                                   
    INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                   
    INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                              
    INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                 
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                             
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE JFR.JefeRegionalId = @EMPLEADOID                                               
    AND LC.esActivo = 1                                                 
    AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                    
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                   
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                   
    AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                               
    AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
    AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
   );                                
                           
  SELECT EC.ExpedienteCreditoId as Id,                                                                         
   P.DocumentoNum as Documento,                                                                         
   UPPER(P.Nombre) Nombre,                                                   
   UPPER(P.ApePaterno) ApePaterno,                                                             
   UPPER(P.ApeMaterno) ApeMaterno,                                                                         
   E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                         
   EC.FechaAgenda,                                           
   EC.FechaActua                                           
  FROM SGF_JefeRegional JFR                                                   
   INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                   
   INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                       
   INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                 
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                     
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38        
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
  WHERE JFR.JefeRegionalId = @EMPLEADOID                                               
   AND LC.esActivo = 1                                                 
   AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                    
   AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                   
   AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                       
   AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                 
   AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                               
   AND (ISNULL(P.IdSupervisor,0) = @SupervisorId OR @SupervisorId = -1)                      
   AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
   AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
   AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
   AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
   AND (EC.BancoId = @BancoId OR @BancoId = 0)      
   AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
  ORDER BY FechaActua DESC                                                          
   OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY                                         
  END                                                 
                                     
     -- OTROS ROLES                                                 
     ELSE                                                 
     BEGIN                                                 
       SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                     
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38           
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId           
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                         
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                          
    AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                 
    AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
    AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)           
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
   );                                   
                           
   SELECT EC.ExpedienteCreditoId as Id,                                                                           
    P.DocumentoNum as Documento,                                                                           
    UPPER(P.Nombre) Nombre,                                                     
    UPPER(P.ApePaterno) ApePaterno,                                  
    UPPER(P.ApeMaterno) ApeMaterno,                                                                           
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                             
    EC.FechaAgenda,                         
    EC.FechaActua                         
   FROM SGF_ExpedienteCredito EC                                                      
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                     
    INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38               
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId               
   WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                      
    AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                     
    AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
    AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                       
    AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                 
    AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                               
    AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                             
    AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                              
    AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                       
    AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)               
    AND (EC.BancoId = @BancoId OR @BancoId = 0)     
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)     
   ORDER BY EC.FechaActua DESC                                                            
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                     
   END                                                 
END