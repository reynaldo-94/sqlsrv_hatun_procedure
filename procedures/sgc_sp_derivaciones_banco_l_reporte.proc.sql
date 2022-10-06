/*--------------------------------------------------------------------------------------                                                                                                                       
' Nombre          : [dbo].[SGC_SP_Derivaciones_Banco_L_Reporte]                                                                                                                                        
' Objetivo        : Obtener datos para descargar el Reporte de Derivaciones                                                                                          
' Creado Por      : REYNALDO CAUCHE                                                                                                      
' Día de Creación : 09-03-2022                                                                                                                                    
' Requerimiento   : SGC                                                                                                                                 
' Modificado por  : Reynaldo Cauche                                                                                                               
' Cambios  :          
 - 09-09-2022  REYNALDO CAUCHE - Se agrego el parametro @AgenciaId     
 - 13-09-2022  REYNALDO CAUCHE - Se agrego el campo ActualizaFecha para poder diferencia las operaciones que se van a descargar   
 - 14-09-2022  REYNALDO CAUCHE - Se agrego una condicion para que no actualice el campo FechaDescarga de la tabla @TableDerivaciones   
'--------------------------------------------------------------------------------------*/                                                                   
CREATE PROCEDURE SGC_SP_Derivaciones_Banco_L_Reporte               
(@Mes int,                                     
 @Anio int,                                     
 @LocalId int,                                     
 @BancoId int,                                   
 @RolId int,                         
 @VerTodos BIT = 0,                       
 @DesdeLogicApps BIT = 1,       
 @AgenciaId int = 0)                                     
