SELECT TOP(100) IdSupervisor,ProveedorId, FechaCrea, * FROM SGF_ExpedienteCredito 
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

select 

SP_HELPTEXT SGC_SP_Reconfirmacion_Banco_L_Reporte  

select * from sgf_persona where DocumentoNum = '43166231'

SELECT UserId, * FROM SGF_USER WHERE EmailEmpresa like '%renato%'

exec SP_Eliminar_Contacto 609885

SELECT isnull(CargoId,0) FROM SGF_USER where UserId = 0

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

select * from sgf_rol_pagina where PageId = 29

insert into sgf_rol_pagina(RoleId,PageId) values (29,29)



insert into SGF_Rol_Pagina (RoleId, PageId) values (48,30)

select * from sgf_pagina -- 48 Operaciones 
insert into sgf_pagina(Nombre,Descripcion,ApplicationId,[Level],[Url],ParentPageId,Icon,Estado,[Order],OrderView)
values ('Carga Respuesta de IF',null,1,2,'/dashboard/carga-respuesta-if',1,'developer_mode',1,6,2)

29 -- Id Cartera
select 

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


update SGF_VariablesNegocio set Android_VersionCode = 39 

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

SELECT count(*) FROM SGF_ExpedienteCredito WHERE EstadoProcesoId = 2

exec SGC_SP_Person_APDP_U '43261919',1,'123.42244','Samsung Galaxy A20','Chrome',1,1,0,''

select * from SGF_APDP where PersonaId

select * from sgf_dominio order by DominioId desc

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

select * from sgf_persona where DocumentoNum = '10504825'

EXEC SGC_SP_PortfolioPerson_Operacion_Por_Id 608760
--885709

SELECT * 
FROM SGF_USER su 
INNER JOIN SGF_Supervisor ss on ss.IdSupervisor = su.EmpleadoId 
where su.UserId = @UserId

select * from sgf_supervisor where IdSupervisor = 1294
select * from sgf_user where empleadoid = 1294

select * from SGF_ExpedienteCredito where TitularId = 885709

select top(1) * from sgb_banco

select TitularId, * from sgf_expedientecredito where ExpedienteCreditoId = 708200

select TipoPersonaId,DocumentoNum,* from sgf_persona where Personaid = 609004

20603614748

select SolicitudId, * from sgf_expedientecredito where expedientecreditoid in (1076499,1072461)

select * from sgf_solicitud where solicitudId in (282908,282161)

exec SGC_SP_ExpedienteCredito_Gestion_Derivar_Solicitud 708406,0,'',''
exec SGC_SP_ResultLoading_Validation 11,

select count(UserId) from sgf_user where UserLogin = '73999345' and UserPassword = '0e7bd1c05526f5cf7d97ed8e4e69aee4815e5ce6'


select UserLogin, UserPassword, EmailEmpresa, * from sgf_user  where UserLogin like '%45503400%'

'Admin'

update sgf_user set UserLogin = '45503400' where UserLogin like '%admin%'

select *from sgf_persona where DocumentoNum = '45503400'

f0345c8fd25fb1c2085db1477e067b426f2040a4


f0345c8fd25fb1c2085db1477e067b426f2040a4

8DRcj9JfscIIXbFHfgZ7Qm8gQKQ=

"QL0AFWMIX8NRZTKeof9cXsvbvu8="

-----
40bd001563085fc35165329ea1ff5c5ecbdbbeef

40bd001563085fc35165329ea1ff5c5ecbdbbeef

QL0AFWMIX8NRZTKeof9cXsvbvu8=


SELECT TOP(1) EXPE.ExpedienteCreditoId,     
        IIF( isnull(SOL.MontoAprobado,0)=0,isnull(SOL.MontoPropuesto,0),MontoAprobado) [Monto],    
        EXPE.EstadoProcesoId [EstadoId],     
        PAR.NombreLargo [NombreEstado],     
        convert(VARCHAR,EXPE.FechaActua,103) [FechaActua],         
        convert(VARCHAR,EXPE.FechaCrea,103) [FechaCrea],        
        EXPE.BancoId,     
        BA.Nombre [NombreBanco],        
        PER.Nombre +' '+ PER.ApePaterno+' '+PER.ApeMaterno [Nombres],
        ISNULL(SP.Nombre +' '+ SP.ApePaterno+' '+SP.ApeMaterno, 'CONTACT CENTER') [NombreSupervisor],        
        ISNULL(USR.Celular,'966575476') [CelularSupervisor],
        PER.DocumentoNum [DocumentoNum]
    FROM SGF_ExpedienteCredito EXPE     
    LEFT JOIN SGF_Solicitud SOL ON SOL.SolicitudId = EXPE.SolicitudId     
    INNER JOIN SGF_Persona PER ON PER.PersonaId = EXPE.TitularId     
    LEFT JOIN SGF_Parametro PAR ON PAR.ParametroId = EXPE.EstadoProcesoId AND PAR.DominioId = 38     
    LEFT JOIN SGB_Banco BA ON BA.BancoId = EXPE.BancoId
    LEFT JOIN SGF_Supervisor SP ON SP.IdSupervisor = EXPE.IdSupervisor
    LEFT JOIN SGF_User USR ON USR.EmpleadoId = SP.IdSupervisor and USR.CargoId = 29
    --WHERE EXPE.TitularId = '45503400'     
    ORDER BY EXPE.ExpedienteCreditoId DESC   



select count(*) from sgf_documentoAdjunto where ExpedienteCreditoId = 708422 and TipoDocumentoAdjuntoId =14

select *from sgf_expedientecredito where ExpedienteCreditoId = 708422

select APDP, PubliAPDP, * from SGF_Persona where PersonaId = 609217

