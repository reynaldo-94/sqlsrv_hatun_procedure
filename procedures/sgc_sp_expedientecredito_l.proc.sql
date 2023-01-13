/*--------------------------------------------------------------------------------------                                                                                                                                                             
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_L]                                                                                                                                                                              
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA LISTA DE CREDITOS                                                                                               
' Creado Por      : REYNALDO CAUCHE                                                                                                                                         
' Día de Creación : 18-12-2021                                                                                                                                                                          
' Requerimiento   : SGC                                                                                                                                                                       
' cambios  :                                                
 - 01-03-2022  REYNALDO CAUCHE                                               
 - 07-09-2022  cristian silva - add                                            
 - 12-09-2022  cristian silva - modify: convert @expedienteCredito@expedienteCredito to expedienteId linea 40                                          
 - 22-09-2022  cristian silva - modify: los P.idSupevisor, por los EC.idsupevisor para que enliste desde la tabla expediente credito el supervisor                                       
 mas no del idsupervisor de la tabla persona en la lista de SUPERVISOR                                      
 - 29-09-2022 cristian silva -add : celular y telefonos en cargo Supervisor                                     
 - 06-10-2022  cristian silva - se modifico @DocumentoNum de varchar 11 a 12                                   
 -  04-11-2022  cristian silva - add: datoslaboralesID                                
 - 10-11-2022  cristian silva - se agrego un outer apply  para el supervisor                               
 -  24-11-2022  cristian silva - se agrego al cargo supervisor  el campo AdvNombre                         
 - 29-11-2022  REYNALDO CAUCHE - Se agrego el campo Prioridad                      
 - 06-12-2022  cristian silva - se agregaron los campos BancoNombre y Observacion en supervisor                 
 - 06-12-2022  cristian silva - se agrego bancoNombre y Observacion para todos los cargos                 
 - 20-12-2022  cristian silva - se agrego contacto, intersado, comentario, motivo en todos los cargos           
 - 21-12-2022  cristian silva - se agrego submotivo, resultado  en todos los cargos             
 - 05-01-2023  cristian silva - se agrego el campo @FlagOperacion  
 - 09-01-2023  cristian silva - se agrego el campo @AgenteId 
'                                                                                                                                                                 
'--------------------------------------------------------------------------------------*/                                                                                                                 
                                                                                                             
