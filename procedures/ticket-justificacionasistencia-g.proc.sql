/*--------------------------------------------------------------------------------------                                       
' Nombre          : [dbo].[SGC_SP_Ticket_Justficacion_Asistencia_U]                         
' Objetivo        : Este procedimiento obtiene los datos del ticketde justificacion                    
' Creado Por      : REYNALDO CAUCHE                     
' Día de Creación : 09-06-2022                         
' Requerimiento   : SGC                         
' Modificado por  :                               
' Día de Modificación :                   
'--------------------------------------------------------------------------------------*/       
    
CREATE PROCEDURE SGC_SP_Ticket_Justficacion_Asistencia_G(        
  @PedidoCambioId int        
)        
AS        
BEGIN        
    SELECT pc.IdSupervisor, convert(varchar, pc.FechaCambio, 23) as FechaCambio, pc.ProveedorNuevoId, pc.MotivoCambio, pc.DescripCambio, pc.EstadoPedido as EstadoTicketId, pr.DocumentoNum, pr.RazonSocial        
    FROM SGF_PedidoCambio pc  
    LEFT JOIN SGF_Proveedor pr ON pc.ProveedorNuevoId = pr.ProveedorId  
    WHERE PedidoCambioId = @PedidoCambioId        
END 