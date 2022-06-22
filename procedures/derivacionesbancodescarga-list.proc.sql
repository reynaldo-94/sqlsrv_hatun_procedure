/*--------------------------------------------------------------------------------------                                                                                        
' Nombre          : [dbo].[SGC_SP_Derivaciones_Banco_L_Reporte]                                                                                                         
' Objetivo        : Obtener datos para descargar el Reporte de Derivaciones                                                           
' Creado Por      : REYNALDO CAUCHE                                                                       
' Día de Creación : 09-03-2022                                                                                                     
' Requerimiento   : SGC                                                                                                  
' Modificado por  : Reynaldo Cauche                                                                                
' Día de Modificación : 11-05-2022                                                                                              
'--------------------------------------------------------------------------------------*/                                    
CREATE PROCEDURE SGC_SP_Derivaciones_Banco_L_Reporte      
(@Mes int,      
 @Anio int,      
 @LocalId int,      
 @BancoId int,    
 @RolId int)      
AS      
BEGIN             
 -- Actualiza cuando es rol Convenios    
   If(@RolId = 27)              
      BEGIN         
    UPDATE SGF_ExpedienteCredito            
    SET FechaDescarga = dbo.getdate()            
    where ExpedienteCreditoId in            
    (Select  EC.ExpedienteCreditoId                
    from SGF_ExpedienteCredito EC                                                                        
    INNER JOIN sgf_expedientecreditodetalle ECD ON ECD.ExpedienteCreditoId = EC.ExpedienteCreditoId                                                                     
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
    where MONTH(ECD.Fecha) = @Mes AND                                             
       YEAR(ECD.Fecha) = @Anio AND                                        
       (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
       (EC.BancoId = @BancoId OR @BancoId = 0) AND          
       (ECD.Observacion LIKE 'CAMBIO DE AGENCIA A :%' OR ECD.Observacion='CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL')                          
    and ISNUll(EC.FechaDescarga,'') = ''            
    )   
   END                     
 Select P.Nombre + ' ' + P.ApePaterno + ' ' + P.ApeMaterno [Nombres],                                            
         P.DocumentoNum,                                  
         DD.Direccion,                                     
         convert(varchar, ECD.Fecha, 103) + ' ' + CONVERT(varchar,ECD.Fecha,108)  as FechaEvaluacion,                        
         O.CodTopaz,                                            
         O.Nombre [Oficina],                                            
         isnull(SOL.Analista,'') [Analista],                            
         ISNULL(SOL.IdAnalista, 0) [IdAnalista],                            
         isnull((Select top 1 Nombre from SGF_ADV where LocalId=EC.ExpedienteCreditoLocalId AND EsActivo=1),'') [ADV],                                            
         SOL.MontoPropuesto,                                            
         dbo.FN_Fechas_Derivacion(ECD.ExpedienteCreditoId) [Fechas],                                            
         ECD.ExpedienteCreditoId,                                                            
         (SELECT top 1 convert(varchar, Fecha, 103) FROM SGF_ExpedienteCreditoDetalle                                                             
          WHERE ExpedienteCreditoId=EC.ExpedienteCreditoId AND ProcesoId = 5 AND                                                             
          (Observacion like 'CAMBIO DE AGENCIA A :%' or Observacion='CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL') ORDER BY Fecha DESC) [FechaUltimaDerivacion],                                            
         S.Nombres + ' ' + S.ApePaterno + ' ' + S.ApeMaterno [Supervisor],                               
         S.DocumentoNum [DNISupervisor],                                            
         ISNULL((SELECT top 1 DocumentoNum FROM SGF_Persona C                                             
                 inner join SGF_Evaluaciones E on E.PersonaId=C.PersonaId and EC.ExpedienteCreditoId=E.ExpedienteCreditoId                                             
                 where E.TipoPersonaId=2), '') as 'DNIConyugue',                                            
         dpto.Nombre as 'Dpto',                                         
         Prov.Nombre as 'Prov',                                            
         Dist.Nombre as 'Dist',                                            
         P.Telefonos,                    
   P.Celular,                                            
         P.Celular2,                                            
         P.Correo,     
         case DL.AntiguedadLaboral      
            when '' then '-'     
            when null then '-'     
            else  convert(varchar, cast(DL.AntiguedadLaboral as date), 103)     
         end as AntiguedadLaboral,                            
         -- isnull(convert(varchar, cast(DL.AntiguedadLaboral as date), 103), '-') as AntiguedadLaboral,      
      --convert(varchar, DL.AntiguedadLaboral, 103) as AntiguedadLaboral,                        
         ISNULL(DL.DiasPago, '')[DiasPago],                                            
         ISNULL(GI.Nombre, '-')[GiroNegocio],                                 
         ISNULL(DL.IngresoNeto, 0)[IngresoBruto],                          
         convert(varchar, EC.FechaDescarga, 103) as FechaDescarga,                      
         EC.ObsDerivacion,                    
      ECD.Fecha[FechaDerivacion],      
      P.DiaLlamada,      
      P.Horario      
    from SGF_ExpedienteCredito EC                                                                        
    INNER JOIN sgf_expedientecreditodetalle ECD ON ECD.ExpedienteCreditoId = EC.ExpedienteCreditoId                                                         
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
    where MONTH(ECD.Fecha) = @Mes AND                                             
          YEAR(ECD.Fecha) = @Anio AND                                        
          (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND        
    (EC.BancoId = @BancoId OR @BancoId = 0) AND          
          (ECD.Observacion LIKE 'CAMBIO DE AGENCIA A :%' OR ECD.Observacion='CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL')                          
 ORDER BY ECD.Fecha desc  
END