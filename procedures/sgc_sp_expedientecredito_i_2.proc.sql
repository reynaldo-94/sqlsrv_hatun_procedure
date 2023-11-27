/*--------------------------------------------------------------------------------------                                                                                                                     
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_I_2]                                                                                                                                      
' Objetivo        : Este procedimiento registrar nuevos creditos para una persona nueva                                                                                                                         
' Creado Por      : SAMUEL FLORES                                                                                                       
' Día de Creación : 24-03-2021                                                                                                                                  
' Requerimiento   : SGC                                                                                                                               
' Modificado por  : Reynaldo Cauche                                                                                                              
' Día de Modificación : 26-04-2022                                                                         
' Cambios                                                                      
    - 03/10/2022 - Cristian Silva   : Solo se modifico @DocumentoNum se agrego el varchar(11) por el varchar(12)                                                                   
    - 29/12/2022 - Reynaldo Cauche  : Agregar campo Prioridad e insertarlo en la tabla SGF_ExpedienteCredito                                                                   
    - 06/12/2022 - Reynaldo Cauche  : Se agrego el parametro @ObservacionCambioEstado                                                                 
    - 03/02/2022 - Reynaldo Cauche  : Se agrego valildacion cuando el tipodireccion no sea igual a 1, se agrego un insert con tipo direccion igual a 1                                                                
    - 16/02/2023 - Cristian Silva   : Se habilito @EstadoProcesoId en sgf_personapara actualizar el estado                                                           
    - 18/03/2023 - Reynaldo Cauche  : Se agrego validacion para el celular                                                           
    - 22/03/2023 - Reynaldo Cauche  : Se agrego validacion para TELEFONOS y se cambio el mensaje                                                   
    - 04/05/2023 - Francisco Lazaro : Validacion de direccion para web                                               
    - 10/05/2023 - Francisco Lazaro : Agregar parametro Proyecto e insertarlo en la tabla SGF_ExpedienteCredito                                 
    - 05/06/2023 - Francisco Lazaro : Actualizar OrigenId para involucrados                                 
    - 13/06/2023 - Reynaldo Cauche  : Se removió la validacion del telefono o celular repetido                              
    - develop-ALFIN - 24/07/2023 - Reynaldo Cauche  : Se modificó el split para las ofertas                
    - develop-ALFIN - /07/2023 - cristian silva - se add @_CanalAlFinId          
    - develop-ALFIN - /08/2023 - cristian silva - se valido el local y zona           
    - develop-rediseño - 21/08/2023 - cristian silva : se add @CurrentHorario               
    - develop-alfin - 18/10/2023 - se valido para que en el historial se guarde 'pre aprobado' en lugar de la oferta, cuando el unico banco aprobado es alfin  
 - develop-manya - 23/10/2023 - francisco lazaro: Se agrega parametro @referidoDoc  
'--------------------------------------------------------------------------------------*/                                                          
                                                                                                       
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_I_2]                                         
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
 @BancoId varchar(100),                                                                 
 @Prioridad varchar(15),                                   
 @BancoIdSelect int = NULL,                                   
 -- Respuesta Sentinel                                                                              
 @ResultadoId varchar(100),                                                           
 @Observacion varchar(MAX),                            
 @Ofertas varchar(MAX) = NULL,                            
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
 @CanalAlFinId varchar(MAX) = NULL,                        
 @TipoBancaId int = NULL,  
 --Referido  
 @ReferidoDoc varchar(15) = NULL,  
 -- Output                                                           
 @Success INT OUTPUT,                                                                                                       
 @Message varchar(8000) OUTPUT,                                                                                       
 @PersonaIdOutput INT OUTPUT,                                                                                       
 @ExpedienteCreditoIdOutput INT OUTPUT)                                                           
AS                        
DECLARE @DatosDireccionId int                                                                                                      
DECLARE @EvaluacionId int                                                                                    
DECLARE @ValueFechaAPDP varchar(100)                                     
DECLARE @OrigenActual int                                 
DECLARE @ObservacionDetalle varchar(MAX) = ''                        
                        
