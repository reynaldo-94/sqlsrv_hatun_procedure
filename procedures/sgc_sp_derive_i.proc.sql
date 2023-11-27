/*--------------------------------------------------------------------------------------                                                                                  
' Nombre          : [dbo].[SGC_SP_Derive_I]                                                                                                   
' Objetivo        : Este procedimiento registra correos al derivar                                                          
' Creado Por      : RICHARD ANGULO                                                                    
' Día de Creación : 00-06-2021                                                                                               
' Requerimiento   : SGC                                                                                            
' Modificado por  : Reynaldo Cauche                                                                          
'Cambios: 06-09-2022 - cristian silva -  EN Calcular el IdOficina(Agencia) cuando el banco es Surgir   linea 63 borre buscar por ubigeo                            
-   29-09-2022 - cristian silva - idoficina             
-   27-07-2023 - Reynaldo Cauche - Se agrego al insert SGF_Solicitud el campo cuotaNumeroPro, cuotaMontoPro     
-   develop-Alfin - 11-08-2023 - cristian silva - se valido @validOficinaId   
-  develop-rediseño - 11-15-2023 -cristian - se add @CodUbigeo  
'--------------------------------------------------------------------------------------*/                                                        
CREATE PROCEDURE SGC_SP_Derive_I      
(@CodTopaz int,      
 @ExpedienteCreditoId int,      
 @Observacion varchar(1000),      
 @UserId int,      
 @BancoId int,      
 @Monto float,      
 @Cuota float,      
 @Plazo int,      
 @Tasa float,      
 @TipoBanca int,  
 @CodUbigeo varchar(8)='',  
 @Success int OUTPUT,      
 @Message varchar(8000) OUTPUT,      
 @NomAgencia varchar(500) OUTPUT)                                    
