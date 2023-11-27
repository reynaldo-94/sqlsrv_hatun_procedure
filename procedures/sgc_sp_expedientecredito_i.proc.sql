/*--------------------------------------------------------------------------------------                                                                 
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_I]                                                                                  
' Objetivo        : Este procedimiento registrar nuevos creditos para una persona nueva                                                                     
' Creado Por      : SAMUEL FLORES                                                   
' Día de Creación : 24-03-2021                                                                              
' Requerimiento   : SGC                                                                           
' Modificado por  : Reynaldo Cauche                                                          
' Día de Modificación : 26-04-2022                     
' Cambios                  
    - 03/10/2022 - cristian silva - solo se modifico @DocumentoNum se agrego el varchar(11) por el varchar(12)               
    - 29/12/2022 - Reynaldo Cauche - Agregar campo Prioridad e INSERTarlo en la tabla SGF_ExpedienteCredito               
    - 06/12/2022 - Reynaldo Cauche - Se agrego el parametro @ObservacionCambioEstado             
    - 03/02/2022 - Reynaldo Cauche - Se agrego valildacion cuANDo el tipodireccion no sea igual a 1, se agrego un INSERT con tipo direccion igual a 1            
    - 16/02/2023 - cristian silva - se habilito @EstadoProcesoId en sgf_personapara actualizar el estado          
    - 18/03/2023 - Reynaldo Cauche - Se agrego validacion para el celular        
    - 22/03/2023 - Reynaldo Cauche - Se agrego validacion para TELEFONOS y se cambio el mensaje        
    - 11/04/2023 - Reynaldo Cauche - Se quito la validacion de telefono para los clientes recurrentes       
    - 10/05/2023 - Francisco Lazaro - Agregar parametro Proyecto e insertarlo en la tabla SGF_ExpedienteCredito   
'--------------------------------------------------------------------------------------*/                                                       
                                                   
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_I]                                                                              
(-- Datos de Persona                                                   
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
 @Direccion varchar(150),    
 @Referencia varchar(150),    
 @Ubigeo varchar(20),    
 @DiaLlamada varchar(25),    
 @Horario varchar(50),    
   
-- Datos Expediente Credito 
 @ExpedienteCreditoId int,    
 @ExpedienteCreditoZonaId int,    
 @ExpedienteCreditoLocalId int,    
 @EstadoProcesoId int,    
 @CanalVentaID int,    
 @ProveedorId int,    
 @UserIdCrea int,    
 @Obra varchar(50),    
 @IdSupervisor int,    
 @AdvId int,    
 @DispositivoId int,    
 @BancoId int,    
 @Prioridad varchar(15),    
   
-- Respuesta Sentinel                                                   
 @ResultadoId int, --ok                                             
 @Observacion varchar(500), ---ok                                                  
 @TipoCredito varchar(25),    
 @IsBancarizado bit = NULL,    
 @OrigenId int,    
   
-- APDP                                                 
 @APDP bit = NULL,    
 @IpAPDP varchar(20) = NULL,    
 @FechaAPDP datetime = NULL,    
 @NavegadorAPDP varchar(20) = NULL,    
 @ModeloDispositivoAPDP varchar(10) = NULL,  
 @PubliAPDP bit = NULL,           
 @MedioAutorizacion int = NULL,      
   
-- Mensaje al cambio de estado a Rechazado o Desistio              
 @ObservacionCambioEstado varchar(500),    
  
 -- Tipo de Campaña     
 @Proyecto int = NULL,   
   
-- SALIDA   
 @Success INT OUTPUT,    
 @Message varchar(8000) OUTPUT,    
 @PersonaIdOutput INT OUTPUT,    
 @ExpedienteCreditoIdOutput INT OUTPUT)   
AS                                                   
    DECLARE @DatosDireccionId int                                                   
    DECLARE @EvaluacionId int                                  
    DECLARE @ValueFechaAPDP varchar(100)        
    DECLARE @Celular1Repetido varchar(50) = ''        
    DECLARE @Celular2Repetido varchar(50) = ''        
    DECLARE @TelefonoRepetido varchar(50) = ''        
