 /*--------------------------------------------------------------------------------------                                                          
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_I]                                                                           
' Objetivo        : Este procedimiento registrar nuevos creditos para una persona nueva                                                              
' Creado Por      : cristian silva                                           
' Día de Creación : 22-12-2022                                                                       
' Requerimiento   : SGC                                                                    
' cambios     
- 03/02/2022 - Reynaldo Cauche - Se agrego valildacion cuando el tipodireccion no sea igual a 1, se agrego un insert con tipo direccion igual a 1
'--------------------------------------------------------------------------------------*/                                                
                                            
ALTER PROCEDURE [dbo].[SGC_SP_ExpedienteCreditoIntervener_I]                                                                       
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
                                            
--Datos Expediente Credito                                            
 @ExpedienteCreditoId int,                                               
 @ExpedienteCreditoZonaId int,                                           
 @ExpedienteCreditoLocalId int,                                               
 @EstadoProcesoId int,                                                                                   
 @UserIdCrea int,                                                                                                                                                                    
 @DispositivoId int,                       
--Respuesta Sentinel                                            
 @ResultadoId int,--ok                                         
 @Observacion varchar(500),---ok                      
       
 -- datos laborales     
@DatosDireccionId int,     
--@DatosDireccionTrabajoId int, 
@CasaPropia int,        
@DatosLaboralesId int,        
@TipoTrabajoId int,        
@FormalidadTrabajoId int,        
@UbigeoTrabajo varchar(500),        
@DireccionTrabajo varchar(500),        
@ReferenciaTrabajo varchar(500),        
@NombreEstablecimiento varchar(500),        
@RucEstablecimiento varchar(500),        
@CentroTrabajo varchar(500),        
@GiroId int,        
@SustentoIngresoId int,        
@IngresoNeto varchar(50),        
@AntiguedadLaboral varchar(500),         
@DiasPago int,        
     
 @Success INT OUTPUT,                                              
 @Message varchar(8000) OUTPUT,                              
 @PersonaIdOutput INT OUTPUT,                              
 @ExpedienteCreditoIdOutput INT OUTPUT       
as                                                                                 
  declare @EvaluacionId int                           
  declare @DatosDireccionTrabajoId int       
  declare @TipoDireccionTrabajoId int       
BEGIN TRY                                              
  BEGIN TRANSACTION                   
        
 SET @TipoDireccionTrabajoId = IIF(@TipoTrabajoId=1,2,3)      
    SET @Success=0;                                    
                                
                                               
 /*=== Ingreso Datos Involucrados ===*/                                            
 If(@TipoPersonaId > 1)               
 Begin                                            
  If (@PersonaId=0)                                            
  begin                                                                     
   set @PersonaId=(Select max(PersonaId)+1 from SGF_Persona)                                            
                                             
   INSERT INTO SGF_Persona              
    (PersonaId,ZonaId,LocalId,EstadoPersonaId,Nombre,ApePaterno,ApeMaterno,DocumentoNum,Telefonos,Celular,Celular2,EstadoCivilId,Correo,             
    UserIdCrea,FechaCrea, CasaPropia)                                            
   values             
    (@PersonaId,@ExpedienteCreditoZonaId,@ExpedienteCreditoLocalId,@EstadoProcesoId,@Nombre,@ApePaterno,@ApeMaterno,@DocumentoNum,@Telefonos,             
    @Celular,@Celular2,@EstadoCivilId,@Correo,@UserIdCrea,dbo.GETDATE(),@CasaPropia)               
               
   if(@DatosDireccionId=0 or @DatosDireccionId is null)                                  
   begin                                  
    set @DatosDireccionId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)                                  
    INSERT INTO SGF_DatosDireccion     
     (DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                                  
    values     
     (@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)                                  
   end                                  
        
         
   if(@DatosLaboralesId=0 or @DatosLaboralesId is null )                                  
   begin                                  
    set @DatosLaboralesId=(Select max(DatosLaboralesId)+1 from SGF_DatosLaborales)                                  
    INSERT INTO SGF_DatosLaborales         
     (DatosLaboralesId,PersonaId,TipoTrabajoId,FormalidadTrabajoId,TipoEstablecimiento,NombreEstablecimiento,ActividadEconomicaId,GiroId,         
     CentroTrabajo,SustentoIngresoId,Cargo,IngresoNeto,AntiguedadLaboral,DiasPago,Ruc)                              
    values         
     (@DatosLaboralesId,@PersonaId,@TipoTrabajoId,@FormalidadTrabajoId,'',@NombreEstablecimiento,0,@GiroId,         
     @CentroTrabajo, @SustentoIngresoId,'',@IngresoNeto,@AntiguedadLaboral,@DiasPago,@RucEstablecimiento)                                  
   end     
     
   If( Len(@DocumentoNum) != 11)                                  
   begin                                  
    set @DatosDireccionTrabajoId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)      
        
    INSERT INTO SGF_DatosDireccion     
     (DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)               
    values     
     (@DatosDireccionTrabajoId,@PersonaId,@TipoDireccionTrabajoId,0,@DireccionTrabajo,@ReferenciaTrabajo,@UbigeoTrabajo,0)                                  
   end      
            
  end       
