 /*--------------------------------------------------------------------------------------                                                
' Nombre          : [dbo].[SGC_SP_ExpedienteCreditoDetalle_I]                                                                 
' Objetivo        : Este procedimiento registra observaciones a los creditos                                
' Creado Por      : RICHARD ANGULO                                  
' Día de Creación : 04-05-2021                                                             
' Requerimiento   : SGC                              
' Día de Modificación : 17-01-2021                  
-  30-11-2022 - cristian silva - se modifico FechaAgenda en la tabla SGF_ExpedienteCredito antes se registraba la fecha actual se le cambio a @DiaAgenda que se envia del front                  
-  30-11-2022 - cristian silva - se valido  if(@DiaAgenda) y que muestre mensaje 'ingresar fecha' si es una fecha anterior a la fecha actual o en adelante           
-  15/08/2023 - Reynaldo Cauche - Se agrego los campos @TipoCompromisoId, @SubTipoCompromisoId           
                                - Se añadio un insert a la tabla sgf_tareas          
- develop-rediseño 24/08/2023 - Reynaldo Cauche - Se agrego validacion con el campo TipoCompromisoId, Observacion, Fehca          
                                - Se removio los parametros FechaAgenda, Procesoid      
- develop-rediseño 08/09/2023 - Reynaldo Cauche - Se cambio los mensajes de observacion      
- develop-rediseño 09/09/2023 - Francisco Lazaro - Agregar ExpedienteCreditoId a SGF_Tareas    
'--------------------------------------------------------------------------------------*/                                  
                                
CREATE PROCEDURE SGC_SP_ExpedienteCreditoDetalle_I           
@ExpedienteCreditoId int,          
@Observacion varchar(500),                                  
@UserIdCrea int,                                  
@Fecha varchar(10),          
@TipoCompromisoId int = NULL,            
@Success INT OUTPUT ,                                    
@Message varchar(8000) OUTPUT                                  
AS                                         
BEGIN                
declare @ItemId int          
declare @ProcesoId int           
                
 BEGIN TRY                                                
  SET @Success = 0;                    
                  
  IF(ISNULL(@Fecha,'') = '' or convert(date,@Fecha,23)>=DATEADD(DAY,-1, convert(date,dbo.getdate(),23)))                
    BEGIN                
      SET @ItemId =( select ISNULL(MAX(ItemId) + 1,1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId)                              
      SET @ProcesoId = ( SELECT EstadoProcesoId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId )          
            
      IF (ISNULL(@TipoCompromisoId,0) != 0)           
        BEGIN               
          DECLARE @TareaId INT = ( select ISNULL(MAX(TareaId) + 1,1) from SGF_Tareas)           
          DECLARE @SupervisorId INT = ( SELECT EmpleadoId FROM SGF_USER where UserId = @UserIdCrea )           
          DECLARE @PersonaId INT = ( SELECT TitularId FROM SGF_ExpedienteCredito where ExpedienteCreditoId = @ExpedienteCreditoId)     
          DECLARE @SubTipoCompromisoId INT;          
          
          -- TIPOCOMPROMISO = 1 (COMPROMISO) SE CONDICIONA CON PROSPECTO          
          IF (@TipoCompromisoId = 1 AND @ProcesoId = 2)           
          BEGIN           
              SET @SubTipoCompromisoId = 1            
              -- SET @Observacion = (SELECT NombreLargo FROM SGF_Parametro WHERE DominioId = 148 AND ParametroId = 1)          
                SET @Observacion = 'De Prospecto a Gestión para la fecha ' + convert(varchar,convert(date,@Fecha,23),103)       
          END          
          
          -- TIPOCOMPROMISO = 1 (COMPROMISO) SE CONDICIONA CON EVALUACION          
          IF (@TipoCompromisoId = 1 AND @ProcesoId = 5)       
          BEGIN           
              SET @SubTipoCompromisoId = 2          
              -- SET @Observacion = (SELECT NombreLargo FROM SGF_Parametro WHERE DominioId = 148 AND ParametroId = 2)          
              SET @Observacion = 'De Evaluación a Desembolsos para la fecha ' + convert(varchar,convert(date,@Fecha,23),103)      
          END          
          
          -- TIPOCOMPROMISO = 2 (AGENDADO)          
          IF (@TipoCompromisoId = 2)           
          BEGIN           
              SET @SubTipoCompromisoId = 3            
              -- SET @Observacion = (SELECT NombreLargo FROM SGF_Parametro WHERE DominioId = 148 AND ParametroId = 3)          
              SET @Observacion = 'Agendado para la fecha ' + convert(varchar,convert(date,@Fecha,23),103)      
          END          
                    
          INSERT INTO SGF_Tareas (TareaId, SupervisorId, PersonaId, TipoCompromisoId, SubTipoCompromisoId, Fecha, ExpedienteCreditoId)           
                          VALUES (@TareaId, @SupervisorId, @PersonaId, @TipoCompromisoId, @SubTipoCompromisoId, cast(@Fecha as date), @ExpedienteCreditoId)           
        END           
          
      INSERT INTO SGF_ExpedienteCreditoDetalle (ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                                  
                                        VALUES (@ExpedienteCreditoId,@ItemId,@ProcesoId,dbo.getDate(),cast(@Fecha as date),@UserIdCrea,@Observacion)                             
                    
      IF ((ISNULL(@Observacion,'') != '' and ISNULL(@Fecha,'') != '') OR (ISNULL(@TipoCompromisoId,0) = 0 and ISNULL(@Observacion,'') = '' ) )          
      BEGIN          
          UPDATE SGF_ExpedienteCredito                         
          SET FechaAgenda = cast(@Fecha as date)          
          WHERE ExpedienteCreditoId = @ExpedienteCreditoId           
      END          
          
      SET @Success = 1;                                  
      SET @Message = 'OK'                 
    END                
  ELSE                
  BEGIN                
 SET @Success = 2;                                  
 SET @Message = '- Seleccionar fecha de hoy o en adelante.'                
  END                              
                                       
 END TRY                        
 BEGIN CATCH                        
  SET @Success = 0;                                    
  SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()                                               
 END CATCH                        
END 