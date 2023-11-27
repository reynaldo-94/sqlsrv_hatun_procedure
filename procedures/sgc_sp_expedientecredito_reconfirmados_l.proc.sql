 
/*------------------------------------------------------------------------------------                                                              
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Reconfirmados_L]                                                      
' Objetivo        : Este procedure nos permite listar creditos reconfirmados                                                     
' Creado Por      : REYNALDO CAUCHE                                                
' Día de Creación : 06-10-2022                                        
' Requerimiento   : SGC                             
' Cambios:                        
  15/11/2022 - cristian silva -se agrego el campo bancoID                        
  15/11/2022 - cristian silva -se agrego en parametro bancoId                    
  16/11/2022 - cristian silva -se elimino el parametro bancoId                  
  14/12/2022 - Francisco Lazaro - Se agrega campo Prioridad    
  02/02/2023 - Francisco Lazaro - Se valida supervisores activos 
  26/06/2023 - Reynaldo Cauche - Se removio los inner join sgf_zona y SGF_JefeRegional para los roles 52 y 1
'-------------------------------------------------------------------------------------*/         
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Reconfirmados_L                
(@SupervisorId INT = 0,          
 @UserId int = 0,         
 @LocalId int = 0,         
 @EstadoId INT,                  
 @Pagina INT,                  
 @Tamanio INT,                  
 @Success INT OUTPUT)                  
