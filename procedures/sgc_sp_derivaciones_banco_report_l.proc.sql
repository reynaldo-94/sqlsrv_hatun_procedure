/*--------------------------------------------------------------------------------------                                                                                                                                                   
' Nombre          : [dbo].[SGC_SP_Derivaciones_Banco_Report_L]                                                                                                                                                                    
' Objetivo        : Obtener datos para descargar el Reporte de Derivaciones                                                                                                                      
' Creado Por      : FRANCISCO LAZARO                                                                                                                                  
' Día de Creación : 20-10-2022                                                                                                                                                                
' Requerimiento   : SGC                                                                                                                                
' Cambios  :          
  07/02/2023 - Reynaldo Cauche - Se agrego los campos CelularSupervisor,Direccion-dist-dpto-prov del negocio   
  09/02/2023 - Reynaldo Cauche - Se agrego a los campos nuevos el where tipodireccion 3 o tipodireccion 2    
'--------------------------------------------------------------------------------------*/             
CREATE PROCEDURE SGC_SP_Derivaciones_Banco_Report_L          
(@Mes INT,                                                                 
 @Anio INT,                                                                  
 @BancoId INT,                                                                
 @LocalId INT = 0,                               
 @AgenciaId INT = 0,             
 @Success INT OUTPUT)           