update SGF_Persona set apdp = 0, PubliAPDP = 0 where PersonaId = 609217

select top(10) * from sgf_dominio where nombre like '%Medio%' 

select* from sgf_dominio where DominioId = 49 

select * from SGF_Parametro where DominioId = 49

select * from SGF_Parametro where DominioId = 143

select * from SGF_APDP

select * from sgf_persona where documentonum = '48078633'

-- 602923

select * from sgf_apdp where personaid = 609271


insert into sgf_parametro (DominioId, ParametroId, NombreLargo, NombreCorto, IndicadorActivo, UserIdCrea, FechaCrea)
values (49, 14, 'Autorizacion de Datos', 'Autorizacion de Datos', 1, 1, dbo.getDate())

insert into sgf_parametro (DominioId, ParametroId, NombreLargo, NombreCorto, IndicadorActivo, UserIdCrea, FechaCrea)
values (49, 15, 'DNI Reverso', 'DNI Reverso', 1, 1, dbo.getDate())

select top(2) * from sgf_expedientecreditodetalle


select * from sgf_persona where DocumentoNum = '000708332'

select top 1 DocumentoNum from SGF_Persona where DocumentoNum ='000708332'

select len('000708332')
71710143

select FechaCrea, *from sgf_persona where len(DocumentoNum) = 9

select EstadoProcesoId,FechaActua,Observacion, * from sgf_expedientecredito where expedientecreditoid = 1068640

select * from sgf_expedientecreditodetalle where ExpedienteCreditoId = 1068640

exec SGC_SP_ResultLoading_Validation 3,'1068640','DESEMBOLSO',0,20,0

NO DESEA -  - según correo de MiBanco - Fecha 04/05/23


EXEC SGC_SP_PortfolioPerson_L 0,20,'','',0,'','','1/1/2015','15/5/2023',0,0

select convert(varchar(50), '13/05/2023',3)

select convert(date, '12/5/2023',103)

2023-05-12 00:00:00.000
2023-05-12 00:00:00.000


select convert(varchar(23), convert(datetime, '12/5/2023'), 26)

select substring(convert(varchar(23), convert(datetime, '12/5/2023'), 26), 0, 11)

2023-05-12

2023-05-12

select EstadoProcesoId, * from sgf_expedientecredito where expedienteCreditoId = 1085813
and EstadoProcesoId not in (5, 9, 10, 16)

select * from sgf_expedientecreditodetalle where expedienteCreditoId = 1085813

select * from sgf_parametro where Dominioid = 38

select top(10) IdSupervisor, * from sgf_persona

exec SGC_SP_PortfolioPerson_L  0,20,'','08921404',8,'','','22/12/2022','22/5/2023',0,1148,0

exec SGC_SP_PortfolioPerson_Operacion_Por_Id 132405

select IdSupervisor, * from SGF_ExpedienteCredito where ExpedienteCreditoId  = 707764

select IdSupervisor,FechaEstadoMax, * from SGF_Persona where PersonaId  = 603110

select isnull(count(DatosDireccionId),0) from SGF_DatosDireccion  
where personaId = 340946 and TipoDireccionId = 2

sdd.PersonaId = sp.PersonaId and sdd.TipoDireccionId=1 

SELECT TOP(100) *FROM SGF_DatosLaborales ORDER BY PersonaId DESC

select top(19) Nombre, * from SGF_Persona

UPDATE SGF_Persona                                  
              SET Nombre='ELISA'
            where PersonaId=385      

-- ELISA
             
EXEC SGC_SP_ExpedienteCredito_U_2 1,3,1,1,0,''

SELECT DatosDireccionId from SGF_DatosDireccion where PersonaId = 1 and TipoDireccionId = 1

select top(1000) solicitudId,FechaActua,FechaCrea,DispositivoId, * from SGF_ExpedienteCredito order by ExpedienteCreditoId desc 
where ExpedienteCreditoId = 708421

SELECT TipoPersonaId FROM SGF_Persona where PersonaId = 609482

select ev.TipoPersonaId, ev.BancoId,
from SGF_Evaluaciones as ev
inner join SGF_Persona as pr on ev.PersonaId = pr.PersonaId
INNER join SGF_DatosDireccion sdd on sdd.PersonaId = pr.PersonaId and sdd.TipoDireccionId=1  
where ExpedienteCreditoId = 708794

select DocumentoNum, * from SGF_Persona where PersonaId = 603000

exec SGC_SP_ExpedienteCredito_Por_Id 708794

select BancoId, SolicitudId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 708798

select Nombre, ApePaterno, ApeMaterno, * from sgf_persona where DocumentoNum = '46683050'

select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 708787

select * from SGF_DatosLaborales where PersonaId = 609209

SELECT DIST.CodUbigeo [Id],                                                                     
      IIF(LEN(1508) < 6, PROV.Nombre + '-' + DIST.Nombre, DIST.Nombre) [Name]                                                     
From SGF_UBIGEO DIST                                                                                                                       
OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                                                                                       
            WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV                                                                      
WHERE (LEN(1508) < 6 AND    
  DIST.CodDpto <> 0 AND   
  DIST.CodProv <> 00 AND  
      DIST.CodDist <> 00) OR 
      (LEN(1508) = 6 AND 
DIST.CodDpto = left(1508, 2) AND                                                                                                                          
      DIST.CodProv = right(left(1508, 4), 2) AND    
      DIST.CodDist <> 00) 

-- 1834


SELECT DIST.CodUbigeo [Id],                                                                     
      IIF(LEN(1508) < 6, DPTO.Nombre + '-' + PROV.Nombre + '-' + DIST.Nombre, DIST.Nombre) [Name]                                                     
