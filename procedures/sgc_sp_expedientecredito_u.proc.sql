/*--------------------------------------------------------------------------------------                                          
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_U]                            
' Objetivo        : Este procedimiento actualiza datos para un cliente (Titular o Involucrado)                            
' Creado Por      : JOSE MARTINEZ                            
' Día de Creación : 24-03-2021                            
' Requerimiento   : SGC                                               
' Cambios:            
  29/08/2022 - REYNALDO CAUCHE - Se agrego la validacion @DocumentoNum != 11 para que no inserte otra direccion cuando es RUC 
  04/12/2022 - REYNALDO CAUCHE - Se removió el parámetro @BancoId, ahora se calculo con el valor ya existente de la tabla expedientecredito 
                      
'--------------------------------------------------------------------------------------*/                                
                            
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_U]                    
                            
--Datos de Persona                            
@DocumentoNum varchar(12),                            
@PersonaId int,                            
@TipoPersonaId int,                            
@Nombre varchar(150),                            
@ApePaterno varchar(150),                            
@ApeMaterno varchar(150),                            
@Telefonos varchar(50),                            
@Celular varchar(9),                            
@Celular2 varchar(9),                            
@EstadoCivilId int,                            
@Correo varchar(50),                            
@DatosDireccionId int,                            
@Direccion varchar(150),                            
@Referencia varchar(150),                            
@Ubigeo varchar(20),           
@DiaLlamada varchar(25),           
@Horario varchar(50),                            
--Datos Expediente Credito                            
@ExpedienteCreditoId int,                            
@ProveedorId int=1021,                            
@UserIdActua int=1458,                            
@Obra varchar(50),                            
@CasaPropia int,                            
@IdSupervisor int=1,                  
@ObservacionMensaje varchar(max),                  
@EstadoProcesoId int,                  
                            
-- Datos Solicitud                            
@SolicitudId int,                            
@MontoMaterialPro float,                            
@MontoEfectivoPro float,                            
                            
-- Datos Laborales                            
@DatosLaboralesId int,                            
@TipoTrabajoId int,                            
@FormalidadTrabajoId int,                            
@UbigeoTrabajo varchar(20),                            
@DireccionTrabajo varchar(150),                            
@ReferenciaTrabajo varchar(150),                            
@NombreEstablecimiento varchar(100),                          
@RucEstablecimiento varchar(100),                          
@CentroTrabajo varchar(100),                            
@GiroId int,                            
@SustentoIngresoId int,                            
@IngresoNeto float,                            
@AntiguedadLaboral varchar(50),                        
@DiasPago int,                        
                            