AS                                     
BEGIN                               
    DECLARE @TableDerivaciones table(Nombres varchar(500), DocumentoNum varchar(500),                               
             Direccion varchar(MAX), FechaEvaluacion varchar(500),                               
             CodTopaz int, Oficina varchar(500),                               
             Analista varchar(500), IdAnalista int,                               
             ADV varchar(500), MontoPropuesto decimal(10, 2),                               
             Fechas varchar(500), ExpedienteCreditoId int,                               
             FechaUltimaDerivacion varchar(500), Supervisor varchar(500),                               
             DNISupervisor varchar(500), DNIConyugue varchar(500),                               
             Dpto varchar(500), Prov varchar(500), Dist varchar(500),                               
             Telefonos varchar(500), Celular varchar(50),                               
             Celular2 varchar(500), Correo varchar(100),                               
             AntiguedadLaboral varchar(500), DiasPago int,                               
             GiroNegocio varchar(500), IngresoBruto decimal(10, 2),                               
             FechaDescarga varchar(500), ObsDerivacion varchar(500),                               
             FechaDerivacion datetime, DiaLlamada varchar(50),                               
             Horario varchar(20), ActualizaFecha CHAR(2))                               
                                  
    INSERT INTO @TableDerivaciones(Nombres, DocumentoNum,                               
                                   Direccion, FechaEvaluacion,                               
                                   CodTopaz, Oficina,                           
                                   Analista, IdAnalista,                             
                                   ADV, MontoPropuesto,                               
                        Fechas, ExpedienteCreditoId,                               
                                   FechaUltimaDerivacion, Supervisor,                               
                                   DNISupervisor, DNIConyugue,                               
                                   Dpto, Prov, Dist,                               
                                   Telefonos, Celular,                               
                                   Celular2, Correo,                               
                                   AntiguedadLaboral, DiasPago,                       
                                   GiroNegocio, IngresoBruto,                               
                                   FechaDescarga, ObsDerivacion,                               
                                   FechaDerivacion, DiaLlamada,                               
                                   Horario, ActualizaFecha)                              
    SELECT P.Nombre + ' ' + P.ApePaterno + ' ' + P.ApeMaterno,                                              
           P.DocumentoNum,                                                                 
           DD.Direccion,                                                                    
           CONVERT(varchar, ECD.Fecha, 103) + ' ' + CONVERT(varchar, ECD.Fecha, 108),                                                       
           O.CodTopaz,                                                                           
           O.Nombre,                                                                           
           ISNULL(SOL.Analista,''),                                                           
           ISNULL(SOL.IdAnalista, 0),                                                           
           --ISNULL((Select top 1 Nombre from SGF_ADV where LocalId=EC.ExpedienteCreditoLocalId AND EsActivo=1),''),           
           ISNULL((Select top 1 Nombre from SGF_ADV where AdvId=EC.AdvId AND EsActivo=1),''),           
           SOL.MontoPropuesto,                                                                           
           dbo.FN_Fechas_Derivacion(ECD.ExpedienteCreditoId),                                                               
           ECD.ExpedienteCreditoId,                                        
           (SELECT top 1 CONVERT(varchar, Fecha, 103) FROM SGF_ExpedienteCreditoDetalle                                                                                            
            WHERE ExpedienteCreditoId=EC.ExpedienteCreditoId AND ProcesoId = 5 AND                                                                                            
            (Observacion like 'CAMBIO DE AGENCIA A :%' or Observacion='CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL') ORDER BY Fecha DESC),                                                                           
           S.Nombres + ' ' + S.ApePaterno + ' ' + S.ApeMaterno,                                                              
           S.DocumentoNum,                                                                           
           ISNULL((SELECT top 1 DocumentoNum FROM SGF_Persona C                                                                            
                   inner join SGF_Evaluaciones E on E.PersonaId=C.PersonaId and EC.ExpedienteCreditoId=E.ExpedienteCreditoId                                                                            
                   where E.TipoPersonaId=2), ''),                                                                           
           dpto.Nombre,                                                                        
           Prov.Nombre,           
           Dist.Nombre,                                                                           
           P.Telefonos,                           
           P.Celular,                                                                           
           P.Celular2,                                
           P.Correo,                                    
           case DL.AntiguedadLaboral                                     
           when '' then '-'                                    
           when null then '-'                                    
           else  CONVERT(varchar, cast(DL.AntiguedadLaboral as date), 103) end,                                                                                  
           ISNULL(DL.DiasPago, ''),                                                                           
           ISNULL(GI.Nombre, '-'),                                                                
           ISNULL(DL.IngresoNeto, 0),                                                         
           CONVERT(varchar, EC.FechaDescarga, 103),                               
           EC.ObsDerivacion,                                                   
           ECD.Fecha,                                     
           P.DiaLlamada,                                     
           P.Horario,     
           case when EC.FechaDescarga is null then 'SI' else 'NO' end  as ActualizaFecha                
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
    WHERE ((MONTH(ECD.Fecha) = @Mes AND YEAR(ECD.Fecha) = @Anio) OR                               
          (@DesdeLogicApps = 1 AND MONTH(ECD.Fecha) = IIF(@Mes = 12, 1, @Mes - 1) AND YEAR(ECD.Fecha) = IIF(@Mes = 12, @Anio - 1, @Anio))) AND                                                                       
          (EC.ExpedienteCreditoLocalId = @LocalId OR @LocalId = 0) AND               
          (EC.BancoId = @BancoId OR @BancoId = 0) AND                                         
          (ECD.Observacion LIKE 'CAMBIO DE AGENCIA A :%' OR ECD.Observacion='CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL') AND                                
          (ISNUll(EC.FechaDescarga, '') = '' OR @VerTodos = 1) AND       
          (@AgenciaId = O.IdOficina OR @AgenciaId = 0)       
    ORDER BY ECD.Fecha desc                                
                               
    --Actualiza cuando es rol Convenios                                
    IF(@RolId = 27)                                             
    BEGIN                               
        UPDATE SGF_ExpedienteCredito                         
        SET FechaDescarga = dbo.getdate()                               
        WHERE ExpedienteCreditoId in                                           
              (Select ExpedienteCreditoId                                               
               from @TableDerivaciones     
               WHERE ActualizaFecha = 'SI')                                
                               
        UPDATE @TableDerivaciones                            
        SET FechaDescarga = CONVERT(varchar, dbo.getdate(), 103)     
        WHERE ActualizaFecha = 'SI'   
    END                               
                               
    select * from @TableDerivaciones                               
    order by FechaDerivacion                               
END