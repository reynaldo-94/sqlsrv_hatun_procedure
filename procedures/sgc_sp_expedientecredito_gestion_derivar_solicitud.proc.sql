/*--------------------------------------------------------------------------------------                                                                                                                                   
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud]                                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO VALIDA LOS CAMPOS DE SOLICITUD CUANDO SE QUIERE PASAR A ESTADO GESTION                                                           
' Creado Por      : Reynaldo Cauche                                                                                                                
' Día de Creación : 22/12/2022                                                                                                                                            
' Requerimiento   : SGC                                                                                                                                             
' Cambios:                     
  22/12/2022 - Reynaldo Cauche - Se creo el procedimiento  
'--------------------------------------------------------------------------------------*/                                                                                       
                                                                                   
CREATE PROCEDURE SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud                        
@ExpedienteCreditoId int,                   
@Success INT OUTPUT ,                                                   
@Message varchar(max) OUTPUT                                                   
as 
    declare @status int
    declare @titularId int
    declare @personaId int
    declare @estadoCivilId int  
    declare @estadoCivilValue int
    declare @valueCasaPropia int
    declare @solicitud int 
    declare @material int                                                   
    declare @materialpro int                                                   
    declare @efectivopro int                               
    declare @efectivo int 
BEGIN TRY                                        
    BEGIN TRANSACTION                                                     
                                                          
        SET @Success = 1;                                                  
        SET @Message = 'OK';

        SET @status = (select sec.EstadoProcesoId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);
        SET @titularId = (select sec.TitularId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);
        SET @personaId = (select sp.TipoPersonaId from SGF_Persona sp WHERE  sp.PersonaId = @titularId); 
        SET @estadoCivilId = (select isnull(count(sp.PersonaId),0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId); 
        SET @estadoCivilValue = (select sp.ParametroId from SGF_Parametro sp where sp.DominioId = 8 and sp.ParametroId = @estadoCivilId);
        SET @valueCasaPropia = (select isnull(sp.CasaPropia,0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId); 
        SET @solicitud = (select ISNULL(sec.SolicitudId,0) from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);
        set @material = (select isnull(count(isnull(ss.MontoMaterialApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                             
        set @materialpro = (select isnull(count(isnull(ss.MontoMaterialPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                                   
        set @efectivopro = (select isnull(count(isnull(ss.MontoEfectivoPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                                   
        set @efectivo = (select isnull(count(isnull(ss.MontoEfectivoApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)

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
                        SET @Message = ''+'-Debe agregar monto material aprobado.'                                                   
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
                        IF @valueCasaPropia = 0                                                 
                            BEGIN                                                   
                                SET @Success = 2;                                                   
                                SET @Message = ''+'-Debe Seleccionar Casa Propia o Sin Casa'                                                         
                            END                                                   
                    END                                                   
            END                  
   COMMIT;   
END TRY                                           
BEGIN CATCH                                                     
    SET @Success = 0;                           
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()                                                   
    ROLLBACK;                                                     
END CATCH