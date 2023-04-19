/*--------------------------------------------------------------------------------------                                                                                                                                  
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Por_Id]                                                                                                                                                  
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE EL DETALLE DEL CREDITO POR ID                                                                                                      
' Creado Por      :                                                                                                                 
' Día de Creación :                                                                                                                                            
' Requerimiento   : SGC                                                                                                                                            
' Modificado por  : REYNALDO CAUCHE                                                                                                                           
' Día de Modificación : 20-04-2022                        
cambios:                     
- 07-09-2022 - cristian silva - linea 134 y 96 - sec.IdSupervisor  que se trae de sgf_expedientecredito                   
- 23-11-2022 - Reynaldo Cauche - Se agregaron CanalventaId,UserIdCrea, etc para el crear operacion desde el enviar a rechazado                
- 28-11-2022 - cristian silva - se agrego el campo NombreGiro              
- 05-12-2022 - Reynaldo Cauche - Se agrego el campo Prioridad              
- 05-01-2023 - cristian silva - se agrego el campo UsuarioCreacion            
- 18/01/2023 - reynaldo cauche - Se agrego el isnull a los campos diasllamada y horario       
- 22-02-2023 - cristian silva - add celular Supervisor     
- 08-03-2023 - Reynaldo Cauche - Se agrego el campo FechaACtivado  
- 21-03-2023 - Reynaldo Cauche - Se agrego el campo PubliAPDP 
'--------------------------------------------------------------------------------------*/                                                                             
                                                                      
