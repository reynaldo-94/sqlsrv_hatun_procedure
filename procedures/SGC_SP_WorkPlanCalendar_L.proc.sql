/*--------------------------------------------------------------------------------------                                                                                                                                         
' Nombre          : [dbo].[SGC_SP_WorkPlanListCalendar]                                                                                                                                                         
' Objetivo        : ESTE PROCEDIMIENTO                                                                                                          
' Creado Por      : CRISTIAN SILVA                                                                                                                       
' Día de Creación :                                                                                                                                                   
' Requerimiento   : SGC                                                                                                                                                   
' Modificado por  :                                                                                                                                
cambios                
'--------------------------------------------------------------------------------------*/                     
                
CREATE PROC [dbo].[SGC_SP_WorkPlanCalendar_L]    
(@SupervisorId int = 0,      
 @Anio int = 0,      
 @Mes int = 0,      
 @Total int out)                                                                                   
AS                                                                                   
BEGIN      
    SET @Total = ISNULL((SELECT COUNT(*) FROM SGF_PlanTrabajo pt     
                  WHERE pt.IdSupervisor = @SupervisorId AND    
                        MONTH(pt.FechaVisita) = @Mes AND   
            YEAR(pt.FechaVisita) = @Anio), 0)  
          
    DECLARE @listaVisitas table(FechaVisita datetime, IdSupervisor int, ProveedorLocalId int)    
    DECLARE @cnt int = 1, @cntProv int = 1;    
        
    WHILE @cnt <= DAY(EOMONTH(DATEFROMPARTS(@Anio, @Mes, 1)))    
    BEGIN    
        INSERT INTO @listaVisitas SELECT DATEFROMPARTS(@Anio, @Mes, @cnt), PL.IdSupervisor, proveedorLocalId     
                                  FROM SGF_ProveedorLocal PL    
                                  INNER JOIN SGF_Proveedor P ON PL.ProveedorId = P.ProveedorId    
                                  WHERE PL.IdSupervisor = @SupervisorId AND PL.IndicadorActivo = 1 AND P.IndicadorActivo <= 3    
  
        SET @cnt = @cnt + 1    
    END;    
        
    SELECT VI.FechaVisita, VI.IdSupervisor, PPTD.IdPlan[IdPlan], PPTD.ItemId[ItemId], VI.proveedorLocalId, PL.NombreComercial, PL.Direccion, PL.Referencia FROM @listaVisitas VI    
    CROSS APPLY (SELECT NombreComercial, Direccion, Referencia FROM SGF_ProveedorLocal PL   
              WHERE PL.ProveedorLocalId = VI.proveedorLocalId) PL    
    OUTER APPLY (SELECT PT.IdPlan, PTD.ItemId FROM SGF_PlanTrabajo PT     
                 CROSS APPLY (SELECT PTD.ItemId FROM SGF_PlanTrabajo_Detalle PTD   
                              WHERE PT.IdPlan = PTD.IdPlan AND   
               PT.IdSupervisor = VI.IdSupervisor AND   
         PT.FechaVisita = VI.FechaVisita AND   
         PTD.ProveedorLocalId = VI.ProveedorLocalId) PTD) PPTD    
END