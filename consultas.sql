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
select top(100) CasaPropia, * from sgf_persona order by PersonaId desc

select titularid, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707703

select top(1000) AntiguedadLaboral,CasaPropia, * from SGF_DatosLaborales 
--where Personaid = 606967
order by DatosLaboralesId desc

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

select * from sgf_dominio where Nombre like '%Rechazo%'
select * from SGF_Rechazo where DominioId = 26

SP_HELPTEXT SGC_TOKEN

select * from sgf_rol_pagina where RoleId = 48

insert into SGF_Rol_Pagina (RoleId, PageId) values (48,30)

select * from sgf_pagina -- 48 Operaciones 
insert into sgf_pagina(Nombre,Descripcion,ApplicationId,[Level],[Url],ParentPageId,Icon,Estado,[Order],OrderView)
values ('Carga Respuesta de IF',null,1,2,'/dashboard/carga-respuesta-if',1,'developer_mode',1,6,2)

select * from sgf_pagina where ParentPageId = 1

select * from sgf_rol where RolDes like '%Operac%'

select * from SGF_Supervisor where IdSupervisor = 1205
select * from SGF_Local

select EmailEmpresa, * from sgf_user where EmpleadoId = 1205

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

SP_HELPTEXT sp_get_list_master



update sgf_expedientecredito
set FechaDescarga = null
where ExpedienteCreditoId = 415354

select * from sgf_parametro where DominioId = 132

EXEC SGC_SP_List_Master_Return_General_L 133


select * from sgf_parametro where DominioId = 130 -- Contactado
select * from sgf_parametro where DominioId = 131 -- Interesado
select * from sgf_parametro where DominioId = 133 -- Resultado
select * from sgf_parametro where DominioId = 136 -- Motivo
select * from sgf_parametro where DominioId = 140 order by NombreLargo asc -- SubMotivo

select * from sgf_parametro where parametroid = 27

select * from sgf_motivo

update SGF_Parametro
set ValorParam = 1
where DominioId = 131 

update SGF_Parametro
set ValorParam = 16
where DominioId = 140 


select sp.ParametroId Id,          
               sp.NombreLargo Name                                                     
        from SGF_Parametro sp                          
        inner join SGF_Dominio sd on sp.DominioId = sd.DominioId                                                               
        where sd.DominioId = 130 and sp.IndicadorActivo  = 1      orde


select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 415354

update SGF_ExpedienteCredito set EstadoProcesoId = 2, EstadoExpedienteId = 1 where ExpedienteCreditoId = 707754


select top(10) * from SGF_ExpedienteCredito_Reconfirmacion

1148

select * from sgf_expedientecredito where IdSupervisor = 1148 and EstadoProcesoId = 5
order by ExpedienteCreditoId DESC


select top(100) LEN(DocumentoNum),  * from sgf_persona where Len(DocumentoNum) = 11
order by PersonaId DESC

select ProveedorId, IdSupervisor, * from SGF_ExpedienteCredito where TitularId = 608682

-- IdSupervisorProveedor: 5, IdSUpervisor: 1148

select * from sgf_user where UserId = 3171

select * from SGF_ProveedorLocal where proveedorLocalId = 6

select * from SGF_Persona where DocumentoNum = '12345678901'

select EstadoProcesoId, IdSupervisor,TitularId, * from sgf_expedientecredito where TitularId IN (
   840871
  ,840806
  ,840622
  ,840103
  ,839951
  ,839576
)
order by ExpedienteCreditoId DESC

select * from SGF_Supervisor where IdSupervisor IN (1411,1315)

select EmailEmpresa,EmpleadoId, * from SGF_USER where EmpleadoId IN (1315,1411) and CargoId = 29

select * from sgf_persona where DocumentoNum = '80283695'

select FechaCrea,FechaEvaluacion, * from SGF_ExpedienteCredito where TitularId = 783048

select ExpedienteCreditoLocalId,  * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707704

select * from sgf_ubigeo where nombre like '%HUAROC%'