ALTER PROCEDURE SGC_SP_ExpedienteCredito_L             
(@EstadoProcesoId int,                                                                                                                     
 @Pagina int,                                                                                                                     
 @Tamanio int,                                                                                                                     
 @DocumentoNum varchar(12),          
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
 @FlagOperacion int,       
 @AgenteId int = 0,     
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
                                                                               
 -----------------ADV------------------                                                                                           
    IF(@CargoId = 4)                                                                         
    BEGIN                                                                                                 
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                  
                        FROM SGF_ExpedienteCredito EC                                                                      
                        INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                              
                        INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                     
                        INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                 
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
                                     from SGF_ExpedienteCreditoDetalle                               
                             where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
                                   group by Observacion,ExpedienteCreditoId, Fecha,ItemId                     
                                     order by ItemId) ECDE             
     OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                   
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                                                
                        AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                       
                        AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                
                        AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                       
                        AND (EC.AdvId = @AD)                                                   
                        AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                         
                        AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                                                                        
                        AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                              
                        AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                 
                        AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                     
                        AND (EC.BancoId = @BancoId OR @BancoId = 0)                                               
                        AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0));                                         
                                                                                  
        SELECT EC.ExpedienteCreditoId as Id,                                                                                         
      P.DocumentoNum as Documento,                                                                                 
      UPPER(P.Nombre) Nombre,            
      UPPER(P.ApePaterno) ApePaterno,                                             
      UPPER(P.ApeMaterno) ApeMaterno,                                                                                                  
      E.NombreCorto ,               
      LEFT(E.NombreCorto,3) NombreCortoFree,                            
      EC.FechaAgenda,                                                      
      EC.FechaActua,                            
      '' AS AdvNombre,                         
      EC.Prioridad,                     
      B.Nombre [BancoNombre],                    
      IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],              
      ISNULL(CONT.NombreLargo, '') [Contactado],               
      ISNULL(INTE.NombreLargo, '') [Interesado],               
      ISNULL(MOTI.NombreLargo, '') [Motivo],               
      ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]           
        FROM SGF_ExpedienteCredito EC                                                                 
      INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
      INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                     
      INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                      
      OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
      from SGF_ExpedienteCreditoDetalle                               
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
      order by ItemId) ECDE             
      OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133               
        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                           
          AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                               
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                               
          AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                    
          AND (ISNULL(P.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                     
          AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                                                                                    
          AND (EC.AdvId = @AD)                                                   
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                   
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                 
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                     
          AND (EC.BancoId = @BancoId OR @BancoId = 0)       
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                 
        ORDER BY EC.FechaActua DESC                     
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                                                          
    END                          
                
                         
 -------------SUPERVISOR----------------                                                                                      
    ELSE IF(@CargoId = 29)                                                                                             
   BEGIN                                                                                             
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                                               
                        FROM SGF_ExpedienteCredito EC                                                                                                
       INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
       INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                  
       INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                               
       OUTER APPLY (select distinct top 1 Nombre                                 
          from SGF_ADV                               
          where AdvId = EC.AdvId                               
          group by Nombre                                
          order by Nombre desc) AD                           
       OUTER APPLY (select distinct top 1 PersonaId,DatosLaboralesId                                 
          from SGF_DatosLaborales                               
          where PersonaId = EC.TitularId                               
          group by PersonaId,DatosLaboralesId                                
          order by DatosLaboralesId desc) DL                     
       OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
          from SGF_ExpedienteCreditoDetalle                               
          where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
          group by Observacion,ExpedienteCreditoId, Fecha, ItemId                                
          order by ItemId) ECDE               
      OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR                  
       LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
       LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
       LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136               
    LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133             
       WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                                                                
                          AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                                
                          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                     
                          AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                              
                          AND EC.IdSupervisor = @SUPERVISOR                                                                       
                          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                   
                      AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                 
                          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                     
                          AND (EC.BancoId = @BancoId OR @BancoId = 0));                                 
                                        
        SELECT EC.ExpedienteCreditoId as Id,                                                                                                                     
     P.DocumentoNum as Documento,                                                                                                                     
     UPPER(P.Nombre) Nombre,                                                                                    
     UPPER(P.ApePaterno) ApePaterno,                                                                                                                     
     UPPER(P.ApeMaterno) ApeMaterno,                                                                                                                     
     E.NombreCorto ,               
     LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                                                          
     EC.FechaAgenda,                                                                   
     EC.FechaActua,                                     
     P.Celular,                                     
     P.Celular2,                                     
     P.Telefonos,                             
     ISNULL(AD.Nombre,'') AdvNombre,                             
     ISNULL(DL.DatosLaboralesId,0)  DatosLaboralesId,                         
     EC.Prioridad,                     
     B.Nombre [BancoNombre],               
     IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],               
     ISNULL(CONT.NombreLargo, '') [Contactado],               
     ISNULL(INTE.NombreLargo, '') [Interesado],               
     ISNULL(MOTI.NombreLargo, '') [Motivo],               
     ISNULL(ECR.Comentario, '') [Comentario],            
     ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]           
        FROM SGF_ExpedienteCredito EC                                                                                                
      INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
      INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                     
      INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                   
      OUTER APPLY (select distinct top 1 Nombre                                 
       FROM SGF_ADV                               
       where AdvId = EC.AdvId                               
       group by Nombre                                
       order by Nombre desc)  AD                           
      OUTER APPLY (select distinct top 1 PersonaId,DatosLaboralesId                                 
       from SGF_DatosLaborales                               
       where PersonaId = EC.TitularId                               
       group by PersonaId,DatosLaboralesId                                
       order by DatosLaboralesId desc)  DL                      
      OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
       from SGF_ExpedienteCreditoDetalle                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
       order by ItemId) ECDE               
      OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133               
        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                        
          AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                                               
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                 
          AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                                                  
          AND (EC.IdSupervisor = @SUPERVISOR)                                 
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                        
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                           
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                  
          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                  
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                 
        ORDER BY EC.FechaActua DESC                                                            
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                                              
    END               
               
 -------------------ESTABLECIMIENTO-----------------                                                                                           
    ELSE IF(@CargoId = 26)                                                                             
    BEGIN                                                                                             
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                                               
                        FROM SGF_ExpedienteCredito EC                                                      
       INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
       INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                                                           
       INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId                                      
       INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                 
       OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
          from SGF_ExpedienteCreditoDetalle                               
          where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
          group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
          order by ItemId) ECDE                
       OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                   
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                                                                
                          AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                                               
                          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                 
                          AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                                                   
                          AND PL.ProveedorLocalId = @EMPLEADOID                                                                       
                          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                        
                          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                 
                          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                     
                          AND (EC.BancoId = @BancoId OR @BancoId = 0)                        
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0));                           
                                                                           
        SELECT EC.ExpedienteCreditoId as Id,                                                                                                                     
    P.DocumentoNum as Documento,                                 
    UPPER(P.Nombre) Nombre,                                                                                               
    UPPER(P.ApePaterno) ApePaterno,                                                                                                                     
    UPPER(P.ApeMaterno) ApeMaterno,                                                                                                                     
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                    
    EC.FechaAgenda,                                                                   
    EC.FechaActua,                               
    '' AS AdvNombre,                         
    EC.Prioridad,                     
    B.Nombre [BancoNombre],                    
    IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''), '') [Observacion],             
    ISNULL(CONT.NombreLargo, '') [Contactado],               
    ISNULL(INTE.NombreLargo, '') [Interesado],               
    ISNULL(MOTI.NombreLargo, '') [Motivo],               
     ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]              
        FROM SGF_ExpedienteCredito EC                             
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                                                
   INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId                                                     
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                   
   OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
     from SGF_ExpedienteCreditoDetalle                      
     where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
     group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
     order by ItemId) ECDE             
   OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                 
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
 --------------JEFE ZONAL------------                                                                                           
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
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
                                     from SGF_ExpedienteCreditoDetalle                               
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
                                     group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
                                     order by ItemId) ECDE           
      OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
         from SGF_ExpedienteCredito_Reconfirmacion                               
         where ExpedienteCreditoId = EC.ExpedienteCreditoId                       
         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
         order by IdReconfirmacion desc) ECR               
         LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
         LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
         LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
         LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
         LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133               
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
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0));                                                                        
                                                 
        SELECT EC.ExpedienteCreditoId as Id,             
    P.DocumentoNum as Documento,                                                                                                                     
    UPPER(P.Nombre) Nombre,                                                                                               
    UPPER(P.ApePaterno) ApePaterno,                                                         
    UPPER(P.ApeMaterno) ApeMaterno,                                                                                                                     
    E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                          
    EC.FechaAgenda,                                                                   
    EC.FechaActua,                                
    '' AS AdvNombre,                         
    EC.Prioridad,                     
    B.Nombre [BancoNombre],                     
    IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],             
    ISNULL(CONT.NombreLargo, '') [Contactado],               
    ISNULL(INTE.NombreLargo, '') [Interesado],               
    ISNULL(MOTI.NombreLargo, '') [Motivo],               
    ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]              
   FROM SGF_JefeZona JZ                
    INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                              
    INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                                             
    INNER JOIN SGF_ExpedienteCredito EC ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                                                                             
    INNER JOIN SGF_Persona P on P.PersonaId=EC.TitularId                                                                                      
    INNER JOIN SGF_Parametro E on E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                      
    INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                  
    OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
       from SGF_ExpedienteCreditoDetalle                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
       order by ItemId) ECDE             
    OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                
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
                                                                                  
 -----------REGIONAL------------                                                                           
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
       OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
          from SGF_ExpedienteCreditoDetalle                               
          where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
          group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
          order by ItemId) ECDE             
       OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133   
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
                         AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0));                                                                          
                                       
   SELECT EC.ExpedienteCreditoId as Id,                                                                                                         
      P.DocumentoNum as Documento,                                                                                                                   
      UPPER(P.Nombre) Nombre,                                                                                             
      UPPER(P.ApePaterno) ApePaterno,                                                                                                       
      UPPER(P.ApeMaterno) ApeMaterno,                                                                             
      E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                     
      EC.FechaAgenda,                                                                                     
      EC.FechaActua,                               
      '' AS AdvNombre,                         
      EC.Prioridad,                     
      B.Nombre [BancoNombre],                     
      IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],             
      ISNULL(CONT.NombreLargo, '') [Contactado],               
      ISNULL(INTE.NombreLargo, '') [Interesado],               
      ISNULL(MOTI.NombreLargo, '') [Motivo],               
       ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]              
        FROM SGF_JefeRegional JFR                                                                                             
      INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId               
      INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                 
      INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                                                                           
      INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                                               
      INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                  
      INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                  
      OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
      from SGF_ExpedienteCreditoDetalle                               
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
      order by ItemId) ECDE             
      OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                   
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
         