BEGIN TRY                                                     
    BEGIN TRANSACTION                          
                                                          
    SET @Success = 0;   
   
    /* ================  Ingreso Datos Titular  ================== */                                                   
    IF (@TipoPersonaId = 0 or @TipoPersonaId = 1)                                                   
    BEGIN                                                   
        IF (@PersonaId = 0)                                                   
        BEGIN                     
            SET @Celular1Repetido = ISNULL((SELECT TOP(1) Celular from SGF_Persona WHERE Celular in (@Celular, IIF(@Celular2 = '', '--', @Celular2))), '');        
            SET @Celular2Repetido = ISNULL((SELECT TOP(1) Celular2 from SGF_Persona WHERE Celular2 in (@Celular, IIF(@Celular2 = '', '--', @Celular2))), '');        
            SET @TelefonoRepetido = ISNULL((SELECT TOP(1) Telefonos from SGF_Persona WHERE Telefonos = @Telefonos), '');        
                    
            IF ((@CanalVentaID <> 12 AND @Celular1Repetido = '' AND @Celular2Repetido = '' AND @TelefonoRepetido = '') OR @CanalVentaID = 12)   
            BEGIN         
                SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) + 1 from SGF_DatosDireccion)                                                   
                SET @PersonaId = (SELECT MAX(PersonaId) + 1 from SGF_Persona)                                                   
                                       
                INSERT INTO SGF_Persona (PersonaId, ZonaId, LocalId, EstadoPersonaId, Nombre, ApePaterno, ApeMaterno, DocumentoNum, Telefonos, Celular, Celular2, EstadoCivilId, Correo, UserIdCrea, OrigenId,                
                                         APDP, IpAPDP, FechaAPDP, NavegadorAPDP, ModeloDispositivoAPDP, PubliAPDP, MedioAutorizacion, ProveedorLocalId, IdSupervisor, FechaCrea, DiaLlamada, Horario)                                     
                                 VALUES (@PersonaId, IIF(@CanalVentaID = 12, 6, @ExpedienteCreditoZonaId), IIF(@CanalVentaID = 12, 13, @ExpedienteCreditoLocalId), @EstadoProcesoId, @Nombre, @ApePaterno, @ApeMaterno, @DocumentoNum, @Telefonos, @Celular, @C
elular2, @EstadoCivilId,                    
                                         @Correo, @UserIdCrea, @OrigenId, @APDP, @IpAPDP, @FechaAPDP, @NavegadorAPDP, @ModeloDispositivoAPDP, @PubliAPDP, @MedioAutorizacion, @ProveedorId, @IdSupervisor, dbo.getdate(), @DiaLlamada, @Horario) 
                                           
                IF (ISNULL(@Direccion, '') <> '')         
                BEGIN         
                    INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                                                                  
                                            VALUES (@DatosDireccionId, @PersonaId, 1, 1, @Direccion, @Referencia, @Ubigeo, 1)          
                END   
            END                
        END                                                   
        ELSE          
        BEGIN       
            SET @DatosDireccionId = (SELECT ISNULL(MAX(DatosDireccionId), 0) from SGF_DatosDireccion WHERE PersonaId = @PersonaId AND TipoDireccionId = 1)                                                   
            SET @ValueFechaAPDP = (SELECT FechaAPDP from SGF_Persona WHERE PersonaId = @PersonaId)                                 
                              
            IF (ISNULL(@ValueFechaAPDP, '') = '')                                 
            BEGIN                                      
                UPDATE SGF_Persona    
                SET Nombre = @Nombre,    
                    ApePaterno = @ApePaterno,    
                    ApeMaterno = @ApeMaterno,    
                    DocumentoNum = @DocumentoNum,    
                    Telefonos = @Telefonos,    
                    Celular = @Celular,    
                    Celular2 = @Celular2,    
                    EstadoCivilId = @EstadoCivilId,    
                    Correo = @Correo,    
                    APDP = @APDP,    
                    IpAPDP = @IpAPDP,    
                    FechaAPDP = @FechaAPDP,    
                    NavegadorAPDP = @NavegadorAPDP,    
                    ModeloDispositivoAPDP = @ModeloDispositivoAPDP,    
                    DiaLlamada = @DiaLlamada,    
                    Horario = @Horario,    
                    IdSupervisor  = @IdSupervisor,    
                    EstadoPersonaId = @EstadoProcesoId           
                WHERE PersonaId = @PersonaId                                      
            END                                 
            ELSE                                  
            BEGIN                                 
                UPDATE SGF_Persona    
                SET Nombre = @Nombre,    
                    ApePaterno = @ApePaterno,    
                    ApeMaterno = @ApeMaterno,    
                    DocumentoNum = @DocumentoNum,    
                    Telefonos = @Telefonos,    
                    Celular = @Celular,    
                    Celular2 = @Celular2,    
                    EstadoCivilId = @EstadoCivilId,    
                    Correo = @Correo,    
                    DiaLlamada = @DiaLlamada,    
                    Horario = @Horario,    
                    IdSupervisor  = @IdSupervisor,    
                    EstadoPersonaId = @EstadoProcesoId           
                WHERE PersonaId = @PersonaId                                                
            END                         
                                                           
            IF (ISNULL(@Direccion, '') <> '')         
            BEGIN        
                IF (@DatosDireccionId = 0)             
                BEGIN             
                    SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) + 1 from SGF_DatosDireccion)       
       		     
                        INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                                                                  
                                                VALUES (@DatosDireccionId, @PersonaId, 1, 1, @Direccion, @Referencia, @Ubigeo, 1)          
                    
                END             
                ELSE             
                BEGIN             
                    UPDATE SGF_DatosDireccion    
                    SET Direccion = @Direccion,    
                        Referencia = @Referencia,    
                        Ubigeo = @Ubigeo                         
                    WHERE DatosDireccionId = @DatosDireccionId             
                END 
            END            
        END                         
                  
        IF ((@CanalVentaID <> 12 AND @Celular1Repetido = '' AND @Celular2Repetido = '' AND @TelefonoRepetido = '') OR @CanalVentaID = 12)        
        BEGIN                   
            SET @ExpedienteCreditoId = (SELECT MAX(ExpedienteCreditoId) + 1 from SGF_ExpedienteCredito)   
            SET @EvaluacionId = (SELECT MAX(EvaluacionId) + 1 from SGF_Evaluaciones)                                                    
               
            INSERT INTO SGF_ExpedienteCredito (ExpedienteCreditoId, TitularId, TipoUsuarioRegistroId, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, EstadoProcesoId, EstadoExpedienteId,    
                                               CanalVentaID, ProveedorId, UserIdCrea, FechaCrea, FechaContacto, TipoExpediente, Obra, IdSupervisor, AdvId, BancoId, DispositivoId, CategoriaId, TipoCredito,    
                                               IsBancarizado, FechaAgENDa, FechaActua, Prioridad, Proyecto)                                                   
                                       VALUES (@ExpedienteCreditoId, @PersonaId, 0, IIF(@CanalVentaID = 12, 6, @ExpedienteCreditoZonaId), IIF(@CanalVentaID = 12, 13, @ExpedienteCreditoLocalId), @EstadoProcesoId, 1,  
									           @CanalVentaID, @ProveedorId, @UserIdCrea, dbo.getdate(), dbo.getdate(), 1, @Obra, @IdSupervisor, @AdvId, @BancoId, @DispositivoId, 1, @TipoCredito,  
											   @IsBancarizado, dbo.GETDATE(), dbo.GETDATE(), @Prioridad, @Proyecto)                                              
      
          
            INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId)                                                   
                                  VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @ResultadoId, @Observacion, 1, @UserIdCrea, dbo.getdate(), 1)                                                   
                                
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                                   
                                              VALUES (@ExpedienteCreditoId, 1, 1, dbo.getdate(), @UserIdCrea, IIF(@Prioridad = 'URGENTE', @ObservacionCambioEstado, @Observacion))                                                   
                                 
            IF (@EstadoProcesoId = 2)   
            BEGIN                                                   
                UPDATE SGF_ExpedienteCredito                                                   
                SET Observacion = @Observacion,    
                    FechaActua = dbo.GETDATE(),    
                    FechaProspecto = dbo.GETDATE()                                                   
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId                                                   
            END                                                   
            ELSE IF (@EstadoProcesoId = 11)   
            BEGIN                                                   
                UPDATE SGF_ExpedienteCredito                                                   
                SET EstadoProcesoId = @EstadoProcesoId,    
                    EstadoExpedienteId = 2,    
                    FechaActua = dbo.GETDATE(),    
                    FechaNoCalifica = dbo.GETDATE(),    
                    Observacion = @Observacion,    
                    UserIdActua = @UserIdCrea                                                   
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId                                                   
            END                                                   
                                
            IF (@EstadoProcesoId > 1)   
            BEGIN                                                   
                INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                                   
                VALUES (@ExpedienteCreditoId, 2, @EstadoProcesoId, dbo.getdate(), @UserIdCrea, @Observacion)                     
            END           
                       
            SET @Success = 1;                                                   
            SET @Message = 'OK';        
        END        
        ELSE        
        BEGIN        
            SET @Success = 2;        
                                                                  
            SET @Message = 'El número ' +    
                  IIF(@Celular1Repetido ! =  '', @Celular1Repetido ,    
                           IIF(@Celular2Repetido ! =  '', @Celular2Repetido,    
                           IIF(@TelefonoRepetido ! =  '', @TelefonoRepetido, ''))) + ' está registrado en otra persona';         
        END        
    END        
                                              
    SET @PersonaIdOutput = @PersonaId;                                   
    SET @ExpedienteCreditoIdOutput = @ExpedienteCreditoId;            
   
    /* ===  Ingreso Datos Involucrados  === */                                                   
    --ELSE IF (@TipoPersonaId > 1)                      
    --BEGIN                                                   
    --    IF (@PersonaId = 0)                                                   
    --    BEGIN                                                   
    --        SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) + 1 from SGF_DatosDireccion)      
    --        SET @PersonaId = (SELECT MAX(PersonaId) + 1 from SGF_Persona)                                                   
                                                                      
    --        INSERT INTO SGF_Persona (PersonaId, ZonaId, LocalId, EstadoPersonaId, Nombre, ApePaterno, ApeMaterno, DocumentoNum, Telefonos, Celular, Celular2, EstadoCivilId, Correo, UserIdCrea, FechaCrea, DiaLlamada, Horario)                             
 
                       
    --                         VALUES (@PersonaId, IIF(@CanalVentaID = 12, 6, @ExpedienteCreditoZonaId), IIF(@CanalVentaID = 12, 13, @ExpedienteCreditoLocalId), @EstadoProcesoId, @Nombre, @ApePaterno, @ApeMaterno, @DocumentoNum, @Telefonos,    
    --                                 @Celular, @Celular2, @EstadoCivilId, @Correo, @UserIdCrea, dbo.GETDATE(), @DiaLlamada, @Horario)                      
                                      
    --        INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                                                    
    --                                VALUES (@DatosDireccionId, @PersonaId, 1, 1, @Direccion, @Referencia, @Ubigeo, 1)                 
    --    END                                                   
    --    ELSE IF (@PersonaId>0)                          
    --    BEGIN                                                   
    --        SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) from SGF_DatosDireccion WHERE PersonaId = @PersonaId AND TipoDireccionId = 1)                                                   
                                                                  
    --        UPDATE SGF_Persona                                                   
    --        SET Nombre = @Nombre,    
    --            ApePaterno = @ApePaterno,    
    --            ApeMaterno = @ApeMaterno,    
    --            DocumentoNum = @DocumentoNum,    
    --            Telefonos = @Telefonos,    
    --            Celular = @Celular,    
    --            Celular2 = @Celular2,    
    --            EstadoCivilId = @EstadoCivilId,    
    --            Correo = @Correo,    
    --            DiaLlamada = @DiaLlamada,    
    --            Horario = @Horario,    
    --            IdSupervisor  = @IdSupervisor                    
    --        WHERE PersonaId = @PersonaId                                                   
                                                                      
    --        UPDATE SGF_DatosDireccion                                                   
    --        SET Direccion = @Direccion,    
    --            Referencia = @Referencia,    
    --            Ubigeo = @Ubigeo                                          
    --        WHERE DatosDireccionId = @DatosDireccionId   
    --    END                           
                                   
    --    SET @EvaluacionId = (SELECT MAX(EvaluacionId) + 1 from SGF_Evaluaciones)                    
                                
    --    INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId)                                      
    --                          VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @ResultadoId, @Observacion, 0, @UserIdCrea, dbo.getdate(), @TipoPersonaId)                                   
                                                                  
    --    /* ===  Si Involucrado No CalIFica, finaliza Crédito  === */                                                   
    --    IF (@ResultadoId = 3)                                                   
    --    BEGIN                          
    --        UPDATE SGF_ExpedienteCredito                                                   
    --        SET EstadoProcesoId = @EstadoProcesoId,    
    --            EstadoExpedienteId = 2,    
    --            FechaActua = dbo.GETDATE(),    
    --            FechaNoCalifica = dbo.GETDATE(),    
    --            Observacion = @Observacion,    
    --            UserIdActua = @UserIdCrea                                         
    --        WHERE ExpedienteCreditoId = @ExpedienteCreditoId                                                   
                                                                      
    --        DECLARE @ItemId int = (SELECT MAX(ItemId) + 1 from SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                    
                                       
    --        INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                                   
    --        VALUES (@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.getdate(), @UserIdCrea, @Observacion)                    
    --    END                                                   
    --END                                  
   
    COMMIT;                                                   
END TRY                                                     
BEGIN CATCH                                                     
    SET @Success = 0;                                                   
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();                                                   
    ROLLBACK;                                                   
END CATCH