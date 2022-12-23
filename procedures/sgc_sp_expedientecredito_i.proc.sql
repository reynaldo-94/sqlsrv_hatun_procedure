 /*--------------------------------------------------------------------------------------                                                    
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_I]                                                                     
' Objetivo        : Este procedimiento registrar nuevos creditos para una persona nueva                                                        
' Creado Por      : SAMUEL FLORES                                      
' Día de Creación : 24-03-2021                                                                 
' Requerimiento   : SGC                                                              
' Modificado por  : Reynaldo Cauche                                             
' Día de Modificación : 26-04-2022        
--cambios     
- 03/10/2022 - cristian silva - solo se modifico @DocumentoNum se agrego el varchar(11) por el varchar(12)  
- 29/12/2022 - Reynaldo Cauche - Agregar campo Prioridad e insertarlo en la tabla SGF_ExpedienteCredito  
- 06/12/2022 - Reynaldo Cauche - Se agrego el parametro @ObservacionCambioEstado 
'--------------------------------------------------------------------------------------*/                                          
                                      
CREATE PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_I]
--Datos de Persona                                      
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
 @DiaLlamada varchar(25),              
 @Horario varchar(50),              
                                      
--Datos Expediente Credito                                      
 @ExpedienteCreditoId int,                                      
 @ExpedienteCreditoZonaId int,                                      
 @ExpedienteCreditoLocalId int,                                      
 @EstadoProcesoId int,                                      
 @CanalVentaID int,                                      
 @ProveedorId int,                                      
 @UserIdCrea int,                                      
 @Obra varchar(50),                                      
 @IdSupervisor int,                                      
 @AdvId int,                                      
 @DispositivoId int,              
 @BancoId int,  
 @Prioridad varchar(15), 
--Respuesta Sentinel                                      
 @ResultadoId int,      --ok                                
 @Observacion varchar(500), ---ok                                     
 @TipoCredito varchar(25),                                      
 @IsBancarizado bit=NULL,                                      
 @OrigenId int,                                      
--APDP                                    
 @APDP bit null,                                    
 @IpAPDP varchar(20) null,                                    
 @FechaAPDP datetime,                                  
 @NavegadorAPDP varchar(20) null,                                    
 @ModeloDispositivoAPDP varchar(10) null, 
-- Mensaje al cambio de estado a Rechazado o Desistio 
 @ObservacionCambioEstado varchar(500),                       
   
 @Success INT OUTPUT,                                      
 @Message varchar(8000) OUTPUT,                      
 @PersonaIdOutput INT OUTPUT,                      
 @ExpedienteCreditoIdOutput INT OUTPUT            
as                                      
  declare @DatosDireccionId int                                      
  declare @EvaluacionId int                     
  declare @ValueFechaAPDP varchar(100)                    
