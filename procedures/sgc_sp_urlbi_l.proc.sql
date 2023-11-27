/*--------------------------------------------------------------------------------------                                                                                                                         
' Nombre          : [dbo].[SGC_SP_UrlBi_L]                                                                                                                                          
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA MOSTRAR EL REPORTE BI                                                          
' Creado Por      :                                                                                                      
' Día de Creación :                                                                                                                                    
' Requerimiento   : SGC                                                                                                                                   
' cambios  :            
 - 14-06-2023 - REYNALDO CAUCHE - Se modifico para el regional, ahora se consulta a la tabla sgf_zona                                                                                                                            
'--------------------------------------------------------------------------------------*/     
  
CREATE PROCEDURE [dbo].[SGC_SP_UrlBi_L]     
(@TypeId int,     
 @ParameterId int)     
AS     
BEGIN     
    -- Administrador de Ventas o Jefe de Zona     
    IF (@TypeId = 4 or @TypeId = 2)     
    BEGIN     
        SELECT distinct isnull(z.RegionZonaId, 0) [RegionZonaId],     
         z.ZonaId,                 
               z.Descripcion,     
               z.UrlBI     
        FROM dbo.SGF_Zona z             
        left join sgf_jefezona jz on z.zonaid = jz.zonaid             
        WHERE z.ZonaId = @ParameterId     
    END     
 -- Jefe Regional     
    ELSE IF (@TypeId = 52)     
 BEGIN     
        -- select distinct RZ.RegionZonaId,         
        --        0 [ZonaId],     
        --  RZ.Descripcion,         
        --        RZ.UrlBI       
        -- from sgf_RegionZona RZ     
        -- WHERE RZ.RegionZonaId = 1 and     
        --    RZ.EsActivo = 1     
        select distinct 0 [RegionZonaId],  
               ZonaId,  
         Descripcion,         
               UrlBI       
        from SGF_Zona     
        WHERE ZonaId = @ParameterId  
 END     
 -- Enfermeria     
 ELSE IF (@TypeId = 50)     
 BEGIN     
     select distinct 0 [RegionZonaId],     
            0 [ZonaId],     
               'Enfermeria' [Descripcion],     
            Descripcion [UrlBI]      
     from SGF_Parametro     
     where DominioId = 126 and     
           ParametroId = 2     
 END     
 -- Asistente Convenios     
 ELSE IF (@TypeId = 27)     
 BEGIN     
     select distinct 0 [RegionZonaId],     
            0 [ZonaId],     
            'Asistente Convenios' [Descripcion],     
            Descripcion [UrlBI]      
     from SGF_Parametro     
     where DominioId = 126 and     
           ParametroId = 3     
 END     
 -- Gestion Diaria     
 ELSE IF (@TypeId = 7)     
 BEGIN     
     select 0 [RegionZonaId],     
            0 [ZonaId],     
            'Gestion Diaria' [Descripcion],     
            Descripcion [UrlBI]      
     from SGF_Parametro     
     where DominioId = 126 and     
           ParametroId = 1     
 END     
 -- General     
 ELSE     
 BEGIN     
    SELECT distinct 0 [RegionZonaId],     
                    0 [ZonaId],                 
                    'General' [Descripcion],     
                     z.UrlBI     
    FROM dbo.SGF_Zona z                      
    WHERE z.ZonaId = 6   
 END     
END