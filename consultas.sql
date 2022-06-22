select top(10) * from SGF_Solicitud order by solicitudId desc

--tickets
SELECT RegionZonaId, * FROM SGF_PedidoCambio
select * from sgf_parametro where dominioid = 27

select DocumentoNum,* from sgf_persona where PersonaId = 267537
select bancoId,FechaCrea,FechaActua,DispositivoId, * from sgf_Expedientecredito where titularId = 267537
order by expedientecreditoid desc

select top(10) FechaCrea,TitularId, IdOficina, * from sgf_Expedientecredito 
order by expedientecreditoid desc
where bancoId = 11 order by expedientecreditoid desc
select DocumentoNum, EstadoCivilId,Telefonos, * from sgf_persona where personaId in (608459)

select * from sgf_persona where documentonum = '41817048'
select * from sgf_persona where documentonum = '41817048'


select * from sgf_datoslaborales where personaid = 267537

-- Oficina son las agencia
select * from sgf_oficina where agenciaId = 93
select * from sgf_oficina_ubigeo

-- Agencias son las zonas
select * from sgf_agencia


select * from sgf_datosdireccion where personaid = 267537

select * from sgf_agencia where bancoId = 11
select * from sgf_oficina where agenciaId = 215
select * from sgf_oficina_ubigeo where idAgencia = 215


select * from sgb_banco

599290
378606
608461
608454
608453
608449
608448
212761
212761
608444

707364
707358

select top(10) titularId,BancoId,FechaCrea, * from sgf_expedientecredito order by expedientecreditoid desc
select * from sgf_persona where PersonaId = 608462
select * from SGF_DatosDireccion where PersonaId = 608462

SELECT * FROM SGF_OFICINA
select * from sgf_oficina_ubigeo
select * from sgb_banco

SELECT * 
FROM sgf_oficina_ubigeo ou
INNER JOIN SGF_OFICINA ofc on ou.IdOficina = ofc.IdOficina

select tipoCredito,bancoId,FechaCrea, * from sgf_expedientecredito where bancoId = 11 and tipoCredito = '' order by expedientecreditoid desc

select EstadoProcesoId from sgf_expedientecredito where tipoCredito = '' 
group by EstadoProcesoId
order by expedientecreditoid desc

select tipoCredito, * from sgf_expedientecredito where expedientecreditoid = 707267

select FechaCrea,DispositivoId, CanalVentaId, * from sgf_expedientecredito where estadoProcesoId = 1 order by expedientecreditoid desc

select * from s


select * from 

select top(10) * from sgf_expedientecredito order by expedientecreditoid desc
select * from sgf_persona where personaId = 608471

select * from sgf_oficina_ubigeo where codUbigeo = 150135

select bancoId,solicitudid,idoficina,FechaActua, * from sgf_Expedientecredito where expedientecreditoid = 707332
select bancoId,idoficina, * from sgf_solicitud where solicitudid = 382038

select * from sgf_canal
-- SCRIPT DE BANCOS CON 0 CMABIAR , SE MODIFICO EL PROCEDIMIENTO, DERIVE E INSERT DETAIL, TAMBIEN CREAR TARJETAS -----
select us.CargoId, ex.canalVentaId, ex.FechaCrea,ex.FechaActua,ex.UserIdCrea,ex.BancoId,ex.DispositivoId,ex.EstadoProcesoId,ex.TipoCredito,ex.FechaProspecto,ex.FechaNocalifica,ex.SolicitudId, * 
from sgf_expedientecredito ex
inner join sgf_user us on ex.UserIdCrea = us.UserId
-- inner join sgf_persona pr on ex.titularId = pr.PersonaId
where ex.bancoId = 0 and ex.userIdCrea != 0
order by ex.expedientecreditoid desc

select emailempresa,CargoId, * from sgf_user where UserId in (2950,12008,3597,4096,3171)

select * from sgf_rol where rolId in (29,11)

select canalVentaId
from sgf_expedientecredito
where bancoId = 0
group by canalVentaId

select DispositivoId, EstadoProcesoId,FechaCrea,BancoId, categoriaId,TipoCredito, * 
from sgf_expedientecredito
where estadoProcesoId = 1zz
order by ExpedienteCreditoId DESC

select * from sgf_persona where DocumentoNum = '25711409's

select top(40) DispositivoId, EstadoProcesoId,FechaCrea,BancoId,categoriaId,TipoCredito, * 
from sgf_expedientecredito
where estadoProcesoId = 2
order by ExpedienteCreditoId DESC

select * from sgf_persona where personaId in (537538,255837,714521,303196,679346,509308,739267,452257,780209)
select * from sgf_persona where personaId in (780738, 780737, 780736, 780735, 780732, 780731, 714180, 780729, 780725)


select top(10) * from sgf_persona where personaId =780033 order by personaId desc

select top(10) * from SGF_DatosLaborales order by personaId desc
select top(2)  FechaCrea,FechaActua,BancoId,DispositivoId, EstadoProcesoId,TipoCredito,FechaProspecto,FechaNocalifica,SolicitudId, * from sgf_expedientecredito where bancoId = 11
order by expedientecreditoid desc
select top(10) UserIdCrea,UserIdActua, FechaCrea,FechaActua,BancoId,DispositivoId, EstadoProcesoId,IsBancarizado,TipoCredito, * from sgf_expedientecredito 
-- where BancoId = 0
order by expedientecreditoid desc

select * from SGF_ExpedienteCredito

select bancoId, * from sgf_expedientecredito where expedientecreditoid = 707329