select *
  from SGF_UBIGEO UB                 
  left join SGF_Local LO                 
  on LO.LocalId=UB.LocalId                 
  where UB.CodUbigeo='150703'  

  select LocalId, * from SGF_UBIGEO where CodUbigeo = '150703'

  SELECT * FROM SGF_Local where LocalId = 5

  Select DIST.CodUbigeo [Id],                            
          PROV.Nombre + '-' + DIST.Nombre [Name], DIST.LocalId          
    From SGF_UBIGEO DIST                                                                              
    OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                                              
              WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV                    
    Where -- DIST.CodDpto<>00 and DIST.CodProv<>00 and DIST.CodDist<>00 
    -- AND PROV.Nombre like '%HUARO%'
    dist.codUbigeo in (150701,150702,150703,150704,150705,150706,150707,150708,150709,150710,150711,150712,150713,150714,150715,
    150717,150718,150719,150720,150721,150722,150723,150724,150725,150726,150727,150728,150729,150730,150731,150732)

    select LocalId, * from sgf_ubigeo where CodUbigeo in (150716)

    update SGF_UBIGEO
    set LocalId = 6
    where codUbigeo in (150701,150702,150703,150704,150705,150706,150707,150708,150709,150710,150711,150712,150713,150714,150715,
    150717,150718,150719,150720,150721,150722,150723,150724,150725,150726,150727,150728,150729,150730,150731,150732)


    select  *from SGF_Local where NombreCorto like '%ATE%' -- id: 6

    select * from sgf_expedien

    exec SGC_SP_Credit_User_Data 3171,0,''

    select * from sgf_supervisor where IdSupervisor = 1148

    select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707718

    select GiroId,IngresoNeto, * from SGF_DatosLaborales where PersonaId = 608755

    update SGF_DatosLaborales set GiroId = null, IngresoNeto = 0 where PersonaId = 608755

    select TitularId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707740

    select * from sgf_persona where PersonaId = 608757

    select TipoDireccionId, * from SGF_DatosDireccion where PersonaId = 608757

    
select  DatosDireccionId from SGF_DatosDireccion where PersonaId=608757 and TipoDireccionId<>1

    select * from SGF_DatosDireccion where PersonaId = 608757

    SELECT * FROM 

EXEC SGC_SP_ExpedienteCredito_Por_Documento '04651593'

EXEC SGC_SP_ExpedienteCredito_Registrados_L '04651593'

SELECT * FROM SGF_Persona WHERE DocumentoNum = '04651593'
select FechaCrea,EstadoProcesoId, * from SGF_ExpedienteCredito where TitularId = 608755

(@Mes int,                                                         
 @Anio int,                                                         
 @LocalId int,                                                         
 @BancoId int,                                      
 @VerTodos BIT = 0,                                           
 @DesdeLogicApps BIT = 1,                           
 @AgenciaId int = 0,                
 @Actualiza bit = 0) 

EXEC SGC_SP_Derivaciones_Banco_L_Reporte 11,2022,0,3,0,0,0,0 -- Excel Todo -- Borrar

EXEC SGC_SP_Derivaciones_Banco_Report_L 11,2022,3,0,0,0 -- Logic Apps

EXEC SGC_SP_Derivaciones_Banco_Report_L_Web 11,2022,3,0,0,0,0,1,1,0 -- NEW
 
EXEC SGC_SP_Derivaciones_Banco_L 3,2021,0,3,0,20,'' -- Web List -- Borrar

select FechaDescarga, * FROM SGF_ExpedienteCredito where ExpedienteCreditoId = 707749

-- Falta:
-- Fechas
-- FechaUltimaDerivacion **
-- FechaDerivacion


select BancoId,EstadoProcesoId,FechaCrea,FechaEvaluacion, * from sgf_expedientecredito where ExpedienteCreditoId in (
  707852
,704924
,707692
,703156
,701868
)

select top(50) BancoId, * from SGF_ExpedienteCredito
where ISNULL(FechaInforme, '') = ''
order by ExpedienteCreditoId desc

select * from sgf_es

select * from SGF_Parametro where NombreCorto like '%RECHA%'

SELECT * FROM SGF_Parametro WHERE DominioId = 38

select * from SGF_ExpedienteCredito

select * from SGF_ExpedienteCredito_Reconfirmacion where ExpedienteCreditoId = 707823

exec SGC_SP_ExpedienteCredito_Por_Id 707834

