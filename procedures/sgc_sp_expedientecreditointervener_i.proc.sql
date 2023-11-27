/*--------------------------------------------------------------------------------------                                                                 
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_I]                                                                                  
' Objetivo        : Este procedimiento registrar nuevos creditos para una persona nueva                                                                     
' Creado Por      : cristian silva                                                  
' Día de Creación : 22-12-2022                                                                              
' Requerimiento   : SGC                                                                           
' cambios            
- 03/02/2022 - Reynaldo Cauche - Se agrego valildacion cuando el tipodireccion no sea igual a 1, se agrego un insert con tipo direccion igual a 1       
- 04/08/2022 - Reynaldo Cauche - Se agrego condicion para que no inserte en banco Alfin (13)
'--------------------------------------------------------------------------------------*/                                                       
                                                   
ALTER PROCEDURE [dbo].[SGC_SP_ExpedienteCreditoIntervener_I]     
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
 -- Datos Expediente Credito                                                   
 @ExpedienteCreditoId int,                                                      
 @ExpedienteCreditoZonaId int,                                                  
 @ExpedienteCreditoLocalId int,                                                      
 @EstadoProcesoId int,                                                                                          
 @UserIdCrea int,                                                                                                                                                                           
 @DispositivoId int,                              
 -- Respuesta Sentinel     
 @BancoId varchar(500),     
 @ResultadoId varchar(500),                                               
 @Observacion varchar(MAX),                                               
 @Ofertas varchar(MAX),                           
 -- datos laborales            
 @DatosDireccionId int,             
 @CasaPropia int,               
 @DatosLaboralesId int,               
 @TipoTrabajoId int,               
 @FormalidadTrabajoId int,               
 @UbigeoTrabajo varchar(500),               
 @DireccionTrabajo varchar(500),               
 @ReferenciaTrabajo varchar(500),               
 @NombreEstablecimiento varchar(500),               
 @RucEstablecimiento varchar(500),               
 @CentroTrabajo varchar(500),               
 @GiroId int,               
 @SustentoIngresoId int,               
 @IngresoNeto varchar(50),               
 @AntiguedadLaboral varchar(500),                
 @DiasPago int,                                        
 -- Output         
 @Success INT OUTPUT,               
 @Message varchar(8000) OUTPUT,                                     
 @PersonaIdOutput INT OUTPUT,                                     
 @ExpedienteCreditoIdOutput INT OUTPUT)     