From SGF_UBIGEO DIST                                                                                                                       
OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO PROV                                                                                                                       
            WHERE PROV.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,4) + '00') PROV  
OUTER APPLY (SELECT Nombre FROM SGF_UBIGEO DPTO                                                                                                                       
            WHERE DPTO.CodUbigeo = SUBSTRING(DIST.CodUbigeo,1,2) + '0000') DPTO                                                                       
WHERE (LEN(1508) < 6 AND    
  DIST.CodDpto <> 0 AND   
  DIST.CodProv <> 00 AND  
      DIST.CodDist <> 00) OR 
      (LEN(1508) = 6 AND 
DIST.CodDpto = left(1508, 2) AND                                                                                                                          
      DIST.CodProv = right(left(1508, 4), 2) AND    
      DIST.CodDist <> 00) 


SELECT top(1000) SUBSTRING(CodUbigeo,1,4) + '00', * FROM SGF_UBIGEO 

select top(100) FechaCrea,FechaActua, * from SGF_ExpedienteCredito order by ExpedienteCreditoId desc

select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 708837
708787

708809

SELECT * FROM SGF_USER where UserLogin IN (
  '46085645','40241537','47538975','41484221','47405693',
  '41700943','40455293','42112241','70030521','10404347018','41772893','45431253'
)

40bd001563085fc35165329ea1ff5c5ecbdbbeef

update SGF_USER set UserPassword = '40bd001563085fc35165329ea1ff5c5ecbdbbeef 'where UserLogin IN (
  '46085645','40241537','47538975','41484221','47405693',
  '41700943','40455293','42112241','70030521','10404347018','41772893','45431253'
)

select * from sgf_local -- RegionalId = EmpleadoId

select * from SGF_JefeRegional -- JefeRegionalId = EmpleadoId, eliminar
select * from SGF_RegionZona
select * from SGF_JefeZona

update SGF_Local
set RegionalId = 12
where LocalId in (13)
DELETE FROM SGF_JefeRegional WHERE JEFEREgionalId = 13

select * from sgf_zona -- Eliminar

select EmailEmpresa,Nombres, ApePaterno, ApeMaterno,EmpleadoId,CargoId, * from sgf_user 
-- where UserId = 3380
where Nombres like '%Carlos%' and ApePaterno like '%Jimenez%'

52

select EmailEmpresa,Nombres,ApePaterno,ApeMaterno, * from sgf_user where UserId = 2861

select * from sgf_user where userid = 3380

select * from SGF_Rol_Pagina



select * from SGF_JefeRegional

update sgf_user 
set EmpleadoId = 11, CargoId = 52
where UserId = 4051

insert into SGF_JefeRegional (JefeRegionalId, Nombre, UserIdCrea, FechaCrea, EsActivo)
values (13,'LOSBETH DIAZ NAJARRO', 1, dbo.getDate(), 1)


select EmailEmpresa, Nombres, ApePaterno, ApeMaterno,IsActive, * from sgf_user 
-- where UserId = 3380
where Nombres like '%Hugo%' and ApePaterno like '%Chavez%'

-- 11
SELECT ZonaId, * FROM sgf_local where RegionalId = 4
select * from SGF_JefeRegional

select IsActive, * from sgf_user where EmailEmpresa like '%adammo.pa%'

update sgf_user
set CargoId = 11
where UserId = 3274

select * from SGF_JefeRegional

select * from

select * from sgf_user where UserId = 3380

select * from sgf_local where RegionalId = 2

select * from sgf_local

alter table sgf_local
add RegionalId int

select *from SGF_JefeRegional

select * from sgf_zona

-- Version
select * from sgf_variables

update SGF_Local
set ZonaId = 8
where RegionalId = 9

-- Rober Mendoza Sanches - id = 2953 - EmpleadoId = 2

exec SGC_TOKEN 'nelly.medrano@hatun.com.pe'

-- 2518	NELLY ROSA MEDRANO OVALLE	52	Jefe Regional	0	0	1	2	1,2	0	

 select                  
  su.UserId,                  
  ISNULL(su.Nombres, '') + ' ' +            
  ISNULL(su.ApePaterno, '') + ' ' +            
  ISNULL(su.ApeMaterno, '') as Name,              
  sr.RolId,                   
  sr.RolDes,                  
  -- 0 LocalId ,      
  (SELECT STRING_AGG(LocalId,',') FROM sgf_local where RegionalId = su.EmpleadoId) as LocalId,         
  -- concat(lc.LocalId,',') as LocalId,
  0 ZonaId,                  
  su.EmpleadoId,                
  --sjr.RegionId,          
  -- ISNULL(@listVioTutorialId, '') as listaVioTutorialId,    
  0 as BancoId,   
  '' as LocalName   
from SGF_USER su                  
inner join SGF_ROL sr on su.CargoId = sr.RolId  
-- INNER JOIN SGF_Local lc on su.EmpleadoId = lc.RegionalId            
-- inner join SGF_JefeRegional sjr on sjr.JefeRegionalId = su.EmpleadoId                
where LOWER(su.EmailEmpresa) = 'nelly.medrano@hatun.com.pe'  and RolId = 52

select * from SGF_RegionZona

select 

select *  from sgf_local

select * from sgf_adv -- LocalId

select top(100) Correspondencia, * from SGF_DatosDireccion

SELECT sl.LocalId [ID],                                                                                                                             
    sl.Descripcion [NAME]                                                                                   
FROM SGF_Local sl                                                                                                     
INNER JOIN SGF_Zona sz ON sl.ZonaId = sz.ZonaId                                                                                                                 
WHERE sz.ZonaId = CAST(8 AS INT)                                                                                            
OR 0 = CAST(8 AS INT) AND sl.esActivo = 1               
ORDER BY sl.Descripcion asc 