select APDP, * from SGF_Persona where PersonaId = 595192

exec SGC_SP_ExpedienteCredito_Registrados_L 707749,'04651593'

exec SGC_SP_ExpedienteCredito_Maximo 0

SELECT ex.ExpedienteCreditoId, ex.EstadoProcesoId 
  FROM SGF_ExpedienteCredito as ex 
  INNER JOIN SGF_Persona as pr ON pr.PersonaId = ex.TitularId 
  WHERE pr.DocumentoNum = @DocumentoNum

update sgf_expedientecredito set EstadoProcesoId = 9 where ExpedienteCreditoId = 707741


update sgf_expedientecredito set EstadoProcesoId = 6 where ExpedienteCreditoId = 707749 -- 6

update SGF_ExpedienteCredito set EstadoExpedienteId = 1  where ExpedienteCreditoId = 707749

select top(20) * from SGF_ExpedienteCredito_Reconfirmacion  order by IdReconfirmacion desc

alter table SGF_ExpedienteCredito_Reconfirmacion drop column bancoid

drop

  select EstadoProcesoId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 693816
  select * from SGF_ExpedienteCreditodetalle where ExpedienteCreditoId = 693816

select EstadoProcesoId, * from SGF_ExpedienteCredito where ExpedienteCreditoId  in(708024,707886,708139)

select * from SGF_Parametro where DominioId = 38

  SELECT ex.IdSupervisor, * 
  FROM SGF_ExpedienteCredito_Reconfirmacion er
  inner join SGF_ExpedienteCredito ex on er.ExpedienteCreditoId = ex.ExpedienteCreditoId
  where ex.BancoId = 12 

exec SGC_SP_ExpedienteCredito_Reconfirmados_L 1148,1,0,20,0

select BancoId,FechaCrea,AdvId,UserIdCrea,Prioridad, * from SGF_ExpedienteCredito where ExpedienteCreditoId IN (707753)

ALTER TABLE SGF_ExpedienteCredito
ADD Prioridad varchar(15)

update SGF_ExpedienteCredito
set Prioridad = 'URGENTE'
where expedientecreditoId = 707882

EXEC SGC_SP_ExpedienteCredito_Por_Id 707777

SELECT * FROM SGF_EXPEDIENTECRE

exec SGC_SP_Credit_User_Data 3171,'',''

select CargoId, * from SGF_USER where UserId=3171   

select * 

EXEC SGC_SP_ExpedienteCredito_Por_Id 707908

select top(2) AdvId,IdSupervisor,FechaCrea, * from SGF_ExpedienteCredito order by ExpedienteCreditoId desc

SELECT Observacion, * FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = 707938

select IdRechazo Id,                                                                                
         Descripcion Name, *                                                          
        from SGF_Rechazo r                                                                                
        where EstadoProcesoId = 9

        update SGF_ExpedienteCreditoDetalle set Observacion = '<b>CAMBIO DE ENTIDAD: MALAS REFERS</b> <br /> TESTT'
        WHERE ExpedienteCreditoId = 707936 and itemid = 1

        CAMBIO DE ENTIDAD: MALAS REFERENCIAS <TESTT


  exec SGC_SP_ExpedienteCredito_Por_Id 704405

  select top(10) fECHACrea, IdSupervisor,UserIdCrea, * from sgf_expedientecredito 
  --where EstadoProcesoId = 5 and UserIdCrea != 3171 and IdSupervisor = 1148
  --where ExpedienteCreditoId = 707755
  order by expedientecreditoid desc

  select * from sgf_user where userId = 3171

  SELECT CodUbigeo,Nombre
  FROM (
  select CodUbigeo,Nombre from SGF_UBIGEO where CodDpto='15' and CodProv='01'
  UNION
  select CodUbigeo,Nombre from SGF_UBIGEO where CodDpto='07' and CodProv='01'
  ) as x
  where x.CodUbigeo = '150111'


  --SURGIR
--SI EL CLIENTE ES DE CODDPTO=15 Y CODPROV=01 SI DEBE SALIR SURGIR EN LAS OPCIONES
select * from SGF_UBIGEO where CodDpto='15' and CodProv='01' -- LIMA METROPOLITANA
select * from SGF_UBIGEO where CodDpto='07' and CodProv='01' -- CALLAO

