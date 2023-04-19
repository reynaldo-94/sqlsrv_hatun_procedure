/*--------------------------------------------------------------------------------------                                                                             
' Nombre          : [dbo].[SGC_SP_ResultLoading_U]                                                                                              
' Objetivo        : Registrar El Resultado de Carga                                                
' Creado Por      : FRANCISCO LAZARO                                                               
' Día de Creación : 18-02-2023                                                                                          
' Requerimiento   : SGC                                                                                       
' Modificado por  : Reynaldo Cauche                                                                     
' Día de Modificación : 27-4-2022    
' Cambios  :        
  ' - Reynaldo Cauche - Cambio de tipo de dato de datetime a string de @FechaCorreo y @Fecha    
  02/03/2023 - Reynaldo Cauche - cUANDO ES Mi Banco la fechaAprobacion de la tabla solicitud lo actualiza con la fecha de desembolso del excel    
  03/03/2023 - Reynaldo Cauche - Se agrego una variable @ObservacionCondicionada para validar el mensaje de Observacion cuando es rechazado mi banco, se seteo el campo cuota numero con el valor plazo   
  07/03/2023 - Reynaldo Cauche - Cuando es desistio se agrego el id motivo rechazo, se agrego la variable @FechaCorreoSinFormat   
  09/03/2023 - Reynaldo Cauche - Se agrego el campo @FiltroLead y varias validaciones para el campo observacion   
  16/03/2023 - Reynaldo Cauche - Cuando el estado es Evaluacion y el FiltroLead es rechazdo el credito se actualiza a Rechazado
  05/04/2023 - Reynaldo Cauche - Se cambio el orden de las validaciones
'--------------------------------------------------------------------------------------*/      
ALTER PROCEDURE SGC_SP_ResultLoading_U_2
(@BancoId int,          
 @FechaCorreo varchar(100),       
 @ExpedienteCreditoId int,       
 @Estado varchar(MAX),       
 @Plazo int,        
 @Fecha varchar(100),      
 @Monto decimal(10, 2),       
 @ResultadoGestion varchar(MAX),       
 @AgenciaAsignada varchar(MAX),       
 @CodAnalista int,       
 @NombreAnalista varchar(MAX),       
 @Contactabilidad varchar(MAX),       
 @Comentario varchar(MAX),       
 @MotivoRechazo varchar(MAX),       
 @SubMotivo varchar(MAX),   
 @FiltroLead varchar(100),       
 @Success int output,   
 @Message varchar(MAX) output)       
