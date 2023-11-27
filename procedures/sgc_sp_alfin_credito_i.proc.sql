/*--------------------------------------------------------------------------------------                                                                                                            
' Nombre          : [dbo].[SGC_SP_Alfin_Credito_I]                                                                                                                      
' Objetivo        :                                                                        
' Creado Por      :                                                                                           
' Día de Creación :                                                                                                                      
' Requerimiento   : SGC          
' Cambios:                    
  - 19/09/2023 - Reynaldo - Se agrego el campo CreadoAlfinLa
'--------------------------------------------------------------------------------------*/    
  
ALTER PROCEDURE SGC_SP_Alfin_Credito_I     
(@ExpedienteCreditoId int,         
 @BancoId int,         
 @PersonaId int,         
 @OfertaMax varchar(20),         
 @Ofertas text,        
 @ObservacionOfertas varchar(max),        
 @CanalAlfinId int,       
 @Success int OUTPUT,         
 @Message varchar(8000) OUTPUT)         
AS         
DECLARE @ExpedienteCreditoIdNuevo INT         
DECLARE @EvaluacionId INT       
declare @AdvIdNuevo int       
declare @AdvIdExp int       
declare @ZonaId int       
declare @LocalId int       
BEGIN         
    BEGIN TRY                      
        BEGIN TRANSACTION                     
            SET @Success = 0;          
         
            SET @ExpedienteCreditoIdNuevo = (Select MAX(ExpedienteCreditoId) + 1 from SGF_ExpedienteCredito)       
            set @ZonaId = (SELECT ExpedienteCreditoZonaId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
            set @LocalId = (SELECT ExpedienteCreditoLocalId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
            set @AdvIdExp = (SELECT ISNULL(AdvId,0) FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)       
    
           declare @selectAdv int = isnull((SELECT TOP(1)  a.advid                                          
                               FROM sgf_adv_atencion  a                                                  
                               inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                                              
                               inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                                               
                               inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                                              
                               inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1             
                               where rezo.esActivo = 1 and lo.localid= @LocalId                                             
                               ORDER BY a.FechaAsignacion ASC),0);    
    
            SET @advIdNuevo = IIF(@AdvIdExp = 0,(iif(@selectAdv =0, (SELECT TOP(1) a.advid       
                    FROM sgf_adv_atencion  a       
                    inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId       
                    inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId       
                    inner join SGF_Local lo on lo.ZonaId = zo.ZonaId       
                    inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1       
                    where rezo.esActivo = 1 and lo.localid = 13      
                    ORDER BY a.FechaAsignacion ASC),@selectAdv)), @AdvIdExp)                   
         
            -- Buscar Estadoproces         
            -- Consultar Canal de venta si es 2 o otro         
            INSERT INTO SGF_ExpedienteCredito (ExpedienteCreditoId, TitularId, TipoUsuarioRegistroId, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, EstadoProcesoId, EstadoExpedienteId,CanalVentaID, ProveedorId, UserIdCrea, FechaCrea,FechaContacto, FechaProspecto,TipoExpediente, Obra, IdSupervisor, AdvId, BancoId, DispositivoId, CategoriaId, TipoCredito, IsBancarizado, FechaAgenda, FechaActua, Prioridad, Proyecto, TipoBanca, CreadoAlfinLa)           
            SELECT @ExpedienteCreditoIdNuevo, TitularId, 0, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, 3 as EstadoProcesoId,1 as EstadoExpedienteId,2 as CanalVentaID,ProveedorId,1,dbo.getDate(),dbo.GETDATE(),dbo.GETDATE(), 1,Obra, 0, @advIdNuevo, @BancoId, 1, 1, TipoCredito, IsBancarizado,  dbo.GETDATE(), dbo.GETDATE(), 'NORMAL', 0, 2, 1         
            FROM SGF_ExpedienteCredito         
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId          
         
            -- ExpedienteDetalle, revisar campo observacion  campo proceso         
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)         
            VALUES (@ExpedienteCreditoIdNuevo, 1, 1, dbo.GETDATE(), 1, '')         
         
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)         
            VALUES (@ExpedienteCreditoIdNuevo, 2, 2, dbo.GETDATE(), 1, 'Cliente tiene un credito preaprobado con oferta maxima de ' + @OfertaMax)       
         
            INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)         
            VALUES (@ExpedienteCreditoIdNuevo, 3, 3, dbo.GETDATE(), 1, 'Cliente tiene un credito preaprobado con oferta maxima de ' + @OfertaMax)       
         
            -- Evaluaciones         
          SET @EvaluacionId = (Select MAX(EvaluacionId) + 1 from SGF_Evaluaciones)         
            INSERT INTO SGF_Evaluaciones (EvaluacionId, ExpedienteCreditoId, PersonaId, BancoId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId, Ofertas, CanalAlfinId)                                       
            VALUES (@EvaluacionId, @ExpedienteCreditoIdNuevo, @PersonaId, @BancoId, 2, @ObservacionOfertas, 1, 1, dbo.GETDATE(), 1, @Ofertas, @CanalAlfinId)         
       
            UPDATE SGF_ADV_atencion                                                         
            set FechaAsignacion = dbo.GETDATE()                                                         
            where AdvId = IIF(@AdvIdExp != 0,@AdvIdExp,@AdvIdNuevo)       
         
            SET @Success = 1                                   
            SET @Message = 'OK'         
                     
            COMMIT;                     
    END TRY                     
    BEGIN CATCH                     
        SET @Success = 0;                     
         
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();                 
        ROLLBACK;                     
    END CATCH                     
END 