select '' as mibanco, '' as surgir, '' as cajalosandes
 
 
--LOS ANDES
--AREQUIPA,PUNO,JUNIN,HUANCAVELICA
--SI EL CLIENTE ES DE CODDPTO
select * from SGF_UBIGEO where CodDpto='04' --AREQUIPA
select * from SGF_UBIGEO where CodDpto='21' --PUNO
select * from SGF_UBIGEO where CodDpto='12' --JUNIN
select * from SGF_UBIGEO where CodDpto='09' --HUANCAVELICA 

select 
from (
  select CodUbigeo,Nombre from SGF_UBIGEO where CodDpto='04'
  union
  select CodUbigeo,Nombre from SGF_UBIGEO where CodDpto='04'
  uni
) as la

select CodUbigeo,Nombre FROM SGF_UBIGEO WHERE CodDpto in ('04','21','12','09')

select BancoId Id,                                                                                  
               Nombre Name                                                                                  
        from SGB_Banco                      
        where Activo = 1 
  
exec [dbo].[SGC_SP_Bank_Available_Ubigeo_L] '150111'

SP_HELPTEXT SGC_SP_ExpedienteCredito_Status_U

select * from SGF_Evaluaciones where ExpedienteCreditoId = 707994
608857 --Persona
608865 --Interviniente

select TitularId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707994
608857

select * from SGF_DatosLaborales where PersonaId IN (608857,608865)

select isnull(count(ISNULL(TipoTrabajoId ,0)),0) from SGF_DatosLaborales where DatosLaboralesId = 142556;


select TipoTrabajoId, * from SGF_DatosLaborales where DatosLaboralesId = 142556;

select top(10) * from sgf_supervisor where nombre like '%jESUS%'
SELECT COUNT(EXPER.ExpedienteCreditoId)-1      
                    FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                 
                    INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                       
                    INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId                                   
                    WHERE (EXPCRED.IdSupervisor = 1161 and EXPER.Estado = 2)

select* from sgf_evaluaciones where expedientecreditoid = 707984
select CodUbigeo from SGF_UBIGEO where CodDpto='04'

select ex.EstadoExpedienteId,ex.EstadoProcesoId,ex.ExpedienteCreditoId,ex.IdSupervisor, * 
from sgf_persona  as p
inner join SGF_ExpedienteCredito as ex on p.PersonaId = ex.TitularId
where p.DocumentoNum = '43069088'

update sgf_Expedientecredito
set EstadoExpedienteId = 2
where ExpedienteCreditoId = 722060

sgf_expedientecredito

select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 722060

select STRING_AGG(PersonaId,',') as PersonaId from sgf_evaluaciones where ExpedienteCreditoId = 708075

select dl.DatosLaboralesId
from sgf_Evaluaciones as ev
inner join SGF_DatosLaborales as dl on ev.PersonaId = dl.PersonaId
where ev.ExpedienteCreditoId = 708075

select * from SGF_DatosLaborales where PersonaId IN (608881,608937,608939)

se

select * from dbo.FN_StrToTable('608881,608937,608939',',')

select STRING_AGG('608881,608937,608939',',')

select * from SGF_DatosDireccion sdd where sdd.PersonaId = 608937

SELECT PersonaId,GiroId, * FROM SGF_DatosLaborales WHERE DatosLaboralesId in (1044059,1044061,1044077)

  update SGF_DatosLaborales 
  set GiroId = 0
  WHERE DatosLaboralesId = 1044059

  1044059
1044061
1044077


SELECT isnull(count(ISNULL(dd.Direccion,0)),0)
from SGF_DatosLaborales dl
inner join SGF_DatosDireccion dd on dl.PersonaId = dd.PersonaId
WHERE DatosLaboralesId = 1044059

select * from SGF_DatosDireccion where PersonaId = 608937

update SGF_DatosDireccion
set Ubigeo = 150132
where  Ubigeo = '' 

select * from SGF_DatosDireccion where Ubigeo = ''

