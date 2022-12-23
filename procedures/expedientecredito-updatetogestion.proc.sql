/*--------------------------------------------------------------------------------------                                                                                                                         
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Gestion_erivar]                                                                                                                                          
' Objetivo        : ESTE PROCEDIMIENTO CAMBIA DE ESTADO, DE PROSPECTO A GESTION                                                   
' Creado Por      :                                                                                                      
' Día de Creación :                                                                                                                                     
' Requerimiento   : SGC                                                                                                                                   
' Cambios:           
  10/11/2022 - REYNALDO CAUCHE - Se agrego la validacion @DocumentoNum != 11 para que no realice algunas validaciones                                                                                                                      
'--------------------------------------------------------------------------------------*/                                                                             
                                                                         
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Gestion_erivar                                       
@ExpedienteCreditoId int,                                         
@UserId int,                     
@DatosLaboralesId int,                      
@RolId int,                    
@LocalId int,                    
@ZonaId int,                    
@Success INT OUTPUT ,                                         
@Message varchar(max) OUTPUT                                         
as                                         
BEGIN                         
    /*DATOS A VALIDAR EN GLOBAL*/                                         
    declare @status int                                         
    declare @personaId int                                         
    declare @titularId int                                         
    declare @estadoCivilId int                                         
    declare @estadoCivilValue int                                         
    declare @valueConyuge int                                         
    declare @valueCasaPropia int                                         
    declare @valueCasaPropiaGarante int                                         
    declare @ItemId int                                          
    declare @solicitud int                                         
    /*---------------------------------*/                                         
                                              
    declare @countDocumentos int                                         
    declare @sustentoingreso int                                         
    declare @ingreso int                                         
    declare @ruc int                                         
    declare @gironegocio int                                         
    declare @cargo int                                         
    declare @fecha int                                         
    declare @centrotrabajo int                                         
    declare @establecimiento int                                         
    declare @tipotrabajo int                       
    declare @tipotrabajoid int                       
    declare @tipoformalidad int                                         
    declare @direccionid int                                         
    declare @tipodireccion int                                         
    declare @ubigeo int                                         
    declare @direccion int              
    declare @referencia int                                
    declare @materialpro int                                         
    declare @material int                                         
    declare @efectivopro int                     
    declare @efectivo int                                         
    declare @obra int            
    declare @antiguedadLaboral varchar(20)                        
    declare @diasPago int                     
    declare @advId int                  
    declare @advIdrol int        
    declare @zonaIdEx int 
    declare @documentoNum varchar(12) 
                    
                                              
    BEGIN TRY                              
    BEGIN TRANSACTION                                           
                                                
        SET @Success = 0;                                        
        SET @Message = '';                                         
        SET @Success = 1;           
       
                 
  SET @advId =(SELECT TOP(1) a.advid               
    FROM sgf_adv_atencion  a                   
     inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId               
     inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                
     inner join SGF_Local lo on lo.ZonaId = zo.ZonaId               
     inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                 
    where rezo.esActivo = 1 and zo.zonaid = @ZonaId and lo.localid=@LocalId               
    ORDER BY a.FechaAsignacion ASC)               
                
  set @advIdrol = (select  AdvId from SGF_ExpedienteCredito where expedienteCreditoId =@ExpedienteCreditoId);               
                            
        /*DATOS A SETEAR GLOBAL*/                                         
        SET @status = (select sec.EstadoProcesoId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);                                         
        SET @titularId = (select sec.TitularId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);                                         
        SET @personaId = (select sp.TipoPersonaId from SGF_Persona sp WHERE  sp.PersonaId = @titularId); 
        SET @documentoNum = (select DocumentoNum from SGF_Persona where PersonaId = @titularId);                         
        SET @estadoCivilId = (select isnull(count(sp.PersonaId),0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId);                                         
        SET @estadoCivilValue = (select sp.ParametroId from SGF_Parametro sp where sp.DominioId = 8 and sp.ParametroId = @estadoCivilId);                                         
        SET @valueConyuge = (select isnull(count(se.PersonaId),0) from SGF_Evaluaciones se WHERE  se.ExpedienteCreditoId = @ExpedienteCreditoId and se.TipoPersonaId = 2);                                         
        SET @valueCasaPropiaGarante = (select isnull(count(se.PersonaId),0) from SGF_Evaluaciones se WHERE  se.ExpedienteCreditoId = @ExpedienteCreditoId and se.TipoPersonaId = 3);                                         
        SET @valueCasaPropia = (select isnull(sp.CasaPropia,0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId);                                         
        SET @solicitud = (select ISNULL(sec.SolicitudId,0) from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);                                         
        set @ItemId =( select ISNULL(MAX(ItemId) + 1,1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId);                                         
        /*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/                                         
                                                    
        --set @countDocumentos = (select isnull(count(*),0) from SGF_DocumentoAdjunto sda where sda.ExpedienteCreditoId = @ExpedienteCreditoId);              
                                   
        set @sustentoingreso = (select SustentoIngresoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        -- set @ingreso = (select isnull(count(ISNULL(sdl.IngresoNeto,0)),0) from SGF_DatosLaborales sdl where sdl.PersonaId = @titularId)                                         
        set @ingreso = (select IngresoNeto from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                        
        set @ruc = (select isnull(count(ISNULL(Ruc,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                    
        -- set @gironegocio = (select isnull(count(ISNULL(sdl.GiroId,0)),0) from SGF_DatosLaborales sdl where sdl.PersonaId = @titularId)                            
        set @gironegocio = (select GiroId  from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        set @cargo = (select isnull(count(ISNULL(Cargo,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        set @fecha = (select isnull(count(ISNULL(FechaIngresoLaboral,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        set @centrotrabajo = (select isnull(count(ISNULL(CentroTrabajo,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        set @establecimiento = (select isnull(count(ISNULL(TipoEstablecimiento,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                         
        set @tipotrabajo = (select isnull(count(ISNULL(TipoTrabajoId ,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                       
        set @tipotrabajoid = (select TipoTrabajoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                       
        set @tipoformalidad = (select FormalidadTrabajoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                        
        set @direccionid = (select isnull(count(ISNULL(sdd.DatosDireccionId,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @titularId)                                         
        set @tipodireccion = (select isnull(count(ISNULL(sdd.TipoDireccionId,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @titularId)                                         
        set @ubigeo = (select isnull(count(ISNULL(sdd.Ubigeo,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @titularId)                                         
        set @direccion = (select isnull(count(ISNULL(sdd.Direccion,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @titularId)                                         
        set @referencia = (select isnull(count(ISNULL(sdd.Referencia,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @titularId)                                         
        set @material = (select isnull(count(isnull(ss.MontoMaterialApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                   
        set @materialpro = (select isnull(count(isnull(ss.MontoMaterialPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                         
        set @efectivopro = (select isnull(count(isnull(ss.MontoEfectivoPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                         
        set @efectivo = (select isnull(count(isnull(ss.MontoEfectivoApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                         
        set @antiguedadLaboral = (select antiguedadLaboral from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                        
        set @diasPago = (select diasPago from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                      
  --set @advId = (select  AdvId from SGF_ExpedienteCredito where expedienteCreditoId =@ExpedienteCreditoId )                   
                     
                   
        IF @solicitud = 0                                         
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar solicitud al expediente.                                         
                '                                         
            END                                         
                                                  
        IF @solicitud = 0                                         
            BEGIN                                         
                IF @material = 0                     
                BEGIN                                         
                    SET @Success = 2;                                         
                    SET @Message = ''+'-Debe agregar monto material aprobado.                                         
'                                         
                END                                         
                IF @materialpro = 0                                         
                BEGIN                                         
                    SET @Success = 2;                                         
                    SET @Message = ''+'-Debe agregar monto material propuesto.                                         
                    '                                         
                END                                         
                IF @efectivopro = 0                                         
                BEGIN                                         
                    SET @Success = 2;                                         
                    SET @Message = ''+'-Debe agregar monto efectivo aprobado.                                         
                    '                                         
                END                                         
                IF @efectivo = 0                                         
                BEGIN                                         
                    SET @Success = 2;                                         
                    SET @Message = ''+'-Debe agregar monto efectivo propuesto.                                         
                    '                                         
                END                                         
            END                                   
                                     
        -- IF @countDocumentos = 0                                         
        --    BEGIN                                 
        --     SET @Success = 2;                                         
        --    SET @Message = ''+'-Debe agregar documentos.                                         
        --'                                         
        --  END                       
                     
        IF @DatosLaboralesId = 0                                     
            BEGIN                                    
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar tipo de trabajo.                                         
                '                                       
            END                       
                       
        IF @tipotrabajo = 0                                  
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar tipo de trabajo.                        
                '                                       
            END                       
                                   
                                   
        IF @referencia = 0                                    
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar referencia.                                         
                '                                         
            END                                         
                                                   
        IF @direccion = 0                                         
            BEGIN               
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar direccion.                                         
                '                                         
           END                                         
                                                   
        IF @ubigeo = 0                                        
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar ubigeo.                                         
                '                                         
            END                                         
                            
        IF @tipodireccion = 0                                         
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar tipo de dirección.                                         
                '                                         
            END                     
                                                  
                                              
                                                   
        IF @establecimiento = 0 and len(@documentoNum) != 11                                         
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar tipo de establecimiento.                                         
          '                                         
            END                                         
                                                   
        IF @centrotrabajo = 0 and len(@documentoNum) != 11                                        
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar centro de trabajo.                                         
                '                                         
   END                                       
                                                   
        IF @fecha = 0 and len(@documentoNum) != 11                                        
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar fecha de ingreso.                                         
                '                                         
            END                                         
                                                  
        IF @cargo = 0 and len(@documentoNum) != 11                                        
            BEGIN                                         
                SET @Success = 2;                                         
                SET @Message = ''+'-Debe agregar cargo en la empresa.                                         
                '                                         
            END                                              
          
        IF @ruc = 0 and len(@documentoNum) != 11                                        
            BEGIN                                         
                SET @Success = 2;                   
                SET @Message = ''+'-Debe agregar ruc laboral.                                         
             '                                         
            END                       
                               
        -- TIPO TRABAJO INDEPENDIENTE - FORMAL O INFORMAL                       
        IF @tipotrabajoid = 1 and (@tipoformalidad = 1 OR @tipoformalidad = 2)                       
            BEGIN                                         
                IF @gironegocio = 0                                         
                    BEGIN                           
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar giro de negocio.                                         
          '                                         
                    END                       
                IF @ingreso = 0                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar ventas brutas.                                         
                        '                                         
                    END 
                -- CUANDO ES RUC NO TIENE ANTIGUEDAD LABORAL 
                IF (@antiguedadLaboral = '' and len(@documentoNum) != 11)                                   
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar antiguedad laboral.'                                         
                    END                                    
            END                       
                               
        -- TIPO TRABAJO DEPENDIENTE - FORMAL                       
        IF (@tipotrabajoid = 2 and @tipoformalidad = 1 and len(@documentoNum) != 11)                       
            BEGIN                       
                IF @gironegocio = 0                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar giro de negocio.                                         
                        '                     
                    END                       
                IF @sustentoingreso = 0                                         
                        BEGIN                                         
                            SET @Success = 2;                                         
                            SET @Message = ''+'-Debe agregar sustento de ingreso.                                         
                            '                                         
                        END                        
                IF @ingreso = 0                                         
                    BEGIN                             
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar salario bruto.                                         
                        '                                         
                    END                       
                IF @antiguedadLaboral = ''                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar antiguedad laboral.'                    
           END                       
                IF @diasPago = 0                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar días de pago.                                         
                        '                                         
                    END                       
            END                       
                               
        -- TIPO TRABAJO DEPENDIENTE - INFORMAL - DIFERENTE A RUC                   
        IF (@tipotrabajoid = 2 and @tipoformalidad = 2 and len(@documentoNum) != 11)                       
            BEGIN                       
             IF @gironegocio = 0                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar giro de negocio.                                         
                        '                                         
                    END                       
                IF @ingreso = 0                                         
                    BEGIN          
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar salario bruto.                                         
                        '                                         
                    END                       
                IF @antiguedadLaboral = ''                                         
                    BEGIN                                         
                        SET @Success = 2;                       
                        SET @Message = ''+'-Debe agregar antiguedad laboral.'                                         
                    END                       
                IF @diasPago = 0                           
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe agregar días de pago.                                         
                        '                                         
                    END                       
            END                       
                                                   
        IF @status != 2                                         
            BEGIN                            
                SET @Success = 2;                                         
                SET @Message = ''+'-No se puede pasar a gestión con el estado actual.                                         
                '                                         
            END                                         
                                                  
        IF @personaId = 1                                         
            BEGIN                                         
                IF @estadoCivilValue in (2,4)                                         
                BEGIN                                         
                    IF @valueConyuge = 0                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                        SET @Message = ''+'-Debe ingresar los datos del Cónyuge.                                         
                        '                                         
                    END                                         
                                                           
                    IF @valueCasaPropia = 0 and @valueCasaPropiaGarante = 0                                         
                    BEGIN                                         
                        SET @Success = 2;                                         
                       SET @Message = ''+'-Debe ingresar Garante de propiedad.                                         
                        '                                               
                    END                                         
                END                                         
            END                              
                                                   
  IF @Success = 1        
  begin    
  if (@advId > 0 and @RolId = 29)    --supervisor       
 BEGIN                
 if(@advIdrol = 0)           
  begin           
   UPDATE SGF_ExpedienteCredito                                          
    SET EstadoProcesoId  = 3 ,                                       
    FechaAgenda = dbo.GETDATE(),                                     
FechaGestion = dbo.GETDATE(),                         
    FechaActua = dbo.GETDATE(),       
    UserIdActua = @UserId       
   WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;             
          
    UPDATE SGF_Persona                                          
  SET EstadoPersonaId  = 3 ,                                                        
  FechaActua = dbo.GETDATE(),       
  UserIdActua = @UserId       
 WHERE PersonaId  = @titularId;        
                                                               
    INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)       
    VALUES(@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')                        
                             
   update SGF_ExpedienteCredito                   
  set AdvId = @advId                   
  where ExpedienteCreditoId = @ExpedienteCreditoId;                    
                   
 UPDATE SGF_ADV_atencion                   
  set FechaAsignacion = dbo.GETDATE()                   
  where AdvId = @advId;                      
                     
   SET @Success = 1;                                         
   SET @Message = 'OK'               
  end        
  --------------------------           
  if(@advIdrol > 0)           
  begin           
   UPDATE SGF_ExpedienteCredito                                          
    SET EstadoProcesoId  = 3 ,                                       
    FechaAgenda = dbo.GETDATE(),                                     
    FechaGestion = dbo.GETDATE(),                         
    FechaActua = dbo.GETDATE()                         
   WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;           
          
       UPDATE SGF_Persona                                          
  SET EstadoPersonaId  = 3 ,                                                        
  FechaActua = dbo.GETDATE(),       
  UserIdActua = @UserId       
 WHERE PersonaId  = @titularId;          
                                                               
   INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                                                 
   VALUES(@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')                        
                             
   --update SGF_ExpedienteCredito                   
   -- set AdvId = @advId                   
   -- where ExpedienteCreditoId = @ExpedienteCreditoId;                    
                   
   --UPDATE SGF_ADV_atencion                   
   -- set FechaAsignacion = dbo.GETDATE()                   
   -- where AdvId = @advId;                      
                     
   SET @Success = 1;                                         
   SET @Message = 'OK'               
  end           
           
  --------------------------------------           
 END                
 else                 BEGIN                                         
  SET @Success = 2;                                         
  SET @Message = ''+'No se puede enviar a Gestión, por que no hay ADV Registrado'                                               
 END                  
               
  if (@advIdrol > 0 and @RolId = 4)--adv               
   begin               
   UPDATE SGF_ExpedienteCredito                                          
    SET EstadoProcesoId  = 3 ,                                       
    FechaAgenda = dbo.GETDATE(),                                     
    FechaGestion = dbo.GETDATE(),                 
    FechaActua = dbo.GETDATE()                        
    WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;       
        
   UPDATE SGF_Persona                                          
  SET EstadoPersonaId  = 3 ,                                                        
  FechaActua = dbo.GETDATE(),       
  UserIdActua = @UserId       
 WHERE PersonaId  = @titularId;           
                                                               
    INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                                                 
    VALUES(@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')        
        
    UPDATE SGF_ADV_atencion                   
    set FechaAsignacion = dbo.GETDATE()                   
    where AdvId = @advIdrol;                 
               
    SET @Success = 1;                                         
    SET @Message = 'OK'                
   end         
   end     
        COMMIT;                                           
    END TRY                                   
 BEGIN CATCH                                           
    SET @Success = 0;                 
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()                                         
    ROLLBACK;                                           
    END CATCH                          
END