SELECT TOP(10) IdSupervisor,ProveedorId, * FROM SGF_ExpedienteCredito 
ORDER BY ExpedienteCreditoId DESC

select FechaDescarga, *
from sgf_expedientecredito
where ExpedienteCreditoId IN (707256,707515,707390)

UPDATE sgf_expedientecredito
SET FechaDescarga = null
where ExpedienteCreditoId IN (707256,707515,707390)

SP_HELPTEXT SGC_SP_ExpedienteCredito_L
EXEC SGC_SP_ProveedorLocal_G 297,''

EXEC 

SELECT       
   PL.IdSupervisor, SP.AdvId, SP.ZonaId,SP.LocalId   
 FROM SGF_ProveedorLocal PL   
 INNER JOIN SGF_Supervisor SP ON SP.IdSupervisor = PL.IdSupervisor    
 WHERE ProveedorLocalId=297  

 select * from SGF_ProveedorLocal where ProveedorLocalId = 297    

 SP_HELPTEXT SGC_SP_Reconfirmations_File_Upload_G

 select * from SGF_ExpedienteCredito_Reconfirmacion

 select TitularId, * from sgf_expedientecredito where ExpedienteCreditoId = 701968

 select FechaReconfirmacion,FechaCrea,Estado, * from SGF_ExpedienteCredito_Reconfirmacion where ExpedienteCreditoId = 701968

 update SGF_ExpedienteCredito_Reconfirmacion
 set FechaReconfirmacion = dbo.getDate(),Estado = 2
  where ExpedienteCreditoId = 701968

 update SGF_ExpedienteCredito_Reconfirmacion
 set FechaReconfirmacion = NULL,Estado = 1
  where ExpedienteCreditoId = 707478

  SP_HELPTEXT SGC_SP_Reconfirmations_File_Upload_G


update SGF_ExpedienteCredito_Reconfirmacion 
set 

select top(10) * from SGF_ExpedienteCredito
where EstadoProcesoId = 5
 order by ExpedienteCreditoId desc

select dbo.FN_Aniadir_DiasLaborables('2022-09-26 09:51:28.027', 5)

exec 

DELETE FROM SGF_ExpedienteCredito_Reconfirmacion WHERE ExpedienteCreditoId = 701968 and Lote = 11

select exc.EstadoExpedienteId, exr.Estado,exc.ExpedienteCreditoId,exc.EstadoProcesoId,max(exr.FechaCrea) as FechaCrea ,exr.Interesado,max(exr.Lote) as Lote
FROM SGF_ExpedienteCredito exc               
INNER JOIN SGF_Evaluaciones eva ON exc.ExpedienteCreditoId = eva.ExpedienteCreditoId               
LEFT JOIN SGF_ExpedienteCredito_Reconfirmacion exr ON exc.ExpedienteCreditoId = exr.ExpedienteCreditoId               
WHERE exc.ExpedienteCreditoId in (707601,701968,631629)            
GROUP BY exc.EstadoExpedienteId, exr.Estado,exc.ExpedienteCreditoId,exc.EstadoProcesoId,exr.Interesado  
HAVING exr.Lote
order by exr.FechaCrea DESC

select exc.ExpedienteCreditoId,max(exr.FechaCrea),max(exr.Lote)
FROM SGF_ExpedienteCredito exc               
INNER JOIN SGF_Evaluaciones eva ON exc.ExpedienteCreditoId = eva.ExpedienteCreditoId               
LEFT JOIN SGF_ExpedienteCredito_Reconfirmacion exr ON exc.ExpedienteCreditoId = exr.ExpedienteCreditoId               
WHERE exc.ExpedienteCreditoId in (707601,701968,631629)      
GROUP BY exc.ExpedienteCreditoId


select pr.DocumentoNum, ex.ExpedienteCreditoId,ex.UserIdCrea,ex.IdSupervisor,pr.IdSupervisor,us.Nombres, us.CargoId,rl.RolDes,ex.ProveedorId, pl.NombreComercial,pl.IdSupervisor,sp.Nombre, ex.FechaCrea
from sgf_expedientecredito ex
INNER JOIN SGF_Persona pr ON ex.TitularId = pr.PersonaId
LEFT JOIN SGF_USER us ON ex.UserIdCrea = us.UserId
LEFT JOIN SGF_Rol rl ON us.CargoId = rl.RolId
LEFT JOIN SGF_ProveedorLocal pl ON ex.ProveedorId = pl.ProveedorLocalId
LEFT JOIN SGF_Supervisor sp ON pl.IdSupervisor = sp.IdSupervisor
where pr.DocumentoNum IN
('09893686','08676042','25796733','10480046','44566664','72564557','47649181') 
and ex.IdSupervisor = 1137
order by pr.DocumentoNum asc

select * from SGF_Persona where DocumentoNum = '06003405'

9893686
8676042
25796733
10480046
44566664
72564557
47649181

select AdvId, IdSupervisor,ProveedorId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 995070