select isnull(count(ISNULL(sdd.Direccion,0)),0) from SGF_DatosDireccion sdd where sdd.PersonaId = 608937
(select isnull(count(ISNULL(sdd.Ubigeo,0)),0) from SGF_DatosLaborales dl INNER JOIN SGF_DatosDireccion sdd ON dl.PersonaId = sdd.PersonaId where dl.DatosLaboralesId = 1044059) 

SELECT dd.DocumentoNum
from SGF_DatosLaborales dl
inner join SGF_PERsona dd on dl.PersonaId = dd.PersonaId
WHERE DatosLaboralesId = 1044059

exec SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud 708075,0,'',''


select              
     su.UserId,              
     ISNULL(su.Nombres, '') + ' ' +          
      ISNULL(su.ApePaterno, '') + ' ' +          
      ISNULL(su.ApeMaterno, '') as Name,            
     sr.RolId,              
     sr.RolDes,              
     0 LocalId,              
     sjz.ZonaId,              
     su.EmpleadoId,     
     su.EmailEmpresa   ,
  -- ISNULL(@listVioTutorialId, '') as listaVioTutorialId,  
  0 as BancoId, 
  '' as LocalName 
    from              
     SGF_USER su              
    inner join              
     SGF_ROL sr               
    on              
     su.CargoId = sr.RolId               
    inner join              
     SGF_JefeZona sjz               
    on              
     sjz.JefeZonaId = su.EmpleadoId              
    where              
     LOWER(su.EmailEmpresa) like  '%leonel.%';     

     select su.CargoId,su.EmailEmpresa  from SGF_USER su where su.EmailEmpresa like  '%cabrera%'

     select STRING_AGG(dl.DatosLaboralesId,',') 
        from sgf_Evaluaciones as ev 
        inner join SGF_DatosLaborales as dl on ev.PersonaId = dl.PersonaId 
        where ev.ExpedienteCreditoId = 707759

    SELECT * FROM SGF_Evaluaciones where ExpedienteCreditoId = 708141


    select ruc, * from SGF_DatosLaborales where PersonaId in (609014)
    update SGF_DatosLaborales
    set ruc = '01234567891'
    where PersonaId in (609014)

    (select isnull(count(ISNULL(Ruc,0)),0) from SGF_DatosLaborales where DatosLaboralesId = 1044116)  


     exec SGC_TOKEN 'ROBERTO.MENDOZA@HATUN.COM.PE'

     SP_HELPTEXT SGC_TOKEN

Select *                        
from SGF_Agencia ac                                    
WHERE ac.BancoId = 3 AND                           
ac.Activo = 1

exec sp_get_list_master 3,31,0,0,0

select * from sgf_oficina where AgenciaId = 215

select ag.AgenciaId, o.IdOficina, O.Nombre
from sgf_agencia as ag
inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId
where ag.BancoId = 11 and ag.Activo  = 1

update sgf_oficina 
set Nombre = 'AG PUENTE PIEDRA'
where IdOficina = 451

update sgf_oficina 
set Nombre = 'AG COMAS'
where IdOficina = 452

update sgf_oficina 
set Nombre = 'AG LOS OLIVOS'
where IdOficina = 453

update sgf_oficina 
set Nombre = 'AG VENTANILLA'
where IdOficina = 454

update sgf_oficina 
set Nombre = 'AG PROCERES'
where IdOficina = 455

update sgf_oficina 
set Nombre = 'AG SAN JUAN DE LURIGANCHO'
where IdOficina = 456

update sgf_oficina 
set Nombre = 'AG VILLA EL SALVADOR'
where IdOficina = 457

update sgf_oficina 
set Nombre = 'AG SAN JUAN DE MIRAFLORES'
where IdOficina = 464

update sgf_oficina 
set Nombre = 'AG HUACHIPA'
where IdOficina = 465

update sgf_oficina 
set Nombre = 'AG LURIN'
where IdOficina = 466

update sgf_oficina 
set Nombre = 'AG CERCADO'
where IdOficina = 467

update sgf_oficina 
set Nombre = 'AG CERRO COLORADO'
where IdOficina = 468

update sgf_oficina 
set Nombre = 'AG AVELINO'
where IdOficina = 469

update sgf_oficina 
set Nombre = 'AG MIRAFLORES'
where IdOficina = 470

update sgf_oficina 
set Nombre = 'AG CASTILLA'
where IdOficina = 471

