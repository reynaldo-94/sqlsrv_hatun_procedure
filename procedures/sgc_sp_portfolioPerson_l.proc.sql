/*--------------------------------------------------------------------------------------                                                                                                                                               
' Nombre          : [dbo].[SGC_SP_PortfolioPerson_L]                                                                                                                                                                
' Objetivo        : OBTIENE LOS DATOS DE LA TABLA PERSONA PARA "CARTERA"                                                                                                                  
' Creado Por      : CRISTIAN SILVA                                                                                                                                 
' Día de Creación : 01-02-2023                                                                                                                                                            
' Requerimiento   : SGC                                                                                                                                                         
' Modificado por  :                                                                                                                                   
' Día de Modificación :                               
  - 11/05/2023 - cristian silva   - Se modifico al nuevo filtro de cartera unido a samuel flores(SGC_SP_Persona_Update_Max y SGC_SP_Max_ExpedienteCredito)                    
  - 15/05/2023 - Reynaldo Cauche  - se medifico la forma en que se hace el filtro para el campo FechaEstadoMax                  
  - 15/05/2023 - Reynaldo Cauche  - Se agrego los campos Celular1,Celuar2, Telefonos          
  - 22/05/2023 - Reynaldo Cauche  - Se agrego el parametro supervisorId      
  - 01/06/2023 - Francisco Lazaro - Se agrego campos Nombre, ApePaterno, ApeMaterno. Se modifica UPPER(BancoNombre)
  - develop-cartera_by_id 14/11/2023    - Reynaldo Cauche - Se agrego el campo PersonaId
'--------------------------------------------------------------------------------------*/                                                                                           
ALTER PROCEDURE [dbo].[SGC_SP_PortfolioPerson_L]                                                                       
(@Pagina int,                   
 @Tamanio int,                   
 @Nombre varchar(25) = '',                   
 @Documento varchar(15) = '',                    
 @EstadoId int = NULL,                   
 @MontoStart varchar(15) = NULL,                   
 @MontoEnd varchar(15) = NULL,                   
 @TiempoStart varchar(15) = NULL,                   
 @TiempoEnd varchar(15) = NULL,                   
 @Establecimiento int = NULL,          
 @SupervisorId int = NULL,    
 @UserIdCrea int = 0,
 @PersonaId int = 0,               
 @Success int output)                                               
