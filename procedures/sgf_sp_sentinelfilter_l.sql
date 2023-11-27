/*--------------------------------------------------------------------------------------                                                                                                                    
' Nombre          : [dbo].[SGF_SP_SentinelFilter_L]                                                                                                                                     
' Objetivo        :                                                                                 
' Creado Por      :                                                                                             
' Día de Creación :                                                                                                                            
' Requerimiento   : SGC                                                                                                                              
' cambios  :                      
 - 12-07-2023 - REYNALDO CAUCHE - Se agrego las columnas ofertas          
 - 26/07/2023 - REYNALDO CAUCHE - Se agrego el parametro UserIdCrea, se agrego validacion, para Roles ADO(4) y Call center(11) mostrar todos los bancos activos, cuando sea roles distintos a addv y call no mostrar banco alFin(13)          
'--------------------------------------------------------------------------------------*/                       
CREATE PROCEDURE SGF_SP_SentinelFilter_L         
(@ExpedienteCreditoId int,          
 @UserIdCrea int = 0,                
 @Success int OUTPUT)                      
AS                      
BEGIN              
    DECLARE @RolId INT = (SELECT CargoId FROM SGF_USER WHERE UserId = @UserIdCrea);        
    DECLARE @RegionZonaId INT = IIF(@RolId != 52, 0, (SELECT RegionZonaId FROM SGF_User US        
                                                      LEFT JOIN SGF_JefeRegional JR ON JR.JefeRegionalId = US.EmpleadoId        
                                                      LEFT JOIN SGF_RegionZona RZ ON RZ.RegionZonaId = JR.RegionId        
                                                      WHERE US.UserId = @UserIdCrea))        
          
    IF (@RolId IS NULL)         
    BEGIN         
     SET @RolId = 0         
    END          
          
    SET @Success = (SELECT COUNT(*) FROM SGF_Evaluaciones                    
                    WHERE ExpedienteCreditoId = @ExpedienteCreditoId)              
                          
    SELECT A.BancoId,                     
           UPPER(A.Nombre) [BancoNombre],                  
           A.Logo [BancoLogo],                  
           IIF((select COUNT(*) from SGF_Evaluaciones X where X.ExpedienteCreditoId = @ExpedienteCreditoId and X.BancoId = A.BancoId) > 0,                     
               IIF((select COUNT(*) from SGF_Evaluaciones X where X.ExpedienteCreditoId = @ExpedienteCreditoId and X.BancoId = A.BancoId and (X.ResultadoId = 3 or X.ResultadoId = 1)) > 0, '2', '1'),                    
               '0') [Authorizated],                    
           B.TipoPersonaId,                     
           C.NombreLargo [TipoPersonaDesc],                  
           B.ExpedienteCreditoId,                    
           B.PersonaId,                     
           B.ResultadoId,                     
           ISNULL(B.Observacion, 'No cuenta con validación para este banco')[Observacion],             
           ISNULL(b.Ofertas, 'No cuenta con campañas')[Oferta],             
           ISNULL(b.CanalAlfinId, 0)[CanalAlfinId]             
    FROM SGB_Banco A        
    LEFT JOIN SGF_Evaluaciones B on A.BancoId = B.BancoId and B.ExpedienteCreditoId = @ExpedienteCreditoId                   
    LEFT JOIN SGF_Parametro C on B.TipoPersonaId = C.ParametroId and C.DominioId = 6        
    WHERE A.Activo = 1             
    --  Sean Roles ADO(4) y Call center(11) mostrar todos los bancos activos, cuando sea roles distintos a addv y call no mostrar banco alFin(13)          
    AND (@RolId in (4, 11, 1, 56) or (@RolId = 52 and @RegionZonaId in (6))) or ((@RolId not in (4, 11, 1, 56) and not (@RolId = 52 and @RegionZonaId in (6))) and A.Activo = 1 and A.BancoId != 13)        
    AND (@RolId in (4, 11, 1, 56) or (@RolId = 52 and @RegionZonaId in (6))) or ((@RolId not in (4, 11, 1, 56) and not (@RolId = 52 and @RegionZonaId in (6))) and A.Activo = 1)        
    ORDER BY BancoId DESC                    
END