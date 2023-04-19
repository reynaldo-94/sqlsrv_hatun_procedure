/*--------------------------------------------------------------------------------------                                                                                                                                     
' Nombre          : [dbo].[SGC_SP_PortfolioPerson_Por_Documento]                                                                                                                                                     
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE EL DETALLE DE LA PERSONA                                                                                                        
' Creado Por      : CRISTIAN SILVA                                                                                                                   
' Día de Creación :                                                                                                                                               
' Requerimiento   : SGC                                                                                                              
' Cambios  :                                   
  - 18-04-2023 - Reynaldo Cauche - En los if de len documento se removio el or documento = 11 (RUC), ya no es necesario que consulte ruc
'--------------------------------------------------------------------------------------*/                 
            
ALTER PROC [dbo].[SGC_SP_PortfolioPerson_Por_Documento]                                         
(  
@Documento varchar(15)  
)                                                                               
AS                                                                               
BEGIN  
if(len(@Documento) = 8 or len(@Documento)= 12)  
begin  
    select PER.PersonaId,/* DATOS PERSONA */                                                                             
      PER.DocumentoNum,                                                                               
      PER.ApePaterno,                                                                               
      PER.ApeMaterno,                                    
      PER.Nombre,                                                      
      PER.Telefonos,                                           
      PER.Celular,                                                                               
      PER.Celular2 ,                                                                               
      PER.Correo,                                                                           
      ISNULL(PER.CasaPropia,0) CasaPropia,                                                                         
      PER.EstadoCivilId,                                                                       
      ISNULL(PAR1.NombreCorto,'') EstadoCivil,             
      PER.LocalId,            
      LO.Descripcion [NombreLocal],            
      PER.ZonaId,            
      ZO.Descripcion [NombreZona],          
      convert(varchar,PER.FechaCrea,3) [FechaRegistro] ,          
      ISNULL(DADI.DatosDireccionId,0) DatosDireccionId,/*DATOS DIRECCION*/                                                                             
      DADI.TipoDireccionId,                                                                               
      UBI.Nombre Distrito,                                                                               
      DADI.Ubigeo,                                                                               
      DADI.Direccion,                                                                         
      DADI.Referencia,             
      DALAB.NombreEstablecimiento,/* DATOS LABORALES*/                               
      DALAB.Ruc[RucEstablecimiento],                                                                            
      DALAB.TipoTrabajoId,                                                                                     
      PAR2.NombreLargo TipoTrabajo,              
      ISNULL(DALAB.DatosLaboralesId, 0) DatosLaboralesId,                                                                               
      DALAB.FormalidadTrabajoId,                                       
      PAR3.NombreCorto FormalidadTrabajo,                                         
      DALAB.CentroTrabajo,                                                               
      DALAB.FechaIngresoLaboral,                                                                                
      DALAB.Cargo,                                     
      ISNULL(DALAB.GiroId,0) [GiroId],                   
      ISNULL(GI.Nombre, '') [NombreGiro],                    
      DALAB.AntiguedadLaboral,                                                 
      DALAB.DiasPago,                                                 
      DALAB.RUC,                                                                               
      DALAB.IngresoNeto,                                                                               
      DALAB.SustentoIngresoId,               
      PAR4.NombreCorto SustentoIngreso,/*DATOS DIRECCION TRABAJO */                                                                          
      ISNULL(DADITRA.DatosDireccionId,0) DatosDireccionTrabajoId,                                                                                
      DADITRA.TipoDireccionId TipoDireccionTrabajoId,                                                                                 
      UBITRA.Nombre DistritoTrabajo,                                                                                 
      DADITRA.Ubigeo UbigeoTrabajo,                                                                                 
      DADITRA.Direccion DireccionTrabajo,                         
      DADITRA.Referencia ReferenciaTrabajo,          
      EXPE.CanalVentaID,          
      PAR5.NombreLargo [CanalVentaNombre],          
      ISNULL(sda.AdjuntoId,0) AdjuntoId,/*DATOS DE LOS DOCUMENTOS*/                                                                             
      sda.Nombre [NombreArchivo],                                                                             
      sda.Ruta,                                         
      sda.Tamanio,                                                                             
      sda.TipoDocumentoAdjuntoId ,    
      sp6.NombreCorto [TipoDocumentoAdjunto]    
    FROM SGF_Persona PER                   
      left JOIN SGF_ExpedienteCredito EXPE on EXPE.TitularId = PER.PersonaId          
      left join SGF_DocumentoAdjunto sda on sda.ExpedienteCreditoId  = EXPE.ExpedienteCreditoId                                                 
      left join SGF_Parametro sp6 on sp6.ParametroId = sda.TipoDocumentoAdjuntoId and sp6.DominioId = 49            
      LEFT JOIN SGF_Parametro PAR1 on PAR1.ParametroId = PER.EstadoCivilId and PAR1.DominioId=8             
      left JOIN SGF_DatosDireccion DADI on DADI.PersonaId = PER.PersonaId and DADI.TipoDireccionId=1            
      LEFT JOIN SGF_UBIGEO UBI on UBI.CodUbigeo = DADI.Ubigeo              
      LEFT JOIN SGF_DatosLaborales DALAB on DALAB.PersonaId = PER.PersonaId             
      LEFT JOIN SGF_Parametro PAR2 on PAR2.ParametroId = DALAB.TipoTrabajoId and PAR2.DominioId=27            
      LEFT JOIN SGF_Parametro PAR3 on PAR3.ParametroId=DALAB.FormalidadTrabajoId and PAR3.DominioId=13             
      LEFT JOIN SGF_Giro GI on GI.GiroId = DALAB.GiroId            
      LEFT JOIN SGF_DatosDireccion DADITRA on DADITRA.DatosDireccionId = (select top 1 DatosDireccionId from SGF_DatosDireccion WHERE personaId = PER.PersonaId AND tipoDireccionId IN (2,3))              
      LEFT JOIN SGF_UBIGEO UBITRA on UBITRA.CodUbigeo = DADITRA.Ubigeo             
      LEFT JOIN SGF_Parametro PAR4 on PAR4.ParametroId=DALAB.SustentoIngresoId and PAR4.DominioId=32             
      LEFT JOIN SGF_Local LO ON LO.LocalId = PER.LocalId            
      LEFT JOIN SGF_Zona ZO ON ZO.ZonaId = PER.ZonaId           
      LEFT JOIN SGF_Parametro PAR5 on PAR5.ParametroId=EXPE.CanalVentaID and PAR5.DominioId=45              
    where PER.DocumentoNum = @Documento  
end  
END