update sgf_oficina 
set Nombre = 'AG PIURA CENTRO'
where IdOficina = 472

update sgf_oficina 
set Nombre = 'AG SULLANA'
where IdOficina = 473

select  AdvId from SGF_ExpedienteCredito where expedienteCreditoId = 708149

exec SGC_SP_Oficina_Banco_G 3

Select  Android_VersionCode [AndroidVersionCode], * from SGF_VariablesNegocio

select top(2) IdOficina,  * from SGF_Oficina
select top(2) * from SGF_Agencia

SELECT o.IdOficina, o.Nombre, ag.BancoId, o.CorreoA
from sgf_agencia as ag
inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId
where ag.Activo = 1 and o.Activo = 1 and ag.bancoId = 11

select FechaDescarga, * from sgf_expedientecredito where expedientecreditoId in (707865)


update sgf_expedientecredito
set FechaDescarga = null
where ExpedienteCreditoId IN (
  708182
,687381
,708179
,708120
,708140 	
,708084
,708127
)

update sgf_expedientecredito
set FechaDescarga = null
where ExpedienteCreditoId IN (
707865
)

sele

(SELECT DocumentoNum 
FROM SGF_Persona C                                                                                           
  inner join SGF_Evaluaciones E on E.PersonaId = C.PersonaId and EC.ExpedienteCreditoId = E.ExpedienteCreditoId                                                                                        
  where E.TipoPersonaId = 2)

SELECT PersonaId,TipoPersonaId,* from SGF_Evaluaciones where ExpedienteCreditoId = 708134

select * from sgf_expedientecredito where expedientecreditoId = 

select * from sgf_oficina where IdOficina = 466

update sgf_oficina set Nombre = 'AG CERRO COLORADO' where IdOficina = 467

AG CERRO COLORADO

jhonnatan.zuni@surgir.com.pe,walter.bustamante@surgir.com.pe,erika.fernandez@surgir.com.pe
marco.escudero@surgir.com.pe,elvia.valdivia@surgir.com.pe,cesar.vilca@surgir.com.pe


-- Comas
update SGF_Oficina 
set CorreoA = 'cpadilla@surgir.com.pe,alexal.lopez@surgir.com.pe'
where IdOficina = 452

-- Avelino
update SGF_Oficina 
set CorreoA = 'wilar.carrillo@surgir.com.pe,roger.loraico@surgir.com.pe'
where IdOficina = 469



select * from SGF_Oficina where IdOficina in (452,469)

select EstadoExpedienteId, EstadoProcesoId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 708071

update SGF_ExpedienteCredito
set EstadoExpedienteId = 1
where ExpedienteCreditoId = 708122

select top(1000) EstadoExpedienteId, EstadoProcesoId, *
from SGF_ExpedienteCredito
where EstadoProcesoId = 6
order by ExpedienteCreditoId desc

select * from SGF_Evaluaciones where ExpedienteCreditoId = 708071

update SGF_Evaluaciones
set ResultadoId = 3
where ExpedienteCreditoId = 708071

select * from SGB_Banco where Activo = 1

update sgb_banco
set RespConvenio = 'Reynaldo y Francisco'
where BancoId = 3


update sgb_banco
set RespConvenio = 'Reynaldo'
where BancoId = 11

update sgb_banco
set MailResponsable = 'reynaldocauche@gmail.com'
where BancoId = 12

select FechaDescarga,BancoId, * 
From sgf_expedientecredito
where expedientecreditoid IN (
1055076,
1058154,
1060304,
1060339,
1060296,
1060108,
1059765)

EXEC SGC_SP_Derivaciones_Banco_Report_L_Web_2 2,2023,11,0,0,0,0,1,0,0


EXEC SGC_SP_Derivaciones_Banco_Report_L_Web 1,2023,11,0,0,0,0,1,1,0

update sgf_expedientecredito
set FechaDescarga = '2023-02-01 08:00:01.373'
where expedientecreditoid IN (
1055076,
1058154,
1060304,
1060339,
1060296,
1060108,
1059765)

+
select FechaDescarga, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 708129

update SGF_ExpedienteCredito
set FechaDescarga = null
where ExpedienteCreditoId = 708129
2023-01-24 12:10:56.580