select IdSupervisor, * from SGF_ProveedorLocal where ProveedorLocalId = 1673



SELECT DispositivoId, CanalVentaId,UserIdCrea,FechaCrea, * FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = 959193

select UserIdCrea,FechaCrea,CanalVentaID,ProveedorId, * from SGF_ExpedienteCredito where CanalVentaID = 12 ORDER BY ExpedienteCreditoId DESC



-- UPDATE sgf_expedientecredito
-- SET IdSupervisor = 1137
-- where ExpedienteCreditoId IN (
-- 996642,995070,997363,996959,998322,999633,998746)

-- 996642,995070,997363,996959,998322,999633,998746


-- UPDATE sgf_expedientecredito
-- SET IdSupervisor = 1260
-- where ExpedienteCreditoId = 995049

995049

SP_HELPTEXT SGC_SP_Reconfirmacion_Banco_L_Reporte  

SELECT * FROM SGF_USER WHERE EmailEmpresa like '%soporte%'

select TitularId, *
from SGF_ExpedienteCredito
where ExpedienteCreditoId = 1000799

select Nombre, * from SGF_Persona where PersonaId IN (693941,830421)

select * from SGF_DatosLaborales where PersonaId = 693941

select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 1000799

SP_HELPTEXT SGC_SP_Proveedor_Local_U

SELECT * FROM SGF_Evaluaciones where ExpedienteCreditoId = 1000799

-- UPDATE SGF_Persona
-- SET Nombre = 'MARIA', ApePaterno = 'QUEZADA', ApeMaterno = 'MORALES', DocumentoNum = '46512498'
-- WHERE PersonaId = 830421

-- UPDATE SGF_ExpedienteCreditoDetalle
-- SET Observacion = 'SE AGREGÓ CÓNYUGE: YEIMI LISBETH RIVERA CONDOR'
-- WHERE ExpedienteCreditoId = 1000799 AND ItemId = 3

-- UPDATE SGF_Evaluaciones 
-- SET PersonaId = 782038
-- WHERE ExpedienteCreditoId = 1000799 AND PersonaId = 830421

select BancoId, FechaCrea,FechaActua,CanalVentaID,DispositivoId,EstadoProcesoId, 
* from sgf_expedientecredito where TitularId = 798530

-- 732 con Solicitud
-- 708 con banco id y solicidtud
-- 

select ex.SolicitudId, ex.FechaCrea,ex.FechaActua,ex.CanalVentaID,ex.DispositivoId,ex.EstadoProcesoId, sl.BancoId
from SGF_ExpedienteCredito as ex
inner join SGF_Solicitud as sl on ex.SolicitudId = sl.SolicitudId
where ex.BancoId = 0 and ex.SolicitudId <> 0 and sl.BancoId = 0
order by ex.expedienteCreditoId desc

select BancoId, * from SGF_ExpedienteCredito where BancoId = 0 order by ExpedienteCreditoId desc

update SGF_ExpedienteCredito 
set BancoId = 11
where SolicitudId IN (260081,259541,258239,257708,256223)

select BancoId, * from SGF_ExpedienteCredito where SolicitudId in (260081,259541,258239,257708,256223)

select * from SGF_Solicitud where SolicitudId = 264859

-- 6099

update SGF_ExpedienteCredito 
set BancoId = 3
where ExpedienteCreditoId in (
  SELECT ExpedienteCreditoId from SGF_ExpedienteCredito where BancoId = 0
)


select * from SGF_Persona where DocumentoNum = '40261109'

select * from SGF_Evaluaciones where PersonaId = 782038

select TitularId,CanalVentaID,FechaCrea, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 1000394
select TipoPersonaId,FechaCrea, * from SGF_Persona where PersonaId = 109448
select * from SGF_DatosDireccion where PersonaId = 109448

select * from sgf_dominio where Nombre like '%Canal%'
select * from SGF_Parametro where DominioId = 45

SP_HELPTEXT SGC_TOKEN

select * from sgf_rol_pagina

select * from sgf_pagina

select * from sgf_rol 

select * from SGF_Supervisor
select * from SGF_Local


select lc.NombreCorto, lc.Descripcion, * 
from SGF_Supervisor as sp
inner join sgf_local as lc on sp.LocalId = lc.LocalId

select * from 

SP_HELPTEXT SGF_SP_Reconfirmacion_I_Movil

SELECT * FROM SGF_ExpedienteCredito_Reconfirmacion WHERE ESTADO = 1 ORDER BY ExpedienteCreditoId DESC

SELECT EXPER.ExpedienteCreditoId, EXPCRED.IdSupervisor
FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                     
INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId           
INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId                       
WHERE EXPER.Estado = 1

EXEC SGC_SP_ExpedienteCredito_Reconfirmados_L 1209,1,0,20,0

select top(100) diaLlamada, * from SGF_Persona order by PersonaId desc

select * from SGF_ExpedienteCredito_Reconfirmacion where IdReconfirmacion = 3358