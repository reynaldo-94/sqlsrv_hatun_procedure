/*--------------------------------------------------------------------------------------                                                         
' Nombre          : [dbo].[SGC_SP_CABMIAR_ESTADO_CREDITO]                                                                          
' Objetivo        : Este procedimiento cambia el estado de los creditos y agrega en la tabla detalle                
' Creado Por      : REYNALDO CAUCHE                                           
' Día de Creación : 03-02-2022                                                                      
' Requerimiento   : SGC                                                                   
' Modificado por  : Reynaldo Cauche                                                  
' Día de Modificación : 05-02-2022           
cambios 
- 19/09/2022 - cristian silva - se agrego @EstadoNumId, @EstadoVeri, @FechaPros, @FechaEva, es para verificar las fechas y el estadoExpedienteId para ver si ya tienen otra operacion en proceso 
'--------------------------------------------------------------------------------------*/             
CREATE PROCEDURE SGC_SP_CABMIAR_ESTADO_CREDITO 
(@ExpedienteCreditoId int,         
 @EstadoProcesoId int,         
 @Observacion varchar(8000),         
 @UserIdCrea int,         
 @Success int OUTPUT,         
 @Message varchar(8000) OUTPUT   
 --@MessageEstado varchar(8000) OUTPUT   
 )         