---------------####################################################################################33-----------------------------------------------------     
  Else If (@PersonaId>0)                   
  begin     
  declare @DatosDireccionIdPerson int; 
	set @DatosDireccionIdPerson=(Select max(DatosDireccionId) from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId=1)    
	SET @DatosDireccionTrabajoId = (select top 1 DatosDireccionId from SGF_DatosDireccion where PersonaId=@PersonaId and TipoDireccionId<>1)     
                                               
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
		CasaPropia = @CasaPropia,     
		UserIdActua = @UserIdCrea     
		where PersonaId=@PersonaId                                            
             
		If( @DatosDireccionIdPerson > 0)                                  
            begin 
                UPDATE SGF_DatosDireccion                                            
                SET                                            
                    Direccion=@Direccion,                                            
                    Referencia=@Referencia,                                            
                    Ubigeo=@Ubigeo     
                WHERE DatosDireccionId=@DatosDireccionIdPerson          
            end
        ELSE 
            BEGIN
                set @DatosDireccionId=(Select max(DatosDireccionId)+1 from SGF_DatosDireccion)
                INSERT INTO SGF_DatosDireccion     
                (DatosDireccionId,PersonaId,TipoDireccionId,Correspondencia,Direccion,Referencia,Ubigeo,EsFijo)                                  
                values     
                (@DatosDireccionId,@PersonaId,1,1,@Direccion,@Referencia,@Ubigeo,1)
            END
		   
		If( @DatosLaboralesId > 0)                                  
		begin   		  
			update SGF_DatosLaborales  
			set TipoTrabajoId=@TipoTrabajoId 
				,FormalidadTrabajoId=@FormalidadTrabajoId 
				,TipoEstablecimiento='' 
				,NombreEstablecimiento=@NombreEstablecimiento 
				,ActividadEconomicaId=0 
				,GiroId=@GiroId 
				,CentroTrabajo=@CentroTrabajo 
				,SustentoIngresoId=@SustentoIngresoId 
				,Cargo='' 
				,IngresoNeto=@IngresoNeto 
				,AntiguedadLaboral=@AntiguedadLaboral 
				,DiasPago=@DiasPago 
				,Ruc=@RucEstablecimiento                           
			where PersonaId=@PersonaId  and DatosLaboralesId = @DatosLaboralesId                                
		end  
 
		If( Len(@DocumentoNum) != 11)                                  
		begin                                  
     
			update SGF_DatosDireccion     
			set TipoDireccionId=@TipoDireccionTrabajoId 
			,Correspondencia=0 
			,Direccion=@DireccionTrabajo 
			,Referencia=@ReferenciaTrabajo 
			,Ubigeo=isnull(@UbigeoTrabajo,'') 
			,EsFijo=0 
			where DatosDireccionId = @DatosDireccionTrabajoId                           
		end                           
        
                                               
  end       
       
	set @EvaluacionId=(Select max(EvaluacionId)+1 from SGF_Evaluaciones)             
             
	INSERT INTO SGF_Evaluaciones         
		(EvaluacionId,ExpedienteCreditoId,PersonaId,ResultadoId,Observacion,EsTitular,UserIdCrea,FechaCrea,TipoPersonaId)                                            
	values         
		(@EvaluacionId,@ExpedienteCreditoId,@PersonaId,@ResultadoId,@Observacion,0,@UserIdCrea,dbo.getdate(),@TipoPersonaId)                            
                                               
	/*=== Si Involucrado No Califica, finaliza Crédito ===*/                                            
	If (@ResultadoId = 3)                                            
	Begin                                            
	UPDATE SGF_ExpedienteCredito                                            
	SET              
		EstadoProcesoId=@EstadoProcesoId,                                            
		EstadoExpedienteId=2,                                            
		FechaActua=dbo.GETDATE(),                                            
		FechaNoCalifica=dbo.GETDATE(),                                            
		Observacion=@Observacion,                                            
		UserIdActua=@UserIdCrea,     
		DispositivoId = @DispositivoId     
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