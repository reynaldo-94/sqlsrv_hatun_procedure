ALTER PROCEDURE SGC_SP_Agencias_G
AS
BEGIN
    -- SELECT top(2) o.IdOficina as AgenciaId, ag.BancoId, IIF(o.IdOficina = 2,'agencia1.xlsx','agencia2.xlsx') as nombre,
    -- IIF(o.IdOficina = 2,'reynaldocauche@gmail.com','reynaldo.cauche@hatun.com.pe') as correo 
    -- from sgf_agencia as ag
    -- inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId
    -- where ag.Activo = 1 and o.Activo = 1 and ag.BancoId = 11

    select o.IdOficina as AgenciaId, ag.BancoId, concat(O.Nombre, '.xlsx') as Nombre, O.CorreoA as Correo
    from sgf_agencia as ag
    inner join sgf_oficina as o on ag.AgenciaId = o.AgenciaId
    where ag.BancoId = 11 and ag.Activo  = 1  and o.Activo = 1
     
END

-- EXEC SGC_SP_Agencias_G


-- ATE: julio.montero@surgir.com.pe, gemayel.curi@surgir.com.pe, mnieva@surgir.com.pe, ronald.manchego@surgir.com.pe
-- COMAS: cpadilla@surgir.com.pe, acastillo@surgir.com.pe, Grupales:rduenas@surgir.com.pe, ltorres@surgir.com.pe
-- OLIVOS: cpadilla@surgir.com.pe, acastillo@surgir.com.pe, Grupales:rduenas@surgir.com.pe, ltorres@surgir.com.pe

-- Ate
UPDATE sgf_oficina
SET CorreoA = 'reynaldocauche@gmail.com'
where IdOficina = 450

-- Comas
UPDATE sgf_oficina
SET CorreoA = 'reynaldo.cauche@hatun.com.pe'
where IdOficina = 452

-- Ate
UPDATE sgf_oficina
SET CorreoA = 'reynaldocauche@gmail.com'
where IdOficina = 453