AS                                                                                        
DECLARE @EvaluacionId int                                  
DECLARE @DatosDireccionTrabajoId int              
DECLARE @TipoDireccionTrabajoId int              
BEGIN TRY                                                     
    BEGIN TRANSACTION                          
     
    SET @TipoDireccionTrabajoId = IIF(@TipoTrabajoId=1,2,3)             
    SET @Success=0;                                           
                                       
    -- Ingreso Datos Involucrados ----------------------------------------------------------------------------------------------------------------------------     
    IF (@TipoPersonaId > 1)                      
    BEGIN                                                   
        IF (@PersonaId = 0)                                                   
        BEGIN                                                                            
            SET @PersonaId = (SELECT MAX(PersonaId) + 1 FROM SGF_Persona)                                                   
                                                                
            INSERT INTO SGF_Persona (PersonaId, ZonaId, LocalId, EstadoPersonaId, Nombre, ApePaterno, ApeMaterno, DocumentoNum, Telefonos, Celular, Celular2, EstadoCivilId, Correo, UserIdCrea, FechaCrea, CasaPropia)                                       
  
                             VALUES (@PersonaId, @ExpedienteCreditoZonaId, @ExpedienteCreditoLocalId, @EstadoProcesoId, @Nombre, @ApePaterno, @ApeMaterno, @DocumentoNum, @Telefonos, @Celular, @Celular2, @EstadoCivilId, @Correo, @UserIdCrea, dbo.GETDATE(),@CasaPropia)                      
                                  
            IF (@DatosDireccionId = 0 or @DatosDireccionId is null)                                         
            BEGIN                                         
               SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) + 1 FROM SGF_DatosDireccion)                                         
               INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                                         
                                       VALUES (@DatosDireccionId, @PersonaId, 1, 1, @Direccion, @Referencia, @Ubigeo, 1)                                         
            END                                         
     
            IF (@DatosLaboralesId = 0 or @DatosLaboralesId is null )                                         
            BEGIN                                         
                SET @DatosLaboralesId = (SELECT MAX(DatosLaboralesId) + 1 FROM SGF_DatosLaborales)                                         
                INSERT INTO SGF_DatosLaborales (DatosLaboralesId,PersonaId,TipoTrabajoId,FormalidadTrabajoId,TipoEstablecimiento,NombreEstablecimiento,ActividadEconomicaId,GiroId,CentroTrabajo,SustentoIngresoId,Cargo,IngresoNeto,AntiguedadLaboral,DiasPago,Ruc)                                     
                                        VALUES (@DatosLaboralesId,@PersonaId,@TipoTrabajoId,@FormalidadTrabajoId,'',@NombreEstablecimiento,0,@GiroId,@CentroTrabajo, @SustentoIngresoId,'',@IngresoNeto,@AntiguedadLaboral,@DiasPago,@RucEstablecimiento)      
            END            
                    
            IF (Len(@DocumentoNum) != 11)                                         
            BEGIN                                         
                SET @DatosDireccionTrabajoId = (SELECT MAX(DatosDireccionId) + 1 FROM SGF_DatosDireccion)             
                INSERT INTO SGF_DatosDireccion (DatosDireccionId, PersonaId, TipoDireccionId, Correspondencia, Direccion, Referencia, Ubigeo, EsFijo)                      
                                        VALUES (@DatosDireccionTrabajoId, @PersonaId, @TipoDireccionTrabajoId, 0, @DireccionTrabajo, @ReferenciaTrabajo, @UbigeoTrabajo,0)                      
            END             
        END              
        ----------------------------------------------------------------------------------------------------------------------------------------------------------     
        ELSE IF (@PersonaId > 0)                          
        BEGIN            
            DECLARE @DatosDireccionIdPerson int;        
            SET @DatosDireccionIdPerson = (SELECT MAX(DatosDireccionId) FROM SGF_DatosDireccion WHERE PersonaId=@PersonaId and TipoDireccionId=1)           
            SET @DatosDireccionTrabajoId = (SELECT top 1 DatosDireccionId FROM SGF_DatosDireccion WHERE PersonaId=@PersonaId and TipoDireccionId<>1)            
                                                                  
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
                CasaPropia = @CasaPropia,            
                UserIdActua = @UserIdCrea            
            WHERE PersonaId = @PersonaId                                                   
                            
            IF (@DatosDireccionIdPerson > 0)                                         
            BEGIN        
                UPDATE SGF_DatosDireccion                                                   
                SET Direccion = @Direccion,                                                   
                    Referencia = @Referencia,                                                   
                    Ubigeo = @Ubigeo            
                WHERE DatosDireccionId = @DatosDireccionIdPerson                 
            END       
            ELSE        
            BEGIN       
                SET @DatosDireccionId = (SELECT MAX(DatosDireccionId) + 1 FROM SGF_DatosDireccion)       
                INSERT INTO SGF_DatosDireccion (DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                                         
                                        VALUES (@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)       
            END       
                    
            IF (@DatosLaboralesId > 0)                                         
            BEGIN              
                UPDATE SGF_DatosLaborales         
                SET TipoTrabajoId = @TipoTrabajoId        
                   ,FormalidadTrabajoId = @FormalidadTrabajoId        
                   ,TipoEstablecimiento = ''        
                   ,NombreEstablecimiento = @NombreEstablecimiento        
                   ,ActividadEconomicaId = 0        
                   ,GiroId = @GiroId        
                   ,CentroTrabajo = @CentroTrabajo        
                   ,SustentoIngresoId = @SustentoIngresoId        
                   ,Cargo = ''        
                   ,IngresoNeto = @IngresoNeto        
                   ,AntiguedadLaboral = @AntiguedadLaboral        
                   ,DiasPago = @DiasPago        
                   ,Ruc = @RucEstablecimiento                                  
                WHERE PersonaId = @PersonaId  and DatosLaboralesId = @DatosLaboralesId                                       
            END         
                
            IF (Len(@DocumentoNum) != 11)                                         
         BEGIN                                         
                UPDATE SGF_DatosDireccion            
                SET TipoDireccionId = @TipoDireccionTrabajoId        
                   ,Correspondencia = 0        
                   ,Direccion = @DireccionTrabajo        
                   ,Referencia = @ReferenciaTrabajo        
                   ,Ubigeo = isnull(@UbigeoTrabajo,'')        
                   ,EsFijo = 0        
                WHERE DatosDireccionId = @DatosDireccionTrabajoId                                  
            END     
        END              
                    
        DECLARE @EvaluacionSentinel TABLE(Id int identity(1,1), BancoId int, ResultadoId int, Observacion varchar(MAX), Ofertas varchar(MAX))       
            
        INSERT INTO @EvaluacionSentinel SELECT A.data [BancoId], B.data [ResultadoId], C.data [Observacion], D.data[Ofertas]          
        FROM (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@BancoId, ',')) A         
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@ResultadoId, ',')) B ON A.Row = B.Row         
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@Observacion, ',')) C ON A.Row = C.Row      
        LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(@Ofertas, ',')) D ON A.Row = D.Row   
         
        DECLARE @i INT = 1       
        WHILE (@i <= (Select MAX(Id) from @EvaluacionSentinel))       
        BEGIN       
            SET @EvaluacionId = (Select MAX(EvaluacionId) + 1 from SGF_Evaluaciones)       
            DECLARE @_BancoId int = (select BancoId from @EvaluacionSentinel where Id = @i)       
            DECLARE @_ResultadoId int = (select ResultadoId from @EvaluacionSentinel where Id = @i)       
            DECLARE @_Observacion varchar(MAX) = (select Observacion from @EvaluacionSentinel where Id = @i)  
            DECLARE @_Ofertas varchar(MAX) = (select Ofertas from @EvaluacionSentinel where Id = @i) 
            IF (@_ResultadoId <> 0)   
            BEGIN   
                IF (@_BancoId != 13)
                BEGIN     
                  INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, BancoId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId)         
                                      VALUES (@EvaluacionId, @ExpedienteCreditoId, @PersonaId, @_BancoId, @_ResultadoId, @_Observacion, 0, @UserIdCrea, dbo.GETDATE(), @TipoPersonaId)       
                END
            END               
            SET @i  = @i  + 1       
        END                                    
                                                              
        -- Si Involucrado No Califica, finaliza Crédito ----------------------------------------------------------------------------------------------------------                                                   
        IF (@EstadoProcesoId NOT IN (1, 2, 3, 4, 5))                                                   
        BEGIN               
            UPDATE SGF_ExpedienteCredito                                                   
            SET EstadoProcesoId = @EstadoProcesoId,                                                   
                EstadoExpedienteId = 2,                                                   
                FechaActua = dbo.GETDATE(),                                                   
                FechaNoCalifica = dbo.GETDATE(),                                                   
                Observacion = @Observacion,      
                UserIdActua = @UserIdCrea,            
                DispositivoId = @DispositivoId            
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId     
                                                                  
            DECLARE @ItemId int = (SELECT MAX(ItemId) + 1 FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                    
                                   
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)     
                                              VALUES (@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.getdate(), @UserIdCrea, @Observacion)     
        END                                          
    END                                             
                              
    SET @Success = 1;                                                   
    SET @Message = 'OK';                                       
    SET @PersonaIdOutput = @PersonaId;                                   
    SET @ExpedienteCreditoIdOutput = @ExpedienteCreditoId;                                   
                                                       
    COMMIT;                                                   
END TRY                                                     
BEGIN CATCH                                                     
    SET @Success = 0;                                                   
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();                                                   
    ROLLBACK;                                                   
END CATCH