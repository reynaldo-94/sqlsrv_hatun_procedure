/*--------------------------------------------------------------------------------------                                                                                      
' Nombre          : [dbo].[SGC_SP_Tickets_L]                                                                                                       
' Objetivo        : Obtener datos para Gestion de ticket                                                         
' Creado Por      : REYNALDO CAUCHE                                                                        
' Día de Creación : 08-04-2022                                                                                                   
' Requerimiento   : SGC                                                                                                
' Modificado por  : REYNALDO CAUCHE                                                                         
' Día de Modificación : 6-6-2022                                                                                            
'--------------------------------------------------------------------------------------*/                                  
CREATE PROCEDURE [dbo].[SGC_SP_Tickets_L]              
(@EstadoTicketId int                
 ,@TipoSolicitudId int                  
 ,@Pagina int                                                                                          
 ,@Tamanio int                        
 ,@Success int output)                  
AS                  
BEGIN                  
    set @Success = (select count(*)                  
                    from dbo.SGF_PedidoCambio PEDC                
                    INNER JOIN dbo.SGF_Parametro PARA on PEDC.TipoCambioId = PARA.ParametroId and PARA.DominioId=104                
                    LEFT  JOIN dbo.SGF_ExpedienteCredito EXPCRED on PEDC.ExpedienteCreditoId = EXPCRED.ExpedienteCreditoId                
                    LEFT  JOIN dbo.SGF_Solicitud SOL on SOL.SolicitudId=EXPCRED.SolicitudId                
                    LEFT  JOIN dbo.SGF_Persona PER on EXPCRED.TitularId=PER.PersonaId                
                    LEFT  JOIN dbo.SGF_Local LOC on PEDC.LocalId=LOC.LocalId                
                    LEFT  JOIN dbo.SGF_Zona ZON on ZON.ZonaId=LOC.ZonaId                
                    INNER JOIN dbo.SGF_Parametro EST on EST.ParametroId = isnull(EXPCRED.EstadoProcesoId, 1) and EST.DominioId = 38                
                    INNER JOIN dbo.SGF_USER U on PEDC.UserIdCrea = U.UserId                
                    LEFT  JOIN dbo.SGF_ROL ROL on ROL.RolId= PARA.ValorEntero                  
                    INNER JOIN SGF_Parametro pr2 on PEDC.EstadoPedido = pr2.ParametroId and pr2.DominioId = 127                
                    where (PEDC.EstadoPedido = @EstadoTicketId OR @EstadoTicketId = 0)                 
                    and (PEDC.TipoCambioId = @TipoSolicitudId OR @TipoSolicitudId = 0));                 
                      
    select convert(varchar, PEDC.FechaCrea, 3) as FechaCrea,               
          PARA.NombreCorto as Solicitud,               
          U.Nombres + ' ' + U.ApePaterno + ' ' + U.ApeMaterno as Solicitante,               
          (SELECT STUFF((select distinct ' / ' + ISNULL((case RolDes when 'Reportes' then 'Gerencia' when 'Recursos Humanos' then 'RRHH' else RolDes end), 'Sistemas') from SGF_ROL                     
                         where RolId in (SELECT Result FROM DBO.FN_StrToTable(ISNULL((SELECT X.ValorParam from SGF_Parametro X where X.DominioId = 104 and X.ParametroId = PEDC.TipoCambioId), 1),',')) and                    
                               (CASE WHEN (SELECT COUNT(*) FROM DBO.FN_StrToTable(ISNULL((SELECT X.ValorParam from SGF_Parametro X where X.DominioId = 104 and X.ParametroId = PEDC.TipoCambioId), 1),',')) = 1 and RolId = 1 THEN 1                    
                                     WHEN (SELECT COUNT(*) FROM DBO.FN_StrToTable(ISNULL((SELECT X.ValorParam from SGF_Parametro X where X.DominioId = 104 and X.ParametroId = PEDC.TipoCambioId), 1),',')) > 1 and RolId = 1 THEN 0                    
                                ELSE 1 END) = 1                    
                         FOR xml path('')),                    
           1,                    
           3,                    
           '')) [Responsable],              
          pr2.ParametroId as IdEstado,               
          pr2.NombreLargo as NomEstado,          
          PEDC.ExpedienteCreditoId as IdExpedienteCredito,          
          SOL.SolicitudId as IdSolicitud,          
          PEDC.PedidoCambioId as Id,      
          PEDC.PedidoCambioId,  
          PEDC.TipoCambioId as IdTipoCambio  
    from dbo.SGF_PedidoCambio PEDC                
    INNER JOIN dbo.SGF_Parametro PARA on PEDC.TipoCambioId = PARA.ParametroId and PARA.DominioId=104                
    LEFT  JOIN dbo.SGF_ExpedienteCredito EXPCRED on PEDC.ExpedienteCreditoId = EXPCRED.ExpedienteCreditoId                
    LEFT  JOIN dbo.SGF_Solicitud SOL on SOL.SolicitudId=EXPCRED.SolicitudId                
    LEFT  JOIN dbo.SGF_Persona PER on EXPCRED.TitularId=PER.PersonaId                
    LEFT  JOIN dbo.SGF_Local LOC on PEDC.LocalId=LOC.LocalId                
    LEFT  JOIN dbo.SGF_Zona ZON on ZON.ZonaId=LOC.ZonaId                
    INNER JOIN dbo.SGF_Parametro EST on EST.ParametroId = isnull(EXPCRED.EstadoProcesoId, 1) and EST.DominioId = 38                
    INNER JOIN dbo.SGF_USER U on PEDC.UserIdCrea = U.UserId                
    LEFT  JOIN dbo.SGF_ROL ROL on ROL.RolId= PARA.ValorEntero                  
    INNER JOIN SGF_Parametro pr2 on PEDC.EstadoPedido = pr2.ParametroId and pr2.DominioId = 127                  
    WHERE (PEDC.EstadoPedido = @EstadoTicketId OR @EstadoTicketId = 0)                 
      AND (PEDC.TipoCambioId = @TipoSolicitudId OR @TipoSolicitudId = 0)                
    order by PEDC.FechaCrea desc                  
    OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;               
END