select  LocalId [ID],                                                                                                                             
        Descripcion [NAME]
from sgf_local
where esActivo = 1 and ZonaId = 8
ORDER BY Descripcion asc 

SELECT * FROM SGF_Zona

select * from sgf_local

  select distinct RZ.RegionZonaId,       
               0 [ZonaId],   
         RZ.Descripcion,       
               RZ.UrlBI     
        from sgf_RegionZona RZ   
        WHERE RZ.RegionZonaId = 0 and   
           RZ.EsActivo = 1    

  select * from SGF_RegionZona

  select * from sgf_local

  alter table sgf_local
  add UrlBI varchar(500)

select EmailEmpresa, * from sgf_user where CargoId = 48
  select * from sgf_pagina

  select * from sgf_rol_pagina where PageId = 27

  update SGF_Zona set UrlBI = 'https://app.powerbi.com/view?r=eyJrIjoiM2Q4ZmNmZGItODMwNy00NDBjLTkyYWYtY2RkMGFjYmY4NzMwIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9'
  where ZonaId = 1

  https://app.powerbi.com/view?r=eyJrIjoiM2Q4ZmNmZGItODMwNy00NDBjLTkyYWYtY2RkMGFjYmY4NzMwIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9

select                   
        su.UserId,                   
        ISNULL(su.Nombres, '') + ' ' +             
        ISNULL(su.ApePaterno, '') + ' ' +             
        ISNULL(su.ApeMaterno, '') as Name,               
        sr.RolId,                   
        sr.RolDes,                   
        -- 0 LocalId ,                   
        (SELECT STRING_AGG(LocalId,',') FROM sgf_local where RegionalId = su.EmpleadoId) as LocalId, 
        (SELECT TOP(1) ZonaId  FROM sgf_local where RegionalId = su.EmpleadoId) as ZonaId,
        su.EmpleadoId,                 
        --sjr.RegionId,           
        0 as BancoId,    
        '' as LocalName    
      from SGF_USER su                   
      inner join SGF_ROL sr on su.CargoId = sr.RolId                  
      -- inner join SGF_JefeRegional sjr on sjr.JefeRegionalId = su.EmpleadoId                 
      where LOWER(su.EmailEmpresa) = 'nelly.medrano@hatun.com.pe' and sr.RolId = 52    

select  * from SGF_JefeRegional
select * from sgf_local

select * from sgf_zona 

https://app.powerbi.com/view?r=eyJrIjoiM2Q4ZmNmZGItODMwNy00NDBjLTkyYWYtY2RkMGFjYmY4NzMwIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9

https://app.powerbi.com/view?r=eyJrIjoiM2Q4ZmNmZGItODMwNy00NDBjLTkyYWYtY2RkMGFjYmY4NzMwIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9

select FechaActivado,EstadoProcesoId, * from sgf_expedientecredito where expedientecreditoid = 1065163

select * from sgf_expedientecreditodetalle where expedientecreditoid = 1065163

1065163


--1077909,1079388
-- Activación confirmada por MiBanco según correo del 06/06/23
Activación confirmada por MiBanco según correo del 06/06/23

SELECT position as Id, cast(value as int) as ExpedienteCreditoId                
FROM dbo.fn_Split('3,4,5',',') 

SELECT sp.ParametroId [ID],                                                       
               sp.NombreLargo [NAME]                                                                                             
        FROM SGF_Parametro sp                                                                       
        INNER JOIN SGF_Dominio sd on sp.DominioId = sd.DominioId                                                                   
        WHERE sd.DominioId = 26 AND sp.IndicadorActivo  = 1    

select * from sgf_user where DocumentoNum = '46085645'
select DocumentoNum, * from sgf_persona where DocumentoNum = '46085645'

exec SGC_SP_Client_Operacion 46085645

select * from sgf_expedientecredito where TitularId = 527039
order by ExpedienteCreditoId desc

select * from sgf_user where userId = 2953

select * from sgf_local where regionalId = 2

select top(10) * from SGF_ExpedienteCredito_Reconfirmacion

SELECT *                        
   
   FROM dbo.SGF_ExpedienteCredito_Reconfirmacion EXPER                                                  
   
   INNER JOIN dbo.SGF_ExpedienteCredito EXPCRED on EXPCRED.ExpedienteCreditoId = EXPER.ExpedienteCreditoId                                        
   INNER JOIN dbo.SGF_Persona PER on PER.PersonaId = EXPCRED.TitularId         
   
   inner join SGF_Local lo on lo.LocalId = EXPCRED.ExpedienteCreditoLocalId         
  --  inner join SGF_Zona zo on zo.ZonaId = lo.ZonaId         
  --  inner join SGF_JefeRegional JZ on zo.RegionZonaId = JZ.RegionId
  -- WHERE  JZ.JefeRegionalId = @EMPLEADOID and (EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 ) 

  WHERE  lo.RegionalId = 2
  -- and (EXPCRED.IdSupervisor = @SupervisorId or @SupervisorId =-1 ) 
   --and( EXPCRED.ExpedienteCreditoLocalId= @LocalId  or @LocalId =0)    
  --   and (EXPER.Estado = @EstadoId)

  select IIF(Result = 'null', '', Result) from FN_StrToTable('desembolso,pendiente,recibido,null,desembolso',',')

  select position as Id, IIF(value = 'null', '', value) as Estado from dbo.fn_Split('desembolso,pendiente,recibido,null,desembolso',',')

  select EstadoProcesoId, * from sgf_expedientecredito where expedientecreditoId = 707754
  
  select  * from sgf_expedientecreditodetalle where ExpedienteCreditoId = 707754 -- userId 3171
  select * from sgf_expedientecreditodetalle where ExpedienteCreditoId = 622867
  
  select * from sgf_user where UserId in (3171,3588,29)

  select * fro

  select * from SGF_Local


  select * from sgf_persona where PersonaId = 608764