---------CALL CENTER ----------------         
 ELSE IF (@CargoId = 11 or @CargoId = 56)         
 BEGIN         
 -----------------------         
  if(@FlagOperacion = 0) -- todas las operaciones     
  begin       
       
  SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                                               
                        FROM SGF_ExpedienteCredito EC                                                                             
         INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
         INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                    
         INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                     
         OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
         from SGF_ExpedienteCreditoDetalle                               
         where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
         group by Observacion,ExpedienteCreditoId, Fecha,ItemId                        order by ItemId) ECDE             
         OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                   
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
						  and ((EC.UserIdCrea = @AgenteId and EC.ExpedienteCreditoLocalId=13) or @AgenteId = 0) 
						  );                                                                             
                                                                           
        SELECT EC.ExpedienteCreditoId as Id,                                                                
   P.DocumentoNum as Documento,                                                                                                                     
   UPPER(P.Nombre) Nombre,                                                                                               
   UPPER(P.ApePaterno) ApePaterno,                                                                            
   UPPER(P.ApeMaterno) ApeMaterno,                                                                                                                     
   E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                                                       
   EC.FechaAgenda,                                                                   
   EC.FechaActua,                                
   '' AS AdvNombre,                        
   EC.Prioridad,                     
   B.Nombre [BancoNombre],                       
   IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],             
   ISNULL(CONT.NombreLargo, '') [Contactado],               
   ISNULL(INTE.NombreLargo, '') [Interesado],               
   ISNULL(MOTI.NombreLargo, '') [Motivo],               
    ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]               
        FROM SGF_ExpedienteCredito EC                                                               
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                         
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                      
   OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
      from SGF_ExpedienteCreditoDetalle                         
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
      order by ItemId) ECDE              
  OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                  
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
		  and ((EC.UserIdCrea = @AgenteId and EC.ExpedienteCreditoLocalId=13) or @AgenteId = 0) 
        ORDER BY EC.FechaActua DESC                                                                                                      
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;           
       
  end       
       
  if(@FlagOperacion = 1) -- mis operaciones     
  begin       
  SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                                               
                        FROM SGF_ExpedienteCredito EC                                                                                                
       INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
       INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                  
       INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                               
       OUTER APPLY (select distinct top 1 Nombre                                 
          from SGF_ADV                               
          where AdvId = EC.AdvId                               
          group by Nombre                                
          order by Nombre desc) AD                           
       OUTER APPLY (select distinct top 1 PersonaId,DatosLaboralesId                                 
          from SGF_DatosLaborales                               
          where PersonaId = EC.TitularId                               
          group by PersonaId,DatosLaboralesId                                
          order by DatosLaboralesId desc) DL                     
       OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
          from SGF_ExpedienteCreditoDetalle                               
          where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
          group by Observacion,ExpedienteCreditoId, Fecha, ItemId                                
          order by ItemId) ECDE               
       OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
          from SGF_ExpedienteCredito_Reconfirmacion                               
          where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
          group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
          order by IdReconfirmacion desc) ECR                  
       LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
       LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
       LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136               
       LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
       LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133             
      WHERE (EC.UserIdCrea = @UserId)       
        and  (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                                                                
        AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)                                                                                          
        AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                               
        AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                                                 
        AND (EC.ExpedienteCreditoLocalId =13)                                               
        AND (ISNULL(P.IdSupervisor, 0) = 0)                                                       
        --AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                                                                       
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
   E.NombreCorto ,               
   LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                                                          
   EC.FechaAgenda,      
   EC.FechaActua,                                     
   P.Celular,                                     
   P.Celular2,                                     
   P.Telefonos,                             
   ISNULL(AD.Nombre,'') AdvNombre,                             
   ISNULL(DL.DatosLaboralesId,0)  DatosLaboralesId,                         
   EC.Prioridad,                     
   B.Nombre [BancoNombre],               
   IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],               
   ISNULL(CONT.NombreLargo, '') [Contactado],               
   ISNULL(INTE.NombreLargo, '') [Interesado],               
   ISNULL(MOTI.NombreLargo, '') [Motivo],               
   ISNULL(ECR.Comentario, '') [Comentario],            
   ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
   ISNULL(RES.NombreLargo, '') [Resultado]           
  FROM SGF_ExpedienteCredito EC    -- from principal                                                                                            
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                                     
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                     
   OUTER APPLY (select distinct top 1 Nombre                                 
      FROM SGF_ADV                               
      where AdvId = EC.AdvId                               
      group by Nombre                                
      order by Nombre desc)  AD                           
   OUTER APPLY (select distinct top 1 PersonaId,DatosLaboralesId                                 
      from SGF_DatosLaborales                               
      where PersonaId = EC.TitularId                               
      group by PersonaId,DatosLaboralesId                                
      order by DatosLaboralesId desc)  DL                      
   OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
      from SGF_ExpedienteCreditoDetalle                               
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
      order by ItemId) ECDE               
   OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
      from SGF_ExpedienteCredito_Reconfirmacion                               
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
      order by IdReconfirmacion desc) ECR               
   LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
   LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
   LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
   LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
   LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133               
  WHERE EC.UserIdCrea = @UserId   -- where principal    
   and  (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres='' or @Nombres is null)                                                                                                
   AND (P.DocumentoNum=@DocumentoNum or @DocumentoNum ='' or @DocumentoNum is null)            
   AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                               
   AND (ISNULL(EC.EnObservacion,0) = @EnObservacion OR @TodosEstado = 0)                                                                                 
   AND (EC.ExpedienteCreditoLocalId = 13)                                               
   AND (ISNULL(P.IdSupervisor, 0) = 0)                                                                         
   --AND ISNULL(P.IdSupervisor, 0) != @TodosSupervisor                                                                       
   AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                        
   AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                 
   AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                 
   AND (EC.BancoId = @BancoId OR @BancoId = 0)                                               
   AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)          
  ORDER BY EC.FechaActua DESC                                                            
  OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;         
       
  end       
         
 ------------------------         
 END         
                                                                                  
 -------------OTROS ROLES------------                                                                                           
    ELSE                                                                                           
    BEGIN                                                                                           
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId),0)                                                                                               
                        FROM SGF_ExpedienteCredito EC                                                                                                
         INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
         INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                    
         INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                     
         OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
         from SGF_ExpedienteCreditoDetalle                               
         where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
         group by Observacion,ExpedienteCreditoId, Fecha,ItemId                        order by ItemId) ECDE             
         OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140              
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133            
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
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0));                                                                             
                                                                           
        SELECT EC.ExpedienteCreditoId as Id,                                                                                                                     
   P.DocumentoNum as Documento,                                                                                                                     
   UPPER(P.Nombre) Nombre,                                                                                               
   UPPER(P.ApePaterno) ApePaterno,                                                                            
   UPPER(P.ApeMaterno) ApeMaterno,                                                                                                                     
   E.NombreCorto ,LEFT(E.NombreCorto,3) NombreCortoFree ,                                                                                                       
   EC.FechaAgenda,                                                                   
   EC.FechaActua,                                
   '' AS AdvNombre,                        
   EC.Prioridad,                     
   B.Nombre [BancoNombre],                IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), isnull(ECDE.Observacion, ''),'') [Observacion],             
   ISNULL(CONT.NombreLargo, '') [Contactado],               
   ISNULL(INTE.NombreLargo, '') [Interesado],               
   ISNULL(MOTI.NombreLargo, '') [Motivo],               
    ISNULL(ECR.Comentario, '') [Comentario],            
      ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],           
     ISNULL(RES.NombreLargo, '') [Resultado]               
        FROM SGF_ExpedienteCredito EC                                                               
   INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId                                                                                               
   INNER JOIN SGF_Parametro E ON E.ParametroId=EC.EstadoProcesoId and E.DominioId=38                                         
   INNER JOIN SGB_Banco B ON EC.BancoId = B.BancoId                      
   OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion,Fecha,ItemId                                 
      from SGF_ExpedienteCreditoDetalle                               
      where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
      group by Observacion,ExpedienteCreditoId, Fecha,ItemId                                
      order by ItemId) ECDE              
  OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
       from SGF_ExpedienteCredito_Reconfirmacion                               
       where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                 
       order by IdReconfirmacion desc) ECR               
      LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130               
      LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131               
      LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136           
      LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140          
      LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                  
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