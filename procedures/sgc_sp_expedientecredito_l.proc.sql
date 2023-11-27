/*--------------------------------------------------------------------------------------                                                                      
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_L]                                                                      
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LA LISTA DE CREDITOS                                                                      
' Creado Por      : REYNALDO CAUCHE                                                                      
' Día de Creación : 18-12-2021                                                                      
' Requerimiento   : SGC                                                                      
' Cambios  :                                                                      
  - 01-03-2022  REYNALDO CAUCHE                                                                      
  - 07-09-2022  CRISTIAN SILVA    - Add                                                                      
  - 12-09-2022  CRISTIAN SILVA    - Modify: convert @expedienteCredito@expedienteCredito to expedienteId linea 40                                                                      
  - 22-09-2022  CRISTIAN SILVA    - Modify: los P.idSupevisor, por los EC.idsupevisor para que enliste desde la tabla expediente credito el supervisor                                                                      
                                            mas no del idsupervisor de la tabla persona en la lista de SUPERVISOR                                                                                                                
  - 29-09-2022  CRISTIAN SILVA    - Add: celular y telefonos en cargo Supervisor                                                                                                               
  - 06-10-2022  CRISTIAN SILVA    - Se modifico @DocumentoNum de varchar 11 a 12                                                                                                             
  - 04-11-2022  CRISTIAN SILVA    - Add: datoslaboralesID                                                                                                          
  - 10-11-2022  CRISTIAN SILVA    - Se agrego un outer apply  para el supervisor                                                                                                         
  - 24-11-2022  CRISTIAN SILVA    - Se agrego al cargo supervisor  el campo AdvNombre                                                                                                   
  - 29-11-2022  REYNALDO CAUCHE   - Se agrego el campo Prioridad                                                                                                
  - 06-12-2022  CRISTIAN SILVA    - Se agregaron los campos BancoNombre y Observacion en supervisor                                                                                           
  - 06-12-2022  CRISTIAN SILVA    - Se agrego bancoNombre y Observacion para todos los cargos                                                                                           
  - 20-12-2022  CRISTIAN SILVA    - Se agrego contacto, intersado, comentario, motivo en todos los cargos                                                                                     
  - 21-12-2022  CRISTIAN SILVA    - Se agrego submotivo, resultado  en todos los cargos                                                                                       
  - 05-01-2023  CRISTIAN SILVA    - Se agrego el campo @FlagOperacion                                                                            
  - 09-01-2023  CRISTIAN SILVA    - Se agrego el campo @AgenteId                                                                      
  - 19-01-2023  CRISTIAN SILVA    - se agrego el campo @AgenciaId                                                                      
  - 19-01-2023  FRANCISCO LAZARO  - Se agrego el campo LimiteDerivacion                                                               
  - 20-01-2023  FRANCISCO LAZARO  - Se agrego el parametro @LimiteDerivacion int = 0                                    
  - 23-01-2023  CRISTIAN SILVA    - se hizo el cambio de filtrar por IdSupervisor de la tabla Persona a la tabla ExpedienteCredio                                                   
  - 31-01-2023 FRANCISCO LAZARO  - Se realizo rollback a cambios de LimiteDerivacion                                     
  - 28-03-2023  CRISTIAN SILVA    - se agrego el campo APDP, PubliAPDP                      
  - 30-05-2023  FRANCISCO LAZARO  - Add: campos ListBancoId, ListBancoNombre, ListBancoLogo, ListAuthorized                             
  - 09/06/2023  REYNALDO CAUCHE - Se cambio la logica para jefe Regional, ya no se consulta a la tabla JefeRegional                            
  - 01/08/2023 REYNALDO CAUCHE -  Para los roles distintos a Callcenter, Supervisor ContactCenter, admin, Regional no mostrar los creditos que tengan relacionado a ALFIN                    
  - develop-alfin 22/08/2023 - A los campos ListBancoId,ListBancoNombre remover un espacio en blanco                   
               - Se agrego una condicion al rol supervisor para que no muestre el banco Alfin
- develop_lista_por_id 10/11/2023 - A los parametros se le agrego un valor inicial              
'--------------------------------------------------------------------------------------*/                                  
ALTER PROCEDURE SGC_SP_ExpedienteCredito_L                         
(@EstadoProcesoId int = 0,                       
 @Pagina int = 0,                       
@Tamanio int = 0,                       
 @DocumentoNum varchar(12) = '',                       
 @Nombres varchar(100) = '',
 @LocalId int = 0,                       
 @ZonalId int = 0,
 @UserId int = 0,
 @CargoId int = 0,
 @EnObservacion bit = 0,                       
 @SupervisorId int = 0,                       
 @TodosEstado bit = 0,                       
 @TodosSupervisor int = 0,                       
 @Mes int = 0,
 @Anio int = 0,
 @CanalVentaId int = 0,                       
 @BancoId int = 0,                       
 @ExpedienteCredito varchar(11) = '',
 @FlagOperacion int = 0,                       
 @AgenteId int = 0,                       
 @AgenciaId int = 0,                            
 --@LimiteDerivacion int = 0,                       
 @Success INT OUTPUT)                                                                      