select * from SGF_Parametro where DominioId = 38

SELECT distinct 0 [RegionZonaId],     
                    0 [ZonaId],                 
                    'General' [Descripcion],     
                     z.UrlBI     
    FROM dbo.SGF_Zona z                      
    WHERE z.ZonaId = 6 

    https://app.powerbi.com/view?r=eyJrIjoiYzI4ZWYzOTQtNzY2Ny00MmZlLWExNGYtZmEzMTJkZDdiZjQyIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9&pageName=ReportSection6d2f7aa58d35d7b805bc
    https://app.powerbi.com/view?r=eyJrIjoiYzI4ZWYzOTQtNzY2Ny00MmZlLWExNGYtZmEzMTJkZDdiZjQyIiwidCI6IjQyMmZkMDE0LTg3NzEtNDgyYS1hMDNlLWQ4N2MyYjI0MzJiNyIsImMiOjR9


    select  LocalId [ID],                                                                                                                             
                    Descripcion [NAME]
            from sgf_local
            where esActivo = 1 and ZonaId = 8
            ORDER BY Descripcion asc   

select ExpedienteCreditoLocalId, * from sgf_expedientecredito where expedienteCreditoId = 1110977

-- 8 sna juan miraflores

select * from sgf_user where UserId = 3274

select EmailEmpresa, * from sgf_user where EmailEmpresa like '%pacheco%'

insert into sgf_user(UserLogin,UserPassword,CargoId,EmpleadoId,IsActive,DateS,UserSId,DateU,ApePaterno,ApeMa)

select RegionalId, * from sgf_local -- 2

update sgf_local 
set RegionalId = NULL
where RegionalId = 12

update sgf_user
set CargoId = 11
where UserId = 3274

select * from s

select * from SGF_JefeRegional
delete from SGF_JefeRegional where JefeRegionalId = 12

select FechaCorreo, * from sgf_ExpedienteCredito where expedientecreditoid = 708845

select * from sgf_ExpedienteCreditoDetalle where expedientecreditoid = 707770

select * from sgf_ExpedienteCreditoDetalle where expedientecreditoid = 708845

select * from sgb_banco

select * from SGF_Parametro where DominioId = 6

update sgb_banco set logo = 'alfin_logo.png' where BancoId = 13

insert into sgb_banco(BancoId, Nombre, NombreCorto, RespConvenio, Activo, UserIdCrea, FechaCrea, NombresSSFF, VarParametrosSentinel, logo )
values (13, 'ALFIN', 'ALFIN', 'Luis Ormeño', 1, 1, dbo.getDate(), 'ALFIN', '{
    "validador": 2,
    "norNroMeses": 1,
    "cppCant": 2,
    "cppNroMesMin": 1,
    "cppNroMesMax": 6,
    "datDiasAtrasoMax": 8,
    "datPromedioDiasAtrasoMax": 5,
    "datNroMeses": 6,
    "edaEdadMin": 20,
    "edaEdadMax": 74,
    "edaTiempoActividadRucMin": 6,
    "derNroMesesLimite": 6,
    "scoreMin": "A",
    "scoreMax": "D"
}', 'alfin_logo.png')

insert into 

select top(10) Ofertas, * from SGF_Evaluaciones order by EvaluacionId desc

select Ofertas, * from SGF_Evaluaciones where ExpedienteCreditoId = 709146



insert into SGF_Evaluaciones 
(EvaluacionId, ExpedienteCreditoId, PersonaId, ResultadoId, Observacion, EsTitular, UserIdCrea, FechaCrea, TipoPersonaId, BancoId, Ofertas)

values (760882, 709117, 608602, 2, 'Test Observación', 0, 1, dbo.getdate(), 8, 13, 'OFERTA DOS DE TEST PARA ESTA OPERACION')

update SGF_Evaluaciones
set Observacion = 'Monto: S/. 5000 Cuota: S/. 500 Plazo: 12 Tasa: 5%'
-- set TipoPersonaId = 0, Observacion = '', ResultadoId = 0
where EvaluacionId in (760881,760882)

exec SGC_SP_ExpedienteCredito_Por_Id 709117

exec SGF_SP_SentinelFilter_L 709117,0

select SolicitudId, * from SGF_ExpedienteCredito where ExpedienteCreditoId = 709117

select * from sgf_solicitud where SolicitudId = 382814

exec SGC_SP_RechazadosFiltroAlFin_L  100,7,0

[
  {
    Oferta 1
  },
  {
    Oferta 2
  }
]

select top(5) Ofertas, * from sgf_evaluaciones  order by expedientecreditoId desc

select * from sgf_evaluaciones  order by expedientecreditoId desc

select Ofertas, * from sgf_evaluaciones  where ExpedienteCreditoId = 709357

update sgf_evaluaciones
-- set Ofertas = '[{"monto": 5000, "cuota": "500.34", "plazo": 12, "tasa": "50.23"},{"monto": 6000, "cuota": "1000.34", "plazo": 6, "tasa": "75.67"}]'
set Ofertas = null
where EvaluacionId = 760899

selelec

select FechaCrea,TitularId,SolicitudId,EstadoProcesoId, AdvId,IdSupervisor, * from sgf_ExpedienteCredito where expedientecreditoid in (709405)
update sgf_ExpedienteCredito set AdvId = 48 where expedientecreditoid in (709404)

