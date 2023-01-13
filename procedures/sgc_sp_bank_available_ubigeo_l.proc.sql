/*--------------------------------------------------------------------------------------                                                                                              
' Nombre          : [dbo].[SGC_SP_Bank_Available_Ubigeo_L]                                                                                                          
' Objetivo        : ESTE PROCEDIMIENTO ME DUELVE LOS BANCOS DISPONIBLES POR UBIGEO                                                           
' Creado Por      :                                                                             
' Día de Creación : 15-12-22                                                                                                       
' Requerimiento   : SGC                                                                                                        
' Modificado por  : REYNALDO CAUCHE                                                                                       
' Cambios :   
	15/12/2022 - Reynaldo Cauche - se creo el procedure 
    24/12/2022 - Reynaldo Cauche - Se agrego los departarmentos Piura y Arequipa a Surgir
'--------------------------------------------------------------------------------------*/              
ALTER PROCEDURE [dbo].[SGC_SP_Bank_Available_Ubigeo_L]                    
(                    
 @CodUbigeo varchar(6)                 
)                    
as 
    declare @ContUbigeoMiBanco int = 0; 
    declare @ContUbigeoSurgir int = 0; 
    declare @ContUbigeoLosAndes int = 0; 
 
BEGIN 
    -- Crear una tabla temporal de Bancos               
    CREATE TABLE #tblBancos(BancoId int,Nombre varchar(50), Activo char(2))                  
    INSERT INTO #tblBancos(BancoId, Nombre, Activo)                  
    select BancoId, Nombre, 'NO' as Activo                                                                                   
    from SGB_Banco                       
    where Activo = 1; 
 
    --MIBANCO(3) 
    SET @ContUbigeoMiBanco = ( 
        select ISNULL(COUNT(CodUbigeo),0) FROM SGF_UBIGEO WHERE CodUbigeo = @CodUbigeo 
    ) 
    update #tblBancos set Activo = IIF(@ContUbigeoMiBanco > 0,'SI','NO') where BancoId = 3 
    --SURGIR (11) 
    SET @ContUbigeoSurgir = ( 
        SELECT ISNULL(COUNT(CodUbigeo),0) 
        FROM ( 
            select CodUbigeo from SGF_UBIGEO where CodDpto='15' and CodProv='01' -- LIMA METROPOLITANA
            UNION 
            select CodUbigeo from SGF_UBIGEO where CodDpto='07' and CodProv='01' -- CALLAO
            UNION
            select CodUbigeo from SGF_UBIGEO where CodDpto in ('04','20')  -- AREQUIPA, PIURA
        ) as sr 
        where sr.CodUbigeo = @CodUbigeo 
    ) 
    update #tblBancos set Activo = IIF(@ContUbigeoSurgir > 0,'SI','NO') where BancoId = 11 
 
    -- CAJA LOS ANDES (12) 
    SET @ContUbigeoLosAndes = ( 
        -- AREQUIPA, PUNO, JUNIN, HUANCAVELICA
        select ISNULL(COUNT(CodUbigeo),0) FROM SGF_UBIGEO WHERE CodDpto in ('04','21','12','09') AND CodUbigeo = @CodUbigeo 
    ) 
    update #tblBancos set Activo = IIF(@ContUbigeoLosAndes > 0,'SI','NO') where BancoId = 12 
 
    select * from #tblBancos 
END 
 
-- EXEC SGC_SP_Bank_Available_Ubigeo_L '123'