BEGIN TRY                                        
  BEGIN TRANSACTION             
                                         
    SET @Success=0;                              
    /*================ Ingreso Datos Titular ==================*/                                      
 If (@TipoPersonaId=0 or @TipoPersonaId=1)                                      
 Begin                                      
  if(@PersonaId=0)                                      
  begin                                      
   set @DatosDireccionId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)                                      
   set @PersonaId=(Select max(PersonaId)+1 from SGF_Persona)                                      
                                         
		INSERT INTO SGF_Persona       
			(PersonaId,ZonaId,LocalId,EstadoPersonaId,Nombre,ApePaterno,ApeMaterno,DocumentoNum,Telefonos,Celular,Celular2,EstadoCivilId,Correo,       
			UserIdCrea,OrigenId,APDP,IpAPDP,FechaAPDP,NavegadorAPDP,ModeloDispositivoAPDP,ProveedorLocalId,IdSupervisor,FechaCrea,DiaLlamada,Horario)                                      
		values       
			(@PersonaId,@ExpedienteCreditoZonaId,@ExpedienteCreditoLocalId,@EstadoProcesoId,@Nombre,@ApePaterno,@ApeMaterno,@DocumentoNum,@Telefonos,@Celular,@Celular2,       
			@EstadoCivilId,@Correo,@UserIdCrea,@OrigenId,@APDP,@IpAPDP,@FechaAPDP,@NavegadorAPDP,@ModeloDispositivoAPDP,@ProveedorId,@IdSupervisor,dbo.getdate(),@DiaLlamada,@Horario)                                      
                                             
		INSERT INTO SGF_DatosDireccion   
			(DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                                       
		values   
			(@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)    
      
  end                                      
  else                                      
  begin                                      
   set @DatosDireccionId=(Select max(DatosDireccionId) from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId=1)                                      
   set @ValueFechaAPDP = (Select FechaAPDP from SGF_Persona where PersonaId=@PersonaId)                    
                       
    IF(ISNULL(@ValueFechaAPDP,'') = '')                    
    begin                         
		UPDATE SGF_Persona                                      
		SET                                      
			Nombre=@Nombre,                                      
			ApePaterno=@ApePaterno,                                      
			ApeMaterno=@ApeMaterno,                                      
			DocumentoNum=@DocumentoNum,                                      
			Telefonos=@Telefonos,                                      
			Celular=@Celular,                                      
			Celular2=@Celular2,                                      
			EstadoCivilId=@EstadoCivilId,                                      
			Correo=@Correo,                    
			APDP=@APDP,                    
			IpAPDP=@IpAPDP,                    
			FechaAPDP=@FechaAPDP,                    
			NavegadorAPDP=@NavegadorAPDP,                    
			ModeloDispositivoAPDP=@ModeloDispositivoAPDP,              
			DiaLlamada=@DiaLlamada,              
			Horario=@Horario,       
			IdSupervisor =@IdSupervisor       
		where PersonaId=@PersonaId                         
    end                    
    else                     
    begin                    
		UPDATE SGF_Persona                                      
		SET                                      
			Nombre=@Nombre,                                      
			ApePaterno=@ApePaterno,                                      
			ApeMaterno=@ApeMaterno,                                      
			DocumentoNum=@DocumentoNum,                       
			Telefonos=@Telefonos,                                      
			Celular=@Celular,                                      
			Celular2=@Celular2,                                      
			EstadoCivilId=@EstadoCivilId,                    
			Correo=@Correo,              
			DiaLlamada=@DiaLlamada,              
			Horario=@Horario,       
			IdSupervisor =@IdSupervisor       
		where PersonaId=@PersonaId                                   
    end            
            
   UPDATE SGF_DatosDireccion                                      
   SET                                      
    Direccion=@Direccion,                                      
    Referencia=@Referencia,                                      
    Ubigeo=@Ubigeo            
   WHERE DatosDireccionId=@DatosDireccionId     
      
 end            
       
   -- segundo if       
                                           
        set @ExpedienteCreditoId=(Select max(ExpedienteCreditoId)+1 from SGF_ExpedienteCredito)                                      
		INSERT INTO SGF_ExpedienteCredito       
			(ExpedienteCreditoId,TitularId,TipoUsuarioRegistroId,ExpedienteCreditoZonaId,ExpedienteCreditoLocalId,EstadoProcesoId,EstadoExpedienteId,       
			CanalVentaID,ProveedorId,UserIdCrea,FechaCrea,FechaContacto,TipoExpediente,Obra,IdSupervisor,AdvId,BancoId,DispositivoId,CategoriaId,TipoCredito,       
			IsBancarizado,FechaAgenda,FechaActua,Prioridad)                                      
		values       
			(@ExpedienteCreditoId,@PersonaId,0,@ExpedienteCreditoZonaId,@ExpedienteCreditoLocalId,@EstadoProcesoId,1,@CanalVentaID,@ProveedorId,@UserIdCrea,       
			dbo.getdate(),dbo.getdate(),1,@Obra,@IdSupervisor,@AdvId,@BancoId,@DispositivoId,1,@TipoCredito,@IsBancarizado,dbo.GETDATE(),dbo.GETDATE(),@Prioridad)                                      
                                       
        set @EvaluacionId=(Select max(EvaluacionId)+1 from SGF_Evaluaciones)       
         
		INSERT INTO SGF_Evaluaciones   
			(EvaluacionId,ExpedienteCreditoId,PersonaId,ResultadoId,Observacion,EsTitular,UserIdCrea,FechaCrea,TipoPersonaId)                                      
		values   
			(@EvaluacionId,@ExpedienteCreditoId,@PersonaId,@ResultadoId,@Observacion,1,@UserIdCrea,dbo.getdate(),1)                                      
                                       
		INSERT INTO SGF_ExpedienteCreditoDetalle   
			(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                                      
		values   
			(@ExpedienteCreditoId,1,1,dbo.getdate(),@UserIdCrea,IIF(@Prioridad = 'URGENTE',@ObservacionCambioEstado,@Observacion))                                      
                                         
		If @EstadoProcesoId=2                                      
		Begin                                      
			UPDATE SGF_ExpedienteCredito                                      
			SET                                      
				Observacion=@Observacion,                                      
				FechaActua=dbo.GETDATE(),                                      
				FechaProspecto=dbo.GETDATE()                                      
			WHERE ExpedienteCreditoId=@ExpedienteCreditoId                                      
		End                                      
		Else If @EstadoProcesoId=11                                      
		Begin                                      
			UPDATE SGF_ExpedienteCredito                                      
			SET                                      
				EstadoProcesoId=@EstadoProcesoId,                                      
				EstadoExpedienteId=2,                                      
				FechaActua=dbo.GETDATE(),                                      
				FechaNoCalifica=dbo.GETDATE(),                                      
				Observacion=@Observacion,                                      
				UserIdActua=@UserIdCrea                                      
			WHERE ExpedienteCreditoId=@ExpedienteCreditoId                                      
		End                                      
                                       
      If @EstadoProcesoId>1                                      
          Begin                                      
			INSERT INTO SGF_ExpedienteCreditoDetalle   
				(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                                      
			values   
				(@ExpedienteCreditoId,2,@EstadoProcesoId,dbo.getdate(),@UserIdCrea,@Observacion)                                      
          End                                      
      End                             
                                         
 /*=== Ingreso Datos Involucrados ===*/                                      
    Else If(@TipoPersonaId > 1)         
      Begin                                      
        If (@PersonaId=0)                                      
          begin                                      
            set @DatosDireccionId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)                          
            set @PersonaId=(Select max(PersonaId)+1 from SGF_Persona)                                      
                                         
			INSERT INTO SGF_Persona       
				(PersonaId,ZonaId,LocalId,EstadoPersonaId,Nombre,ApePaterno,ApeMaterno,DocumentoNum,Telefonos,Celular,Celular2,EstadoCivilId,Correo,       
				UserIdCrea,FechaCrea,DiaLlamada,Horario)                                      
			values       
				(@PersonaId,@ExpedienteCreditoZonaId,@ExpedienteCreditoLocalId,@EstadoProcesoId,@Nombre,@ApePaterno,@ApeMaterno,@DocumentoNum,@Telefonos,       
				@Celular,@Celular2,@EstadoCivilId,@Correo,@UserIdCrea,dbo.GETDATE(),@DiaLlamada,@Horario)         
         
			INSERT INTO SGF_DatosDireccion   
				(DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                                       
			values   
				(@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)    
			   
          end                                      
        Else If (@PersonaId>0)             
          begin                                      
            set @DatosDireccionId=(Select max(DatosDireccionId) from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId=1)                                      
                                         
			UPDATE SGF_Persona                                      
			SET                                      
				Nombre=@Nombre,                                      
				ApePaterno=@ApePaterno,                      
				ApeMaterno=@ApeMaterno,                                      
				DocumentoNum=@DocumentoNum,                                      
				Telefonos=@Telefonos,                         
				Celular=@Celular,                                      
				Celular2=@Celular2,                                      
				EstadoCivilId=@EstadoCivilId,                                      
				Correo=@Correo,              
				DiaLlamada=@DiaLlamada,              
				Horario=@Horario,       
				IdSupervisor =@IdSupervisor       
			where PersonaId=@PersonaId                                      
                                         
			UPDATE SGF_DatosDireccion                                      
			SET                                      
				Direccion=@Direccion,                                      
				Referencia=@Referencia,                                      
				Ubigeo=@Ubigeo                             
			WHERE DatosDireccionId=@DatosDireccionId                                      
                                         
          end                                      
          
        set @EvaluacionId=(Select max(EvaluacionId)+1 from SGF_Evaluaciones)       
       
		INSERT INTO SGF_Evaluaciones   
			(EvaluacionId,ExpedienteCreditoId,PersonaId,ResultadoId,Observacion,EsTitular,UserIdCrea,FechaCrea,TipoPersonaId)                                      
		values   
			(@EvaluacionId,@ExpedienteCreditoId,@PersonaId,@ResultadoId,@Observacion,0,@UserIdCrea,dbo.getdate(),@TipoPersonaId)                      
                                         
        /*=== Si Involucrado No Califica, finaliza Crédito ===*/                                      
        If (@ResultadoId=3)                                      
          Begin                                      
			UPDATE SGF_ExpedienteCredito                                      
			SET        
				EstadoProcesoId=@EstadoProcesoId,                                      
				EstadoExpedienteId=2,                                      
				FechaActua=dbo.GETDATE(),                                      
				FechaNoCalifica=dbo.GETDATE(),                                      
				Observacion=@Observacion,                                      
				UserIdActua=@UserIdCrea                            
			WHERE ExpedienteCreditoId=@ExpedienteCreditoId                                      
                                         
  declare @ItemId int = (Select max(ItemId)+1 from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId)       
          
		INSERT INTO SGF_ExpedienteCreditoDetalle   
			(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,UsuarioId,Observacion)                                      
		VALUES   
			(@ExpedienteCreditoId,@ItemId,@EstadoProcesoId,dbo.getdate(),@UserIdCrea,@Observacion)       
       
          End                                      
      End                                
             
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