select * from sgf_adv where AdvId = 48

select * from sgf_user where EmailEmpresa like '%anyolina.ortega%'
-- Id: 709384

select * from sgf_ExpedienteCreditoDetalle where expedientecreditoid = 709382

select * from sgf_solicitud where SolicitudId = 382869

select Ofertas,  BancoId,Observacion, *from SGF_Evaluaciones where ExpedienteCreditoId in (709397,709398,709334)

update SGF_Evaluaciones set CanalAlfinId = 3 where EvaluacionId = 761260

upda

select * from sgf_

select * from SGF_Persona where PersonaId = 609704

select *from SGF_DatosDireccion where PersonaId = 609704

select * from SGF_Solicitud where SolicitudId = 

select * from SGF_DatosLaborales where PersonaId = 609704

709220

-- 709220 , 709301


select top(1002)  FechaCrea,FechaActua,AdvId, * from SGF_ExpedienteCredito 
-- WHERE eXPEDIENTEcreditoId = 709393
order by expedienteCreditoId desc 


709397
select top(100)

where EstadoProcesoId in (9, 10, 11, 12)
order by expedienteCreditoId desc

UPDATE SGF_ExpedienteCredito
SET FechaActua = '2023-07-19 13:56:22.250'
where ExpedienteCreditoId in (
    709404
  )

select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT(
'"[{\"Oferta\":1900,\"Plazo\":12,\"Cuota\":229.87,\"Tasa\":83.70},{\"Oferta\":2400,\"Plazo\":18,\"Cuota\":221.50,\"Tasa\":83.70},{\"Oferta\":2400,\"Plazo\":24,\"Cuota\":212.22,\"Tasa\":83.70},{\"Oferta\":3200,\"Plazo\":36,\"Cuota\":211.53,\"Tasa\":83.70}]/##','/#')

   "[{\"Oferta\":1900,\"Plazo\":12,\"Cuota\":229.87,\"Tasa\":83.70},{\"Oferta\":2400,\"Plazo\":18,\"Cuota\":221.50,\"Tasa\":83.70},{\"Oferta\":2400,\"Plazo\":24,\"Cuota\":212.22,\"Tasa\":83.70},{\"Oferta\":3200,\"Plazo\":36,\"Cuota\":211.53,\"Tasa\":83.70}]
"

select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT('', '//#') WHERE data != ''

 SELECT A.data [BancoId], B.data [ResultadoId], C.data [Observacion], D.data [Ofertas]  
 from (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT('bank1,bakn2', ',')) A  
  LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT('res1,res2', ',')) B ON A.Row = B.Row     
  LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT('obs1,obs2', ',')) C ON A.Row = C.Row  
  LEFT JOIN (select ROW_NUMBER() OVER(order by (select null)) AS Row, data from dbo.SPLIT('', '//#') where data != '') D ON A.Row = D.Row   


  select * from sgf_evaluaciones where expedientecreditoId = 709425

  update sgf_evaluaciones set CanalAlfinId = 3  where expedientecreditoId = 709318

exec SGC_SP_ExpedienteCredito_Por_Id 709405

----


select top(20)  FechaCrea,FechaActua,AdvId, * from SGF_ExpedienteCredito 
-- WHERE eXPEDIENTEcreditoId = 709393
order by expedienteCreditoId desc 

exec SGC_SP_RechazadosFiltroAlFin_L 1000,7,0

SELECT * FROM SGF_ExpedienteCredito e inner join SGF_Persona p on e.TitularId = p.PersonaId
WHERE year(e.fecharechazado) = 2023 and month(e.fecharechazado)= 07 and day(e.fecharechazado)=19 and len (p.DocumentoNum) =8

 

SELECT * FROM SGF_ExpedienteCredito e inner join SGF_Persona p on e.TitularId = p.PersonaId
WHERE year(e.fechadesistio) = 2023 and month(e.fechadesistio)= 07 and day(e.fechadesistio)=19 and len (p.DocumentoNum) =8

 

SELECT * FROM SGF_ExpedienteCredito e inner join SGF_Persona p on e.TitularId = p.PersonaId
WHERE year(e.fechanocalifica) = 2023 and month(e.fechanocalifica)= 07 and day(e.fechanocalifica)=19 and len (p.DocumentoNum) =8

 

SELECT * FROM SGF_ExpedienteCredito e inner join SGF_Persona p on e.TitularId = p.PersonaId
WHERE year(e.fechanoquiere) = 2023 and month(e.fechanoquiere)= 07 and day(e.fechanoquiere)=19 and len (p.DocumentoNum) =8

SELECT FechaActua,  
                DATEDIFF(DAY, FechaActua, dbo.GETDATE())[Dias],       
                EX.*,       
                EXPC.TitularId FROM        
        (SELECT A.DocumentoNum,              
                MAX(B.ExpedienteCreditoId)[ExpedienteCreditoId]         
        FROM SGF_Persona A         
        INNER JOIN SGF_ExpedienteCredito B ON A.PersonaId = B.TitularId 
        WHERE Len(A.DocumentoNum) = 8       
        GROUP BY A.DocumentoNum) EX        
        INNER JOIN SGF_ExpedienteCredito EXPC ON EX.ExpedienteCreditoId = EXPC.ExpedienteCreditoId  
        WHERE EstadoProcesoId in (9, 10, 11, 12) and DATEDIFF(DAY, EXPC.FechaActua, @currentDate) = @limitFiltro

select SolicitudId,EstadoProcesoId,AdvId, * from sgf_expedientecredito where ExpedienteCreditoId = 709411

selec