AS                                                         
BEGIN                                                                      
    DECLARE @AD INT = (SELECT ISNULL(sa.AdvId , 0) FROM SGF_USER su INNER JOIN SGF_ADV sa on sa.AdvId = su.EmpleadoId where su.UserId = @UserId)                                                                      
    DECLARE @SUPERVISOR INT = (SELECT ISNULL(ss.IdSupervisor , 0) FROM SGF_USER su INNER JOIN SGF_Supervisor ss on ss.IdSupervisor = su.EmpleadoId where su.UserId = @UserId)                                                                      
    DECLARE @JEFEZONAL INT = (SELECT ISNULL(sjz.JefeZonaId , 0) FROM SGF_USER su INNER JOIN SGF_JefeZona sjz on sjz.JefeZonaId = su.EmpleadoId where su.UserId = @UserId)                                                                      
    DECLARE @EMPLEADOID INT = (SELECT ISNULL(EmpleadoId , 0) FROM SGF_USER where UserId = @UserId)                                                                      
    DECLARE @expedienteId INT = convert(int, @ExpedienteCredito)                                                                      
    DECLARE @PROVEEDOR INT                                                              
    DECLARE @FECHAACTUAL DATETIME = dbo.GETDATE()                                                              
                                                                      
    -- ADV ----------------------------------------------------------------------------------------------------------------------------------------                           
    IF(@CargoId = 4)                                                                      
    BEGIN                                                       
        SET @Success = (                
                         SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                      
                         FROM SGF_ExpedienteCredito EC                                                                      
                             LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                         
                             INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                   
                             OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                         
                                          from SGF_ExpedienteCreditoDetalle                       
                                          where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                           
                                          group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                        
                                          order by ItemId) ECDE                                                  
                             OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                          
  
    
    
                 
                                          from SGF_ExpedienteCredito_Reconfirmacion                                                                                             
                                          where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                        
                                          group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                 
                                          order by IdReconfirmacion desc) ECR                                        
                             OUTER APPLY (select distinct top 1 Nombre                                                                                                           
                                          FROM SGF_ADV                                                                                                         
                                          where AdvId = EC.AdvId                                                                                                         
                                          group by Nombre                                                                                                          
                                          order by Nombre desc)  AD                                                                                         
                             LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
                             INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                            
                             LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                       
                             LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
                             LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
                             LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
                           LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                          
                         WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                 
            
              
                 
                             AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                 
                             AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                             
                             AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                       
                             AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                      
                             AND (EC.AdvId = @AD)                                                          
                             AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                  
                             AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                               
                             AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                          
                             AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                   
                             AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                              
                             AND (EC.BancoId = @BancoId OR @BancoId = 0)                                      
                             AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                  
                             AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                   
                         /*AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/                
        );                        
                                                                
          SELECT EC.ExpedienteCreditoId [Id],                       
              P.DocumentoNum [Documento],                       
              UPPER(P.Nombre) [Nombre],                       
              UPPER(P.ApePaterno) [ApePaterno],                       
              UPPER(P.ApeMaterno) [ApeMaterno],                       
              E.NombreCorto ,                       
              LEFT(E.NombreCorto, 3) [NombreCortoFree],                       
              EC.FechaAgenda,                       
              EC.FechaActua,                       
              ISNULL(AD.Nombre, '') [AdvNombre],                       
              EC.Prioridad,                       
              IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
              ISNULL(CONT.NombreLargo, '') [Contactado],                       
            ISNULL(INTE.NombreLargo, '') [Interesado],                       
              ISNULL(MOTI.NombreLargo, '') [Motivo],                       
              ISNULL(ECR.Comentario, '') [Comentario],                       
              ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
              ISNULL(RES.NombreLargo, '') [Resultado],                       
              ISNULL(P.APDP, 0) [APDP],                       
              ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
              --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                                       
              --IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                                                                                     
        ISNULL(B.Nombre, '') [BancoNombre],                       
              STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
              STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
              STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
              [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                      
          FROM SGF_ExpedienteCredito EC                                        
              LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                         
              INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                          
              OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                           from SGF_ExpedienteCreditoDetalle                                                                 
                           where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                        
                           group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
                           order by ItemId) ECDE                                                               
              OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                         
  
                           from SGF_ExpedienteCredito_Reconfirmacion                                                                                                         
                           where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                     
                           group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                 
                           order by IdReconfirmacion desc) ECR                                        
              OUTER APPLY (select distinct top 1 Nombre                                                    
                           FROM SGF_ADV                                                                                                         
                           where AdvId = EC.AdvId                                                                                                         
                           group by Nombre                                                                                                          
                           order by Nombre desc)  AD                                                                                       
              LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
              INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                            
              LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                       
              LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                              
              LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                 
              LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
              LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                                           
          WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                        
              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                 
              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                         
              AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                    
              AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                                                 
              AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                      
              AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                      
              AND (EC.AdvId = @AD)                                    
              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                             
              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                            
              AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                    
              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                 
              AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                  
              AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                
              --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                      
          ORDER BY EC.FechaActua DESC                                                                                               
          OFFSET @Pagina * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                 
                
    END                                                        
                                                                                          
                                          
    -- SUPERVISOR ----------------------------------------------------------------------------------------------------------------------------------                                  
    ELSE IF(@CargoId = 29)                                      
    BEGIN                                                                                                                                                                       
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                                
                        FROM SGF_ExpedienteCredito EC                                                                                                                                                                          
                        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                       
                        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                                                                                  
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                                                                                         
                        OUTER APPLY (select distinct top 1 Nombre                                                                                      
                                     from SGF_ADV                                                                                                         
                                     where AdvId = EC.AdvId                                                                   
                       group by Nombre                                                                                                     
                                     order by Nombre desc) AD                                                                                           
                      OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                                                                                           
                                     from SGF_DatosLaborales                                                                                                         
                                     where PersonaId = EC.TitularId                                                                                                         
                                     group by PersonaId, DatosLaboralesId                                   
                                     order by DatosLaboralesId desc) DL                                          
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                                     from SGF_ExpedienteCreditoDetalle                                                                                                         
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                       
                                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
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
                        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                                  
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                           
                              AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                         
                              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                
                              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                    
             AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                       
                              AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                      
                              AND EC.IdSupervisor = @SUPERVISOR                                                                            
                              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                             
                              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                     
                              AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                                                               
                              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                   
                              AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                          
                              --AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                      
        AND EC.BancoId != 13                      
                              /*AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/);                                   
                                                      
        SELECT EC.ExpedienteCreditoId as Id,                       
           P.DocumentoNum as Documento,                       
           UPPER(P.Nombre) Nombre,                       
           UPPER(P.ApePaterno) ApePaterno,                       
           UPPER(P.ApeMaterno) ApeMaterno,                       
           E.NombreCorto ,                       
           LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
           EC.FechaAgenda,                       
           EC.FechaActua,                       
           P.Celular,                       
           P.Celular2,                       
           P.Telefonos,                       
           ISNULL(AD.Nombre, '') AdvNombre,                       
           ISNULL(DL.DatosLaboralesId, 0)  DatosLaboralesId,                       
           EC.Prioridad,                       
           ISNULL(B.Nombre, '') [BancoNombre],                       
           IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
           ISNULL(CONT.NombreLargo, '') [Contactado],                       
           ISNULL(INTE.NombreLargo, '') [Interesado],                       
           ISNULL(MOTI.NombreLargo, '') [Motivo],                       
           ISNULL(ECR.Comentario, '') [Comentario],                       
           ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
           ISNULL(RES.NombreLargo, '') [Resultado],                 
           ISNULL(P.APDP, 0) [APDP],                       
           ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
           [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
           --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                                       
           --IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                                                                      
        FROM SGF_ExpedienteCredito EC                                        
          LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                         
          INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                        
          OUTER APPLY (select distinct top 1 Nombre                                                       
                       FROM SGF_ADV                                                                                                         
                       where AdvId = EC.AdvId                                                                                                         
                       group by Nombre                                                                                                          
                       order by Nombre desc)  AD                                                                      
          OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                                            
                       from SGF_DatosLaborales                                                                                                      
                       where PersonaId = EC.TitularId                                                                                                         
                       group by PersonaId, DatosLaboralesId                                                                                                     
                       order by DatosLaboralesId desc)  DL                                                                                                
          OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                       from SGF_ExpedienteCreditoDetalle                                                                                                         
                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                        
                       group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                  
                       order by ItemId) ECDE                                                                                           
          OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                    
                       from SGF_ExpedienteCredito_Reconfirmacion                                                                    
                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                  
                       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                               
                       order by IdReconfirmacion desc) ECR                                                                                                                              
          LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                          
       INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                          
          LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
          LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
          LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
          LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
          LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                           
       WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                        
          AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                          
          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                                        
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                                           
          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                       
          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                      
          AND (EC.IdSupervisor = @SUPERVISOR)                                                             
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                                                  
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                        
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                            
          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                          
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                        
          ------AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                        
          AND EC.BancoId != 13                      
          --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                                            
  
    
       
       
           
           
              
                
                  
                   
                    
        ORDER BY EC.FechaActua DESC                      
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                 
    END                               
                                                                                
                                                              
    -- ESTABLECIMIENTO ----------------------------------------------------------------------------------------------------------------------------                                                                      
    ELSE IF(@CargoId = 26)                                                                   
    BEGIN                                                                                                       
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                              
                        FROM SGF_ExpedienteCredito EC                                         
                        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                          
                        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                
                        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                                                                                          
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                                  from SGF_ExpedienteCreditoDetalle                                      
                                  where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                  group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
           order by ItemId) ECDE                                                                                       
                        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                
  
    
      
       
           
           
                                  from SGF_ExpedienteCredito_Reconfirmacion                                                                                 
                                  where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                     
                              group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                    
 
     
      
       
                                  order by IdReconfirmacion desc) ECR                                        
                        OUTER APPLY (select distinct top 1 Nombre                                                       
                                  from SGF_ADV                                   
                                  where AdvId = EC.AdvId                                                                                                         
                                  group by Nombre                                                                        
                                  order by Nombre desc)  AD                                         
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId         
                        INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId                                          
                        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
                        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
                        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
                        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
                        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                      
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                                                             
                          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                                                                 
  
    
     
        
          
            
                          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                      
    AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                             
                          AND PL.ProveedorLocalId = @EMPLEADOID                                                                                                                                                 
                          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                          
                          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                       
                          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                                                               
                          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                               
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                  
                          AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                        
                          AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                         
        AND EC.BancoId != 13                      
                       /*AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/);                                           
   
    
      
                                                      
        SELECT EC.ExpedienteCreditoId as Id,                       
               P.DocumentoNum as Documento,                       
               UPPER(P.Nombre) Nombre,                       
         UPPER(P.ApePaterno) ApePaterno,                       
               UPPER(P.ApeMaterno) ApeMaterno,                       
               E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
               EC.FechaAgenda,                       
               EC.FechaActua,                       
               ISNULL(AD.Nombre, '') AdvNombre,                       
               EC.Prioridad,                       
               ISNULL(B.Nombre, '') [BancoNombre],                       
               IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
               ISNULL(CONT.NombreLargo, '') [Contactado],                       
               ISNULL(INTE.NombreLargo, '') [Interesado],                       
               ISNULL(MOTI.NombreLargo, '') [Motivo],                  
               ISNULL(ECR.Comentario, '') [Comentario],                       
               ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
               ISNULL(RES.NombreLargo, '') [Resultado],                       
               ISNULL(P.APDP, 0) [APDP],                       
               ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                 
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
               [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
               --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                                       
               --IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                       
         FROM SGF_ExpedienteCredito EC                                         
            LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                          
            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                                                                         
            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                        
            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                        from SGF_ExpedienteCreditoDetalle                                                                                                
                        where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                        group by Observacion, ExpedienteCreditoId, Fecha, ItemId                      
                        order by ItemId) ECDE                                                                                       
            OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                             
                        from SGF_ExpedienteCredito_Reconfirmacion                                                                                                         
                        where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                     
                        group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                         
  
                        order by IdReconfirmacion desc) ECR                                        
            OUTER APPLY (select distinct top 1 Nombre                                                                                                           
        from SGF_ADV                                                                                              
                        where AdvId = EC.AdvId                                                                                                        
                        group by Nombre                                                                  
                        order by Nombre desc)  AD                                         
            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
            INNER JOIN SGF_ProveedorLocal PL ON PL.ProveedorLocalId = EC.ProveedorId                                          
            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                         
            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                            
            LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                             
            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                       
            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                                                      
            WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                                                             
              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                 
              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                                                           
              AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                           
              AND PL.ProveedorLocalId = @EMPLEADOID                                                                                                                                                 
              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                                                  
              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
              AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                                                               
              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                               
              AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                  
              AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                
              AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                      
     AND EC.BancoId != 13                      
              --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                                
            ORDER BY EC.FechaActua DESC                                            
            OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                                 
    END                                                              
                                                                       
                                                                    
    -- JEFE ZONAL --------------------------------------------------------------------------------------------------------------------------------                                      
    ELSE IF(@CargoId = 2)                                                                                                                                             
    BEGIN                                                                                                                                                                     
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                                                                                                         
                        FROM SGF_JefeZona JZ                                                                                          
       INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                              
                        INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                     
                        INNER JOIN SGF_ExpedienteCredito EC ON EC.ExpedienteCreditoLocalId = LC.LocalId                                         
                        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                           
        INNER JOIN SGF_Persona P on P.PersonaId = EC.TitularId                                      
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                 
                                     from SGF_ExpedienteCreditoDetalle                                                                            
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                
                                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
        order by ItemId) ECDE                                                                          
                        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                     
                                     from SGF_ExpedienteCredito_Reconfirmacion                                
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                             
 
    
      
        
          
            
              
               
                                     order by IdReconfirmacion desc) ECR                                        
                        OUTER APPLY (select distinct top 1 Nombre                                                                                                           
                                     FROM SGF_ADV                               
                                     where AdvId = EC.AdvId                                                                                               
                                     group by Nombre                                                                                                          
                                     order by Nombre desc)  AD                                                                                             
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
                        INNER JOIN SGF_Parametro E on E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                          
                 LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
                        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
                        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
                        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
                        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                          
                        WHERE JZ.JefeZonaId = @EMPLEADOID                                                                                                           
                      AND LC.esActivo = 1                                                     
                          AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                         
                          AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                         
                          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                               
  AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                             
                          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                                               
  
    
     
         
          
                          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                                                                                                                                    
                          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                               AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                            
  
    
      
        
          
            
              
                                                                                              
                          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                             
                          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
                          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                                                               
                          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                          
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                          
               AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                      
                          AND EC.BancoId != 13                                                                  
                          /*AND (EC.IdOficina = @AgenciaId  or @AgenciaId = 0)                                             
                            AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/);                                         
  
    
     
         
          
            
              
               
                  
                   
                    
                      
                                                                                                           
        SELECT EC.ExpedienteCreditoId as Id,                       
               P.DocumentoNum as Documento,                       
 UPPER(P.Nombre) Nombre,                       
               UPPER(P.ApePaterno) ApePaterno,                       
               UPPER(P.ApeMaterno) ApeMaterno,                       
               E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
               EC.FechaAgenda,                       
               EC.FechaActua,                       
               ISNULL(AD.Nombre, '') AdvNombre,                   
               EC.Prioridad,                       
               ISNULL(B.Nombre, '') [BancoNombre],                       
          IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
               ISNULL(CONT.NombreLargo, '') [Contactado],                       
               ISNULL(INTE.NombreLargo, '') [Interesado],                       
               ISNULL(MOTI.NombreLargo, '') [Motivo],                       
               ISNULL(ECR.Comentario, '') [Comentario],                       
               ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
               ISNULL(RES.NombreLargo, '') [Resultado],                       
               ISNULL(P.APDP, 0) [APDP],                       
               ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
               [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                    
               --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                                       
               -- IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                                                                      
        FROM SGF_JefeZona JZ                                                
        INNER JOIN SGF_Zona ZN ON ZN.ZonaId = JZ.ZonaId                                                  
        INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId                                                                                                                                                                       
        INNER JOIN SGF_ExpedienteCredito EC ON EC.ExpedienteCreditoLocalId = LC.LocalId                                         
        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                             
        INNER JOIN SGF_Persona P on P.PersonaId = EC.TitularId                                                                                                                                                                                                
   
   
      
         
          
            
             
                 
                  
                   
                    
                       
        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                     from SGF_ExpedienteCreditoDetalle                                                                                          
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                        
                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
                     order by ItemId) ECDE                                                                          
        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                      
                     from SGF_ExpedienteCredito_Reconfirmacion                                                                                 
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                      
                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                      
                     order by IdReconfirmacion desc) ECR                                        
        OUTER APPLY (select distinct top 1 Nombre                                                                      
                     FROM SGF_ADV                                                                                                         
                     where AdvId = EC.AdvId                                                                                                         
                     group by Nombre                                          
                     order by Nombre desc)  AD                                                                                                                   
        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
        INNER JOIN SGF_Parametro E on E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                          
        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                        
        WHERE JZ.JefeZonaId = @EMPLEADOID                                                                                                           
          AND LC.esActivo = 1                                                                                    
          AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                         
          AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                         
          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                               
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                             
          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                                                         
          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                                                                                                                                    
          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                           
          AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                                          
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                                                  
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                      
          AND (EC.BancoId = @BancoId OR @BancoId = 0)                   
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                 
  
     
    AND EC.BancoId != 13                                                                    
          --AND (EC.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                                
          --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                                             
  
    
      
       
          
             
             
                
                   
                   
                    
                      
        ORDER BY EC.FechaActua DESC                                  
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                          
    END                                      
                                                                                          
                                                        
    -- REGIONAL ----------------------------------------------------------------------------------------------------------------------------                                                                      
    ELSE IF(@CargoId = 52)                                                                                                   
    BEGIN                      
     DECLARE @RegionZonaId INT = ISNULL((SELECT RegionZonaId FROM SGF_User US                        
                                            LEFT JOIN SGF_JefeRegional JR ON JR.JefeRegionalId = US.EmpleadoId                        
                                            LEFT JOIN SGF_RegionZona RZ ON RZ.RegionZonaId = JR.RegionId                        
                                            WHERE US.UserId = @UserId), 0)                      
                      
    SET @Success = (                
                    SELECT  ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                      
                            -- FROM SGF_JefeRegional JFR                                                                                                                                     
                            -- INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                                                         
                            -- INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId  and LC.LocalId ! = 13                                  
                    FROM SGF_Local LC                                                   
                        INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                        
                        LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId               
                        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                          
                     OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                  
                                        from SGF_ExpedienteCreditoDetalle                                                                                                         
                                        where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                     
                                        group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                           
                                        order by ItemId) ECDE                                                                                       
                        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                          
                                        from SGF_ExpedienteCredito_Reconfirmacion                                                                                                 
                                        where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                        group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                           
                                        order by IdReconfirmacion desc) ECR                                         
                        OUTER APPLY (select distinct top 1 Nombre                                  
                                        FROM SGF_ADV where AdvId = EC.AdvId                                                                                                         
                                        group by Nombre                                                                                                          
                                        order by Nombre desc)  AD                                         
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
                        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                         
                        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
                        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                               
                        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
                        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                      
                        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                             
                        -- WHERE JFR.JefeRegionalId = @EMPLEADOID                                                                                                                 
                        -- AND LC.esActivo = 1                                                                                                                                            
                    WHERE ((@RegionZonaId = 6) OR (@RegionZonaId != 6 AND LC.RegionalId = @EmpleadoId))                      
           AND LC.esActivo = 1                           
                        AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                        
                        AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                          
                        AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                                              
                        AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                                                 
                        AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                         
                        AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                     
                        AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                                                                                                   
                        AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                                                      
                        AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                                                  
                        AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                            
                        AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                      
                        AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                                                         
                        AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                        
                        AND ((@RegionZonaId = 6) OR (@RegionZonaId != 6 ))            
                        --AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13) AND EC.BancoId != 13))                      
                        and ((@RegionZonaId = 6) OR (@RegionZonaId != 6 AND  EC.BancoId != 13 ))                  
                        /*AND (EC.IdOficina = @AgenciaId  or @AgenciaId = 0)                            
                        AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/                
                    );                                           
                            
       SELECT EC.ExpedienteCreditoId as Id,                       
          P.DocumentoNum as Documento,                       
          UPPER(P.Nombre) Nombre,                       
          UPPER(P.ApePaterno) ApePaterno,                       
          UPPER(P.ApeMaterno) ApeMaterno,                       
          E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
          EC.FechaAgenda,                       
          EC.FechaActua,                       
          ISNULL(AD.Nombre, '') AdvNombre,                       
          EC.Prioridad,                       
          ISNULL(B.Nombre, '') [BancoNombre],                       
          IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
          ISNULL(CONT.NombreLargo, '') [Contactado],                       
          ISNULL(INTE.NombreLargo, '') [Interesado],                       
          ISNULL(MOTI.NombreLargo, '') [Motivo],                       
          ISNULL(ECR.Comentario, '') [Comentario],                       
          ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
          ISNULL(RES.NombreLargo, '') [Resultado],                       
          ISNULL(P.APDP, 0) [APDP],                       
          ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
          STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
          STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
          STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
          [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
          --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +--IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día')[LimiteDerivacion]                                                                      
          -- FROM SGF_JefeRegional JFR                                                                                                                                                                       
          -- INNER JOIN SGF_Zona ZN ON ZN.RegionZonaId = JFR.RegionId                                                                                         
          -- INNER JOIN SGF_Local LC ON LC.ZonaId = ZN.ZonaId  and LC.LocalId ! = 13                                 
FROM SGF_Local LC                             
          INNER JOIN SGF_ExpedienteCredito EC  ON EC.ExpedienteCreditoLocalId = LC.LocalId                                        
          LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                           
          INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                         
          OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                        
                       from SGF_ExpedienteCreditoDetalle                                                                                                         
                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                     
                       group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
                       order by ItemId) ECDE                                                                                       
          OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                           
                       from SGF_ExpedienteCredito_Reconfirmacion                                     
                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado               
                       order by IdReconfirmacion desc) ECR                              
          OUTER APPLY (select distinct top 1 Nombre                                                                                        
                       FROM SGF_ADV                                                                                  
                       where AdvId = EC.AdvId                                                                                                         
                       group by Nombre                                                                                                          
                       order by Nombre desc)  AD                                         
          LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
          INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                         
          LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                                 
          LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
          LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
          LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
          LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                          
          -- WHERE JFR.JefeRegionalId = @EMPLEADOID                                                                                                                                                                   
          --   AND LC.esActivo = 1                                                                                                                 
       WHERE         
          ((@RegionZonaId = 6) OR (@RegionZonaId != 6 AND LC.RegionalId = @EmpleadoId))                            
          AND LC.esActivo = 1                           
          AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                          
          AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                           
          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                    
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                        
          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                               
          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                      
          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                          
          AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                   
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                              
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                               
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                     
          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                                                          
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                      
          AND ((@RegionZonaId = 6) OR (@RegionZonaId != 6))             
          --AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13) AND EC.BancoId != 13))            
          and ((@RegionZonaId = 6) OR (@RegionZonaId != 6 AND  EC.BancoId != 13 ))                      
          --AND (EC.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                             
          --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                                            
   
    
     
                 
          ORDER BY FechaActua DESC                                                                                                           
          OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY                 
                         
    END                                                                           
                                          
    -- CALL CENTER ----------------------------------------------------------------------------------------------------------------------------                                                                                   
    ELSE IF (@CargoId = 11 or @CargoId = 56)                                                                                   
    BEGIN                                                                    
        IF(@FlagOperacion = 0) -- todas las operaciones                                                                               
        BEGIN                                                                                                   
            SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                                                                                                         
                        FROM SGF_ExpedienteCredito EC                                        
                            LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                        
                            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                           
                            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                                         from SGF_ExpedienteCreditoDetalle                                                                    
                                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
   group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                          
                                         order by ItemId) ECDE                                          
                            OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                            
  
    
     
         
          
            
              
               
                                         from SGF_ExpedienteCredito_Reconfirmacion                                                                                               
                                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                       
                                         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                   
                  
                   
                    
                                         order by IdReconfirmacion desc) ECR                                        
                            OUTER APPLY (select distinct top 1 Nombre                                                                                                           
                                         from SGF_ADV                                                                                                         
                                         where AdvId = EC.AdvId                                                      
            group by Nombre                                                                                                          
                                         order by Nombre desc)  AD                                                                                                 
                            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
                            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                          
                            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
                            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
           LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                       
                            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                           
                            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                                  
                            WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                    
                              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                                                            
   
    
      
        
          
            
             
                 
                 
                    
                    
                        
                              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                       
                              AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                         
   AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                         
                              AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                        
                              AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                          
                              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                       
                              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
                              AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                           
                              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                   
    AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)            
   AND ((EC.UserIdCrea = @AgenteId and EC.ExpedienteCreditoLocalId = 13) or @AgenteId = 0)                                                  
                              AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                  
                              /*AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/);             
     
        
           
           
               
                
                  
                   
                    
                       
            SELECT EC.ExpedienteCreditoId as Id,                       
                   P.DocumentoNum as Documento,                       
                   UPPER(P.Nombre) Nombre,                       
                   UPPER(P.ApePaterno) ApePaterno,                       
                   UPPER(P.ApeMaterno) ApeMaterno,                       
                   E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
                   EC.FechaAgenda,                       
                   EC.FechaActua,                       
                   ISNULL(AD.Nombre, '') AdvNombre,                      
        --'' AdvNombre,                     
                   EC.Prioridad,                       
                   ISNULL(B.Nombre, '') [BancoNombre],                       
                   IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
                   ISNULL(CONT.NombreLargo, '') [Contactado],                       
                   ISNULL(INTE.NombreLargo, '') [Interesado],                       
                   ISNULL(MOTI.NombreLargo, '') [Motivo],                       
                   ISNULL(ECR.Comentario, '') [Comentario],                       
                   ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
                   ISNULL(RES.NombreLargo, '') [Resultado],                       
                   ISNULL(P.APDP, 0) [APDP],                       
                   ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
                   [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
                   --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                      
                   --IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                             
            FROM SGF_ExpedienteCredito EC                                   
            LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                        
            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                                                                                            
  
    
       
        
          
           
               
                
                  
                   
                     
                       
            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                         from SGF_ExpedienteCreditoDetalle                                                                             
                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                               
                         group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                
                         order by ItemId) ECDE                             
OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                         
                         from SGF_ExpedienteCredito_Reconfirmacion                                                                                                         
                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                         
  
                         order by IdReconfirmacion desc) ECR                                        
            OUTER APPLY (select distinct top 1 Nombre , AdvId                                                                                                          
                         from SGF_ADV                                                                                                         
                         where AdvId = EC.AdvId                                        
                  group by Nombre ,AdvId                     
                         order by Nombre,AdvId desc)  AD                                                                                                 
            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                          
            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                         
            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
            LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                           
            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                           
            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                     
   left join SGF_ADV adv1 on adv1.AdvId = 0    
            WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                                  
              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                            
              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                                      
              AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                                           
              AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                                                                                         
              AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                     
     AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                  
              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                   
              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
              AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                           
              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                                                         
              AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                                                            
              AND ((EC.UserIdCrea = @AgenteId and EC.ExpedienteCreditoLocalId = 13) or @AgenteId = 0)                                                  
              AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                     
      and NOT (EC.AdvId != 0 AND EC.BancoId = 13)                     
              --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                                        
       
           
           
              
                 
                 
                   
            ORDER BY EC.FechaActua DESC                                                                                                                    
            OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                          
        END                                                                                 
                                        
        IF (@FlagOperacion = 1) -- mis operaciones                                                                   
        BEGIN                                                                                 
            SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                       
                            FROM SGF_ExpedienteCredito EC    -- from principal                                        
                            LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                         
                            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                    
                            OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                  
                    from SGF_DatosLaborales                                                                                                         
      where PersonaId = EC.TitularId                                                                                                         
                                         group by PersonaId, DatosLaboralesId                            
                                         order by DatosLaboralesId desc)  DL                                                                                                
                            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                                         from SGF_ExpedienteCreditoDetalle                                                            
                                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                         group by Observacion, ExpedienteCreditoId, Fecha, ItemId                           
               order by ItemId) ECDE                                                                            
                            OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                       
                                         from SGF_ExpedienteCredito_Reconfirmacion                                                                                                         
                                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                        
  
    
       
       
          
            
              
                                         order by IdReconfirmacion desc) ECR                                         
                            OUTER APPLY (select distinct top 1 Nombre                                                                                                           
                                         FROM SGF_ADV                                   
                                         where AdvId = EC.AdvId  and EC.BancoId != 13                                                                                                       
                                         group by Nombre                                                                                                          
                                         order by Nombre desc)  AD                                                                                          
                            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
                            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                        
                            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                                       
                            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
                            LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                            
                            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                               
                            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                                       
                            WHERE EC.UserIdCrea = @UserId   -- where principal                                                                             
                            AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                         
                            AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                         
                            AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                      
                            AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                   
                            AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                                                                      
                            AND (EC.ExpedienteCreditoLocalId = 13)                                                                                                                         
                            AND (ISNULL(EC.IdSupervisor, 0) = 0)                                                   
                            AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                                                  
                            AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
                            AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                            
                            AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                           
                            AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                                              
                            /*AND ISNULL(P.IdSupervisor, 0) ! =  @TodosSupervisor                                                  
                            AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)*/);                                        
   
   
       
       
           
            
             
                 
                 
                   
                       
                      
            SELECT EC.ExpedienteCreditoId as Id,                       
                   P.DocumentoNum as Documento,                       
                   UPPER(P.Nombre) Nombre,                       
                   UPPER(P.ApePaterno) ApePaterno,                       
                   UPPER(P.ApeMaterno) ApeMaterno,                       
                   E.NombreCorto ,                       
                   LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
                   EC.FechaAgenda,                       
                   EC.FechaActua,                       
                   P.Celular,                       
                   P.Celular2,                       
                   P.Telefonos,                       
                   ISNULL(AD.Nombre, '') AdvNombre,                      
       --'' AdvNombre,                    
                   ISNULL(DL.DatosLaboralesId, 0)  DatosLaboralesId,                       
                   EC.Prioridad,                       
                   ISNULL(B.Nombre, '') [BancoNombre],                       
                   IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
                   ISNULL(CONT.NombreLargo, '') [Contactado],                       
                   ISNULL(INTE.NombreLargo, '') [Interesado],                       
                   ISNULL(MOTI.NombreLargo, '') [Motivo],                       