AS           
BEGIN           
    SET @Success = (select count(*) from SGF_ExpedienteCredito EC        
                    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId        
                    INNER JOIN SGF_DatosDireccion DD ON DD.DatosDireccionId = (SELECT top 1 DatosDireccionId        
                                                                               FROM SGF_DatosDireccion AS d2        
                                                                               WHERE d2.PersonaId = EC.TitularId AND d2.EsFijo = 1        
                                                                               ORDER BY DatosDireccionId DESC)        
                    INNER JOIN SGF_DatosLaborales DL ON DL.DatosLaboralesId = (SELECT top 1 DatosLaboralesId        
                                                                               FROM SGF_DatosLaborales AS d3        
                                                                               WHERE d3.PersonaId = EC.TitularId        
                                                                               ORDER BY DatosLaboralesId DESC)        
                    LEFT  JOIN SGF_Giro GI ON GI.GiroId = DL.GiroId AND GI.EsActivo = 1        
                    INNER JOIN SGF_Solicitud SOL ON SOL.SolicitudId = Ec.SolicitudId        
                    LEFT JOIN SGF_Oficina O ON O.IdOficina = SOL.IdOficina        
                    LEFT  JOIN SGF_User S ON S.EmpleadoId = EC.IdSupervisor AND S.CargoId = 29        
                    INNER JOIN SGF_Ubigeo dpto ON dpto.CodUbigeo = SUBSTRING(DD.ubigeo,1,2) + '0000'        
                    INNER JOIN SGF_Ubigeo prov ON prov.CodUbigeo = SUBSTRING(DD.ubigeo,1,4) + '00'        
                    INNER JOIN SGF_Ubigeo dist ON dist.CodUbigeo = DD.ubigeo        
                    WHERE ((MONTH(EC.FechaEvaluacion) = @Mes AND YEAR(EC.FechaEvaluacion) = @Anio) OR                                                 
                           (MONTH(EC.FechaEvaluacion) = IIF(@Mes = 12, 1, @Mes - 1) AND YEAR(EC.FechaEvaluacion) = IIF(@Mes = 12, @Anio - 1, @Anio))) AND         
                   (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
                          (EC.BancoId = @BancoId OR @BancoId = 0) AND        
                          (EC.EstadoProcesoId = 5) AND        
                          ISNUll(EC.FechaDescarga, '') = '' AND        
                          (@AgenciaId = O.IdOficina OR @AgenciaId = 0))        
        
    SELECT ISNULL(P.Nombre + ' ' + P.ApePaterno + ' ' + P.ApeMaterno, '') [Nombres],           
           ISNULL(P.DocumentoNum, '') [DocumentoNum],           
           ISNULL(DD.Direccion, '') [Direccion],                                                                                              
           ISNULL(CONVERT(varchar, EC.FechaEvaluacion, 103) + ' ' + CONVERT(varchar, EC.FechaEvaluacion, 108), '') [FechaEvaluacion],                                                                                 
           ISNULL(O.CodTopaz, '') [CodTopaz],                    
           ISNULL(O.Nombre, '') [Oficina],                    
           ISNULL(SOL.Analista,'') [Analista],                                                                                     
           ISNULL(SOL.IdAnalista, 0) [IdAnalista],                                                                                                             
           ISNULL((Select top 1 Nombre from SGF_ADV where AdvId=EC.AdvId AND EsActivo=1),'') [ADV],                                     
           ISNULL(SOL.MontoPropuesto, 0) [MontoPropuesto],                        
           EC.ExpedienteCreditoId,                                                                                                                                    
           ISNULL(S.Nombres + ' ' + S.ApePaterno + ' ' + S.ApeMaterno, '') [Supervisor],                    
           ISNULL(S.DocumentoNum, '') [DNISupervisor],     
           ISNULL(S.Celular, '') [CelularSupervisor],         
           ISNULL((SELECT top 1 DocumentoNum FROM SGF_Persona C                                                                                            
                   inner join SGF_Evaluaciones E on E.PersonaId = C.PersonaId and EC.ExpedienteCreditoId = E.ExpedienteCreditoId                                                                                         
                   where E.TipoPersonaId = 2), '') [DNIConyugue],                                                                 
           ISNULL(DPTO.Nombre, '') [Dpto],                                                                                        
           ISNULL(PROV.Nombre, '') [Prov],                                     
           ISNULL(DIST.Nombre, '') [Dist],                                                                                                     
           ISNULL(P.Telefonos, '') [Telefonos],                                                   
           ISNULL(P.Celular, '') [Celular],                                                                                                     
           ISNULL(P.Celular2, '') [Celular2],                                                          
           ISNULL(P.Correo, '') [Correo],        
           ISNULL(case DL.AntiguedadLaboral        
                  when '' then '-'        
                  when null then '-'        
                  else  CONVERT(varchar, cast(DL.AntiguedadLaboral as date), 103) end, '') [AntiguedadLaboral],        
           ISNULL(DL.DiasPago, '')[DiasPago],                   
           ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(GI.Nombre, Char(9), ' '), Char(10), ' '), Char(13), ' '), Char(59), ' '), ',', ''), '-') [GiroNegocio],         
           ISNULL(DL.IngresoNeto, 0) [IngresoBruto],        
           ISNULL(CONVERT(varchar, EC.FechaDescarga, 103) + ' ' + CONVERT(varchar, EC.FechaDescarga, 108), CONVERT(varchar, dbo.GETDATE(), 103) + ' ' + CONVERT(varchar, dbo.GETDATE(), 108)) [FechaDescarga],        
           ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(EC.ObsDerivacion, Char(9), ''), Char(10), ''), Char(13), ''), Char(59), ''), '') [ObsDerivacion],        
           ISNULL(P.DiaLlamada, '') [DiaLlamada],        
           ISNULL(P.Horario, '') [Horario],        
           case when EC.FechaDescarga is null then 'SI' else 'NO' end [ActualizaFecha],    
               
           (SELECT TOP(1) sdd.Direccion FROM SGF_DatosDireccion as sdd where sdd.PersonaId = Ec.TitularId And (TipoDireccionId = 3 OR TipoDireccionId = 2)) [DireccionNegocio] ,    
           (SELECT TOP(1) sub.Nombre FROM SGF_DatosDireccion as sdd INNER JOIN SGF_Ubigeo as sub ON sub.CodUbigeo = SUBSTRING(sdd.ubigeo,1,2) + '0000' where sdd.PersonaId = Ec.TitularId And (TipoDireccionId = 3 OR TipoDireccionId = 2)) [DptoNegocio],    
           (SELECT TOP(1) sub.Nombre FROM SGF_DatosDireccion as sdd INNER JOIN SGF_Ubigeo as sub ON sub.CodUbigeo = SUBSTRING(sdd.ubigeo,1,4) + '00' where sdd.PersonaId = Ec.TitularId And (TipoDireccionId = 3 OR TipoDireccionId = 2)) [ProvNegocio],    
           (SELECT TOP(1) sub.Nombre FROM SGF_DatosDireccion as sdd INNER JOIN SGF_Ubigeo as sub ON sub.CodUbigeo = sdd.ubigeo where sdd.PersonaId = Ec.TitularId And (TipoDireccionId = 3 OR TipoDireccionId = 2)) [DistNegocio]    
    from SGF_ExpedienteCredito EC        
    INNER JOIN SGF_Persona P ON P.PersonaId=EC.TitularId        
    INNER JOIN SGF_DatosDireccion DD ON DD.DatosDireccionId = (SELECT top 1 DatosDireccionId        
                                                               FROM SGF_DatosDireccion AS d2        
                                                               WHERE d2.PersonaId = EC.TitularId AND d2.EsFijo = 1        
                                                               ORDER BY DatosDireccionId DESC)        
    INNER JOIN SGF_DatosLaborales DL ON DL.DatosLaboralesId = (SELECT top 1 DatosLaboralesId        
                                                               FROM SGF_DatosLaborales AS d3        
                                                               WHERE d3.PersonaId = EC.TitularId        
                                                               ORDER BY DatosLaboralesId DESC)        
    LEFT  JOIN SGF_Giro GI ON GI.GiroId = DL.GiroId AND GI.EsActivo = 1        
    INNER JOIN SGF_Solicitud SOL ON SOL.SolicitudId = Ec.SolicitudId        
    LEFT JOIN SGF_Oficina O ON O.IdOficina = SOL.IdOficina        
    LEFT  JOIN SGF_User S ON S.EmpleadoId = EC.IdSupervisor AND S.CargoId = 29        
    INNER JOIN SGF_Ubigeo dpto ON dpto.CodUbigeo = SUBSTRING(DD.ubigeo,1,2) + '0000'        
    INNER JOIN SGF_Ubigeo prov ON prov.CodUbigeo = SUBSTRING(DD.ubigeo,1,4) + '00'        
    INNER JOIN SGF_Ubigeo dist ON dist.CodUbigeo = DD.ubigeo        
    WHERE ((MONTH(EC.FechaEvaluacion) = @Mes AND YEAR(EC.FechaEvaluacion) = @Anio) OR                                                 
          (MONTH(EC.FechaEvaluacion) = IIF(@Mes = 12, 1, @Mes - 1) AND YEAR(EC.FechaEvaluacion) = IIF(@Mes = 12, @Anio - 1, @Anio))) AND         
    (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
          (EC.BancoId = @BancoId OR @BancoId = 0) AND        
          (EC.EstadoProcesoId = 5) AND        
          ISNUll(EC.FechaDescarga, '') = '' AND        
          (@AgenciaId = O.IdOficina OR @AgenciaId = 0)        
    ORDER BY EC.FechaEvaluacion desc        
END