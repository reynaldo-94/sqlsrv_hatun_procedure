/*--------------------------------------------------------------------------------------                                                 
' Nombre          : [dbo].[SGC_SP_Ticket_Justficacion_Asistencia_I]                                                                  
' Objetivo        : Este procedimiento Crea nuevos ticket .. Justificacion de Asistenca                                            
' Creado Por      : Reynaldo Cauche                                   
' Día de Creación : 27-05-2022                                                              
' Requerimiento   : SGC                                                           
' Modificado por  : Reynaldo Cauche                                        
' Día de Modificación : 17-6-2022                                               
'--------------------------------------------------------------------------------------*/        
      
CREATE PROCEDURE [dbo].[SGC_SP_Ticket_Justficacion_Asistencia_I]      
    @SupervisorId int      
    ,@Fecha varchar(20)      
    ,@ProveedorId int  -- Se Refiere al PlanTrabajoDetalleId
    ,@MotivoCambio varchar(1000)      
    ,@Descripcion varchar(8000)      
    ,@UserIdCrea int      
    ,@TipoCambioId int      
    ,@EstadoTicketId int      
    ,@ZonaId int      
    ,@LocalId INT      
    ,@RegionZonaId int      
    ,@ObservacionHistorial varchar(800)    
    ,@ObservacionHistorialAtendido varchar(800)      
    ,@Success int OUTPUT      
    ,@Message varchar(8000) OUTPUT      
AS      
BEGIN      
    DECLARE @PedidoCambioId int;      
    DECLARE @IdHistorialCambio int;    
    DECLARE @PlanTrabajoId int;    
    DECLARE @PlanTrabajoDetalleId int;    
    DECLARE @ItemId int;    
    DECLARE @UserSupervisorId int;  
    DECLARE @ProveedorLocalId INT;
    BEGIN TRY      
        BEGIN TRANSACTION        
            SET @Success=0;      
      
            set @PedidoCambioId=(Select max(PedidoCambioId)+1 FROM SGF_PedidoCambio)      
            SET @IdHistorialCambio = (select ISNULL(MAX(IdHistorialCambio),0)+1 FROM dbo.SGF_PedidoCambio_Historial)    
            SET @PlanTrabajoId = (Select ISNULL(max(IdPlan),0)+1 FROM SGF_PlanTrabajo)    
            SET @PlanTrabajoDetalleId = (SELECT ISNULL(max(IdPlanTrabajoDetalle),0)+1 FROM SGF_PlanTrabajo_Detalle)
            SET @UserSupervisorId = (select us.UserId  
                                    from sgf_user us  
                                    inner join SGF_Supervisor sp on sp.IdSupervisor = us.EmpleadoId  
                                    where sp.IdSupervisor = @SupervisorId and us.CargoId = 29);
            SET @ProveedorLocalId = (SELECT ProveedorLocalId FROM SGF_PlanTrabajo_Detalle WHERE IdPlanTrabajoDetalle = @ProveedorId);
    
            -- Insertar en Plan Trabajo    
            -- INSERT INTO SGF_PlanTrabajo(IdPlan, UserId, FechaVisita, FechaCrea, UserIdCrea, TipoPlan, IdSupervisor)    
            -- VALUES (@PlanTrabajoId, @UserSupervisorId, @Fecha, dbo.getDate(), @UserIdCrea, @TipoCambioId, @SupervisorId)    
    
            -- SET @ItemId = (SELECT ISNULL(MAX(ItemId),0) + 1 FROM SGF_PlanTrabajo_Detalle WHERE IdPlan = @PlanTrabajoId)    
    
            -- -- Insertar en Plan Trabajo Detalle    
            -- INSERT INTO SGF_PlanTrabajo_Detalle(IdPlanTrabajoDetalle, IdPlan, ProveedorLocalId, ItemId, FechaCrea, UserIdCrea, Justificacion, FechaJustificacion, EstAsistencia)    
            -- VALUES (@PlanTrabajoDetalleId, @PlanTrabajoId, @ProveedorId, @ItemId, dbo.getDate(), @UserIdCrea, @Descripcion, dbo.getDate(), @EstadoTicketId)    
    
            -- Estado Atendido    
            IF(@MotivoCambio = 'Problemas con marcación')    
                BEGIN
                    INSERT INTO SGF_PedidoCambio (PedidoCambioId,TipoCambioId,MotivoCambio,DescripCambio,ExpedienteCreditoId,StatusClienteId,FechaCambio,IdSupervisor,UserIdCrea,FechaCrea,EstadoPedido,ZonaId,LocalId,ProveedorNuevoId,RegionZonaId,UserIdAtendio,FechaAtendio,PlanTrabajoDetalleId)
                    VALUES (@PedidoCambioId,@TipoCambioId,@MotivoCambio,@Descripcion,0,0,CONVERT(DATETIME, @Fecha, 102),@SupervisorId,@UserIdCrea,dbo.getDate(),@EstadoTicketId,@ZonaId,@LocalId,@ProveedorLocalId,@RegionZonaId,@UserIdCrea,dbo.getDate(),@ProveedorId)
      
                    INSERT INTO SGF_PedidoCambio_Historial(IdHistorialCambio,IdPedidoCambioId,Estado,Observacion,FechaCrea,UserIdCrea)      
                    VALUES (@IdHistorialCambio,@PedidoCambioId,4,@ObservacionHistorial,dbo.getDate(),@UserIdCrea)    
    
                    SET @IdHistorialCambio = (select ISNULL(MAX(IdHistorialCambio),0)+1 from dbo.SGF_PedidoCambio_Historial)    
    
                    INSERT INTO SGF_PedidoCambio_Historial(IdHistorialCambio,IdPedidoCambioId,Estado,Observacion,FechaCrea,UserIdCrea)      
                    VALUES (@IdHistorialCambio,@PedidoCambioId,@EstadoTicketId,@ObservacionHistorialAtendido,dbo.getDate(),@UserIdCrea)

                    UPDATE SGF_PlanTrabajo_Detalle  
                    SET Justificacion = @Descripcion  
                        ,FechaJustificacion = dbo.getDate()  
                        ,EstAsistencia = @EstadoTicketId  
                    WHERE IdPlanTrabajoDetalle = @ProveedorId  
                END    
            ELSE    
                BEGIN    
                    INSERT INTO SGF_PedidoCambio (PedidoCambioId,TipoCambioId,MotivoCambio,DescripCambio,ExpedienteCreditoId,StatusClienteId,FechaCambio,IdSupervisor,UserIdCrea,FechaCrea,EstadoPedido,ZonaId,LocalId,ProveedorNuevoId,RegionZonaId,PlanTrabajoDetalleId)
                    VALUES (@PedidoCambioId,@TipoCambioId,@MotivoCambio,@Descripcion,0,0,CONVERT(DATETIME, @Fecha, 102),@SupervisorId,@UserIdCrea,dbo.getDate(),@EstadoTicketId,@ZonaId,@LocalId,@ProveedorLocalId,@RegionZonaId,@ProveedorId)
      
                    INSERT INTO SGF_PedidoCambio_Historial(IdHistorialCambio,IdPedidoCambioId,Estado,Observacion,FechaCrea,UserIdCrea)
                    VALUES (@IdHistorialCambio,@PedidoCambioId,@EstadoTicketId,@ObservacionHistorial,dbo.getDate(),@UserIdCrea)
                END     
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