ISNULL(ECR.Comentario, '') [Comentario],                       
                   ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
                   ISNULL(RES.NombreLargo, '') [Resultado],                       
                   ISNULL(P.APDP, 0) [APDP],                       
                   ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
                   STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                
                   [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
                   --, CAST(IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) as varchar(5)) +                                                                       
                   --IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > =  2, ' dias', ' día') [LimiteDerivacion]                                                                      
            FROM SGF_ExpedienteCredito EC    -- from principal                                        
        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                         
            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                        
            OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                                                                                           
                         from SGF_DatosLaborales                                             
                         where PersonaId = EC.TitularId                                                                                                         
                         group by PersonaId, DatosLaboralesId                             
                         order by DatosLaboralesId desc) DL                                                      
            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                              
                         from SGF_ExpedienteCreditoDetalle                                                                                                         
                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                         group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                          
                         order by ItemId) ECDE                                                                            
            OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                           
                         from SGF_ExpedienteCredito_Reconfirmacion                                                                                                         
where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                     
                         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                      
                         order by IdReconfirmacion desc) ECR                                         
            OUTER APPLY (select distinct top 1 Nombre,AdvId                                                                                                           
                         FROM SGF_ADV                                                                                                         
       where AdvId = EC.AdvId                                                                                                         
                         group by Nombre ,AdvId                                                                                       
                         order by Nombre,AdvId desc)  AD                                                
            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                        
            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                        
            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                               
            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
            LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                           
            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                       
            WHERE EC.UserIdCrea = @UserId   -- where principal                                           
              AND (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                         
              AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                         
              AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                      
              AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                   
              AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                       
              AND (EC.ExpedienteCreditoLocalId = 13)                             
              AND (ISNULL(EC.IdSupervisor, 0) = 0)                                                                                                  
              AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                                                                      
              AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                                                           
       AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                           
              AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                           
              AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                    
     and NOT (EC.AdvId != 0 AND EC.BancoId = 13)                     
              --AND ISNULL(P.IdSupervisor, 0) ! =  @TodosSupervisor                                                  
              --AND (IIF(DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)) > 0, DATEDIFF(day, @FECHAACTUAL, DATEADD(day, 3, EC.FechaCrea)), 0) = @LimiteDerivacion OR @LimiteDerivacion = -1)                                          
            ORDER BY EC.FechaActua DESC                                                                                                                                
            OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                                         
        END                                            
    END                                           
                                           
    -- ADMIN ----------------------------------------------------------------------------------------------------------------------------------                                                                      
    ELSE IF(@CargoId = 1)                                                 
    BEGIN                                                                                                                  
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                                 
                        FROM SGF_ExpedienteCredito EC                                        
                        LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                         
                        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                       
                        OUTER APPLY (select distinct top 1 Nombre                                                       
            FROM SGF_ADV                                                                                                         
                                     where AdvId = EC.AdvId                                                                                                         
                                     group by Nombre                                                                                                          
                                     order by Nombre desc)  AD                                        
                        OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                                                                 
                                     from SGF_DatosLaborales                                                                                                         
                                     where PersonaId = EC.TitularId                                                                                                         
                                     group by PersonaId, DatosLaboralesId                                                                                                          
                                     order by DatosLaboralesId desc)  DL                                                                                                
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                         
                  from SGF_ExpedienteCreditoDetalle                                                
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                                     
                                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                  
                                     order by ItemId) ECDE                                                                                           
                        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                    
                                     from SGF_ExpedienteCredito_Reconfirmacion                                           
                where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                             
 
    
       
       
          
            
              
               
                                     order by IdReconfirmacion desc) ECR                                        
                        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                                                                      
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
                        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                        
                        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
                        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
                        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                        
                        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                 
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                         
                          AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                           
                          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                       
                          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                       
                          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                            
                          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                             
                          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                                                                                                   
                          AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                                 
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
               LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
               EC.FechaAgenda,                       
               EC.FechaActua,                       
               P.Celular,                       
               P.Celular2,                       
               P.Telefonos,                       
               ISNULL(AD.Nombre, '') AdvNombre,                       
               ISNULL(DL.DatosLaboralesId, 0)  DatosLaboralesId,                       
               EC.Prioridad,                       
               ISNULL(B.Nombre, '') [BancoNombre],                    
               IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'), ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
               ISNULL(CONT.NombreLargo, '') [Contactado],                       
               ISNULL(INTE.NombreLargo, '') [Interesado],                       
               ISNULL(MOTI.NombreLargo, '') [Motivo],                       
               ISNULL(ECR.Comentario, '') [Comentario],                       
               ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
               ISNULL(RES.NombreLargo, '') [Resultado],                       
               ISNULL(P.APDP, 0) [APDP],                      
               ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
               [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
        FROM SGF_ExpedienteCredito EC                                               
        LEFT JOIN SGF_Solicitud sol on sol.SolicitudId = EC.SolicitudId                                         
        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                   
        OUTER APPLY (select distinct top 1 Nombre                                                       
                     FROM SGF_ADV                                                 
                     where AdvId = EC.AdvId                                                     
                     group by Nombre                                                                                                          
                     order by Nombre desc)  AD                                                                                                     
        OUTER APPLY (select distinct top 1 PersonaId, DatosLaboralesId                                                                
                     from SGF_DatosLaborales                                                                                                         
                     where PersonaId = EC.TitularId                                                                                                         
                     group by PersonaId, DatosLaboralesId                                                                                                          
                     order by DatosLaboralesId desc)  DL                                              
        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                           
                     from SGF_ExpedienteCreditoDetalle                                                  
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                
                     order by ItemId) ECDE                                                                                           
        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                 
                     from SGF_ExpedienteCredito_Reconfirmacion                                                              
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                                                         
                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                                           
                     order by IdReconfirmacion desc) ECR                                        
        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                                                                                                               
        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                         
    LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                                   
        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                         
        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                     
        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                     
        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                                
        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                        
          AND (sol.IdOficina = @AgenciaId  or @AgenciaId = 0)                                        
          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                                                                                        
          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                          
          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                         
          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                        
          AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                            
          AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                        
          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                                   
          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                  
          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                                                                            
          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                          
          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)            
        ORDER BY EC.FechaActua DESC                                                
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                        
    END                                                    
   
    ---- BACKOFFICE AND OPERACIONES ---------------------------------------------------------------------------------------------------------------------------------------  
    ELSE IF (@CargoId = 31 or @CargoId = 48)     
  BEGIN                                                                                                                                                                              
        SET @Success = (SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                         
                        FROM SGF_ExpedienteCredito EC                                                                                                                          
                        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                           
                        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId        
                        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                       
                                     from SGF_ExpedienteCreditoDetalle                                                      
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                         
                                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                      
                                     order by ItemId) ECDE                                                                                    
                        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado      
                                     from SGF_ExpedienteCredito_Reconfirmacion                                                                                                     
                                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                      
                                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                        
             order by IdReconfirmacion desc) ECR                                           
                        OUTER APPLY (select distinct top 1 Nombre                                                                                                       
                                     FROM SGF_ADV                                                                                                     
                                     where AdvId = EC.AdvId                                                                            
                                     group by Nombre                        
                                     order by Nombre desc)  AD                                                                                                         
                        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                            
                        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                             
                        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                         
                        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                         
                        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                 
                        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                
                        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                       
                        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null) AND        
                              (ss.IdOficina = @AgenciaId  or @AgenciaId = 0) AND        
                              (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null) AND        
                              (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0) AND        
                              (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0) AND        
                              (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
                              (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1) AND        
                              ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor AND        
                              (MONTH(EC.FechaActua) = @Mes OR @Mes = 0) AND        
                              (YEAR(EC.FechaActua) = @Anio OR @Anio = 0) AND        
                              (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0) AND        
                              (EC.BancoId = @BancoId OR @BancoId = 0) AND        
                              (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)        
                              --(SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13) = 0 AND        
                              --EC.BancoId != 13  
         )        
                                                                                                                                  
        SELECT EC.ExpedienteCreditoId as Id,                         
               P.DocumentoNum as Documento,                         
               UPPER(P.Nombre) Nombre,                         
               UPPER(P.ApePaterno) ApePaterno,                         
               UPPER(P.ApeMaterno) ApeMaterno,                         
               E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                         
               EC.FechaAgenda,                         
               EC.FechaActua,                         
               ISNULL(AD.Nombre, '') AdvNombre,                         
               EC.Prioridad,                         
               ISNULL(B.Nombre, '') [BancoNombre],                         
               IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'),                         
               ISNULL(ECDE.Observacion, ''), '') [Observacion],                         
               ISNULL(CONT.NombreLargo, '') [Contactado],                         
               ISNULL(INTE.NombreLargo, '') [Interesado],                         
               ISNULL(MOTI.NombreLargo, '') [Motivo],                         
               ISNULL(ECR.Comentario, '') [Comentario],                         
               ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                         
               ISNULL(RES.NombreLargo, '') [Resultado],                         
               ISNULL(P.APDP, 0) [APDP],                         
               ISNULL(P.PubliAPDP, 0) [PubliAPDP],                         
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                         
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                         
               STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                         
               [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                                
        FROM SGF_ExpedienteCredito EC              
        LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                           
        INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                                        
        OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                 
                     from SGF_ExpedienteCreditoDetalle                                                                 
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                            
                     group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                               
                     order by ItemId) ECDE                                                                                    
        OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                       
                     from SGF_ExpedienteCredito_Reconfirmacion                                                                                                     
                     where ExpedienteCreditoId = EC.ExpedienteCreditoId                                         
                     group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                        
                     order by IdReconfirmacion desc) ECR                                           
        OUTER APPLY (select distinct top 1 Nombre                                                                                                       
                     FROM SGF_ADV                                                                  
                     where AdvId = EC.AdvId                                                                                                     
                     group by Nombre                                                                                                      
         order by Nombre desc)  AD                                                                                   
        LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                            
        INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                             
        LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                         
        LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                     
        LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                                 
        LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                                
        LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                    
        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null) AND        
              (ss.IdOficina = @AgenciaId  or @AgenciaId = 0) AND        
              (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null) AND        
              (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0) AND        
              (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0) AND        
              (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
              (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1) AND        
              ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor AND        
              (MONTH(EC.FechaActua) = @Mes OR @Mes = 0) AND        
              (YEAR(EC.FechaActua) = @Anio OR @Anio = 0) AND        
              (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0) AND        
              (EC.BancoId = @BancoId OR @BancoId = 0) AND        
              (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)         
              --(SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13) = 0 AND        
              --EC.BancoId != 13        
        ORDER BY EC.FechaActua DESC        
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;        
    END   
                                                                                                                     
    -- OTROS ROLES ---------------------------------------------------------------------------------------------------------------------------                                             
    ELSE                                                                                                                                                                     
    BEGIN                                                                                                                                                                            
        SET @Success = (      
                      SELECT ISNULL(COUNT(EC.ExpedienteCreditoId), 0)                                                                                       
                      FROM SGF_ExpedienteCredito EC                                                                                                                        
                 LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                         
                          INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                                                                                
                          OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                     
                                       from SGF_ExpedienteCreditoDetalle                                                    
                                       where ExpedienteCreditoId = EC.ExpedienteCreditoId              
                                       group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                                    
                                       order by ItemId) ECDE                                                                                  
                          OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                             
  
    
        
                                       from SGF_ExpedienteCredito_Reconfirmacion                                                                                                   
                                       where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                    
                                       group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                           
  
    
          
                                       order by IdReconfirmacion desc) ECR                                         
                          OUTER APPLY (select distinct top 1 Nombre                                                                                                     
                                       from SGF_ADV                                                                                                   
                                       where AdvId = EC.AdvId                                              
                                       group by Nombre                                                                                                    
                                       order by Nombre desc)  AD                                                                                                       
                          LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                          
                          INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                           
                          LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                       
                          LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                       
                          LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                               
                          LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                              
                          LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                  
                      WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                          
                          AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                          
                          AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                                          
                          AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                                                                                      
                          AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                                                                        
 AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                                                                                                   
                          AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                     
                          AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                                                           
                          AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                            
                          AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                       
                          AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                                                      
                          AND (EC.BancoId = @BancoId OR @BancoId = 0)                                    
                          AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                        
                          AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                      
                          AND EC.BancoId != 13      
     );                                                                               
                                                                                                                                
        SELECT EC.ExpedienteCreditoId as Id,                       
            P.DocumentoNum as Documento,                       
            UPPER(P.Nombre) Nombre,                       
            UPPER(P.ApePaterno) ApePaterno,                       
            UPPER(P.ApeMaterno) ApeMaterno,                       
            E.NombreCorto , LEFT(E.NombreCorto, 3) NombreCortoFree ,                       
            EC.FechaAgenda,                       
            EC.FechaActua,                       
            ISNULL(AD.Nombre, '') AdvNombre,                       
            EC.Prioridad,                       
            ISNULL(B.Nombre, '') [BancoNombre],                       
            IIF(EC.Prioridad IN ('URGENTE', 'RECONFIRMADO'),                       
            ISNULL(ECDE.Observacion, ''), '') [Observacion],                       
            ISNULL(CONT.NombreLargo, '') [Contactado],                       
            ISNULL(INTE.NombreLargo, '') [Interesado],                       
            ISNULL(MOTI.NombreLargo, '') [Motivo],                       
            ISNULL(ECR.Comentario, '') [Comentario],                       
            ISNULL(SUBMOT.NombreLargo, '') [SubMotivo],                       
            ISNULL(RES.NombreLargo, '') [Resultado],                       
            ISNULL(P.APDP, 0) [APDP],                       
            ISNULL(P.PubliAPDP, 0) [PubliAPDP],                       
            STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],                       
            STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Nombre) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],                       
            STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 AND BancoId != 13 order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],                       
            [dbo].[FN_ObtenerDataBancoEvaluacion](EC.ExpedienteCreditoId, @UserId) [ListAuthorized]                              
        FROM SGF_ExpedienteCredito EC                                         
            LEFT JOIN SGF_Solicitud ss on ss.SolicitudId = EC.SolicitudId                                               
            INNER JOIN SGF_Persona P ON P.PersonaId = EC.TitularId                                   
            OUTER APPLY (select distinct top 1 ExpedienteCreditoId, Observacion, Fecha, ItemId                                                                                                     
                         from SGF_ExpedienteCreditoDetalle                                                                                                
                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                                          
                         group by Observacion, ExpedienteCreditoId, Fecha, ItemId                                                                                             
                         order by ItemId) ECDE                                                                                  
            OUTER APPLY (select distinct top 1 IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                     
                         from SGF_ExpedienteCredito_Reconfirmacion                                                                                                   
                         where ExpedienteCreditoId = EC.ExpedienteCreditoId                                       
                         group by IdReconfirmacion, ExpedienteCreditoId, Contactado, Interesado, Comentario, Motivo, FechaCrea  , SubMotivo, Resultado                                                                                      
                         order by IdReconfirmacion desc) ECR                                         
            OUTER APPLY (select distinct top 1 Nombre                                                                                                     
                         from SGF_ADV                                                                                                   
                         where AdvId = EC.AdvId                                                                                                   
                         group by Nombre                                                          
                         order by Nombre desc)  AD                                                                                 
            LEFT JOIN SGB_Banco B ON EC.BancoId = B.BancoId                                     
            INNER JOIN SGF_Parametro E ON E.ParametroId = EC.EstadoProcesoId and E.DominioId = 38                                           
            LEFT JOIN SGF_Parametro CONT ON CONT.ParametroId = ECR.Contactado and CONT.DominioId = 130                                                       
            LEFT JOIN SGF_Parametro INTE ON INTE.ParametroId = ECR.Interesado and INTE.DominioId = 131                                                                                   
            LEFT JOIN SGF_Parametro MOTI ON MOTI.ParametroId = ECR.Motivo and MOTI.DominioId = 136                                                                               
            LEFT JOIN SGF_Parametro SUBMOT ON SUBMOT.ParametroId = ECR.SubMotivo and SUBMOT.DominioId = 140                                                                              
            LEFT JOIN SGF_Parametro RES ON RES.ParametroId = ECR.Resultado and RES.DominioId = 133                                                  
        WHERE (P.Nombre+' '+P.ApePaterno+' '+P.ApeMaterno like '%'+@Nombres+'%' or @Nombres = '' or @Nombres is null)                                          
            AND (ss.IdOficina = @AgenciaId  or @AgenciaId = 0)                                                          
            AND (P.DocumentoNum = @DocumentoNum or @DocumentoNum  = '' or @DocumentoNum is null)                                   
            AND (EC.EstadoProcesoId = @EstadoProcesoId OR @EstadoProcesoId = 0)                                                
            AND (ISNULL(EC.EnObservacion, 0) = @EnObservacion OR @TodosEstado = 0)                                        
            AND (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0)                      
            AND (ISNULL(EC.IdSupervisor, 0) = @SupervisorId OR @SupervisorId = -1)                                                                                                                                             
            AND ISNULL(EC.IdSupervisor, 0) ! =  @TodosSupervisor                                                                                                                                           
            AND (MONTH(EC.FechaActua) = @Mes OR @Mes = 0)                                                            
            AND (YEAR(EC.FechaActua) = @Anio OR @Anio = 0)                                                                                                       
            AND (ISNULL(EC.CanalVentaID, 0) = @CanalVentaId OR @CanalVentaId = 0)                               
            AND (EC.BancoId = @BancoId OR @BancoId = 0)                                                                                                                   
            AND (EC.ExpedienteCreditoId = @expedienteId OR @expedienteId = 0)                        
            AND 0 = (SELECT count(*) FROM SGF_Evaluaciones AS eva where eva.ExpedienteCreditoId = EC.ExpedienteCreditoId and eva.BancoId = 13)                      
            AND EC.BancoId != 13                      
        ORDER BY EC.FechaActua DESC                                                               
        OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;          
        
    END                   
END 