select SolicitudId,MontoPropuesto,MontoEfectivoPro,CuotaMonto,CuotaNumero,FrecuenciaPagoId,CuotaMontoPro,CuotaNumeroPro,TasaPro, * 
from SGF_Solicitud where SolicitudId = 382915

select top(10) FechaCrea, * from sgf_expedientecredito order by ExpedienteCreditoId desc

select BancoId, * from SGF_Evaluaciones where ExpedienteCreditoId = 709221

SELECT SolicitudId,* FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = 709462

select * from sgf_adv_atencion where RegionId = 1

exec SGC_SP_ExpedienteCredito_Por_Id 709415

selec

select convert(float,226.03) CanalAlfinId

declare @advIdcall int                           
SET @advIdcall =(
  SELECT TOP(1)  a.advid                                   
  FROM sgf_adv_atencion  a                                           
  inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                                       
  inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                                        
  inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                                       
  inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1      
  where rezo.esActivo = 1 and zo.zonaid = 1 and lo.localid=1                                       
  ORDER BY a.FechaAsignacion ASC)  

UPDATE SGF_ADV_atencion                                                  
set FechaAsignacion = dbo.GETDATE()                                                  
where AdvId = @advIdcall

sp_helptext SGC_SP_Alfin_Credito_I_2

 alfin_logo.png, surgir_logo.png, mibanco_logo.png

exec SGC_SP_ExpedienteCredito_L 0,0,                                              
20,                                                         
 '',                                                         
 '',                                                                      
 0,                                                                    
 0,                                            
 1791,                                              
 29,                                              
 0,                                              
 -1,                                              
 0,                        
 -1,                                              
 0,                                              
 0,                                              
 0,                                              
 0,                                              
 '',                                              
 0,                                                         
 0,                                              
 0,
 0                     

 select * from sgf_ubigeo where CodUbigeo = 150142 and CodDpto in ('04','21','12','09')

 select FechaActua, * from SGF_ExpedienteCredito where TitularId = 609757 

 select * from sgf_persona where DocumentoNum = '21802367'

 SELECT ExpedienteCreditoLocalId, ExpedienteCreditoLocalId,AdvId, * FROM SGF_ExpedienteCredito where ExpedienteCreditoId = 709620

 select FechaActua,AdvId, * from sgf_expedientecredito 
 where ExpedienteCreditoId = 709644
 order by expedientecreditoid desc

 27/7/2023

update SGF_ExpedienteCredito set FechaActua = '2023-07-28 16:26:49.390'
WHere ExpedienteCreditoId in (709652)
 
exec SGC_SP_RechazadosFiltroAlFin_L 1000,7,0

2023-07-27 16:26:49.390

select * from SGF_ExpedienteCredito 
where expedientecreditoId = 709631

select *from sgf_evaluaciones where ExpedienteCreditoid = 709650

select * from sgf_adv where AdvId in (50,9)


SELECT TOP(1)  a.advid                                      
FROM sgf_adv_atencion  a                                              
inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                                          
inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                                           
inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                                          
inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1         
where rezo.esActivo = 1 and lo.localid= 1                                         
ORDER BY a.FechaAsignacion ASC

declare @selectAdv int = isnull((SELECT TOP(1) a.advid    
                    FROM sgf_adv_atencion  a    
                    inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId    
                    inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId    
                    inner join SGF_Local lo on lo.ZonaId = zo.ZonaId    
                    inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1    
                    where rezo.esActivo = 1 and lo.localid = 8    
                    ORDER BY a.FechaAsignacion ASC),0);

declare @advIdNuevo int = IIF(@AdvIdActual = 0,(iif(@selectAdv =0, (SELECT TOP(1) a.advid    
                    FROM sgf_adv_atencion  a    
                    inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId    
                    inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId    
                    inner join SGF_Local lo on lo.ZonaId = zo.ZonaId    
                    inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1    
                    where rezo.esActivo = 1 and lo.localid = 13   
                    ORDER BY a.FechaAsignacion ASC),@selectAdv)), @AdvIdActual);

                    select @advIdNuevo

select top(10) * from sgf_oficina where AgenciaId = 7870

select top(10) * from sgf_agencia

select * from sgf_expedientecredito where ExpedienteCreditoId = 41909103

select * from sgf_user where EmailEmpresa like '%adammo.chimbote%' -- 2, 14

SELECT LocalId [ID],                  
                   Descripcion [NAME]                                                                                                                 
            FROM  SGF_LOCAL                                                                                                                   
            WHERE esActivo = 1                          
            ORDER BY descripcion asc 

select * from sgf_local where RegionalId = 14

select convert(decimal(12,2),3*1.0 / (
  (select count(*) + 1 from SGF_Parametro where DominioId = 38 and IndicadorActivo = 1 and ValorParam = 1)))

  select * from SGF_Parametro where DominioId = 38 and IndicadorActivo = 1

  select * from sgf_tareas order by tareaid desc -- 16

  select * from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = 709851

  SupervisorId,PersonaId,TipoCompromisoId,SubTipoCompromisoId

  select * from sgf_user WHERE UserId = 784
  SELECT * FROM SGF_Supervisor where IdSupervisor = 48

  select STUFF((SELECT ', ' + CONVERT(NVARCHAR(20), BancoId) FROM SGB_Banco WHERE Activo = 1 ORDER BY BancoId DESC FOR xml path('')), 1, 1, '')

  select * from sgf_tareas

  select * from sgf_parametro where DominioId = 147 -- Tipo compromiso
  select * from sgf_parametro where DominioId = 148

  select * from sgf_dominio where DominioId in (147,148)

  1: Compromiso1

  Agendar 2,3



   13,11,3

   13,11,3
  13,11,3
   13, 11, 3

   select *from sgf_tareas order by tareaid desc
  select * from sgf_expedientecreditodetalle where ExpedienteCreditoId = 709913

   alter table sgf_tareas
   add Fecha DATE

   alter table SGF_Tareas
   drop column FechaCompromiso

