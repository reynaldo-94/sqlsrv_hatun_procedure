/*--------------------------------------------------------------------------------------                                                                                                                                   
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Gestion_Derivar_DatosLaborales]                                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO VALIDA LOS CAMPOS DE DATOS LABORALES CUANDO SE QUIERE PASAR A ESTADO GESTION                                                            
' Creado Por      : Reynaldo Cauche                                                                                                                
' Día de Creación : 22/12/2022                                                                                                                                            
' Requerimiento   : SGC                                                                                                                                             
' Cambios:                     
  22/12/2022 - Reynaldo Cauche - Se creo el procedimiento  
'--------------------------------------------------------------------------------------*/                                                                                       
                                                                                   
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Gestion_Derivar_DatosLaborales                        
@DatosLaboralesId int,
@PersonaId int,                     
@Success INT OUTPUT ,                                                   
@Message varchar(max) OUTPUT                                                   
as 
    declare @documentoNum varchar(12)
    declare @tipotrabajoid int     
    declare @sustentoingreso int 
    declare @ingreso int                                                   
    declare @ruc int                                                   
    declare @gironegocio int
    declare @cargo int                                                   
    declare @fecha int                                                   
    declare @centrotrabajo int                                                  
    declare @establecimiento int         
    declare @tipoformalidad int
    declare @ubigeo int  
    declare @direccion int                        
    declare @referencia int   
    declare @tipodireccion int   
    declare @antiguedadLaboral varchar(20)
    declare @diasPago int    
BEGIN TRY                                        
    BEGIN TRANSACTION                                                     
                                                          
        SET @Success = 1;                                                  
        SET @Message = 'OK';

        SET @documentoNum = (select DocumentoNum from SGF_Persona where PersonaId = @PersonaId);

        set @tipotrabajoid = (select TipoTrabajoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)
        set @sustentoingreso = (select SustentoIngresoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                               
        set @ingreso = (select IngresoNeto from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                  
        set @ruc = (select isnull(count(ISNULL(Ruc,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                  
        set @gironegocio = (select GiroId  from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                                   
        set @cargo = (select isnull(count(ISNULL(Cargo,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                                   
        set @fecha = (select isnull(count(ISNULL(FechaIngresoLaboral,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                                   
        set @centrotrabajo = (select isnull(count(ISNULL(CentroTrabajo,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)                                                   
        set @establecimiento = (select isnull(count(ISNULL(TipoEstablecimiento,0)),0) from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)
        set @tipoformalidad = (select FormalidadTrabajoId from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)
        set @ubigeo = (select isnull(count(ISNULL(sdd.Ubigeo,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @PersonaId)                                                   
        set @direccion = (select isnull(count(ISNULL(sdd.Direccion,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @PersonaId)                                                   
        set @referencia = (select isnull(count(ISNULL(sdd.Referencia,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @PersonaId)
        set @tipodireccion = (select isnull(count(ISNULL(sdd.TipoDireccionId,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = @PersonaId)
        set @antiguedadLaboral = (select antiguedadLaboral from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)
        set @diasPago = (select diasPago from SGF_DatosLaborales where DatosLaboralesId = @DatosLaboralesId)

         IF @DatosLaboralesId = 0                                               
            BEGIN                                              
               SET @Success = 2;                                                   
               SET @Message = ''+'-Debe agregar tipo de trabajo.                                                   
                '                                                 
            END

        IF @tipotrabajoid = 0                                            
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
                        SET @Message = ''+'-Debe agregar giro de negocio.'                                                   
                    END                                 
                IF @ingreso = 0                                                   
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar ventas brutas.'                                                   
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
                        SET @Message = ''+'-Debe agregar giro de negocio.'                               
                    END                                 
                IF @sustentoingreso = 0                                                   
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar sustento de ingreso.'                                                   
                    END                                  
                IF @ingreso = 0                                                   
                    BEGIN                                       
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar salario bruto.'                                                   
                    END                                 
                IF @antiguedadLaboral = ''                                                   
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar antiguedad laboral.'                              
                    END                                 
                IF @diasPago = 0                                                   
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar días de pago.'                                                   
                    END                                 
            END

        -- TIPO TRABAJO DEPENDIENTE - INFORMAL - DIFERENTE A RUC                             
        IF (@tipotrabajoid = 2 and @tipoformalidad = 2 and len(@documentoNum) != 11)                                 
            BEGIN                                 
             IF @gironegocio = 0                                                   
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar giro de negocio.'                                                   
                    END                                 
                IF @ingreso = 0                                                   
                    BEGIN                    
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar salario bruto.'                                                   
                    END                                 
                IF @antiguedadLaboral = ''                                                   
                    BEGIN                                          
                        SET @Success = 2;                                 
                        SET @Message = ''+'-Debe agregar antiguedad laboral.'                                                   
                    END                                 
                IF @diasPago = 0                                     
                    BEGIN                                                   
                        SET @Success = 2;                                                   
                        SET @Message = ''+'-Debe agregar días de pago.'                                                   
                    END                                 
            END                        
   COMMIT;   
END TRY                                           
BEGIN CATCH                                                     
    SET @Success = 0;                           
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()                                                   
    ROLLBACK;                                                     
END CATCH