DECLARE @ExpedienteCreditoIdActual int                        
DECLARE @ExpedienteCreditoLocalIdActual int                        
DECLARE @ExpedienteCreditoZonaIdActual int                        
DECLARE @AdvIdActual int                        
DECLARE @ExpedienteCreditoLocalIdNuevo int                        
DECLARE @ExpedienteCreditoZonaIdNuevo int                        
DECLARE @AdvIdNuevo int                    
DECLARE @CurrentHorario varchar(2)  
DECLARE @ReferidoId int  
BEGIN TRY                                                                                                         
    BEGIN TRANSACTION                                                        
                                                                             
    SET @Success = 0      
    SET @ExpedienteCreditoIdActual = ISNULL((select MAX(ExpedienteCreditoId) from SGF_ExpedienteCredito where TitularId = @PersonaId), 0)                        
    SET @ExpedienteCreditoLocalIdActual = IIF(ISNULL(@ExpedienteCreditoId, 0) = 0, 0, (select ExpedienteCreditoLocalId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoIdActual))                        
    SET @ExpedienteCreditoZonaIdActual = IIF(ISNULL(@ExpedienteCreditoId, 0) = 0, 0, (select ExpedienteCreditoZonaId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoIdActual))                        
    SET @AdvIdActual = IIF(ISNULL(@ExpedienteCreditoId, 0) = 0, 0, (select AdvId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoIdActual))                        
    SET @OrigenActual = ISNULL((SELECT DISTINCT OrigenId FROM SGF_Persona where PersonaId = (SELECT MAX(PersonaId) FROM SGF_Persona where DocumentoNum = @DocumentoNum)), 0)                        
    SET @ExpedienteCreditoLocalIdActual  = IIF(@ExpedienteCreditoLocalIdActual = 0, 13, @ExpedienteCreditoLocalIdActual)                        
    SET @ExpedienteCreditoZonaIdActual  = IIF(@ExpedienteCreditoZonaIdActual = 0, 6, @ExpedienteCreditoZonaIdActual)                   
    SET @CurrentHorario = iif(@CanalVentaID= 12 and @Horario != '',@Horario, iif(@CanalVentaID= 12 or @Horario = '','0',@Horario))  
 SET @ReferidoId = IIF(ISNULL(@ReferidoDoc, '') != '', (select top 1 PersonaId from SGF_Persona where DocumentoNum = @ReferidoDoc), 0)  
       
    DECLARE @selectAdv int = isnull((SELECT TOP(1) a.advid                        
                                     FROM sgf_adv_atencion  a                     
                                     inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                        
                                     inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                        
                                     inner join SGF_Local lo on lo.ZonaId = zo.ZonaId       
                                     inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                        
                                     where rezo.esActivo = 1 and lo.localid = @ExpedienteCreditoLocalIdActual                        
                                     ORDER BY a.FechaAsignacion ASC),0)                      
                         
    SET @advIdNuevo = IIF(@AdvIdActual = 0,(iif(@selectAdv = 0, (SELECT TOP(1) a.advid                        
                                                                 FROM sgf_adv_atencion  a                        
                                                                 inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                        
                                                                 inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                        
                                                                 inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                        
                                                                 inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                        
                                                                 WHERE rezo.esActivo = 1 and lo.localid = 13                       
                                                                 ORDER BY a.FechaAsignacion ASC),@selectAdv)), @AdvIdActual)                        
                                                                                  
    IF ((@CanalVentaID <> 12 AND (@PersonaId = 0 OR @PersonaId <> 0)) OR @CanalVentaID = 12)                    
    BEGIN                                         
        -- Ingreso Datos Titular ---------------------------------------------------------------------------------------------------------------------------                                                           
        IF (@TipoPersonaId = 0 or @TipoPersonaId = 1)                                                                                                       
        BEGIN                                                          
            IF (@PersonaId = 0)                                                       
            BEGIN                                                              
                SET @DatosDireccionId = (Select MAX(DatosDireccionId) + 1 from SGF_DatosDireccion)                                                                          
                SET @PersonaId = (Select MAX(PersonaId) + 1 from SGF_Persona)                                   
                INSERT INTO SGF_Persona (PersonaId, ZonaId, LocalId, EstadoPersonaId, Nombre, ApePaterno, ApeMaterno, DocumentoNum, Telefonos, Celular, Celular2, EstadoCivilId, Correo, UserIdCrea, OrigenId,  
                                         APDP, IpAPDP, FechaAPDP, NavegadorAPDP, ModeloDispositivoAPDP, PubliAPDP, MedioAutorizacion, ProveedorLocalId, IdSupervisor, FechaCrea, DiaLlamada, Horario)  
                                 VALUES (@PersonaId, IIF(@CanalVentaID = 12, 6, @ExpedienteCreditoZonaId), IIF(@CanalVentaID = 12, 13, @ExpedienteCreditoLocalId), @EstadoProcesoId, @Nombre, @ApePaterno, @ApeMaterno, @DocumentoNum, @Telefonos, @Celular, @Celular2, @EstadoCivilId,                                                          
                                         @Correo, @UserIdCrea, @OrigenId, @APDP, @IpAPDP, @FechaAPDP, @NavegadorAPDP, @ModeloDispositivoAPDP, @PubliAPDP, @MedioAutorizacion, @ProveedorId, @IdSupervisor, dbo.getdate(), @DiaLlamada, @CurrentHorario)        
  
  
                IF (ISNULL(@Direccion, '') <> '')                                               
                BEGIN                                               
                    INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                                     
                    VALUES (@DatosDireccionId, @PersonaId, 1, 1, @Direccion, @Referencia, @Ubigeo, 1)                                                
                END                                               
           END                             
            ELSE                                         
            BEGIN                                                              
                SET @DatosDireccionId = (Select isnull(MAX(DatosDireccionId), 0) from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId = 1)                                                                                                   
 
     
                SET @ValueFechaAPDP = (Select FechaAPDP from SGF_Persona where PersonaId = @PersonaId)                                                                                     
                                                                                                         
                IF(ISNULL(@ValueFechaAPDP,'') = '')                                              
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
                        Horario = @CurrentHorario,                                                                        
                        IdSupervisor = @IdSupervisor,                                                         
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
                        Horario = @CurrentHorario,                                                                        
                        IdSupervisor = @IdSupervisor,                                                               
                        EstadoPersonaId = @EstadoProcesoId,                                 
                        OrigenId = IIF(@OrigenActual = 0, @OrigenId, OrigenId)                                 
                    WHERE PersonaId = @PersonaId                                                                                                    
                END                                                                             
                IF (ISNULL(@Direccion, '') <> '')                                             
                BEGIN                                             
                    IF (@DatosDireccionId = 0)                                                                 
                    BEGIN                                                                 
                        SET @DatosDireccionId = (Select MAX(DatosDireccionId)+1 from SGF_DatosDireccion)                                             
                                                
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
        END                                                           
                                                            
        -- SEGUNDO IF ----------------------------------------------------------------------------------------------------------------------------------                                                           
                                                                              
        SET @ExpedienteCreditoId = (Select MAX(ExpedienteCreditoId) + 1 from SGF_ExpedienteCredito)                                                        
                                                       
        DECLARE @EvaluacionSentinel TABLE(Id int identity(1,1), BancoId int, ResultadoId int, Observacion varchar(MAX), Ofertas varchar(MAX), CanalAlFinId varchar(MAX))                                                         
                                                              
        INSERT INTO @EvaluacionSentinel SELECT A.data [BancoId], B.data [ResultadoId], C.data [Observacion], D.data [Ofertas], E.data[CanalAlFin]                           
        FROM (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@BancoId, ',')) A                                                           
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@ResultadoId, ',')) B ON A.Row = B.Row                               
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@Observacion, ',')) C ON A.Row = C.Row                            
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@Ofertas, '//#')) D ON A.Row = D.Row                          
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@CanalAlFinId, ',')) E ON A.Row = E.Row      
                                                                               
        INSERT INTO SGF_ExpedienteCredito (ExpedienteCreditoId, TitularId, TipoUsuarioRegistroId, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, EstadoProcesoId, EstadoExpedienteId,                     
                                           CanalVentaID, ProveedorId, UserIdCrea, FechaCrea, FechaContacto, TipoExpediente, Obra, IdSupervisor, AdvId, BancoId, DispositivoId, CategoriaId,                                      
                                           TipoCredito, IsBancarizado, FechaAgenda, FechaActua, Prioridad, Proyecto, TipoBanca, ReferidoId)                                                                                                       
                                   VALUES (@ExpedienteCreditoId, @PersonaId, 0, IIF(@TipoBancaId = 1, @ExpedienteCreditoZonaIdActual, IIF(@CanalVentaID = 12, 6, @ExpedienteCreditoZonaId)),                         
                                           IIF(@TipoBancaId = 1, @ExpedienteCreditoLocalIdActual, IIF(@CanalVentaID = 12, 13, @ExpedienteCreditoLocalId)), @EstadoProcesoId, 1,              
                                           @CanalVentaID, @ProveedorId, @UserIdCrea, dbo.GETDATE(), dbo.GETDATE(), 1, @Obra, @IdSupervisor,  IIF(@TipoBancaId = 1, @AdvIdNuevo, @AdvId), @BancoIdSelect, @DispositivoId, 1,                                   
   
                                           @TipoCredito, @IsBancarizado, dbo.GETDATE(), dbo.GETDATE(), @Prioridad, @Proyecto, @TipoBancaId, @ReferidoId)                                           
                                                              
        DECLARE @i INT = 1           
        WHILE (@i <= (Select MAX(Id) from @EvaluacionSentinel))                                                         
        BEGIN                                                         
            SET @EvaluacionId = (Select MAX(EvaluacionId) + 1 from SGF_Evaluaciones)                                                         
            DECLARE @_BancoId int = (select BancoId from @EvaluacionSentinel where Id = @i)                                                         
            DECLARE @_ResultadoId int = (select ResultadoId from @EvaluacionSentinel where Id = @i)                                                         
            DECLARE @_Observacion varchar(MAX) = (select Observacion from @EvaluacionSentinel where Id = @i)                                               
            DECLARE @_Ofertas varchar(MAX) = (select Ofertas from @EvaluacionSentinel where Id = @i)                          
            DECLARE @_CanalAlFinId varchar(MAX) = (select CanalAlFinId from @EvaluacionSentinel where Id = @i)                             
            DECLARE @_IsInsertEvaluacion int = (select COUNT(*) from SGF_Evaluaciones X where X.ExpedienteCreditoId = @ExpedienteCreditoId and X.PersonaId = @PersonaId and X.BancoId = @_BancoId)                                     
            DECLARE @_ResultadoIdActual int = (select TOP 1 ResultadoId from SGF_Evaluaciones X where X.ExpedienteCreditoId = @ExpedienteCreditoId and X.PersonaId = @PersonaId and X.BancoId = @_BancoId)                                     
            DECLARE @_EvaluacionIdActual int = (select TOP 1 EvaluacionId from SGF_Evaluaciones X where X.ExpedienteCreditoId = @ExpedienteCreditoId and X.PersonaId = @PersonaId and X.BancoId = @_BancoId)                                     
            SET @ObservacionDetalle = IIF(@ObservacionDetalle = '', @_Observacion, IIF(@_ResultadoId = 2, @_Observacion, @ObservacionDetalle))                               
            IF @_IsInsertEvaluacion = 0                                     
            BEGIN                          
            -- Banco != 13 : 13 != 13                          
            -- Banco = 13 y Ofertas no es null : 13 = 13 y Ofertas = null                          
                IF (@_BancoId != 13 or (@_BancoId = 13 and ((@_Ofertas != '' and @TipoBancaId != 1) or @_Observacion = 'NO CUENTA CON CAMPAÑAS' or @_Observacion = 'NO CUENTA CON CAMPANIAS' or @_Observacion = 'YA CUENTA CON UN DESEMBOLSO ACTIVO')))        
                    
                BEGIN                          
                    INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, BancoId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId, Ofertas, CanalAlFinId)              
                                          VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @_BancoId, @_ResultadoId, @_Observacion, 1, @UserIdCrea, dbo.GETDATE(), 1, @_Ofertas, @_CanalAlFinId)                          
                END                          
            END                                     
            ELSE IF @_ResultadoIdActual NOT IN (1, 2, 3)                                     
            BEGIN                                     
                UPDATE SGF_Evaluaciones SET ResultadoId = @_ResultadoId WHERE EvaluacionId = @_EvaluacionIdActual               
            END                                     
            SET @i  = @i  + 1                                                         
        END                                                  
                                                       
        INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                           
        VALUES (@ExpedienteCreditoId, 1, 1, dbo.GETDATE(), @UserIdCrea, IIF(@Prioridad = 'URGENTE', @ObservacionCambioEstado, IIF(CHARINDEX('CON SCORE', @ObservacionDetalle) > 0 or CHARINDEX('-CAMPAÑA', @ObservacionDetalle) > 0, 'CLIENTE TIENE UN CREDITO PRE-APROBADO POR SU BUENA CALIFICACION EN EL SISTEMA FINANCIERO.', @ObservacionDetalle)))                               
                                                                   
        IF @EstadoProcesoId = 2                                               
        BEGIN                      
            UPDATE SGF_ExpedienteCredito                                                                                                       
            SET Observacion = IIF(CHARINDEX('CON SCORE', @ObservacionDetalle) > 0, 'CLIENTE TIENE UN CREDITO PRE-APROBADO POR SU BUENA CALIFICACION EN EL SISTEMA FINANCIERO.', @ObservacionDetalle),                                           
                FechaActua = dbo.GETDATE(),                                                                                                       
                FechaProspecto = dbo.GETDATE()                 
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId                                                                                                      
        END                                                                                                       
        ELSE IF @EstadoProcesoId = 11                                                                                                       
        BEGIN                       
            UPDATE SGF_ExpedienteCredito                                                                                          
            SET EstadoProcesoId = @EstadoProcesoId,                                                                                                       
                EstadoExpedienteId = 2,                                                                                                       
                FechaActua = dbo.GETDATE(),                                                                                                       
                FechaNoCalifica = dbo.GETDATE(),                                                                                     
                Observacion = IIF(CHARINDEX('CON SCORE', @ObservacionDetalle) > 0, 'CLIENTE TIENE UN CREDITO PRE-APROBADO POR SU BUENA CALIFICACION EN EL SISTEMA FINANCIERO.', @ObservacionDetalle),                        
                UserIdActua = @UserIdCrea                                                                    
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId                                                                                                  
        END                                                                                                       
                                                        
        IF @EstadoProcesoId > 1                                                                        
        BEGIN                                                                                                       
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                                                                                       
            VALUES (@ExpedienteCreditoId, 2, @EstadoProcesoId, dbo.GETDATE(), @UserIdCrea, IIF(CHARINDEX('CON SCORE', @ObservacionDetalle) > 0 or CHARINDEX('-CAMPAÑA', @ObservacionDetalle) > 0, 'CLIENTE TIENE UN CREDITO PRE-APROBADO POR SU BUENA CALIFICACION EN EL SISTEMA FINANCIERO.',@ObservacionDetalle))              
        END                                                                                                    
        SET @Success = 1                                                       
        SET @Message = 'OK'                                                       
        SET @PersonaIdOutput = @PersonaId                                                       
        SET @ExpedienteCreditoIdOutput = @ExpedienteCreditoId                                                       
    END                             
                                                        
    COMMIT;                                                                                                  
END TRY                                                                                                         
BEGIN CATCH                                                                                                        
    SET @Success = 0;                                                                      
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();                                                                    
    ROLLBACK;                                                                                                       
END CATCH