AS                                                                            
BEGIN                   
      DECLARE @RolId INT = ISNULL((SELECT CargoId FROM SGF_USER WHERE UserId = @UserIdCrea), 0);    
      DECLARE @RegionZonaId INT = ISNULL(IIF(@RolId != 52, 0, (SELECT RegionZonaId FROM SGF_User US    
                                                      LEFT JOIN SGF_JefeRegional JR ON JR.JefeRegionalId = US.EmpleadoId    
                                                      LEFT JOIN SGF_RegionZona RZ ON RZ.RegionZonaId = JR.RegionId    
                                                      WHERE US.UserId = @UserIdCrea)), 0)             
                 
      DECLARE @montoSta float = (iif(ISNULL(@MontoStart, '') = '', 0, convert(float, @MontoStart)))                         
      DECLARE @montoEn float = (iif(ISNULL(@MontoEnd, '') = '', 0, convert(float, @MontoEnd)))                      
                   
      set @Success = (Select COUNT(P.PersonaId)                       
                        from SGF_Persona P                          
                        LEFT join SGF_Parametro PA on PA.ParametroId = P.EstadoMax AND PA.DominioId = 38                              
                        where (P.ProveedorLocalId = @Establecimiento or ISNULL(@Establecimiento, '') = 0) AND                   
                        ((P.MontoMax BETWEEN @montoSta AND  @montoEn) or (@montoSta = 0 AND @montoEn  = 0)) AND                   
                        (Trim(P.Nombre) + ' ' +  Trim(P.ApePaterno)  + ' ' + Trim(P.ApeMaterno) like '%' + trim(@Nombre) + '%' or @Nombre = '' or @Nombre is null) AND                   
                        (trim(P.DocumentoNum) like '%' + trim(@Documento) + '%' or @Documento = '' or @Documento is null ) AND                   
                        (P.EstadoMax = @EstadoId or @EstadoId= 0) AND                   
                              -- ((P.FechaEstadoMax BETWEEN substring(convert(varchar(23), convert(datetime, @TiempoStart), 26), 0, 11) AND substring(convert(varchar(23), convert(datetime, @TiempoEnd), 26), 0, 11)) or (ISNULL(@TiempoStart, '') = '' AND ISNULL(@TiempoEnd, '')= ''))                     
                              -- ((P.FechaEstadoMax BETWEEN convert(datetime, @TiempoStart) AND convert(datetime, @TiempoEnd)) or (@TiempoStart = '' AND @TiempoEnd = '')) AND               
                        ((P.FechaEstadoMax BETWEEN convert(date,@TiempoStart,103) AND convert(date,@TiempoEnd,103)) or (ISNULL(@TiempoStart, '') = '' AND ISNULL(@TiempoEnd, '') = '')) AND          
                        (P.IdSupervisor = @SupervisorId OR @SupervisorId = 0) AND
                        (P.PersonaId = @PersonaId OR @PersonaId = 0));          
               
      Select P.PersonaId [Id],                   
           P.DocumentoNum [Documento],                   
           P.Nombre + ' ' + P.ApePaterno + ' ' + P.ApeMaterno [Nombres],          
           P.Nombre,      
           P.ApePaterno,      
           P.ApeMaterno,      
           ISNULL(LEFT((PA.NombreCorto), 3),'-') [NomEstado],                   
           isnull(convert(varchar, P.FechaEstadoMax, 3), '') [FechaActua],                   
           isnull(convert(varchar, P.FechaCrea, 3), '') [FechaCrea],                   
           ISNULL(P.MontoMax,0) [Monto],                   
           ISNULL(P.EstadoMax,0) [EstadoId],                 
           ISNULL(P.Celular,'') [Celular],                  
           ISNULL(P.Celular2,'') [Celular2],                                
           ISNULL(P.Telefonos,'') [Telefonos],        
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 AND   
            ((@RolId in (4, 11, 1, 56) or (@RolId = 52 and @RegionZonaId in (6))) or ((@RolId not in (4, 11, 1, 56) and not (@RolId = 52 and @RegionZonaId in (6))) and BancoId != 13)) order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoId],      
  
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), UPPER(Nombre)) FROM SGB_Banco WHERE Activo = 1 AND   
            ((@RolId in (4, 11, 1, 56) or (@RolId = 52 and @RegionZonaId in (6))) or ((@RolId not in (4, 11, 1, 56) and not (@RolId = 52 and @RegionZonaId in (6))) and BancoId != 13)) order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoNombre],  
      
           STUFF((SELECT ',' + CONVERT(NVARCHAR(20), Logo) FROM SGB_Banco WHERE Activo = 1 AND   
            ((@RolId in (4, 11, 1, 56) or (@RolId = 52 and @RegionZonaId in (6))) or ((@RolId not in (4, 11, 1, 56) and not (@RolId = 52 and @RegionZonaId in (6))) and BancoId != 13)) order by BancoId DESC FOR xml path('')), 1, 1, '') [ListBancoLogo],    
      
           [dbo].[FN_ObtenerDataBancoEvaluacionCartera](P.PersonaId, @UserIdCrea) [ListAuthorized]        
            from SGF_Persona P                          
            LEFT join SGF_Parametro PA on PA.ParametroId = P.EstadoMax AND PA.DominioId = 38                              
            where (P.ProveedorLocalId = @Establecimiento or ISNULL(@Establecimiento, '') = 0) AND                   
            ((P.MontoMax BETWEEN @montoSta AND  @montoEn) or (@montoSta = 0 AND @montoEn  = 0)) AND                   
            (Trim(P.Nombre) + ' ' +  Trim(P.ApePaterno)  + ' ' + Trim(P.ApeMaterno) like '%' + trim(@Nombre) + '%' or @Nombre = '' or @Nombre is null) AND                   
            (trim(P.DocumentoNum) like '%' + trim(@Documento) + '%' or @Documento = '' or @Documento is null ) AND                
            (P.EstadoMax = @EstadoId or @EstadoId= 0) AND                   
            -- ((P.FechaEstadoMax BETWEEN substring(convert(varchar(23), convert(datetime, @TiempoStart), 26), 0, 11) AND substring(convert(varchar(23), convert(datetime, @TiempoEnd), 26), 0, 11)) or (ISNULL(@TiempoStart, '') = '' AND ISNULL(@TiempoEnd, '')= ''))                     
            -- ((P.FechaEstadoMax BETWEEN convert(datetime, @TiempoStart) AND convert(datetime, @TiempoEnd)) or (@TiempoStart = '' AND @TiempoEnd = '')) AND                   
            ((P.FechaEstadoMax BETWEEN convert(date,@TiempoStart,103) AND convert(date,@TiempoEnd,103)) or (ISNULL(@TiempoStart, '') = '' AND ISNULL(@TiempoEnd, '') = '')) AND
            (P.IdSupervisor = @SupervisorId OR @SupervisorId = 0) AND
            (P.PersonaId = @PersonaId OR @PersonaId = 0)
      order by P.MontoMax desc                                     
      offset @Pagina * @Tamanio rows fetch next @Tamanio rows only;                     
end