select * from sgf_persona where DocumentoNum = '10504825'

select * from SGF_DatosDireccion where PersonaId = 608760
update SGF_DatosDireccion
set TipoDireccionId = 2
where DatosDireccionId = 808594

EXEC


select top(100) Nombres, DocumentoNum,Celular, * from sgf_user order by UserId Desc

select top(100) TipoDireccionId, * from SGF_DatosDireccion order by DatosDireccionId DESC  

UPDATE SGF_ExpedienteCredito
set FechaDescarga = null
where ExpedienteCreditoId in (708065,708141)

SELECT TitularId, *
from SGF_ExpedienteCredito
where ExpedienteCreditoId in (708065)

608870
609012

select * from SGF_DatosDireccion where PersonaId in (607542)

DELETE FROM SGF_DatosDireccion WHERE DatosDireccionId = 808456

select * from SGF_UBIGEO where CodUbigeo = '020702'

SGC_SP_Derivaciones_Banco_Report_L2

EXEC SGC_SP_Derivaciones_Banco_Report_L 12,2022,3,0,0,1

--15SEC
EXEC SGC_SP_Derivaciones_Banco_Report_L 2,2023,11,0,0,1

select (
  SELECT ISNULL(sdd.Direccion,'re') as ddnegocio  FROM SGF_DatosDireccion as sdd where sdd.PersonaId =608870 And sdd.TipoDireccionId = 3
) as ddnegocio

select * from sgb_banco where activo = 1


select FechaInforme, * from sgf_expedientecredito where expedientecreditoid in (708197,708114)
x|
update sgf_expedientecredito
set fechaInforme = null
where expedientecreditoid in (708197,708114)

select FechaDescarga,FechaEvaluacion, * from sgf_expedientecredito where expedientecreditoid = 1065539

exec SGC_SP_BancoInforme_L 12,0

select FechaInforme, * from sgf_ExpedienteCredito where ExpedienteCreditoId in (708253,708259,708251,708304)

select top(10) * from SGF_ExpedienteCreditoDetalle  order by expedienteCreditoId desc


SELECT TitularId,EstadoProcesoId,EstadoExpedienteId ,Observacion,UserIdActua,FechaRechazado,FechaActua,SolicitudId,* 
FROM SGF_ExpedienteCredito where ExpedienteCreditoId IN (702647
,704913
,708186
,708229)

select EstadoPersonaId,UserIdActua, FechaActua, * from sgf_persona where PersonaId in (604833
,606590
,608722
,609115)

select MontoEfectivoApro,
FechaActua,
FechaAprobacion,
UserIdActua,
MontoAprobado,
CuotaNumero,* from SGF_Solicitud where SolicitudId IN (180646
,181850
,382418
,382453
)



    UPDATE SGF_Solicitud    
            SET MontoEfectivoApro = @Monto,    
                FechaActua = dbo.getdate(),    
                FechaAprobacion = dbo.getdate(),    
                UserIdActua = 3588,    
                MontoAprobado = ISNULL(MontoMaterialApro, 0) + @Monto,    
                CuotaNumero = 0    


SELECT * FROM SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 708229

SELECT * FROM SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 707947


Cliente pasa a DESISTIÓ según correo de MiBanco - Fecha 03/03/23 12:58:23

Cliente pasa a RECHAZADO según correo de MiBanco - Fecha - 03/03/23 13:02:51 - No califica por comportamiento de pago

Cliente pasa a RECHAZADO según correo de MiBanco - Fecha - 03/03/23 13:04:35 - No califica por comportamiento de pago

Cliente pasa a RECHAZADO según correo de MiBanco - Fecha 03/03/23 13:04:35

select CuotaMonto,CuotaNumero, * from SGF_Solicitud  where SolicitudId = 382123

select FechaDescarga, * from SGF_ExpedienteCredito where expedientecreditoid in (
  1072707
,1073916
,1073317
,1072461
,1073894
)

selec

-- Tabla facturas, boletas

select * from public.factura limit 2

select top(10000) FechaActivado,FechaProceso,FechaCorreo, * from sgf_expedientecredito order by expedientecreditoid desc WHERE isnull(FechaCorreo, '') != '' where expedi

