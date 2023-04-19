/*--------------------------------------------------------------------------------------                                                                                                            
' Nombre          : [dbo].[[SGC_SP_ExpedienteCredito_Por_Id]]                                                                                                                             
' Objetivo        : ESTE PROCEDIMIENTO APRUEBA EL CREDITO                                                                          
' Creado Por      :                                                                                           
' Día de Creación :                                                                                                                      
' Requerimiento   : SGC                                                                                                               
' Cambios:           
'--------------------------------------------------------------------------------------*/                    
              
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_I_Aprobation]                        
@ExpedienteCreditoId int,                        
@SolicitudId INT,                        
@FechaAprobacion varchar(10),                        
@FechaVencimiento varchar(10),                        
@NCuotas int,                        
@NPagos int,                         
@MontoEfectivo varchar(20),                        
@MontoMaterial varchar(20),                   
@MontoCuotas varchar(20),                        
@UserIdActua INT,--                        
@Observacion varchar(300),--              
@BancoId INT,              
@Success INT OUTPUT ,                        
@Message varchar(8000) OUTPUT                        
as                        
		declare @ExpCreditoDetalleId INT                        
		declare @PersonaId int                        
		declare @TitularId int                        
		declare @MovimientoId int                         
		declare @MontoMaterialApro decimal(15,2)                         
		declare @MontoMovCtaCte decimal(15,2)                         
		declare @ItemId int                         
		declare @ProcesoId int                         
		declare @Referencia varchar(90)            
		declare @BancoIdAc int            
 BEGIN TRY                          
  BEGIN TRANSACTION                          
                           
	SET @Success = 0;                        
	SET @ExpCreditoDetalleId = (SELECT ISNULL(MAX(Itemid),0)+1 FROM SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId)                        
	SET @PersonaId = (select TitularId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)                        
	set @TitularId = (select TitularId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)                            
	set @MovimientoId = (select MovimientoId from SGF_Movimientos_Cta_Cte where Mov_enabled = 1 and ExpedienteCreditoId = @ExpedienteCreditoId and TitularId = @TitularId)                            
	set @MontoMaterialApro = (select MontoMaterialApro from SGF_Solicitud where SolicitudId = (select top 1 SolicitudId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId order by ExpedienteCreditoId desc))  
	set @MontoMovCtaCte = (select Monto from SGF_Movimientos_Cta_Cte where MovimientoId = @MovimientoId)                            
	set @ItemId = (select MAX(ItemId) + 1 from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId)                                  
	set @ProcesoId = (select EstadoProcesoId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)    
	set @Referencia = (select DocumentoNum + ' - ' + Nombre + ' ' + ApePaterno + ' ' + ApeMaterno from SGF_Persona where PersonaId = @TitularId)              
	set @BancoIdAc = (select bancoId from SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)             
                           
	UPDATE SGF_Solicitud              
		SET MontoAprobado = CAST(@MontoEfectivo AS FLOAT) + CAST(@MontoMaterial AS FLOAT),                        
		CuotaNumero= @NCuotas,    
		CuotaMonto = CAST(@MontoCuotas AS FLOAT),                        
		FechaAprobacion = CAST(@FechaAprobacion AS DATE),    
		FechaVenciPriCuota = CAST(@FechaVencimiento AS DATE),                        
		UserIdActua = @UserIdActua,    
		FechaActua = dbo.getdate(),    
		EstadoSolicitudId  = 2,                        
		MontoMaterialApro = CAST(@MontoMaterial AS FLOAT),    
		MontoEfectivoApro =CAST(@MontoEfectivo AS FLOAT),                
		FrecuenciaPagoId = @NPagos,              
		bancoId = @BancoIdAc              
	WHERE SolicitudId = @SolicitudId;                        
                           
	IF CAST(@MontoMaterial AS FLOAT) != 0                        
	BEGIN                        
		UPDATE SGF_ExpedienteCredito                         
			SET UserIdActua = @UserIdActua,    
			EstadoProcesoId = 6,                   
			FechaActua = dbo.getdate(),    
			FechaCarta = dbo.getdate(),                        
			Observacion = UPPER(@Observacion),    
			Maestro = 0,                        
			FechaAgenda = dbo.getdate() 
		WHERE ExpedienteCreditoId=@ExpedienteCreditoId;                        
                          
		INSERT INTO SGF_ExpedienteCreditoDetalle                        
		(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                        
		values                        
		(@ExpedienteCreditoId,@ExpCreditoDetalleId,6,dbo.getdate(),@UserIdActua,UPPER(@Observacion));                        
                             
		UPDATE SGF_Persona                        
			set EstadoPersonaId = 6,                        
			UserIdActua = @UserIdActua,                        
			FechaActua = dbo.getdate()                        
		WHERE PersonaId = @PersonaId;                        
	END                        
                            
	IF CAST(@MontoMaterial AS FLOAT) = 0                        
	BEGIN                        
		UPDATE SGF_ExpedienteCredito                         
			SET UserIdActua = @UserIdActua,    
			EstadoProcesoId = 8,                        
			FechaActua = dbo.getdate(),     
			FechaCarta = dbo.getdate(),                        
			Observacion = UPPER(@Observacion),     
			Maestro = 0,                        
			EstadoExpedienteId = 2,     
			FechaActivado = dbo.getdate()                               
		WHERE ExpedienteCreditoId=@ExpedienteCreditoId;                     
                          
		INSERT INTO SGF_ExpedienteCreditoDetalle                        
		(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                        
		values                        
		(@ExpedienteCreditoId,@ExpCreditoDetalleId,8,dbo.getdate(),@UserIdActua,UPPER(@Observacion));                        
                             
		UPDATE SGF_Persona                        
			set EstadoPersonaId = 8,                        
			UserIdActua = @UserIdActua,                        
			FechaActua = dbo.getdate()                        
		WHERE PersonaId = @PersonaId;  		  
	END                        
                           
                           
    IF @MontoMaterialApro = @MontoMovCtaCte                            
    BEGIN                            
                               
		UPDATE [dbo].[SGF_Movimientos_Cta_Cte]                            
			SET ExpedienteCreditoId=@ExpedienteCreditoId,                            
				Fecha_Conciliacion = dbo.getdate(),                            
				EstadoMovimientoId = 3,                            
				EstadoLiquidadoId = 1,                                     
				Referencia = @Referencia                          
		WHERE MovimientoId = @MovimientoId                          
                            
		insert into SGF_ExpedienteCreditoDetalle     
		(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)      
		values      
		(@ExpedienteCreditoId, @ItemId, @ProcesoId, dbo.getdate(), @UserIdActua, UPPER('Nuevo Movimiento Cta Cte conciliado.'))                       
    END                        
                           
	SET @Success = 1;                        
	SET @Message = 'OK'                        
                             
  COMMIT;                          
 END TRY                          
 BEGIN CATCH                          
  SET @Success = 0;                          
  SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()                        
  ROLLBACK;                          
 END CATCH 