AS         
BEGIN         
 DECLARE @ItemId int     
 DECLARE @NomEstado varchar(100)     
 DECLARE @EstadoNumId int  
 DECLARE @EstadoVeri int 
 DECLARE @FechaPros int  
 DECLARE @FechaEva int 
    
	SET @EstadoVeri = (select top 1 EstadoExpedienteId from SGF_ExpedienteCredito   
					   where TitularId =(select top 1 a.TitularId from SGF_ExpedienteCredito as a  
										 where a.ExpedienteCreditoId = @ExpedienteCreditoId) 
										 order by FechaActua desc);   
	SET @EstadoNumId = (select top 1 EstadoProcesoId from SGF_ExpedienteCredito   
					   where TitularId =(select top 1 a.TitularId from SGF_ExpedienteCredito as a  
										 where a.ExpedienteCreditoId = @ExpedienteCreditoId) 
										 order by FechaActua desc);  
	SET @NomEstado = ISNULL((select UPPER(NombreLargo) from SGF_Parametro  
							 where DominioId = 38  
							 and ParametroId = iif(@EstadoNumId=8 or @EstadoNumId=9 or @EstadoNumId=10 or @EstadoNumId=11 or @EstadoNumId=12 ,@EstadoProcesoId,@EstadoNumId)) 
					 , '');    
	SET @ItemId = (select ISNULL(MAX(ItemId) + 1,1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId);    
	SET @FechaPros = (select len(convert(varchar(11),fechaActua,23)) from SGF_ExpedienteCredito    
					where ExpedienteCreditoId = @ExpedienteCreditoId    
					and  convert(date,dateadd(month,-1, dbo.getdate()),23) <=convert(date,fechaActua)    
					and convert(date, dbo.getdate(), 23) >=convert(date,fechaActua)   
					);   
	set @FechaEva = (select len(convert(varchar(11),fechaActua,23)) from SGF_ExpedienteCredito  
					 where ExpedienteCreditoId = @ExpedienteCreditoId  
					 and convert(date,dateadd(month,-3, dbo.getdate()),23) <=convert(date,fechaActua) 
					 and convert(date, dbo.getdate(), 23) >=convert(date,fechaActua)  
					 ); 
   
BEGIN TRY         
	BEGIN TRANSACTION   
	SET @Success = 0;   
	SET @Message = '';                                         
     
	if (@EstadoVeri =1)   
	begin   
		SET @Success = 2;                               
		SET @Message = ''+'-El cliente ya tiene otra Operacion en ' + @NomEstado;   
	end   
   
	IF(@EstadoVeri = 2)   
	begin    
	--SET @NomEstado = ISNULL((select UPPER(NombreLargo) from SGF_Parametro where DominioId = 38 and ParametroId = @EstadoProcesoId), '');           
	-- ESTADO PROSPECTO         
		IF (@EstadoProcesoId = 2  )   
		BEGIN   
			if( @FechaPros = 10)   
			begin   
				INSERT INTO SGF_ExpedienteCreditoDetalle   
				(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                         
				VALUES   
				(@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.GETDATE(), @UserIdCrea, 'CLIENTE REGRESO A ' + @NomEstado + ' : ' + UPPER(@Observacion))      
   
				UPDATE SGF_ExpedienteCredito                               
				SET EstadoProcesoId = @EstadoProcesoId,   
					FechaProspecto = dbo.GETDATE(),   
					FechaActua = dbo.GETDATE(),   
					UserIdActua = @UserIdCrea,   
					Observacion = @Observacion,   
					EstadoExpedienteid = 1           
				WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
                 
				UPDATE SGF_Evaluaciones       
				SET ResultadoId = 2,   
					FechaActua = dbo.GETDATE(),   
					Observacion = 'TITULAR REGRESO A ' + @NomEstado + ' : ' + UPPER(@Observacion),   
					UserIdActua = @UserIdCrea       
				WHERE ExpedienteCreditoId = @ExpedienteCreditoId      
   
				SET @Success = 1;                               
				SET @Message = 'OK';     
			end   
			else   
			begin   
				SET @Success = 2;    
				SET @Message = '-Cliente no puede regresar a Prospecto. Debe Crearse una nueva Operación';   
			end   
			END    
       
			-- ESTADO GESTION     
			ELSE IF (@EstadoProcesoId = 3)     
			BEGIN     
				INSERT INTO SGF_ExpedienteCreditoDetalle   
				(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                         
				VALUES   
				(@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.GETDATE(), @UserIdCrea, 'CLIENTE REGRESO A ' + @NomEstado + ' : ' + UPPER(@Observacion))      
   
				UPDATE SGF_ExpedienteCredito                               
				SET EstadoProcesoId = @EstadoProcesoId,   
					FechaProspecto =dbo.GETDATE(),   
					FechaActua = dbo.GETDATE(),    
					UserIdActua = @UserIdCrea,   
					Observacion = @Observacion,    
					EstadoExpedienteid = 1           
				WHERE ExpedienteCreditoId = @ExpedienteCreditoId       
                 
				UPDATE SGF_Evaluaciones       
				SET ResultadoId = 2,   
					FechaActua = dbo.GETDATE(),   
					Observacion = 'TITULAR REGRESO A ' + @NomEstado + ' : ' + UPPER(@Observacion),   
					UserIdActua = @UserIdCrea       
				WHERE ExpedienteCreditoId = @ExpedienteCreditoId      
         
				SET @Success = 1;                               
				SET @Message = 'OK';     
			END     
			-- ESTADO EVALUACION         
			ELSE IF (@EstadoProcesoId = 5)         
			BEGIN   
				if(@FechaEva = 10) 
					begin 
					INSERT INTO SGF_ExpedienteCreditoDetalle   
					(ExpedienteCreditoId, ItemId, ProcesoId, Fecha, UsuarioId, Observacion)                                         
					VALUES   
					(@ExpedienteCreditoId, @ItemId, @EstadoProcesoId, dbo.GETDATE(), @UserIdCrea, 'CLIENTE REGRESO A ' + @NomEstado + ' : ' + UPPER(@Observacion))      
   
					UPDATE SGF_ExpedienteCredito                               
					SET EstadoProcesoId = @EstadoProcesoId,   
						FechaEvaluacion = dbo.GETDATE(),   
						FechaActua = dbo.GETDATE(),   
						UserIdActua = @UserIdCrea,   
						Observacion = @Observacion,   
						EstadoExpedienteid = 1             
					WHERE ExpedienteCreditoId = @ExpedienteCreditoId        
         
					SET @Success = 1;                               
					SET @Message = 'OK';   
				end 
				else 
				begin				 
					SET @Success = 2;                               
					SET @Message = 'Cliente no puede regresar a evaluación, se derivo hace más de 3 meses';  
				end 
		END        
	end    
	COMMIT;         
END TRY                               
	BEGIN CATCH      
		SET @Success = 0;                               
		SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS varchar(100)) + ' ERROR: ' + ERROR_MESSAGE();     
		ROLLBACK;       
	END CATCH           
END