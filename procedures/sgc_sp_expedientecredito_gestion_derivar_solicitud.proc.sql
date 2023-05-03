/*--------------------------------------------------------------------------------------                                                                                                                                      
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud]                                                                                                                                                       
' Objetivo        : ESTE PROCEDIMIENTO VALIDA LOS CAMPOS DE SOLICITUD CUANDO SE QUIERE PASAR A ESTADO GESTION                                                              
' Creado Por      : Reynaldo Cauche                                                                                                                   
' Día de Creación : 22/12/2022                                                                                                                                               
' Requerimiento   : SGC                                                                                                                                                
' Cambios:                        
  22/12/2022 - Reynaldo Cauche - Se creo el procedimiento    
  13/04/2022 - Reynaldo Cauche - Se agrego validacion para los campos apdp y publiApdp 
  17/04/2022 - Reynaldo Cauche - Se removio la validacion de publiApdp
  19/04/2022 - Reynaldo Cauche - Cuando es Ruc que no valide el campo apdp
'--------------------------------------------------------------------------------------*/                                                                                          
                                                                                      
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud                           
@ExpedienteCreditoId int,                      
@Success INT OUTPUT ,                                                      
@Message varchar(max) OUTPUT,  
@ListPersonasId varchar(max) OUTPUT                                                    
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
    declare @apdp bit
    declare @documentoNum varchar(15)
BEGIN TRY                                           
    BEGIN TRANSACTION                                                        
                                                             
        SET @Success = 1;                                                     
        SET @Message = 'OK';   
        SET @ListPersonasId = '';  
   
        SET @status = (select sec.EstadoProcesoId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);   
        SET @titularId = (select sec.TitularId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);   
        SET @personaId = (select sp.TipoPersonaId from SGF_Persona sp WHERE  sp.PersonaId = @titularId);    
        SET @documentoNum = (select isnull(DocumentoNum,'') from sgf_persona WHERE  PersonaId = @titularId)
        SET @estadoCivilId = (select isnull(count(sp.PersonaId),0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId);    
        SET @estadoCivilValue = (select sp.ParametroId from SGF_Parametro sp where sp.DominioId = 8 and sp.ParametroId = @estadoCivilId);   
        SET @valueCasaPropia = (select isnull(sp.CasaPropia,0) from SGF_Persona sp WHERE  sp.PersonaId = @titularId);    
        SET @solicitud = (select ISNULL(sec.SolicitudId,0) from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);   
        set @material = (select isnull(count(isnull(ss.MontoMaterialApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                                
        set @materialpro = (select isnull(count(isnull(ss.MontoMaterialPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                                      
        set @efectivopro = (select isnull(count(isnull(ss.MontoEfectivoPro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)                                                      
        set @efectivo = (select isnull(count(isnull(ss.MontoEfectivoApro ,0)),0) from SGF_Solicitud ss where ss.SolicitudId = @solicitud)
        SET @apdp = (SELECT isnull(APDP,0) from SGF_Persona where PersonaId = @titularId )

        if (len(@documentoNum) = 8 or len(@documentoNum) = 12) and @apdp != 1
            BEGIN                                                      
                SET @Success = 2;                                                      
                SET @Message = 'Falta completar autorización de datos personales'                                                      
            END        
   
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
  
        -- Si paso todo devuelve personasId, datosLaboralesId  
        -- Devuelvo las personasId 
        SET @ListPersonasId = (select STRING_AGG(PersonaId,',')  
                                    from sgf_Evaluaciones  
                                    where ExpedienteCreditoId = @ExpedienteCreditoId); 
   COMMIT;      
END TRY                                              
BEGIN CATCH                                                        
    SET @Success = 0;                              
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()  
    SET @ListPersonasId = '';                                                
    ROLLBACK;                                                        
END CATCH