@Success INT OUTPUT,                            
@Message varchar(8000) OUTPUT                            
AS                    
BEGIN                    
    declare @MontoPropuesto float                            
    declare @DatosDireccionTrabajoId int                            
    declare @TipoDireccionTrabajoId int 
    DECLARE @BancoId int                  
    declare @ItemId int                     
    BEGIN TRY                              
        BEGIN TRANSACTION                              
                                   
        SET @Success=0;                            
        SET @MontoPropuesto=@MontoMaterialPro + @MontoEfectivoPro                            
        SET @DatosDireccionTrabajoId = (select top 1 DatosDireccionId from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId<>1)           
        SET @TipoDireccionTrabajoId = IIF(@TipoTrabajoId=1,2,3)    
        SET @BancoId = (SELECT BancoId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId);                       
                                    
        if(@PersonaId<>0)                            
            begin                            
                UPDATE SGF_Persona                            
                SET Nombre=@Nombre,               
                    ApePaterno=@ApePaterno,                            
                    ApeMaterno=@ApeMaterno,                            
                    Telefonos=@Telefonos,                            
                    Celular=@Celular,                            
                    Celular2=@Celular2,                            
                    EstadoCivilId=@EstadoCivilId,                
                    Correo=@Correo,                            
                    CasaPropia=@CasaPropia,           
                    DiaLlamada=@DiaLlamada,           
                    Horario=@Horario                            
                where PersonaId=@PersonaId                            
            end                            
                                   
        if(@DatosDireccionId=0)                            
            begin                            
                set @DatosDireccionId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)                            
                    INSERT INTO SGF_DatosDireccion(DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                            
                    values(@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)                            
            end                            
        else                            
            begin                       
                --set @DatosDireccionId=(Select top 1 DatosDireccionId from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId=1)                           
                UPDATE SGF_DatosDireccion                            
                SET Direccion=@Direccion,                            
                    Referencia=@Referencia,                            
                    Ubigeo=@Ubigeo                            
                WHERE DatosDireccionId=@DatosDireccionId                            
            end                            
                                   
        if(@DatosLaboralesId=0)                            
            begin                            
                set @DatosLaboralesId=(Select max(DatosLaboralesId)+1 from SGF_DatosLaborales)                            
                INSERT INTO SGF_DatosLaborales   
                (DatosLaboralesId,PersonaId,TipoTrabajoId,FormalidadTrabajoId,TipoEstablecimiento,NombreEstablecimiento,ActividadEconomicaId,GiroId,   
                CentroTrabajo,SustentoIngresoId,Cargo,IngresoNeto,AntiguedadLaboral,DiasPago,Ruc)                        
                values   
                (@DatosLaboralesId,@PersonaId,@TipoTrabajoId,@FormalidadTrabajoId,'',@NombreEstablecimiento,0,@GiroId,   
                @CentroTrabajo, @SustentoIngresoId,'',@IngresoNeto,@AntiguedadLaboral,@DiasPago,@RucEstablecimiento)                            
            end                            
        else                       
            begin                            
                --set @DatosLaboralesId=(Select top 1 DatosLaboralesId from SGF_DatosLaborales where PersonaId=@PersonaId)                                 
                UPDATE SGF_DatosLaborales                            
                SET TipoTrabajoId=@TipoTrabajoId,                            
                    FormalidadTrabajoId=@FormalidadTrabajoId,   
                    NombreEstablecimiento=@NombreEstablecimiento,                           
                    Ruc=@RucEstablecimiento,                       
                    GiroId=@GiroId,                            
                    CentroTrabajo=@CentroTrabajo,                            
                    SustentoIngresoId=@SustentoIngresoId,                                           IngresoNeto=@IngresoNeto,                        
                    AntiguedadLaboral=@AntiguedadLaboral,                        
                    DiasPago=@DiasPago              
                WHERE DatosLaboralesId=@DatosLaboralesId                            
            end  
  
        -- Cuando es RUC no actualizar    
        If(@DatosDireccionTrabajoId IS NULL AND Len(@DocumentoNum) != 11)                            
            begin                            
                set @DatosDireccionTrabajoId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)                            
                    INSERT INTO SGF_DatosDireccion(DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)         
                    values(@DatosDireccionTrabajoId,@PersonaId,@TipoDireccionTrabajoId,0,@DireccionTrabajo,@ReferenciaTrabajo,@UbigeoTrabajo,0)                            
                end                            
        Else                            
            begin                            
                UPDATE SGF_DatosDireccion                            
                SET TipoDireccionId=@TipoDireccionTrabajoId,                            
                    Direccion=@DireccionTrabajo,                            
                    Referencia=@ReferenciaTrabajo,                            
                    Ubigeo=@UbigeoTrabajo                            
                WHERE DatosDireccionId=@DatosDireccionTrabajoId                            
            end                            
                                   
        /*=== Registro solo para Titular del Crédito ===*/                            
        If (@TipoPersonaId=1)                 
            Begin                            
                If (@SolicitudId=0)                            
                    Begin                            
                        set @SolicitudId=(select max(SolicitudId)+1 from SGF_Solicitud)                            
                        INSERT INTO SGF_Solicitud(SolicitudId,BancoId,PersonaId,FechaSolicitud,MonedaId,FrecuenciaPagoId,MontoPropuesto,MontoMaterialPro,MontoEfectivoPro,EstadoSolicitudId,UserIdCrea,FechaCrea)                            
                        VALUES(@SolicitudId,@BancoId,@PersonaId,dbo.getdate(),1,3,@MontoPropuesto,@MontoMaterialPro,@MontoEfectivoPro,1,@UserIdActua,dbo.getdate())                            
                                        
                        UPDATE SGF_ExpedienteCredito                            
                        SET SolicitudId=@SolicitudId,                    
                            Obra=@Obra                     
                        WHERE ExpedienteCreditoId=@ExpedienteCreditoId                            
                    End                            
                Else                               
                    Begin                            
                        --set @SolicitudId=(Select top 1 SolicitudId from SGF_ExpedienteCredito where ExpedienteCreditoId=@ExpedienteCreditoId)                         
                        UPDATE SGF_Solicitud                            
                        SET MontoPropuesto=@MontoPropuesto,                            
                            MontoMaterialPro=@MontoMaterialPro,                            
                            MontoEfectivoPro=@MontoEfectivoPro,                            
                            UserIdActua=@UserIdActua,                            
                            FechaActua=dbo.getdate(),         
                            BancoId = IIF(@BancoId = 0, BancoId, @BancoId)         
                        WHERE SolicitudId=@SolicitudId                            
                                        
                        UPDATE SGF_ExpedienteCredito                            
                        SET Obra=@Obra WHERE ExpedienteCreditoId=@ExpedienteCreditoId                            
                    End                            
            End                    
                    
        UPDATE SGF_ExpedienteCredito                    
        SET FechaActua = dbo.GETDATE(), BancoId = IIF(@BancoId = 0, BancoId, @BancoId)                  
        WHERE ExpedienteCreditoId=@ExpedienteCreditoId                     
                    
        IF (@ObservacionMensaje != '')                  
            BEGIN                  
                SET @ItemId=(Select max(ItemId)+1 from SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                  
                INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, Observacion, UsuarioId)                  
                VALUES(@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.getdate(), @ObservacionMensaje, @UserIdActua)                  
            END                  
                   
        SET @Success = 1;                            
        SET @Message = 'OK';                            
                                  
        COMMIT;                            
    END TRY                              
    BEGIN CATCH                              
     SET @Success = 0;                            
     SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();                            
     ROLLBACK;                            
    END CATCH                    
END