declare @search varchar(50)
SET @search = 'SGF_ExpedienteCredito'

SELECT 
ROUTINE_NAME
,ROUTINE_DEFINITION
FROM 
INFORMATION_SCHEMA.ROUTINES
WHERE 
ROUTINE_DEFINITION LIKE '%' + @search + '%'
AND ROUTINE_TYPE ='PROCEDURE'
ORDER BY
ROUTINE_NAME

select * from sgf_solicitud where 

select top(10) ex.expedientecreditoid, pr.PersonaId,
case when ofu.IdDerivacion is null then 0 else 1 end  as HabilitarSurgir
from sgf_expedientecredito ex
inner join sgf_persona pr on ex.titularId = pr.personaId
inner join SGF_DatosDireccion dd on pr.PersonaId = dd.personaId
left join sgf_oficina_ubigeo ofu on dd.Ubigeo = ofu.CodUbigeo
where ex.BancoId = 3 
order by expedientecreditoid desc

EXEC SGC_SP_ExpedienteCredito_Por_Id 707364

select bancoId,FechaCrea,DispositivoId,FechaActua, * from sgf_expedientecredito where titularid = 267537

select * from sgf_Evaluaciones where expedientecreditoId = 921560

update sgf_Expedientecredito set estadoProcesoId = 2 where expedientecreditoId = 707355

select emailempresa, * from sgf_user where emailempresa like '%sco%'

       select * from sgf_ubigeo where nombre like '%huachip%'
       select bancoId, * from sgf_expedientecredito where bancoId = 11
update sgf_expedientecredito set bancoId = 11  where bancoid = 8
select * from sgb_banco

select EstadoProcesoId, * from sgf_expedientecredito where expedientecreditoid = 906176

select *from sgf_solicitud limit 5

update sgf_expedientecredito set FechaDescarga = null where expedientecreditoid = 707220

select * from sgf_ubigeo where codprov = '01' and coddpto = 07

select * from sgf_ubigeo where codprov = '01' and coddpto = 15
order by nombre asc

select * from sgb_banco
update sgb_banco set bancoId = 11  where bancoid = 8

select solicitudid, * from sgf_expedientecredito where ExpedienteCreditoId = 903562;

select * from SGF_Evaluaciones where ExpedienteCreditoId = 903562;

select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 903562;

update sgf_expedientecredito set EstadoProcesoId = 12 where ExpedienteCreditoId = 775923

select * from sgf_solicitud

select * from sgb_banco
select * from sgf_user where cargoId = 27

select * from sgf_AsistenteConvenio

update sgf_AsistenteConvenio set bancoId = 11  where bancoid = 8


Select DIST.CodUbigeo [Id],                                                              
                PROV.Nombre + '-' + DIST.Nombre [Name], dist.codprov, dist.coddpto                                                       
         From SGF_UBIGEO DIST                                                              
         OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                              
                      WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV                                                             
         Where DIST.CodDpto<>00 and DIST.CodProv<>00 and DIST.CodDist<>00 and PROV.Nombre like '%lima%'

SP_hELPTEXT sgc_token

SELECT BancoId, * FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = 707333

select * from sgb_banco

select top(10) FechaCrea, FechaAtendio, FechaActua, EstadoPedido, * from SGF_PedidoCambio
where estadopedido = 2

select  TOP(10) Horario,DiaLlamada, * from sgf_persona order by personaid desc


select top(10) BancoId, * from SGF_ExpedienteCredito
order by ExpedienteCreditoId desc

select titularId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707183
select Horario,DiaLlamada, * from sgf_persona where personaid = 598372
select  * from SGF_DatosLaborales where personaid = 598372
update sgf_persona set DiaLlamada = '1,3' where personaId = 607065

update sgf_persona set Horario = ''

-- Responsable id vinculado con userId
ALTER TABLE SGF_PedidoCambio
ADD ResponsableId int(50) not null

responsableid, pasoid, isAtendio
id, id, 0

-- Problemas de Salud : RRHH va a responsable Id

SELECT * FROM SGF_PEDIDODETALLE

select EstadoPedido from SGF_PedidoCambio
group by EstadoPedido

select * from SGF_dominio where dominioid = 

select convert(varchar, pc.FechaCrea, 5) as FechaCrea, pr1.NombreCorto as Solicitud, rz.Nombre as Solicitante, 'Operaciones' as Responsable, pr2.ParametroId as IdEstado, pr2.NombreLargo as NomEstado
from SGF_PedidoCambio pc
inner join SGF_Parametro pr1 on pc.TipoCambioId = pr1.ParametroId and pr1.DominioId = 52  and pr1.ParametroId = 1
inner join SGF_Parametro pr2 on pc.EstadoPedido = pr2.ParametroId and pr2.DominioId = 127
inner join SGF_JefeRegional rz ON pc.RegionZonaId = rz.RegionId
where pr.DominioId = 52  and pr.ParametroId = 1

SELECT * FROM sgf_regionzona
SELECT * FROM SGF_JefeRegional
select *from sgf_user where userod = 

select * from sgf_user where useridcrea = 40

select * from SGF_Parametro where DominioId = 52

update SGF_Parametro set IndicadorActivo = 1 where DominioId = 52 and ParametroId = 1

SELECT * FROM SGF_dominio where nombre like '%pedido%'

select * from SGF_dominio where DominioId = 52
select * from sgf_param

select JefeZonaId from SGF_JefeZona where zonaid = 1

SP_HELPTEXT sp_get_list_master


select * from 