AS       
BEGIN       
    DECLARE @FechaCorreoSinFormat varchar(100) = @FechaCorreo   
    DECLARE @PersonaId int = (select TitularId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
    DECLARE @EstadoProcesoId int = (select EstadoProcesoId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
    DECLARE @SolicitudId int = (select SolicitudId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
    DECLARE @ItemId int = ISNULL((select MAX(ItemId) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId), 0) + 1       
    DECLARE @ProcesoId int = (select ProcesoId from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemId - 1)       
    DECLARE @IdReconfirmacion int = (select top 1 IdReconfirmacion from SGF_ExpedienteCredito_Reconfirmacion where ExpedienteCreditoId = 345345 order by IdReconfirmacion desc)       
	DECLARE @AgenciaAsignadaId int = (select top 1 IdOficina from SGF_Oficina where UPPER(Nombre) = @AgenciaAsignada order by IdOficina desc)    
    DECLARE @ExpedienteUltimaObservacion int = 0;   
    DECLARE @ContadorExpUltimaObservacion int = 0;   
    DECLARE @ItemIdUltimaObservacion int = 0;   
    -- DECLARE @ProcesoIdModifcado int = 0;  
   
	SET @FechaCorreo = convert(NVARCHAR,  convert(varchar, (convert(varchar, convert(DATETIME,@FechaCorreo), 3))))  
       
    SET @Success = 0       
    SET @Message = 'ERROR'       
       
    IF @BancoId = 3  --MI BANCO       
    BEGIN       
        -- 1. DESEMBOLSO                          ---> Activado Actualizar - Plazo, Fecha y Monto. Cuota vacio, y agregar historial (Activacion confirmada por Mi Banco segun correo del *FechaCorreo*)       
        --    2. CERRADO                             ---> Desistio (Cliente pasa a DESISTIO segun correo de Mi Banco *FechaCorreo*)       
        --    3. EVALUACION, PRE-PRESTAMO y REVISION ---> Aun debe mantenerse en evaluacion, Agregar como comentario "ESTADO + columna J Resultado de Gestion + Segun correo MiBanco *FechaCorreo*".        
        --    4. RECHAZADO                           ---> Enviar a Rechazado "Envio a Rechazado segun correo de MB *FechaCorreo*"       
        --    5. RECHAZADO POR EVALUACION            ---> Columna Resultado Gestion comienza en "No Califica + *ResultadoGestion*"       
        --    6. RESULTADO GESTION Y ESTADO SOLICITUD VACIOS Y MARCA CONTACTABILIDAD "NO CONTACTADO" ---> COMENTARIO: "NO CONTACTADO segun correo de MB FechaCorreo"     
   
        -- ACTUALIZAR FECHAPROCESO, FECHACORREO   
        UPDATE SGF_ExpedienteCredito   
        SET FechaProceso = dbo.GETDATE(),   
            FechaCorreo = @FechaCorreoSinFormat   
        WHERE ExpedienteCreditoId = @ExpedienteCreditoId

        IF @Estado = 'CERRADO' --and @EstadoProcesoId = 10       
        BEGIN       
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 10,       
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId       
                   
            UPDATE SGF_ExpedienteCredito                 
                SET EstadoProcesoId = 10,       
                EstadoExpedienteId = 2,       
                Observacion = 'Cliente pasa a DESISTIÓ según correo de MiBanco - Fecha ' + @FechaCorreo,       
                UserIdActua = 3588,
                FechaActua = dbo.GETDATE(),   
                FechaDesistio = dbo.GETDATE()      
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%Cliente pasa a DESISTIÓ según correo de MiBanco - Fecha%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = 'Cliente pasa a DESISTIÓ según correo de MiBanco - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1, TipoRechazoId = 27   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
   
                END   
            ELSE       
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 10, NULL, NULL, dbo.getdate(), NULL, 27, NULL, NULL, 3588, 'Cliente pasa a DESISTIÓ según correo de MiBanco - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,1)                       
        END     
    
        IF @Estado = 'DESEMBOLSO'      
        BEGIN       
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 8,     
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId       
                   
            UPDATE SGF_ExpedienteCredito       
            SET EstadoProcesoId = 8,       
                EstadoExpedienteId = 2,       
                Observacion = 'Activación confirmada por MiBanco según correo del ' + @FechaCorreo,       
                UserIdActua = 3588,            
                FechaActua = dbo.GETDATE(),   
                FechaActivado = @Fecha   
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
       
            UPDATE SGF_Solicitud       
            SET MontoEfectivoApro = @Monto,       
                FechaActua = dbo.getdate(),    
                FechaAprobacion = @Fecha,       
                UserIdActua = 3588,       
                MontoAprobado = ISNULL(MontoMaterialApro, 0) + @Monto,       
                CuotaNumero = @Plazo,   
                CuotaMonto = 0   
            WHERE SolicitudId = @SolicitudId       
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%Activación confirmada por MiBanco según correo del %'   
            order by ExpedienteCreditoId DESC   
                                           
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = 'Activación confirmada por MiBanco según correo del ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
   
                END   
            ELSE       
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 8, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, 'Activación confirmada por MiBanco según correo del ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)      
        END

        IF @Estado = 'RECHAZADO'       
        BEGIN       
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 9,       
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId       
                   
            UPDATE SGF_ExpedienteCredito   
            SET EstadoProcesoId = 9,   
                EstadoExpedienteId = 2,       
                Observacion = 'Rechazo' + ' - ' + @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco - Fecha ' + @FechaCorreo,       
                UserIdActua = 3588,       
                FechaRechazado = dbo.GETDATE(),       
                FechaActua = dbo.GETDATE()       
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
   
            -- Si cumple la condicion de que en el excel en la columna resultado gestion que comience el texto con no califica, en ese caso se agregar el texto del valor de Resultado Gestion   
            DECLARE @ObservacionrEstRecha varchar(500)

            SET @ObservacionrEstRecha = 'Rechazo' + ' - ' + @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco - Fecha '   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@ObservacionrEstRecha+'%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = @ObservacionrEstRecha + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE    
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 9, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @ObservacionrEstRecha + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)     
     
        END

        IF @Estado = 'RECHAZADO POR EVALUACION'       
        BEGIN       
            UPDATE SGF_ExpedienteCredito       
            SET Observacion = 'No Califica - ' + @ResultadoGestion,       
                FechaActua = dbo.GETDATE(),       
                UserIdActua = 3588    
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
                   
            UPDATE SGF_ExpedienteCredito_Reconfirmacion       
            SET ResultadoGestion = @ResultadoGestion       
            WHERE IdReconfirmacion = @IdReconfirmacion   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%No Califica - ' + @ResultadoGestion +'%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = 'No Califica - ' + @ResultadoGestion, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE   
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, @ProcesoId, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, 'No Califica - ' + @ResultadoGestion, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)       
        END
        
        IF (@Estado = 'EVALUACION' or @Estado = 'PRE-PRESTAMO' or @Estado = 'REVISION') and @EstadoProcesoId = 5       
        BEGIN          
   
            DECLARE @ObservacionCondicionadaMBEval varchar(500) 
            SET @ObservacionCondicionadaMBEval = @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco - Fecha '   
   
            UPDATE SGF_ExpedienteCredito   
            -- Colocar el nombre del estado       
            SET Observacion = @ObservacionCondicionadaMBEval + @FechaCorreo,       
                UserIdActua = 3588,      
                FechaActua = dbo.GETDATE()       
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+ @ObservacionCondicionadaMBEval + '%'   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = @ObservacionCondicionadaMBEval + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1, ProcesoId = @ProcesoId 
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE   
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, @ProcesoId, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @ObservacionCondicionadaMBEval + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)       
        END

        IF (@Estado = '' and @FiltroLead = 'RECHAZADO')
        BEGIN
            UPDATE SGF_ExpedienteCredito   
            SET EstadoProcesoId = 9,   
            EstadoExpedienteId = 2,  
            FechaRechazado = dbo.getdate(),
            Observacion = 'RECHAZADO POR CRM según correo de MiBanco - Fecha ' + @FechaCorreo,       
            UserIdActua = 3588,      
            FechaActua = dbo.GETDATE()  
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
        END

        IF (@Estado = '' and @FiltroLead = 'DERIVADO')
        BEGIN
            IF (UPPER(@ResultadoGestion) like '%NO CALIFICA%')
            BEGIN
                DECLARE @ObservacionCondicionadaRsNoc varchar(500)   
                UPDATE SGF_ExpedienteCredito   
                SET EstadoProcesoId = 9,   
                    EstadoExpedienteId = 2,       
                    Observacion = @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco - Fecha ' + @FechaCorreo,       
                    UserIdActua = 3588,       
                    FechaRechazado = dbo.GETDATE(),       
                    FechaActua = dbo.GETDATE()       
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
                
                SET @ObservacionCondicionadaRsNoc = @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco - Fecha '   

                -- Condicionar si inserta o actualiza   
                select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
                from SGF_ExpedienteCreditoDetalle   
                where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@ObservacionCondicionadaRsNoc+'%'   
                order by ExpedienteCreditoId DESC   
   
                IF (@ExpedienteUltimaObservacion != 0)   
                    BEGIN   
                        UPDATE SGF_ExpedienteCreditoDetalle   
                        SET Observacion = @ObservacionCondicionadaRsNoc + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                        where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                    END   
                ELSE    
                    INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 9, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @ObservacionCondicionadaRsNoc + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)     
                
            END
            ELSE IF  (@ResultadoGestion != '')
            BEGIN
                select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
                from SGF_ExpedienteCreditoDetalle   
                where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco Fecha%'   
                order by ExpedienteCreditoId DESC   
    
                IF (@ExpedienteUltimaObservacion != 0)   
                    BEGIN   
                        UPDATE SGF_ExpedienteCreditoDetalle   
                        SET Observacion = @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                        where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                    END   
                ELSE    
                    INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, @ProcesoId, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @ResultadoGestion + ' - ' + @MotivoRechazo + ' - según correo de MiBanco Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)       
            END
            ELSE IF @ResultadoGestion = '' and @Contactabilidad = 'NO CONTACTADO'       
            BEGIN       
                UPDATE SGF_ExpedienteCredito       
                SET Observacion = 'NO CONTACTADO según correo de MiBanco - Fecha ' + @FechaCorreo,       
                    FechaActua = dbo.GETDATE(),       
                    UserIdActua = 3588    
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
    
                -- Condicionar si inserta o actualiza   
                select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
                from SGF_ExpedienteCreditoDetalle   
                where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%NO CONTACTADO según correo de MiBanco - Fecha%'   
                order by ExpedienteCreditoId DESC   
    
                IF (@ExpedienteUltimaObservacion != 0)   
                    BEGIN   
                        UPDATE SGF_ExpedienteCreditoDetalle   
                        SET Observacion = 'NO CONTACTADO según correo de MiBanco - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                        where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                    END   
                ELSE    
                    INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, @ProcesoId, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, 'NO CONTACTADO según correo de MiBanco - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)       
            END
        END         
       
        SET @Success = 1       
        SET @Message = 'REGISTRO MIBANCO: OK'       
    END       
   
         
       
    IF @BancoId = 11  --SURGIR       
    BEGIN       
        --    Siempre Actualizar Agencia Asignada        
        --    Buscar Campo:        
        --    1. AgenciaAsignada       
        --    2. Cod Analista        
        --    3. NombreAnalista, si no existe codanalista crearlo y asignarlo       
                    
        --    Estado Solicitud:       
        --    1. Desembolsado         ---> Activado(Importe, Fecha, Plazo, sin cuota) + Activado segun correo de SURGIR fecha *FechaCorreo*       
        --    2. Rechazado            ---> Agregar Comentario: Contactabilidad + Comentario + Motivo de rechazo + SubMotivo + Rechazado segun correo de SURGIR fecha xx (Separar por un guion)       
        --    3. Desistio             ---> Agregar Comentario: Contactabilidad + Comentario + Motivo de rechazo + SubMotivo + Desistio segun correo de SURGIR *FechaCorreo* (Separar por un guion)       
        --    4. Evaluacion/Pendiente ---> Agregar Comentario: Contactabilidad + Comentario + Motivo de rechazo + SubMotivo + Evaluacion segun correo de SURGIR *FechaCorreo* (Separar por un guion)       
        --    5. Estado Vacio         ---> Agregar Comentario: Contactabilidad + Comentario + Motivo de rechazo + SubMotivo + Evaluacion segun correo de SURGIR *FechaCorreo* (Separar por un guion)       
       
        -- ACTUALIZAR FECHAPROCESO, FECHACORREO   
        UPDATE SGF_ExpedienteCredito   
        SET FechaProceso = dbo.GETDATE(),   
            FechaCorreo = @FechaCorreoSinFormat   
        WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
       
        DECLARE @AnalistaValido int = (select COUNT(*) from SGF_AsesorBanco where Codigo = @CodAnalista)       
        IF @AnalistaValido = 0       
        BEGIN       
            DECLARE @IdAsesorNuevo int = (select MAX(IdAsesor) + 1 from SGF_AsesorBanco)       
            INSERT INTO SGF_AsesorBanco VALUES (@IdAsesorNuevo, @NombreAnalista, 1, 3588, NULL, dbo.getdate(), NULL, '', '', '', @CodAnalista)       
        END       
               
        -- UPDATE SGF_ExpedienteCredito        
        -- SET IdOficina = @AgenciaAsignadaId,       
        --     IdAsesorBanco = @CodAnalista    
        -- WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
               
        IF UPPER(@Estado) = 'DESEMBOLSADO'     
        BEGIN       
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 8,       
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId      
    
            UPDATE SGF_Solicitud       
            SET MontoEfectivoApro = @Monto,       
                FechaActua = dbo.getdate(),       
                FechaAprobacion = @Fecha,       
                UserIdActua = 3588,       
                MontoAprobado = ISNULL(MontoMaterialApro, 0) + @Monto,         
                CuotaNumero = @Plazo,   
                CuotaMonto = 0    
            WHERE SolicitudId = @SolicitudId       
          
            UPDATE SGF_ExpedienteCredito       
            SET EstadoProcesoId = 8,      
                EstadoExpedienteId = 2,     
                Observacion = 'Activado según correo de SURGIR - Fecha ' + @FechaCorreo,    
                FechaActua = dbo.GETDATE(),       
                UserIdActua = 3588,   
                FechaActivado = @Fecha   
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%Activado según correo de SURGIR - Fecha%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
             UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = 'Activado según correo de SURGIR - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE    
        INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 8, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, 'Activado según correo de SURGIR - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL , NULL, NULL, NULL, NULL, 1)       
        END       
               
        IF UPPER(@Estado) = 'RECHAZADO'      
        BEGIN                   
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 9,       
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId     
    
            UPDATE SGF_ExpedienteCredito       
            SET EstadoProcesoId = 9,   
                EstadoExpedienteId = 2,    
                Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Rechazado según correo de SURGIR - Fecha ' + @FechaCorreo,       
                FechaActua = dbo.GETDATE(),       
                UserIdActua = 3588,   
                FechaRechazado = dbo.GETDATE()   
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Rechazado según correo de SURGIR - Fecha%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Rechazado según correo de SURGIR - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE    
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 9, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Rechazado según correo de SURGIR - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)       
                   
        END       
               
        IF UPPER(@Estado) = 'DESISTIO'       
        BEGIN                   
            UPDATE SGF_Persona       
            SET EstadoPersonaId = 10,       
                UserIdActua = 3588,       
                FechaActua = dbo.GETDATE()       
            WHERE PersonaId = @PersonaId     
    
            UPDATE SGF_ExpedienteCredito       
            SET EstadoProcesoId = 10,       
                EstadoExpedienteId = 2,    
                Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Desistió según correo de SURGIR - Fecha ' + @FechaCorreo,       
                FechaActua = dbo.GETDATE(),       
                UserIdActua = 3588,   
                FechaDesistio = dbo.GETDATE()   
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Desistió según correo de SURGIR - Fecha%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Desistió según correo de SURGIR - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1, TipoRechazoId = 27   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE    
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, 10, NULL, NULL, dbo.getdate(), NULL, 27, NULL, NULL, 3588, @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Desistió según correo de SURGIR - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)     
        END    
               
        IF UPPER(@Estado) = 'EVALUACION' OR UPPER(@Estado) = 'PENDIENTE' OR UPPER(@Estado) = ''       
        BEGIN               
            UPDATE SGF_ExpedienteCredito    
            SET Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Evaluacion según correo de SURGIR - Fecha ' + @FechaCorreo,       
                FechaActua = dbo.GETDATE(),       
                UserIdActua = 3588    
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId   
   
            -- Condicionar si inserta o actualiza   
            select top(1)  @ExpedienteUltimaObservacion = ExpedienteCreditoId, @ContadorExpUltimaObservacion = Contador, @ItemIdUltimaObservacion = ItemId   
            from SGF_ExpedienteCreditoDetalle   
            where ExpedienteCreditoId = @ExpedienteCreditoId and Observacion like '%'+@Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Evaluacion según correo de SURGIR - Fecha%'   
            order by ExpedienteCreditoId DESC   
   
            IF (@ExpedienteUltimaObservacion != 0)   
                BEGIN   
                    UPDATE SGF_ExpedienteCreditoDetalle   
                    SET Observacion = @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Evaluacion según correo de SURGIR - Fecha ' + @FechaCorreo, Contador = @ContadorExpUltimaObservacion + 1   
                    where ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdUltimaObservacion   
                END   
            ELSE    
                INSERT INTO SGF_ExpedienteCreditoDetalle VALUES (@ExpedienteCreditoId, @ItemId, @ProcesoId, NULL, NULL, dbo.getdate(), NULL, NULL, NULL, NULL, 3588, @Contactabilidad + ' - ' + @Comentario + ' - ' + @MotivoRechazo + ' - ' + @SubMotivo + ' - Evaluacion según correo de SURGIR - Fecha ' + @FechaCorreo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)                       
        END       
       
        SET @Success = 1       
        SET @Message = 'REGISTRO SURGIR: OK'       
    END       
       
    IF @BancoId NOT IN (3, 11)       
    BEGIN       
        SET @Success = 0       
        SET @Message = 'REGISTRO INCORRECTO: BANCO NO VALIDO'       
    END       
END