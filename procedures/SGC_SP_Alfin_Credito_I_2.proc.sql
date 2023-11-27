/*--------------------------------------------------------------------------------------                                                                                                                          
' Nombre          : [dbo].[SGC_SP_Alfin_Credito_I]                                                                                                                                    
' Objetivo        :                                                                                      
' Creado Por      :                                                                                                         
' Día de Creación : 02/09/2023                                                                                                                                     
' Requerimiento   : SGC                        
' Cambios:                                  
  - 02/09/2023 - cristian silva - nuevo fue alcansado por Francisco                
'--------------------------------------------------------------------------------------*/                  
                
ALTER PROCEDURE SGC_SP_Alfin_Credito_I_2                   
(@cXML nvarchar(max) = '',                     
 @Success int OUTPUT,                       
 @Message varchar(8000) OUTPUT)                       
AS                       
          
DECLARE @Insertar varchar(100),          
  @nId INT;          
          
BEGIN TRAN @Insertar          
          
DECLARE @tblExpedientes TABLE (          
    idx smallint Primary Key IDENTITY(1,1),          
    expedienteCreditoId int ,          
    bancoId int,          
    personaId int,          
    ofertaMax varchar(20),          
    ofertas text,          
    observacionOfertas varchar(max),          
    canalAlfinId int          
)          
          
EXEC sp_xml_preparedocumenT @nId OUTPUT, @cXML;          
          
insert into @tblExpedientes          
select          
    expedienteCreditoId,          
    bancoId,          
    personaId,          
    ofertaMax,          
    ofertas,          
    observacionOfertas,          
    canalAlfinId          
from openxml(@nId, 'registros/rows', 2)          
with          
(expedienteCreditoId int,          
  bancoId int,          
  personaId int,          
  ofertaMax varchar(20),          
  ofertas text,          
  observacionOfertas varchar(max),          
  canalAlfinId int          
 )          
          
DECLARE @i int = 1;            
DECLARE @ExpedienteCreditoIdNuevo INT,          
    @EvaluacionId INT,          
    @AdvIdNuevo INT,                     
    @AdvIdExp INT,                  
    @ZonaId INT,          
    @LocalId INT,  
    @HorarioExp VARCHAR(50);  
          
DECLARE @ExpedienteCreditoId int,                       
 @BancoId int,                       
 @PersonaId int,                       
 @OfertaMax varchar(20),                       
 @Ofertas varchar(max),                      
 @ObservacionOfertas varchar(max),                      
 @CanalAlfinId int;           
                  
WHILE @i <= (select MAX(idx) from @tblExpedientes)          
BEGIN          
           
              
    SET @ExpedienteCreditoId = (SELECT ExpedienteCreditoId FROM @tblExpedientes WHERE idx = @i)          
    SET @BancoId = (SELECT BancoId FROM @tblExpedientes WHERE idx = @i)          
    SET @PersonaId = (SELECT PersonaId FROM @tblExpedientes WHERE idx = @i)          
    SET @OfertaMax = (SELECT OfertaMax FROM @tblExpedientes WHERE idx = @i)          
    SET @Ofertas = (SELECT Ofertas FROM @tblExpedientes WHERE idx = @i)          
    SET @ObservacionOfertas = (SELECT ObservacionOfertas FROM @tblExpedientes WHERE idx = @i)          
    SET @CanalAlfinId = (SELECT CanalAlfinId FROM @tblExpedientes WHERE idx = @i)          
          
    SET @ExpedienteCreditoIdNuevo = (Select MAX(ExpedienteCreditoId) + 1 from SGF_ExpedienteCredito)          
    set @ZonaId = (SELECT ExpedienteCreditoZonaId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)                     
    set @LocalId = (SELECT ExpedienteCreditoLocalId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)                     
    set @AdvIdExp = (SELECT ISNULL(AdvId,0) FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)          
    set @HorarioExp = (SELECT IIF(ISNULL(Horario,'') = '', '0', Horario) FROM SGF_Persona where PersonaId = @PersonaId)          
          
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
           
 INSERT INTO SGF_ExpedienteCredito (ExpedienteCreditoId, TitularId, TipoUsuarioRegistroId, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, EstadoProcesoId, EstadoExpedienteId,CanalVentaID, ProveedorId, UserIdCrea, FechaCrea,FechaContacto, FechaProspecto,TipoExpediente, Obra, IdSupervisor, AdvId, BancoId, DispositivoId, CategoriaId, TipoCredito, IsBancarizado, FechaAgenda, FechaActua, Prioridad, Proyecto, TipoBanca, CreadoAlfinLa, Observacion)                         
    SELECT @ExpedienteCreditoIdNuevo, TitularId, 0, ExpedienteCreditoZonaId, ExpedienteCreditoLocalId, 3 as EstadoProcesoId,1 as EstadoExpedienteId,2 as CanalVentaID,ProveedorId,1,dbo.getDate(),dbo.GETDATE(),dbo.GETDATE(), 1,Obra, 0, @advIdNuevo, @BancoId, 1, 1, TipoCredito, IsBancarizado,  dbo.GETDATE(), dbo.GETDATE(), 'NORMAL', 0, 2, 1, 'FILTRADO POR PROCESO AUTOMATICO'                       
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
  
    UPDATE SGF_Persona  
    SET Horario = @HorarioExp  
    WHERE PersonaId = @PersonaId            
          
    SET @i = @i + 1          
           
END;          
          
EXEC sp_xml_removedocument @nId;          
          
SET @Message = 'Se realizo el proceso con éxito.'           
          
IF @@Error != 0          
BEGIN          
    ROLLBACK TRAN @Insertar          
    SET @Message = 'Se produjo un error durante el procedimiento.'          
    RETURN -1;          
    END          
          
COMMIT TRAN @Insertar;