AS                                    
BEGIN  
 DECLARE @CurrentLocal int  
 DECLARE @CurrentLocalExistent int  
 DECLARE @CurrentZonaExistent int  
 DECLARE @CurrentUbigeo varchar(8)  
    DECLARE @ItemId int                                                      
    DECLARE @CodSolicitud int                               
    DECLARE @CodOficina int                              
    DECLARE @Agencia varchar(500)                  
    DECLARE @validOficinaId int = IIF(@CodTopaz = 0, 0, (SELECT top 1 IdOficina FROM SGF_Oficina WHERE CodTopaz = @CodTopaz and BancoId = @BancoId))      
   
 set @CurrentUbigeo = iif(@CodUbigeo != '',@CodUbigeo,(select top 1 isnull(di.Ubigeo,0) from SGF_ExpedienteCredito ex inner join SGF_DatosDireccion di on di.PersonaId = ex.TitularId and di.EsFijo = 1   
              where ex.ExpedienteCreditoId = @ExpedienteCreditoId))   
 set @CurrentLocal = iif(@CurrentUbigeo !=0,(select top 1 isnull(LocalId,0) from SGF_UBIGEO where CodUbigeo =@CurrentUbigeo), 13 )   
 set @CurrentLocalExistent = iif(@CurrentLocal = 0,13,@CurrentLocal)  
 set @CurrentZonaExistent =(select top 1 ZonaId from SGF_Local  where LocalId = @CurrentLocalExistent)  
  
  
  
            
    BEGIN TRY                                                        
        BEGIN TRANSACTION                                                        
                                                            
        SET @Success = 0;                                                       
                                                          
        IF(@TipoBanca != 1)                      
        BEGIN                    
            --recuperar el maximo y sumar 1                                                              
            SET @ItemId = (SELECT ISNULL(MAX(ItemId) + 1, 1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                   
            INSERT INTO SGF_ExpedienteCreditoDetalle  
               (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)         
            VALUES   
               (@ExpedienteCreditoId, @ItemId, 5, dbo.getdate(), @UserId, @Observacion)                                         
                                    
            --recuperar el maximo y sumar 1                                                              
            SET @ItemId = (SELECT ISNULL(MAX(ItemId) + 1, 1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                     
            INSERT INTO SGF_ExpedienteCreditoDetalle  
               (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, DiaAgenda, UsuarioId, Observacion)                 
            VALUES   
               (@ExpedienteCreditoId, @ItemId, 5, dbo.getdate(), dbo.getdate(), @UserId, 'CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL')                                                                      
                                                              
            UPDATE P                                                  
               SET P.EstadoPersonaId = 5,      
               P.UserIdActua = @UserId,  
      P.LocalId = @CurrentLocalExistent,  
      P.ZonaId = @CurrentZonaExistent  
            FROM SGF_Persona P                                                        
               LEFT JOIN sgf_expedientecredito ex ON P.PersonaId = ex.titularid                              
            WHERE ex.ExpedienteCreditoId = @ExpedienteCreditoId                             
                                                    
            UPDATE SGF_ExpedienteCredito                                                        
            SET EstadoProcesoId = 5,      
                FechaEvaluacion = dbo.getdate(),      
                FechaActua = dbo.getdate(),      
                FechaAgenda = dbo.getdate(),      
                UserIdActua = @UserId,      
                Observacion = 'CLIENTE FUE DERIVADO POR SISTEMA HATUNSOL',      
                ObsDerivacion = @Observacion,      
                BancoId = @BancoId,      
                IdOficina = @validOficinaId,      
                TipoBanca = @TipoBanca,  
    ExpedienteCreditoLocalId = @CurrentLocalExistent,  
    ExpedienteCreditoZonaId = @CurrentZonaExistent  
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId      
                                                            
            UPDATE SGF_ExpedienteCreditoDetalle                                                        
            SET ProcesoId = 5,      
                Fecha = dbo.getdate()      
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId AND       
            ItemId = @ItemId                                            
                                                               
                                                        
            SET @CodSolicitud = (SELECT top 1 ISNULL(SolicitudId, 0) FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                 
                   
            IF (@CodSolicitud != 0)                
            BEGIN                 
                UPDATE SGF_Solicitud                                                  
                SET IdOficina = @validOficinaId,      
                    UserIdActua = @UserId,      
                    BancoId = @BancoId                                    
                WHERE SolicitudId = @CodSolicitud                           
                                              
                IF (@Monto != '' and @Cuota != '' and @Plazo != '')                        
                BEGIN                                        
                    update SGF_Solicitud                        
                    SET MontoPropuesto = @Monto,      
                        MontoEfectivoPro = @Monto,      
                        CuotaMonto = @Cuota,      
                        CuotaNumero = @Plazo,      
                        CuotaMontoPro = @Cuota,      
                        CuotaNumeroPro = @Plazo,      
                        TasaPro = @Tasa      
                   WHERE SolicitudId = @CodSolicitud                          
                END                 
            END                
            ELSE            
            BEGIN                 
                DECLARE @solicitudItem int = (SELECT max(SolicitudId)+1 FROM SGF_Solicitud);                
                DECLARE @personaIdItem int = (SELECT top 1 TitularId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                
                             
                INSERT INTO SGF_Solicitud (SolicitudId,                
                                           PersonaId,            
                                           FechaSolicitud,            
                                           MonedaId,         
                                           EstadoSolicitudId,      
                                           MontoPropuesto,        
                                           MontoEfectivoPro,         
                                           FrecuenciaPagoId,           
                                           CuotaMontoPro,           
                                           CuotaNumeroPro,         
                                           TasaPro,             
                                           IdOficina,           
                                           UserIdCrea,          
                                           BancoId,          
                                           FechaCrea)                
                                   VALUES (@solicitudItem,               
                                           @personaIdItem,           
                                           dbo.getdate(),      
                                           1,      
                                           1,      
                                           @Monto,      
                                           @Monto,      
                                           3,      
                                           @Cuota,      
                                           @Plazo,      
                                           @Tasa,      
                                           @validOficinaId,      
                                           @UserId,      
                                           @BancoId,      
                                           dbo.getdate())                
                                
                UPDATE SGF_ExpedienteCredito                                                        
                SET SolicitudId = @solicitudItem                
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId                  
            END                     
            SET @Success = 1;                                              
            SET @Message = 'Se derivó a la agencia correctamente';                                
        END                       
        ELSE                     
        BEGIN                      
            DECLARE @titularId int                      
            DECLARE @advIdrol int;                      
            DECLARE @RolId int;                      
                                  
            SET @titularId = (SELECT sec.TitularId FROM SGF_ExpedienteCredito sec WHERE sec.ExpedienteCreditoId = @ExpedienteCreditoId);                       
            SET @advIdrol = ISNULL((SELECT  AdvId FROM SGF_ExpedienteCredito WHERE expedienteCreditoId = @ExpedienteCreditoId), 0);                      
            SET @RolId = (SELECT top 1 CargoId FROM SGF_USER WHERE UserId = @UserId)                      
                                  
            IF (@advIdrol > 0 and @RolId = 4)--adv                                                         
            BEGIN                                                         
                UPDATE SGF_ExpedienteCredito                                                                                    
                SET EstadoProcesoId = 3,      
       FechaAgenda = dbo.GETDATE(),      
                    FechaGestion = dbo.GETDATE(),      
                    FechaActua = dbo.GETDATE(),      
                    UserIdActua = @UserId,      
                    Observacion = @Observacion,      
                    BancoId = @BancoId,      
                    IdOficina = @validOficinaId,      
                    TipoBanca = @TipoBanca,  
     ExpedienteCreditoLocalId = @CurrentLocalExistent,  
        ExpedienteCreditoZonaId = @CurrentZonaExistent  
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId;                                
                                                
                UPDATE SGF_Persona                                      
                SET EstadoPersonaId = 3,      
                    FechaActua = dbo.GETDATE(),      
                    UserIdActua = @UserId,  
                    LocalId = @CurrentLocalExistent,  
                    ZonaId = @CurrentZonaExistent  
                WHERE PersonaId = @titularId;                                
                                        
                SET @ItemId = (SELECT ISNULL(MAX(ItemId) + 1, 1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                    
                INSERT INTO SGF_ExpedienteCreditoDetalle   
                   (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, DiaAgenda, UsuarioId, Observacion)                       
                VALUES   
                   (@ExpedienteCreditoId, @ItemId, 3, dbo.GETDATE(), cast(dbo.GETDATE() as date), @UserId, 'SE ENVIO A GESTIÓN DESDE PROSPECTO')                                
                                                
                UPDATE SGF_ADV_atencion                                                             
                   SET FechaAsignacion = dbo.GETDATE()    
                WHERE AdvId = @advIdrol;                                
            END                        
                                      
            IF(@RolId = 11 or @RolId = 56)--call center, Supervisor Call Center                                                     
            BEGIN                                      
                DECLARE @advIdcall int                                      
                SET @advIdcall = (SELECT TOP(1) a.advid                                                  
                                  FROM sgf_adv_atencion  a                                                      
                                  inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                                                  
                                  inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                                                   
                                  inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                                                  
                                  inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                 
                                  WHERE rezo.esActivo = 1 and zo.zonaid = 6 and lo.localid = 13                                                            
                                  ORDER BY a.FechaAsignacion ASC)                                 
                                                
                UPDATE SGF_ExpedienteCredito                                                                                    
                SET EstadoProcesoId = 3,      
                    FechaAgenda = dbo.GETDATE(),      
                    FechaGestion = dbo.GETDATE(),      
                    FechaActua = dbo.GETDATE(),      
                    UserIdActua = @UserId,      
                    AdvId = @advIdcall,      
                    Observacion = @Observacion,      
                    BancoId = @BancoId,      
                    IdOficina = @validOficinaId,      
                    TipoBanca = @TipoBanca,  
     ExpedienteCreditoLocalId = @CurrentLocalExistent,  
        ExpedienteCreditoZonaId = @CurrentZonaExistent                      
                WHERE ExpedienteCreditoId = @ExpedienteCreditoId;                                
                                                
                UPDATE SGF_Persona                                                                                    
                SET EstadoPersonaId = 3,      
                    FechaActua = dbo.GETDATE(),      
                    UserIdActua = @UserId,  
                    LocalId = @CurrentLocalExistent,  
                    ZonaId = @CurrentZonaExistent                                
                WHERE PersonaId = @titularId;                                
                                                
                SET @ItemId = (SELECT ISNULL(MAX(ItemId) + 1, 1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                    
                INSERT INTO SGF_ExpedienteCreditoDetalle  
                   (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, DiaAgenda, UsuarioId, Observacion)                     
                VALUES  
                   (@ExpedienteCreditoId, @ItemId, 3, dbo.GETDATE(), cast(dbo.GETDATE() as date), @UserId, 'SE ENVIO A GESTIÓN DESDE PROSPECTO')                                  
                                                
                UPDATE SGF_ADV_atencion                                                             
                   SET FechaAsignacion = dbo.GETDATE()                                                             
                WHERE AdvId = @advIdcall;                                
            END                            
                                            
            SET @ItemId = (SELECT ISNULL(MAX(ItemId) + 1, 1) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)                                         
            INSERT INTO SGF_ExpedienteCreditoDetalle   
               (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                                                  
            VALUES  
               (@ExpedienteCreditoId, @ItemId, 3, dbo.getdate(), @UserId, @Observacion)                                         
                                                                          
            UPDATE P                                                        
               SET P.EstadoPersonaId = 3,      
               P.UserIdActua = @UserId,  
      P.LocalId = @CurrentLocalExistent,  
      P.ZonaId = @CurrentZonaExistent  
            FROM SGF_Persona P                                        
               LEFT JOIN sgf_expedientecredito ex ON P.PersonaId = ex.titularid                            
            WHERE ex.ExpedienteCreditoId = @ExpedienteCreditoId                             
                        
            UPDATE SGF_ExpedienteCreditoDetalle                    
            SET ProcesoId = 3,       
                Fecha = dbo.getdate()                                                       
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId AND ItemId = @ItemId                               
                           
            SET @Success = 1;                                                        
            SET @Message = 'Se envió a Gestion Correctamente';                            
        END                                                                         
        COMMIT;                                           
    END TRY                                                        
    BEGIN CATCH                                                        
        SET @Success = 0;                                                        
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS varchar(100)) + ' ERROR: ' + ERROR_MESSAGE()                                           
        ROLLBACK;                                                        
    END CATCH                          
END