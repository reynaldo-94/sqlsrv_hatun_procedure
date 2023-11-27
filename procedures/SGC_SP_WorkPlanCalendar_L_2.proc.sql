/*--------------------------------------------------------------------------------------                                                                                                                                                       
' Nombre          : [dbo].[SGC_SP_WorkPlanCalendar_L_2]                                                                                                                                                                       
' Objetivo        : ESTE PROCEDIMIENTO                                                                                                                        
' Creado Por      : REYNALDO CAUCHE                                                                                                                                 
' Día de Creación : 13-9-2023                                                                                                                                                 
' Requerimiento   : SGC                                                                                                                                                                 
' Modificado por  :                                                                                                                                              
cambios           
- develop-rediseño - 13/09/2023 - reynaldo cauche update procedimiento de SGC_SP_WorkPlanCalendar_L.       
- develop-rediseño - 19/09/2023 - cristian silva - se agrego EstadoPlanTrabajo    
- develop-rediseño - 20/09/2023 - francisco lazaro - se modifico logica de campo PlanTrabajoEnabled  
'--------------------------------------------------------------------------------------*/                                   
                              

select top(2000) CreadoAlfinLa,FechaCrea,* from SGF_ExpedienteCredito
where  CreadoAlfinLa = 1 order by expedientecreditoid desc
CREATE PROC [dbo].[SGC_SP_WorkPlanCalendar_L_2]  
(@SupervisorId int = 0,                    
 @Fecha varchar(20))                                                                                                 
AS                                                                                                 
BEGIN  
    DECLARE @FechaDatetime datetime = CAST(@Fecha as datetime)  
 DECLARE @EnabledEstado int = ISNULL((select COUNT(*) from SGF_PlanTrabajo   
                                      where MONTH(FechaVisita) = MONTH(@FechaDatetime) and   
                 YEAR(FechaVisita) = YEAR(@FechaDatetime) and   
              EstadoPlanTrabajo = 2 and   
              IdSupervisor = @SupervisorId), 0)  
  
    SELECT VI.IdSupervisor,    
           ISNULL(PPTD.IdPlan, 0) [IdPlan],    
           PPTD.ItemId[ItemId],    
           VI.proveedorLocalId,    
           PL.NombreComercial,    
           PL.Direccion,    
           PL.Referencia,   
     IIF(@EnabledEstado > 0, 0, IIF(@FechaDatetime < dbo.getDate(), 0, 1)) [PlanTrabajoEnabled],  
           PPTD.EstadoPlanTrabajo    
    FROM (SELECT @Fecha as FechaVisita, PL.IdSupervisor, proveedorLocalId                   
          FROM SGF_ProveedorLocal PL                  
          INNER JOIN SGF_Proveedor P ON PL.ProveedorId = P.ProveedorId                  
          WHERE PL.IdSupervisor = @SupervisorId AND PL.IndicadorActivo = 1 AND P.IndicadorActivo <= 3) as VI              
    CROSS APPLY (SELECT NombreComercial, Direccion, Referencia FROM SGF_ProveedorLocal PL WHERE PL.ProveedorLocalId = VI.proveedorLocalId) PL                  
    OUTER APPLY (SELECT PT.IdPlan, PTD.ItemId, PT.FechaVisita, PT.EstadoPlanTrabajo FROM SGF_PlanTrabajo PT                   
    CROSS APPLY (SELECT PTD.ItemId FROM SGF_PlanTrabajo_Detalle PTD                 
    WHERE PT.IdPlan = PTD.IdPlan AND                 
          PT.IdSupervisor = VI.IdSupervisor AND                 
          PT.FechaVisita = VI.FechaVisita AND                 
          PTD.ProveedorLocalId = VI.ProveedorLocalId) PTD) PPTD              
END 