AS                             
BEGIN              
          
 declare @rolid int  = (select top 1 CargoId  from SGF_USER where UserId =  @UserId)         
 DECLARE @EMPLEADOID INT = (SELECT isnull(EmpleadoId ,0) FROM SGF_USER where UserId = @UserId)          
          
         
 if(@rolid = 29)         
  begin          
  SET @Success = (SELECT COUNT(EXPER.ExpedienteCreditoId)                             
  FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId         
  WHERE((EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 )  and (EXPER.Estado = @EstadoId)));                
                  
  SELECT EXPER.IdReconfirmacion [ReconfirmacionId],                                            
   EXPER.ExpedienteCreditoId,                                        
   EXPCRED.IdSupervisor,                                         
   PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno [NombreCompleto],                                                   
   PER.DocumentoNum,                                               
   ISNULL(EXPER.ResultadoGestion, '') [ResultadoGestion],                                        
   EXPER.MarcaContactabilidad,                                        
   ISNULL(PER.Horario, '') [Horario],                                        
   ISNULL(PER.Celular, '') [Celular],                                   
   ISNULL(PER.Celular2, '') [Celular2],                                   
   ISNULL(PER.Telefonos, '') [Telefono],                                   
   ISNULL((DATEDIFF(DAY, EXPCRED.FechaEvaluacion, dbo.getdate())), '') [Dias],                                      
   ISNULL(PER.DiaLlamada, '') [DiaLlamada],                        
   ISNULL(EXPCRED.BancoId, 0) [BancoId],                  
   ISNULL(EXPCRED.Prioridad, '') [Prioridad]                  
  FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId    
  WHERE((EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 )  and (EXPER.Estado = @EstadoId))                    
  ORDER BY Dias DESC              
  OFFSET @Pagina * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY               
 end         
     
 if(@rolid = 2)         
 begin          
         
  SET @Success = (SELECT COUNT(EXPER.ExpedienteCreditoId)               
  FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId         
   inner join SGF_Local lo on lo.ZonaId = EXPCRED.ExpedienteCreditoZonaId         
   inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
   inner join SGF_JefeZona JZ on zo.ZonaId = JZ.ZonaId           
  WHERE JZ.JefeZonaId = @EMPLEADOID          
   and ((EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 )           
   and (EXPER.Estado = @EstadoId) )  );             
                  
  SELECT EXPER.IdReconfirmacion [ReconfirmacionId],                                            
   EXPER.ExpedienteCreditoId,                                        
   EXPCRED.IdSupervisor,                                         
   PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno [NombreCompleto],                                                   
   PER.DocumentoNum,                                               
   ISNULL(EXPER.ResultadoGestion, '') [ResultadoGestion],                                        
   EXPER.MarcaContactabilidad,                                        
   ISNULL(PER.Horario, '') [Horario],                                        
   ISNULL(PER.Celular, '') [Celular],                                   
   ISNULL(PER.Celular2, '') [Celular2],                                   
   ISNULL(PER.Telefonos, '') [Telefono],                                   
   ISNULL((DATEDIFF(DAY, EXPCRED.FechaEvaluacion, dbo.getdate())), '') [Dias],                                      
   ISNULL(PER.DiaLlamada, '') [DiaLlamada],                        
   ISNULL(EXPCRED.BancoId, 0) [BancoId],                  
   ISNULL(EXPCRED.Prioridad, '') [Prioridad]                  
   FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId            
   inner join SGF_Local lo on lo.ZonaId = EXPCRED.ExpedienteCreditoZonaId         
   inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
   inner join SGF_JefeZona JZ on  JZ.ZonaId  = zo.ZonaId      
  WHERE JZ.JefeZonaId = @EMPLEADOID          
   and ((EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId = -1 )          
   and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)         
   and (EXPER.Estado = @EstadoId))                  
   ORDER BY Dias DESC                                
   OFFSET @Pagina * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY               
 end         
         
         
  if(@rolid = 52)         
 begin        
   SET @Success = (SELECT Distinct COUNT(EXPER.ExpedienteCreditoId)                             
   
   FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId         
   
   inner join SGF_Local lo on lo.LocalId = EXPCRED.ExpedienteCreditoLocalId         
  --  inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
  --  inner join SGF_JefeRegional JZ on zo.RegionZonaId = JZ.RegionId
  -- WHERE  JZ.JefeRegionalId = @EMPLEADOID and (EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 ) 

  WHERE  lo.RegionalId = @EMPLEADOID and (EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 ) 
   and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)      and (EXPER.Estado = @EstadoId));                
                  
  SELECT Distinct EXPER.IdReconfirmacion [ReconfirmacionId],                                            
   EXPER.ExpedienteCreditoId,                         
   EXPCRED.IdSupervisor,                                         
   PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno [NombreCompleto],                                                   
   PER.DocumentoNum,                                               
   ISNULL(EXPER.ResultadoGestion, '') [ResultadoGestion],                                        
   EXPER.MarcaContactabilidad,                                        
   ISNULL(PER.Horario, '') [Horario],                                        
   ISNULL(PER.Celular, '') [Celular],                                   
   ISNULL(PER.Celular2, '') [Celular2],                                   
   ISNULL(PER.Telefonos, '') [Telefono],                                   
   ISNULL((DATEDIFF(DAY, EXPCRED.FechaEvaluacion, dbo.getdate())), '') [Dias],                                      
   ISNULL(PER.DiaLlamada, '') [DiaLlamada],                        
   ISNULL(EXPCRED.BancoId, 0) [BancoId],                  
   ISNULL(EXPCRED.Prioridad, '') [Prioridad]                  
   FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId       
   
  --  inner join SGF_Local lo on lo.ZonaId = EXPCRED.ExpedienteCreditoZonaId         
  --  inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
  --  inner join SGF_JefeRegional JZ on zo.RegionZonaId = JZ.RegionId     

  inner join SGF_Local lo on lo.LocalId = EXPCRED.ExpedienteCreditoLocalId         
   
  -- WHERE JZ.JefeRegionalId = @EMPLEADOID          
  WHERE lo.RegionalId = @EMPLEADOID          
   and(EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 )           
   and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)         
   and (EXPER.Estado = @EstadoId)  
   ORDER BY Dias DESC                                
   OFFSET @Pagina * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY       
       
 end         
   
 if(@rolid = 1)    
 begin       
 SET @Success = (SELECT Distinct COUNT(EXPER.ExpedienteCreditoId)                             
  FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId         
   inner join SGF_Local lo on lo.LocalId = EXPCRED.ExpedienteCreditoLocalId         

  --  inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
  --  inner join SGF_JefeRegional JZ on zo.RegionZonaId = JZ.RegionId           
  
  WHERE  (EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 ) and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)      and (EXPER.Estado = @EstadoId));                
                  
  SELECT Distinct EXPER.IdReconfirmacion [ReconfirmacionId],                                            
   EXPER.ExpedienteCreditoId,                                        
   EXPCRED.IdSupervisor,                                         
   PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno [NombreCompleto],                                                   
   PER.DocumentoNum,                                               
   ISNULL(EXPER.ResultadoGestion, '') [ResultadoGestion],                                        
   EXPER.MarcaContactabilidad,                                
   ISNULL(PER.Horario, '') [Horario],                                        
   ISNULL(PER.Celular, '') [Celular],                                   
   ISNULL(PER.Celular2, '') [Celular2],                                   
   ISNULL(PER.Telefonos, '') [Telefono],                                   
   ISNULL((DATEDIFF(DAY, EXPCRED.FechaEvaluacion, dbo.getdate())), '') [Dias],                                      
   ISNULL(PER.DiaLlamada, '') [DiaLlamada],                        
   ISNULL(EXPCRED.BancoId, 0) [BancoId],                  
   ISNULL(EXPCRED.Prioridad, '') [Prioridad]    
   FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId            
   inner join SGF_Local lo on lo.LocalId = EXPCRED.ExpedienteCreditoLocalId         
   
  --  inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
  --  inner join SGF_JefeRegional JZ on zo.RegionZonaId = JZ.RegionId    
    
  WHERE(EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 )           
   and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)         
   and (EXPER.Estado = @EstadoId) 
   ORDER BY Dias DESC                                
   OFFSET @Pagina * @Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY        
 end         
END 