select * fr

ALTER TABLE sgf_expedientecredito
ADD FechaProceso DATETIME


ALTER TABLE sgf_expedientecredito
ADD FechaCorreo DATETIME

ALTER TABLE sgf_expedientecredito
DROP COLUMN FechaCorreo


UPDATE sgf_expedientecredito
SET FechaActivado = dbo.getDate()
WHERE ExpedienteCreditoId = 707797

select FechaDesistio, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 707735
select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 707735

RECHAZADO - No Califica - No Cumple Perfil - según correo de MiBanco - Fecha 08/03/23 14:37:43
RECHAZADO - No Califica - No Cumple Perfil - según correo de MiBanco - Fecha 08/03/23 14:41:45

No desea oferta – Tasa alta - según correo de MiBanco Fecha 08/03/23 14:37:42
RECHAZADO CRM Mi Banco según correo de MiBanco - Fecha 08/03/23 14:37:42

UPDATE SGF_ExpedienteCredito SET EstadoExpedienteId = 1, EstadoProcesoId = 4  where ExpedienteCreditoId = 416639

707735


707819

select * from sgf_persona where documentonum = '70218553'

exec SGC_SP_ExpedienteCredito_Por_Id2 607103

SELECT * FROM SGF_Evaluaciones where ExpedienteCreditoId = 708448

select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 607103

select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 597233


exec SGC_SP_BancoInforme_L 3,0

select * from SGF_APDP

select * from sgf_persona where personaid = 609174

select dbo.getDate()

-- 20452121211

2023-03-18 05:27:00.560
2023-03-20 02:33:58.827

select top(1000) APDP, PubliAPDP, * from sgf_persona
ORDER BY PersonaId desc

select * from sgf_persona where PersonaId = 166311
update SGF_Persona set PubliAPDP = 1, APDP = 0 where PersonaId = 166311

SELECT * FROM SGF_ExpedienteCredito where TitularId = 609174
exec SGC_SP_ExpedienteCredito_Por_Id 708189

select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 708189

select TOP(1000) TitularId, * from SGF_ExpedienteCredito order by ExpedienteCreditoId desc

select Celular, Celular2,Telefonos, * from SGF_Persona where PersonaId = 609198

select count(personaid) from SGF_Persona where Celular = '910910910' AND PERSONAID != 609146


select count(personaid) from SGF_Persona where Celular2 = '910910911' AND PERSONAID != 609146

select TOP(1) isnull(Telefonos,'') from SGF_Persona where Telefonos = '2603212'

select top(1) isnull(Celular,'')  from SGF_Persona where Celular in ('900600301',IIF('910910911' = '','--','910910911')) and PersonaId != 609146

select count(personaid) from SGF_Persona where Celular2 in ('900600301',IIF('910910910' = '','--','910910910')) and PersonaId != 609146

select BancoId,SolicitudId, * from sgf_expedientecredito where expedientecreditoid in (1090608)

select * from sgf_expedientecreditodetalle where expedientecreditoid in (1090608)

select MontoEfectivoApro,* from SGF_Solicitud where SolicitudId in (286719)

select top(100) * from SGF_ExpedienteCredito where BancoId = 11 and EstadoProcesoId = 8  order by ExpedienteCreditoId desc

select * from sgf_expedientecredito where expedientecreditoid = 708448

select * from sgf_persona where DocumentoNum = '43261919'

exec SGC_SP_Person_APDP_U '43261919',1,'123.42244','Samsung Galaxy A20','Chrome',1,1,0,''

select * from SGF_APDP where PersonaId

 @APDP bit,         
 @IpAPDP  varchar(15),         
 @ModeloDispositivoAPDP  varchar(50),         
 @NavegadorAPDP  varchar(50),         
 @PubliAPDP bit,
 @MedioAutorizacion int = 0,   
 @Success int OUTPUT,                                           
 @Message varchar(8000) OUTPUT    

select top(1000) apdp,PubliAPDP, * from sgf_persona where PersonaId = 609238
update sgf_persona set PubliAPDP = 1 where  PersonaId = 609238
-- order by PersonaId desc 
where PersonaId = 727450

select top(100) * from SGF_APDP 

select * from sgf_expediente