select * from sgf_persona where DocumentoNum = '15150111'

select * from SGF_DatosDireccion where PersonaId = 610127

update SGF_DatosDireccion
set Direccion = 'ABCDEF'
WHERE DatosDireccionId = 809801

select ValorParam,* from SGF_Parametro where DominioId = 38 and IndicadorActivo = 1 and ValorParam = 1

select * from SGF_Parametro where DominioId = 38 and IndicadorActivo = 1 and ValorParam = 2

update SGF_Parametro
set ValorParam = 5
WHERE DominioId = 38 and ParametroId = 6

select * from sgf_expedientecredito where 
exec SGC_SP_ExpedienteCredito_Por_Id  710079

SELECT * FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = 709104

select convert(varchar,'2023-05-04',103)

delete from SGF_PlanTrabajo where IdSupervisor = 1209

delete 
from sgf_plantrabajo_detalle 
where IdPlanTrabajoDetalle in (
278916,278917,278918,278919,278920,278921,278922,278923,278924,278925,278926,278927,278928,278929,278930,278931,278932,278933,278934,278935,278936,278937,278938,278939,278940,278941,278942,278943,278944,278945,278946,278947,278948,278949,278950,278951,278952,278953,278954,278955,278956,278957,278958,278959,278960,278961,278962,278963,278964,278965,278966,278967,278968,278969,278970,278971,278972,278973,278974,278975,278976,278977,278978,278979,278980,278981,278982,278983,278984,278985,278986,278987,278988,278989,278990,278991,278992,278993,278994,278995,278996,278997,278998,278999,279000,279001,279002,279003,279004,279005,279006,279007,279008,279009,279010,279011,279012,279013,279014,279015,279016,279017,279018,279019,279020,279021,294199,294200,294201,294202,294203,294204,294205,294206,294207,294208,294209,294210,294211,294212,294213,294214,294215,294216,294217,294218,294219,296493,296494,296495,296496,296497,296498,296499,296500,296501,296502,296503,296504,296505,296506,296507,296508,296509,296510,296511,296512,296513,296514,296515,296516,296517,296518,296519,296520,296521,296522,296523,296524,296525,296526,296527,296528,296529,296530,296531,296532,296533,296534,296535,296536,296537,296538,296539,296540,296541,296542,296543,296544,296545,296546,296547,296548,296549,296550,296551,296552,296553,296554,296555,296556,296557,296558,296559,296560,296561,296562,327073,327074,327075,327076,327077,327078,327079,327080,327081,327082,327083,327084,327085,327086,327087,327088,327089,327090,327091,327092,327093,327094,327095,327096,327097,327098,327099,327100,327101,327102,327103,327104,327105,327106,327107,327108,327109,327110,335417,335418,335419,335420,335421,335422,335423,335424,335425,335426,335427,337692,337693,337694,337695,337696,337697,337698,337699,337700,337701,337702,337703,337704,337705,337706,337707,337708,337709,337710,337711,337712,337713,337714,337715,337716,337717,337718,337719,337720,337721,337722,337723,337724,337725,337726,341808,341809,341810,341811,341812,341813,341814,347479,347480,347481,347482,347483,347484,347485,347486,347487,347488,347489,347490,347491,347492,347493,347494,347495,347496,347497,347498,347499,347500,347501,347502,347503,347504,347505,347506,347507,347508,347509,347510,347511,347512,347513,347514,347515,347516,360500,360501,360502,360503,360504,360505,360506,360507,360508,360509,360510,360511,360512,360513,360514,360515,360516,360517,367059,367060,367061,367062,367063,367064,367065,367066,367067,367068,367069,367070,367071,367072,367073,367074,367075,367076,367077,367078,367079,367080,367081,367082,371092,371093,371094,371095,371096,371097,371098,382224,382225,382226,382227,382228,382229,382230,382397,382398,382399,382400,382401,382402,382403,382404,382405,382406,382407,383237,383238,383239,383240,383241,383242,383243,383244,383245,383246,383247,383248,383249,383250,383251,383252,383253,385903,385904,385905,385906,385907,385908,385909,390679,390680,390681,390682,391263,391264,391265,391266,391267,391268,391269,391270,391271,391272,391568,391569,391570,391571,391572,391573,391574,391575,391576,391577,391578,391579,391580,391581,391582,391583,391584,391585,391586,391587,391588,393099,393100,393101,393102,393103,393104,393105,393106,393107,393108,393109,393110,393111,393112,393113,393114,393115,393116,401632,401633,401634,401635,401636,401637,401638,401639,401640,401641,401642,401643,401644,401645,401646,401647,401648,401649,401650,401651,401652,401653,401654,401655,401656,401657,401658,401659,401660,401661,401662,402717,402718,403034,403035,403036,403037,403042,403043,403044,403045,403051,403052,403053,403054,403103,403104,403105,403106,403107,403108,403109,403110,403115,403116,403117,403118,403127,403128,403129,403130,403131,403132,403133,403134,403139,403140,403141,403142,403151,403152,403153,403154,403159,403160,403161,403162,403167,403168,403169,403170,403171,403172,403173,403174,403183,403184,403185,403186,403187,403188,403189,403190,403195,403196,403197,403198,403215,403216,403217,403218,403219,403220,403221,403222,403223,403224,403225,403226,403227,403228,403229,403230,403231,403232,403233,403234,403294,403295,403296,403297,403301,403302,403303,403304
)
