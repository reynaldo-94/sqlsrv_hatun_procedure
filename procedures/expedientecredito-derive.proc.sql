/*--------------------------------------------------------------------------------------                                                    
' Nombre          : [dbo].[SGC_SP_Derive_I]                                                                     
' Objetivo        : Este procedimiento registra correos al derivar                            
' Creado Por      : RICHARD ANGULO                                      
' Día de Creación : 00-06-2021                                                                 
' Requerimiento   : SGC                                                              
' Modificado por  : Reynaldo Cauche                                            
' Día de Modificación : 10-05-2022                                                
'--------------------------------------------------------------------------------------*/                          
ALTER PROCEDURE SGC_SP_Derive_I  
(@IdOficina int,                          
 @AgenciaId int,                     
 @TipoProductoId int,                  
 @ExpedienteCreditoId int,                          
 --@Correo varchar(1000),                     
 @Fecha varchar(30),              
 @Observacion varchar(1000),      
 @UserId int, 
 @BancoId int, 
 @Ubigeo varchar(15), 
 @Success int OUTPUT,                          
 @Message varchar(8000) OUTPUT,
 @NomAgencia varchar(500) OUTPUT)      
AS      
BEGIN      
    DECLARE @ItemId int                        
    DECLARE @CodSolicitud int 
    DECLARE @CodOficina int
    DECLARE @Agencia varchar(500)                        
    BEGIN TRY                          
        BEGIN TRANSACTION                          
                              
        SET @Success = 0;                          
        --SET @ItemId = (SELECT                          
        --  MAX(ItemId)                          
        --FROM SGF_ExpedienteCreditoDetalle                          
        --WHERE ExpedienteCreditoId = @ExpedienteCreditoId);                          
                            
        --recuperar el maximo y sumar 1                                
        set @ItemId = (select ISNULL(MAX(ItemId) + 1, 1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId)                             
                             
        INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                    
        values(@ExpedienteCreditoId, @ItemId, 5, @Fecha, @UserId, @Observacion)           
  
        --recuperar el maximo y sumar 1                                
        set @ItemId = (select ISNULL(MAX(ItemId) + 1, 1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId)                             
                             
        INSERT INTO SGF_ExpedienteCreditoDetalle(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, DiaAgenda, UsuarioId, Observacion)                                    
        values(@ExpedienteCreditoId, @ItemId, 5, @Fecha, @Fecha, @UserId, 'CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL')                          
                               
        --UPDATE SGF_Oficina                          
        --SET CorreoA = @Correo                          
        --WHERE IdOficina = @IdOficina                          
        --AND AgenciaId = @AgenciaId                          
                            
        UPDATE P                          
        SET P.EstadoPersonaId = 5, P.UserIdActua = @UserId      
        FROM SGF_Persona P                          
        LEFT JOIN sgf_expedientecredito ex ON P.PersonaId = ex.titularid                          
        WHERE ex.ExpedienteCreditoId = @ExpedienteCreditoId 
 
        -- Calcular el IdOficina(Agencia) cuando el banco es Surgir 
        IF (@BancoId = 11) 
          BEGIN
            SET @CodOficina = (SELECT IdOficina FROM sgf_oficina_ubigeo WHERE CodUbigeo = @Ubigeo);
            SET @NomAgencia = (SELECT ofc.Nombre FROM sgf_oficina_ubigeo oub INNER JOIN sgf_oficina ofc ON oub.IdOficina = ofc.IdOficina WHERE oub.CodUbigeo = @Ubigeo);
          END
        ELSE 
          BEGIN
            SET @CodOficina = @IdOficina;
            SET @NomAgencia = (SELECT Nombre FROM sgf_oficina where IdOficina = @IdOficina);
          END
   
        UPDATE SGF_ExpedienteCredito                          
        SET EstadoProcesoId = 5, FechaEvaluacion = @Fecha, FechaActua = @Fecha, FechaAgenda = @Fecha,   
		    UserIdActua = @UserId, Observacion = 'CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL', ObsDerivacion = @Observacion, BancoId = @BancoId, IdOficina = @CodOficina 
        WHERE ExpedienteCreditoId = @ExpedienteCreditoId                        
                     
        UPDATE SGF_ExpedienteCreditoDetalle                          
        SET ProcesoId = 5, Fecha = @Fecha                         
        WHERE ExpedienteCreditoId = @ExpedienteCreditoId AND ItemId = @ItemId              
                          
                   
        SET @CodSolicitud = (select SolicitudId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId) 
 
        UPDATE SGF_Solicitud                    
        SET AgenciaId = @AgenciaId, IdOficina = @CodOficina, TipoProductoId = @TipoProductoId, UserIdActua = @UserId, BancoId = @BancoId      
        WHERE SolicitudId = @CodSolicitud    
                                
        SET @Success = 1;                          
        SET @Message = 'OK';        
                              
        COMMIT;             
    END TRY                          
    BEGIN CATCH                          
      SET @Success = 0;                          
      SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS varchar(100)) + ' ERROR: ' + ERROR_MESSAGE()             
      ROLLBACK;                          
    END CATCH      
END