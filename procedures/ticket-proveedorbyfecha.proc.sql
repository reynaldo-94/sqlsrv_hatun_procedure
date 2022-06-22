    
 /*--------------------------------------------------------------------------------------                                                 
' Nombre          : [dbo].[SGC_SP_Ticket_Proveedor_ByFecha_L]                                                                  
' Objetivo        : Este procedimiento devuelve proveedores del plan trabajo porfecha                                                  
' Creado Por      : REYNALDO CAUCHE                                 
' Día de Creación : 17-06-2022                                                              
' Requerimiento   : SGC                                                           
' Modificado por  :                                        
' Día de Modificación :                                                      
'--------------------------------------------------------------------------------------*/    
    
CREATE PROCEDURE SGC_SP_Ticket_Proveedor_ByFecha_L    
(@Fecha VARCHAR(20), @SupervisorId INT)        
AS    
    
BEGIN    
 DECLARE @UserId INT;    
    
 SET @UserId = (SELECT us.UserId    
      FROM sgf_user us    
      INNER JOIN SGF_Supervisor sp ON sp.IdSupervisor = us.EmpleadoId    
      WHERE sp.IdSupervisor = @SupervisorId and CargoId = 29);    
    
    SELECT pd.ProveedorLocalId AS Id,pr.NombreComercial AS Name       
    FROM SGF_PlanTrabajo  pt      
    INNER JOIN SGF_PlanTrabajo_Detalle pd ON pt.IdPlan = pd.IdPlan      
    INNER JOIN SGF_ProveedorLocal pr on pd.ProveedorLocalId = pr.ProveedorLocalId      
    WHERE CONVERT(VARCHAR,pt.FechaVisita,23) = @Fecha AND pt.UserId = @UserId    
    ORDER BY pr.NombreComercial ASC      
END 