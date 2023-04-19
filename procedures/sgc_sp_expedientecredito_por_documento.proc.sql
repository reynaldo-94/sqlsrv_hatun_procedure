/*--------------------------------------------------------------------------------------                                                                                                      
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Por_Documento]                                                                                                                
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE DATOS DEL CREDITO                                                                   
' Creado Por      :                                                                                     
' Día de Creación :                                                                                                                
' Requerimiento   : SGC    
' Cambios:              
  17/11/2022 - REYNALDO CAUCHE - Se quito el valor DocumentoDuplicado ya que ya no se va a hacer la validacion de no permitir crear mismo dni en el mes             
  18/01/2023 - reynaldo cauche - Se agrego el isnull a los campos diasllamada y horario 
'--------------------------------------------------------------------------------------*/                   
ALTER PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_Por_Documento]                    
(@DocumentoNum varchar(12)) 
as                    
begin                    
    Select ISNULL(EC.ExpedienteCreditoId,0) ExpedienteCreditoId,                          
           ISNULL(S.SolicitudId,0) SolicitudId,                          
           ISNULL(IIF(EC.EnObservacion=1 and EC.EstadoProcesoId=5,15,EC.EstadoProcesoId),0) EstadoProcesoId,                    
           ISNULL(E4.NombreCorto,'') EstadoProceso,                          
           ISNULL(EC.EstadoExpedienteId,0) EstadoExpedienteId,                    
           ISNULL(EC.ExpedienteCreditoZonaId,0) ExpedienteCreditoZonaId,                    
           ISNULL(EC.ExpedienteCreditoLocalId,0) ExpedienteCreditoLocalId,                    
           P.PersonaId,                    
           ISNULL(EV.TipoPersonaId,0) TipoPersonaId,                    
           ISNULL(TP.NombreCorto,'') TipoPersona,                    
           P.DocumentoNum,                    
           ISNULL(UPPER(P.Nombre),'') Nombre,                          
           ISNULL(UPPER(P.ApePaterno),'') ApePaterno,                          
           ISNULL(UPPER(P.ApeMaterno),'') ApeMaterno,                          
           ISNULL(P.Telefonos,'') Telefonos,                    
           ISNULL(P.Celular,'') Celular,                          
           ISNULL(Celular2,'') Celular2,                    
           ISNULL(P.Correo,'') Correo,                    
           ISNULL(P.EstadoCivilId,0) EstadoCivilId,                    
           ISNULL(EEC.NombreCorto,'') EstadoCivil,                          
           --ISNULL(P.ProveedorLocalId,0) ProveedorId,               
           ISNULL(EC.ProveedorId,0) ProveedorId,                
           ISNULL(SPP.IdSupervisor,0) IdSupervisorProveedor,                    
           ISNULL(SPP.NombreComercial,'') RazonSocial,                          
           ISNULL(P.CasaPropia,0) CasaPropia,                    
           ISNULL(P.IdSupervisor,0) IdSupervisor,                    
           ISNULL(SP.ApePaterno + ' ' + SP.ApeMaterno + ' ' + SP.Nombre,'') Supervisor,                    
           ISNULL(DD.DatosDireccionId,0) DatosDireccionId,                    
           DD.TipoDireccionId,                    
           su.Nombre Distrito,                          
           DD.Ubigeo,                          
           DD.Direccion,                          
           DD.Referencia,                          
           ISNULL(DL.DatosLaboralesId,0) DatosLaboralesId,                    
           DL.TipoTrabajoId, --Independienteono                          
           EEC1.NombreCorto TipoTrabajo,                          
           DL.FormalidadTrabajoId,                          
           EEC2.NombreCorto FormalidadTrabajo,                          
           DL.NombreEstablecimiento,                          
           DL.Ruc[RucEstablecimiento],                  
           DL.CentroTrabajo,                    
           DL.FechaIngresoLaboral,                          
           DL.Cargo,                  
           DL.GiroNegocio,                          
           DL.RUC,                          
           DL.IngresoNeto,                      
           DL.SustentoIngresoId,                          
           EEC3.NombreCorto SustentoIngreso,                    
           ISNULL(DDT.DatosDireccionId,0) DatosDireccionTrabajoId,/*DATOS DIRECCIÓN- TRABAJO*/                    
           DDT.TipoDireccionId TipoDireccionTrabajoId,                    
           SUT.Nombre DistritoTrabajo,                    
           DDT.Ubigeo UbigeoTrabajo,                    
           DDT.Direccion DireccionTrabajo,                    
           DDT.Referencia ReferenciaTrabajo,                  
           EC.IdSupervisor IdSupervisorCredito,                
           PR.DocumentoNum DocumentoNumProveedor,         
           ISNULL(P.DiaLlamada,'') AS DiaLlamada,         
           ISNULL(P.Horario, '') AS Horario,     
           P.OrigenId,  
		   IIF(PC.EstadoPedido not in (1, 3) , 1, 0) [IsPedidoCambioAbierto]  
    from SGF_Persona P                    
    LEFT JOIN SGF_ExpedienteCredito EC on P.PersonaId=EC.TitularId and EC.ExpedienteCreditoId = (select MAX(ExpedienteCreditoId) from SGF_ExpedienteCredito where TitularId=P.PersonaId)                    
    LEFT JOIN SGF_Evaluaciones EV on EV.PersonaId=P.PersonaId and case when EC.ExpedienteCreditoId is not null then EC.ExpedienteCreditoId else EV.ExpedienteCreditoId end = EV.ExpedienteCreditoId                    
    LEFT JOIN SGF_Supervisor SP on P.IdSupervisor = SP.IdSupervisor                           
    LEFT JOIN SGF_Solicitud S on S.SolicitudId=EC.SolicitudId                          
    LEFT JOIN SGF_DatosDireccion DD on DD.PersonaId=P.PersonaId                          
    LEFT JOIN SGF_DatosLaborales DL on DL.PersonaId=P.PersonaId                    
    LEFT JOIN SGF_DatosDireccion DDT on DDT.PersonaId = P.PersonaId and case DL.TipoTrabajoId when 1 then 2 when 2 then 3 else 0 end = DDT.TipoDireccionId                    
    LEFT JOIN SGF_Parametro E4 on E4.ParametroId=EC.EstadoProcesoId and E4.DominioId=38                          
    LEFT JOIN SGF_Parametro TP on TP.ParametroId=EV.TipoPersonaId and TP.DominioId=6                    
    LEFT JOIN SGF_Parametro EEC on EEC.ParametroId=P.EstadoCivilId and EEC.DominioId=8                          
    LEFT JOIN SGF_Parametro EEC1 on EEC1.ParametroId=DL.TipoTrabajoId and EEC1.DominioId=27                          
    LEFT JOIN SGF_Parametro EEC2 on EEC2.ParametroId=DL.FormalidadTrabajoId and EEC2.DominioId=13                          
    LEFT JOIN SGF_Parametro EEC3 on EEC3.ParametroId=DL.SustentoIngresoId and EEC3.DominioId=32                          
    LEFT JOIN SGF_UBIGEO SU on su.CodUbigeo = DD.Ubigeo                          
    LEFT JOIN SGF_UBIGEO SUT on SUT.CodUbigeo = DDT.Ubigeo                    
    LEFT JOIN SGF_ProveedorLocal SPP on SPP.ProveedorLocalId = EC.ProveedorId                
    LEFT JOIN SGF_Proveedor PR ON PR.ProveedorId = SPP.ProveedorId  
	LEFT JOIN SGF_PedidoCambio PC ON PC.ExpedientecreditoId = EC.ExpedientecreditoId and PC.PedidoCambioId = (select MAX(PedidoCambioId) from SGF_PedidoCambio where ExpedientecreditoId = EC.ExpedientecreditoId)  
    where P.DocumentoNum=@DocumentoNum              
end 