CREATE PROC [dbo].[SGC_SP_ExpedienteCredito_Por_Id]                                      
(@Id int)                                                                            
as                                                                            
BEGIN 
 
  select sec.ExpedienteCreditoId ,/*DATOS DEL EXPEDIENTE - GENERAL*/                                                                            
  IIF(sec.EnObservacion = 1 and sec.EstadoProcesoId=5,15,sec.EstadoProcesoId) EstadoProcesoId,                                                                            
  sec.EstadoExpedienteId,                                        
  ISNULL(dbo.SGF_FN_ExpEstadoAnterior(775923), 0) [EstadoProcesoIdAnterior],                                        
  sp3.NombreCorto EstadoProceso,                                                                             
  sec.ExpedienteCreditoZonaId,                                                                            
  sec.ExpedienteCreditoLocalId,                                                                            
  ISNULL(sec.Obra,' ')  Obra,                                                                             
  sab.Nombres as Analista,/*DATOS DEL EXPEDIENTE - INFORMACIÓN*/                                                                            
  isnull(sab.IdAsesor,0) IdAsesor,                                                                            
  sab.Correo CorreoAsesor,                                                                            
  sab.Codigo ,                                                                            
  sab.Telefonos TlfAsesor,                                                                          
  ISNULL(sa.Nombre,'') Ado,      
  ISNULL(sa.AdvId,0) AdoId,                   
  ISNULL(sa2.Descripcion,'') Agencia,                                              
  ss.AgenciaId,                                        
  ss.IdOficina,               
  ss.TipoproductoId,                                                                         
  ISNULL(so.Nombre,'') Oficina,                                                                    
  se.TipoPersonaId,/*DATOS DE LOS INVOLUCRADOS - PERSONALES*/                                               
  se.ResultadoId, /*RESULTADO EVALUACION - PERSONALES*/                                                                 
  sp4.NombreCorto TipoPersona,                   
  se.PersonaId,                                                                            
  sp.DocumentoNum,                                                                            
  sp.ApePaterno,                                                                            
  sp.ApeMaterno,                                 
  sp.Nombre,                                                   
  sp.Telefonos,                                         
  sp.Celular,                                                                            
  sp.Celular2 ,                                                                            
  sp.Correo,                                                                        
  ISNULL(sp.CasaPropia,0) CasaPropia,                                                                      
  sp.EstadoCivilId,/*DATOS DE LOS INVOLUCRADOS - ESTADO CIVIL*/                                                                            
  ISNULL(sp2.NombreCorto,'') EstadoCivil,                                                                            
  ISNULL(sdd.DatosDireccionId,0) DatosDireccionId,                                                                            
  sdd.TipoDireccionId,                                                                            
  dep.Nombre+'/'+prov.Nombre+'/'+su2.Nombre Distrito,                                                                            
  sdd.Ubigeo,                                                                            
  sdd.Direccion,/*DATOS DE LOS INVOLUCRADOS - DIRECCIÓN*/                                                                            
  sdd.Referencia,                                                                            
  sdl.NombreEstablecimiento,/*DATOS DE LOS INVOLUCRADOS - DATOS LABORALES*/                                
  sdl.Ruc[RucEstablecimiento],                                                                         
  sdl.TipoTrabajoId,                                                                        
  --sp8.NombreCorto TipoTrabajo,                   
  sp8.NombreLargo TipoTrabajo,                  
  ISNULL(sdl.DatosLaboralesId, 0) DatosLaboralesId,                                                                            
  sdl.FormalidadTrabajoId,                                                                            
  sp9.NombreCorto FormalidadTrabajo,                                                                            
  sdl.CentroTrabajo,                                                                            
  sdl.FechaIngresoLaboral,                                                                             
  sdl.Cargo,                                                                            
  ISNULL(sdl.GiroId,0) [GiroId],                
  ISNULL(sg.Nombre, '') [NombreGiro],               
  sdl.AntiguedadLaboral,                                              
  sdl.DiasPago,                                              
  sdl.RUC,                                                                            
  sdl.IngresoNeto,               
  sdl.SustentoIngresoId,                                                                            
  sp10.NombreCorto SustentoIngreso,                                                                       
  ISNULL(sddt.DatosDireccionId,0) DatosDireccionTrabajoId,/*DATOS DIRECCIÓN- TRABAJO*/                                                                            
  sddt.TipoDireccionId TipoDireccionTrabajoId,                       
  dept.Nombre+'/'+provt.Nombre+'/'+sut2.Nombre DistritoTrabajo,                                                                            
  sddt.Ubigeo UbigeoTrabajo,                                                           
  sddt.Direccion DireccionTrabajo,                    
  sddt.Referencia ReferenciaTrabajo,                                                                            
  ISNULL(sda.AdjuntoId,0) AdjuntoId,/*DATOS DE LOS DOCUMENTOS*/                                                                            
  sda.Nombre NombreArchivo,                                                                            
  sda.Ruta,                                        
  sda.Tamanio,                                                                            
  sda.TipoDocumentoAdjuntoId,                                                                        
  sp6.NombreCorto TipoDocumentoAdjunto,                                                                            
  secd.ItemId,/*DATOS DEL DETALLE DEL EXPEDIENTE*/                                                                            
  sp7.NombreLargo[Proceso],                                             
  su.Nombres+' '+su.ApePaterno+' '+su.ApeMaterno [Usuario],                                                                            
  secd.Observacion,                                                                       
  secd.DiaAgenda,                                   
  secd.Fecha,                                                         
  sp5.ProveedorLocalId [ProveedorId] ,/*DATOS DEL PROVEEDOR*/                                                                            
  ISNULL(sp5.NombreComercial,'') RazonSocial,                                                          
  ISNULL(ss2.IdSupervisor,0) IdSupervisor,                                                                
  ISNULL(ss2.Nombre + ' ' + ss2.ApePaterno + ' ' + ss2.ApeMaterno,'') Supervisor,/*DATOS DEL SUPERVISOR*/           
  isnull(DL.Celular,'') [CelularSupervisor],         
  ISNULL(sec.SolicitudId ,0) SolicitudId,/*DATOS DE LA SOLICITUD*/                                                                            
  ss.MontoMaterialPro,                                                                            
  ss.MontoEfectivoPro,                                                                            
  ss.MontoEfectivoApro,                                            
  ss.MontoMaterialApro,                                                                    
  lc.Descripcion LocalNombre,                                      
  sp11.NombreLargo CanalVentaNombre,                                  
  sec.BancoId,                            
  sec.TitularId PersonaIdExpCredito,                                  
  (SELECT count(ExpedienteCreditoId) FROM SGF_ExpedienteCredito where TitularId = sec.TitularId) ContadorPersona,                           
  case when ofu.IdDerivacion is null then 0 else 1 end as HabilitarSurgir ,                          
  ISNULL(sp.DiaLlamada, '') as DiaLlamada,                           
  ISNULL(sp.Horario, '') as Horario,                       
  sp.OrigenId,                   
  sec.CanalVentaID,                   
  sec.UserIdCrea,                   
  1 as DispositivoId,                   
  sp.APDP,                   
  sp.IpAPDP,                   
  sp.FechaAPDP,                   
  sp.NavegadorAPDP,                   
  sp.ModeloDispositivoAPDP,              
  sec.Prioridad,            
  usa.Nombres+' '+ usa.ApePaterno+' '+ usa.ApeMaterno [UsuarioCreacion],  
  convert(varchar, sec.FechaActivado, 103) [FechaActivado], 
  sp.PubliAPDP    
  FROM SGF_ExpedienteCredito sec               
 INNER join SGF_Evaluaciones se on se.ExpedienteCreditoId = sec.ExpedienteCreditoId               
 INNER join SGF_Persona sp on sp.PersonaId = se.PersonaId               
 INNER join SGF_DatosDireccion sdd on sdd.PersonaId = sp.PersonaId and sdd.TipoDireccionId=1               
 left join SGF_DatosLaborales sdl on sdl.PersonaId = sp.PersonaId             left join SGF_DatosDireccion sddt on sddt.DatosDireccionId = (select top 1 DatosDireccionId from SGF_DatosDireccion WHERE personaId = sp.PersonaId AND tipoDireccionId IN (2,3))
  
  
   
               
 left join SGF_Parametro sp2 on sp2.ParametroId = sp.EstadoCivilId and sp2.DominioId=8               
 left join SGF_Parametro sp3 on sp3.ParametroId = sec.EstadoProcesoId and sp3.DominioId=38                                                                              
 left join SGF_Parametro sp4 on sp4.ParametroId = se.TipoPersonaId and sp4.DominioId=6                                                         
 left join SGF_ProveedorLocal sp5 on sp5.ProveedorLocalId = sec.ProveedorId                          
 left join SGF_AsesorBanco sab on sab.IdAsesor = sec.IdAsesorBanco                                                                             
 left join SGF_DocumentoAdjunto sda on sda.ExpedienteCreditoId  = sec.ExpedienteCreditoId                                                
 left join SGF_Parametro sp6 on sp6.ParametroId = sda.TipoDocumentoAdjuntoId and sp6.DominioId = 49                                                                            
 left join SGF_ExpedienteCreditoDetalle secd on secd.ExpedienteCreditoId = sec.ExpedienteCreditoId                                
 left join SGF_Parametro sp7 on sp7.ParametroId=secd.ProcesoId and sp7.DominioId=38                            
 left join SGF_USER su on su.UserId = secd.UsuarioId              
 left join SGF_USER usa on usa.UserId = sec.UserIdCrea            
 left join SGF_Parametro sp8 on sp8.ParametroId = sdl.TipoTrabajoId and sp8.DominioId=27                
 left join SGF_Parametro sp9 on sp9.ParametroId=sdl.FormalidadTrabajoId and sp9.DominioId=13                                                                           
 left join SGF_Parametro sp10 on sp10.ParametroId=sdl.SustentoIngresoId and sp10.DominioId=32               
 left join SGF_Giro sg on sg.GiroId = sdl.GiroId               
 left join SGF_Solicitud ss on ss.SolicitudId  = sec.SolicitudId                                              
 left join SGF_UBIGEO su2 on su2.CodUbigeo = sdd.Ubigeo      
    
 left join SGF_UBIGEO dep on dep.CodUbigeo = su2.CodDpto+'0000'     
 left join SGF_UBIGEO prov on prov.CodUbigeo =  su2.CodDpto+su2.CodProv+'00'   
   
 left join SGF_UBIGEO sut2 on sut2.CodUbigeo = sddt.Ubigeo        
    
 left join SGF_UBIGEO dept on dept.CodUbigeo = sut2.CodDpto+'0000'     
 left join SGF_UBIGEO provt on provt.CodUbigeo =  sut2.CodDpto+sut2.CodProv+'00'   
   
 left JOIN SGF_Supervisor ss2 on ss2.IdSupervisor = sec.IdSupervisor       
 OUTER APPLY (select distinct top 1 EmpleadoId, Celular,CargoId                                                                              
                       from SGF_USER                                                                            
                       where EmpleadoId = ss2.IdSupervisor  and CargoId = 29                                                                         
                       group by EmpleadoId,Celular,CargoId                                                                             
                       order by EmpleadoId,Celular,CargoId desc)  DL          
 left join SGF_ADV sa on sec.AdvId = sa.AdvId                                                                            
 left join SGF_Agencia sa2 on sa2.AgenciaId = ss.AgenciaId                                                                                  
 left join SGF_Oficina so on sa2.AgenciaId  = so.AgenciaId and ss.IdOficina = so.IdOficina                 
 LEFT JOIN SGF_Local LC ON LC.LocalId = sec.ExpedienteCreditoLocalId                                      
 left join SGF_Parametro sp11 on sp11.ParametroId=sec.CanalVentaID and sp11.DominioId=45                           
 left join SGF_Oficina_Ubigeo ofu on sdd.Ubigeo = ofu.CodUbigeo                              
 where sec.ExpedienteCreditoId = @Id 
 
end 