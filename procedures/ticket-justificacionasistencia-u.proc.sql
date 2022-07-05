/*--------------------------------------------------------------------------------------                                         
' Nombre          : [dbo].[SGC_SP_Ticket_Justficacion_Asistencia_U]                           
' Objetivo        : Este procedimiento actualiza justificacion de asistencia - tickets                         
' Creado Por      : REYNALDO CAUCHE                       
' Día de Creación : 09-06-2022                           
' Requerimiento   : SGC                           
' Modificado por  :                                 
' Día de Modificación :                     
'--------------------------------------------------------------------------------------*/                               
                           
CREATE PROCEDURE [dbo].[SGC_SP_Ticket_Justficacion_Asistencia_U]       
  @SupervisorId int        
  ,@Fecha varchar(20)        
  ,@ProveedorId int        
  ,@MotivoCambio varchar(1000)        
  ,@Descripcion varchar(8000)        
  ,@UserIdCrea int        
  ,@TipoCambioId int        
  ,@EstadoTicketId int      
  ,@ObservacionHistorial varchar(800)      
  ,@PedidoCambioId int
  ,@PlanTrabajoDetalleId int      
  ,@Success int OUTPUT        
  ,@Message varchar(8000) OUTPUT      
AS        
BEGIN       
  DECLARE @IdHistorialCambio int;       
  BEGIN TRY        
      BEGIN TRANSACTION          
          SET @Success=0;      
      
          SET @IdHistorialCambio = (select ISNULL(MAX(IdHistorialCambio),0)+1 from dbo.SGF_PedidoCambio_Historial)        
      
          -- UPDATE SGF_PedidoCambio      
          -- SET MotivoCambio = @MotivoCambio      
          --     ,DescripCambio = @Descripcion      
          --     ,FechaCambio = CONVERT(DATETIME, @Fecha, 102)      
          --     ,IdSupervisor = @SupervisorId      
          --     ,EstadoPedido = @EstadoTicketId      
          --     ,ProveedorNuevoId = @ProveedorId      
          --     ,UserIdActua = @UserIdCrea    
          --     ,UserIdAtendio = @UserIdCrea     
          --     ,FechaAtendio = dbo.getDate()      
          --     ,FechaActua = dbo.getDate()       
          -- WHERE PedidoCambioId = @PedidoCambioId 

          UPDATE SGF_PedidoCambio      
          SET EstadoPedido = @EstadoTicketId       
              ,UserIdActua = @UserIdCrea    
              ,UserIdAtendio = @UserIdCrea     
              ,FechaAtendio = dbo.getDate()      
              ,FechaActua = dbo.getDate()       
          WHERE PedidoCambioId = @PedidoCambioId      
      
          INSERT INTO SGF_PedidoCambio_Historial(IdHistorialCambio,IdPedidoCambioId,Estado,Observacion,FechaCrea,UserIdCrea)        
          VALUES (@IdHistorialCambio,@PedidoCambioId,@EstadoTicketId,@ObservacionHistorial,dbo.getDate(),@UserIdCrea)  
  
          UPDATE SGF_PlanTrabajo_Detalle  
          SET Justificacion = @Descripcion  
              ,FechaJustificacion = dbo.getDate()  
              ,EstAsistencia = @EstadoTicketId  
          WHERE IdPlanTrabajoDetalle = @PlanTrabajoDetalleId  
  
          SET @Success = 1;        
          SET @Message = 'OK';        
      COMMIT;        
  END TRY        
  BEGIN CATCH        
    SET @Success = 0;        
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE();        
    ROLLBACK;        
  END CATCH        
END 