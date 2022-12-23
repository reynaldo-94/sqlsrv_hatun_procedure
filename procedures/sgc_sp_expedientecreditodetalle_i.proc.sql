 /*--------------------------------------------------------------------------------------                                 
' Nombre          : [dbo].[SGC_SP_ExpedienteCreditoDetalle_I]                                                  
' Objetivo        : Este procedimiento registra observaciones a los creditos                 
' Creado Por      : RICHARD ANGULO                   
' Día de Creación : 04-05-2021                                              
' Requerimiento   : SGC                                           
' Modificado por  :                           
' Día de Modificación : 17-01-2021   
-  30-11-2022 - cristian silva - se modifico FechaAgenda en la tabla SGF_ExpedienteCredito antes se registraba la fecha actual se le cambio a @DiaAgenda que se envia del front   
-  30-11-2022 - cristian silva - se valido  if(@DiaAgenda) y que muestre mensaje 'ingresar fecha' si es una fecha anterior a la fecha actual o en adelante 
'--------------------------------------------------------------------------------------*/                   
                 
CREATE PROCEDURE SGC_SP_ExpedienteCreditoDetalle_I                
@ExpedienteCreditoId int,                   
@ProcesoId int,                 
@Observacion varchar(500),                   
@UserIdCrea int,                   
@DiaAgenda varchar(10),         
@Fecha varchar(20),       
@Success INT OUTPUT ,                     
@Message varchar(8000) OUTPUT                   
AS                          
BEGIN 
declare @ItemId int   
 
 BEGIN TRY                                 
  SET @Success = 0;     
   
  IF(convert(date,@DiaAgenda,23)>DATEADD(DAY,-1, convert(date,dbo.getdate(),23))) 
  BEGIN 
	SET @ItemId =( select ISNULL(MAX(ItemId) + 1,1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId)               
    
	INSERT INTO SGF_ExpedienteCreditoDetalle   
		(ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                   
	values   
		(@ExpedienteCreditoId,@ItemId,@ProcesoId,@Fecha,cast(@DiaAgenda as date),@UserIdCrea,@Observacion)              
   
	UPDATE SGF_ExpedienteCredito          
		set FechaAgenda = cast(@DiaAgenda as date)      
	where ExpedienteCreditoId = @ExpedienteCreditoId     
          
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