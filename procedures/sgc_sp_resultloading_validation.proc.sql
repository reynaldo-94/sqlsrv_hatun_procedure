/*--------------------------------------------------------------------------------------                                                                                 
' Nombre          : [dbo].[SGC_SP_ResultLoading_Validation]                                                                                                  
' Objetivo        :                                
' Creado Por      : FRANCISCO LAZARO                                                                   
' Día de Creación : 28-02-2022                                                                                              
' Requerimiento   : SGC
' Cambios:           
  21/04/2022 - REYNALDO CAUCHE - Para el caso de Surgir se cambio de Left Join sgf_user a Inner join                                                                         
'--------------------------------------------------------------------------------------*/                             
ALTER PROCEDURE [dbo].[SGC_SP_ResultLoading_Validation]            
(@BancoId int,            
 @ExpedienteCreditoId varchar(max),            
 @Estado varchar(max),          
 @Pagina int,          
 @Tamanio int,          
 @Success int output)            
AS            
BEGIN            
    SET @Success = 0          
    DECLARE @TABLEEXPCRED table(Id int identity(1,1), ExpedienteCreditoId int)           
    DECLARE @TABLEESTADO table(Id int identity(1,1), Estado varchar(50))          
              
    INSERT INTO @TABLEEXPCRED SELECT IIF(Result = 'null', '', Result) from FN_StrToTable(@ExpedienteCreditoId,',')          
    INSERT INTO @TABLEESTADO SELECT IIF(Result = 'null', '', Result) from FN_StrToTable(@Estado,',')        
         
    DECLARE @TABLEEXPCRED_COUNT int = (select COUNT(*) from @TABLEEXPCRED)        
            
    IF @BancoId = 3            
    BEGIN            
        SET @Success = 1          
        SELECT ISNULL(EXPC.BancoId, 0) [BancoId],            
               ISNULL(A.ExpedienteCreditoId, 0) [ExpedienteCreditoId],            
               ISNULL(EXPC.EstadoProcesoId, 0) [EstadoProcesoId],            
               ISNULL(EST.NombreLargo, '') [EstadoProcesoNombre],          
               ISNULL(B.Estado, '') [EstadoBancoNombre],         
               ISNULL(PER.DocumentoNum, '') [DocumentoNum],         
               ISNULL(PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno, '') [NombreCompleto],         
               IIF(EXPC.BancoId <> @BancoId, 'OP no pertenece a Banco',             
                   IIF((UPPER(B.Estado) = 'DESEMBOLSO' and EXPC.EstadoProcesoId not in (5, 9, 10, 16)) or             
                       (UPPER(B.Estado) = 'CERRADO' and EstadoProcesoId not in (5)) or             
                       (UPPER(B.Estado) = 'RECHAZADO' and EXPC.EstadoProcesoId not in (5)) or      
					   (UPPER(B.Estado) in ('EVALUACION', 'PRE-PRESTAMO', 'REVISION', '') and EXPC.EstadoProcesoId not in (5)), 'OP se encuentra en estado ' + EST.NombreLargo,            
                       IIF(UPPER(B.Estado) in ('EVALUACION', 'PRE-PRESTAMO', 'REVISION', '') and EXCD.ItemId IS NOT NULL, 'Comentario ya Agregado anteriormente',           
                           IIF(UPPER(B.Estado) not in ('DESEMBOLSO', 'CERRADO', 'RECHAZADO', 'EVALUACION', 'PRE-PRESTAMO', 'REVISION', ''), 'Estado no válido',           
                               IIF(EXPC.ExpedienteCreditoId is NULL, 'NOP no válido', 'Correcto')))))[Observacion],             
               IIF(EXPC.BancoId <> @BancoId, 0,             
                   IIF((UPPER(B.Estado) = 'DESEMBOLSO' and EXPC.EstadoProcesoId not in (5, 9, 10, 16)) or             
                       (UPPER(B.Estado) = 'CERRADO' and EstadoProcesoId not in (5)) or             
                       (UPPER(B.Estado) = 'RECHAZADO' and EXPC.EstadoProcesoId not in (5)) or      
					   (UPPER(B.Estado) in ('EVALUACION', 'PRE-PRESTAMO', 'REVISION', '') and EXPC.EstadoProcesoId not in (5)), 0,            
                       IIF(UPPER(B.Estado) in ('EVALUACION', 'PRE-PRESTAMO', 'REVISION', '') and EXCD.ItemId IS NOT NULL, 0,          
                           IIF(UPPER(B.Estado) not in ('DESEMBOLSO', 'CERRADO', 'RECHAZADO', 'EVALUACION', 'PRE-PRESTAMO', 'REVISION', ''), 0,           
                               IIF(EXPC.ExpedienteCreditoId is NULL, 0, 1)))))[EsValido]     
        FROM @TABLEEXPCRED A          
        LEFT JOIN @TABLEESTADO B ON A.Id = B.Id          
        LEFT JOIN SGF_ExpedienteCredito EXPC ON A.ExpedienteCreditoId = EXPC.ExpedienteCreditoId        
        LEFT JOIN SGF_Persona PER ON EXPC.TitularId = PER.PersonaId        
        LEFT JOIN SGF_Parametro EST on EXPC.EstadoProcesoId = EST.ParametroId and EST.DominioId = 38          
        LEFT JOIN (SELECT EXCD.ExpedienteCreditoId, MAX(ItemId)[ItemId]          
                   FROM @TABLEEXPCRED A          
                   INNER JOIN @TABLEESTADO B ON A.Id = B.Id          
                   INNER JOIN SGF_ExpedienteCreditoDetalle EXCD ON A.ExpedienteCreditoId = EXCD.ExpedienteCreditoId          
                   INNER JOIN SGF_USER US ON EXCD.UsuarioId = US.UserId and US.CargoId = 48 and US.IsActive = 1           
                   where UPPER(EXCD.Observacion) like IIF(B.Estado = '', 'NO CONTACTADO%', UPPER(B.Estado + '%'))          
                   GROUP BY EXCD.ExpedienteCreditoId) EXCD ON A.ExpedienteCreditoId = EXCD.ExpedienteCreditoId          
        ORDER BY A.ExpedienteCreditoId desc              
        OFFSET @Pagina * IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS FETCH NEXT IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS ONLY;              
    END            
    ELSE IF @BancoId = 11            
    BEGIN          
        SET @Success = 1          
        SELECT ISNULL(EXPC.BancoId, 0) [BancoId],            
               ISNULL(A.ExpedienteCreditoId, 0) [ExpedienteCreditoId],            
               ISNULL(EXPC.EstadoProcesoId, 0) [EstadoProcesoId],            
               ISNULL(EST.NombreLargo, '') [EstadoProcesoNombre],          
               ISNULL(B.Estado, '') [EstadoBancoNombre],         
               ISNULL(PER.DocumentoNum, '') [DocumentoNum],         
               ISNULL(PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno, '') [NombreCompleto],        
               IIF(EXPC.BancoId <> @BancoId, 'OP no pertenece a Banco',             
                   IIF((UPPER(B.Estado) = 'DESEMBOLSADO' and EXPC.EstadoProcesoId not in (5, 9, 10, 16)) or             
                       (UPPER(B.Estado) = 'DESISTIO' and EstadoProcesoId not in (5)) or             
                       (UPPER(B.Estado) = 'RECHAZADO' and EXPC.EstadoProcesoId not in (5)) or      
					   (UPPER(B.Estado) in ('EVALUACION', 'PENDIENTE', '') and EXPC.EstadoProcesoId not in (5)), 'OP se encuentra en estado ' + EST.NombreLargo,            
                       IIF(UPPER(B.Estado) in ('EVALUACION', 'PENDIENTE', '') and EXCD.ItemId IS NOT NULL, 'Comentario ya Agregado anteriormente',           
                           IIF(UPPER(B.Estado) not in ('DESEMBOLSADO', 'DESISTIO', 'RECHAZADO', 'EVALUACION', 'PENDIENTE', ''), 'Estado no válido',           
                               IIF(EXPC.ExpedienteCreditoId is NULL, 'NOP no válido', 'Correcto')))))[Observacion],
               IIF(EXPC.BancoId <> @BancoId, 0,             
                   IIF((UPPER(B.Estado) = 'DESEMBOLSADO' and EXPC.EstadoProcesoId not in (5, 9, 10, 16)) or             
                       (UPPER(B.Estado) = 'DESISTIO' and EstadoProcesoId not in (5)) or             
                       (UPPER(B.Estado) = 'RECHAZADO' and EXPC.EstadoProcesoId not in (5)) or      
					   (UPPER(B.Estado) in ('EVALUACION', 'PENDIENTE', '') and EXPC.EstadoProcesoId not in (5)), 0,            
                       IIF(UPPER(B.Estado) in ('EVALUACION', 'PENDIENTE', '') and EXCD.ItemId IS NOT NULL, 0,          
                           IIF(UPPER(B.Estado) not in ('DESEMBOLSADO', 'DESISTIO', 'RECHAZADO', 'EVALUACION', 'PENDIENTE', ''), 0,           
                           IIF(EXPC.ExpedienteCreditoId is NULL, 0, 1)))))[EsValido]
        FROM @TABLEEXPCRED A          
        LEFT JOIN @TABLEESTADO B ON A.Id = B.Id          
        LEFT JOIN SGF_ExpedienteCredito EXPC ON A.ExpedienteCreditoId = EXPC.ExpedienteCreditoId          
        LEFT JOIN SGF_Persona PER ON EXPC.TitularId = PER.PersonaId        
        LEFT JOIN SGF_Parametro EST on EXPC.EstadoProcesoId = EST.ParametroId and EST.DominioId = 38          
        LEFT JOIN (SELECT EXCD.ExpedienteCreditoId, MAX(ItemId)[ItemId]          
                   FROM @TABLEEXPCRED A          
                   INNER JOIN @TABLEESTADO B ON A.Id = B.Id          
                   INNER JOIN SGF_ExpedienteCreditoDetalle EXCD ON A.ExpedienteCreditoId = EXCD.ExpedienteCreditoId          
                   INNER  JOIN SGF_USER US ON EXCD.UsuarioId = US.UserId and US.CargoId = 48 and US.IsActive = 1           
                   where UPPER(EXCD.Observacion) like IIF(B.Estado = '', 'NO CONTACTADO%', UPPER(B.Estado + '%'))          
                   GROUP BY EXCD.ExpedienteCreditoId) EXCD ON A.ExpedienteCreditoId = EXCD.ExpedienteCreditoId            
        ORDER BY A.ExpedienteCreditoId desc              
        OFFSET @Pagina * IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS FETCH NEXT IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS ONLY;          
    END            
    ELSE            
    BEGIN            
        SELECT ISNULL(EXPC.BancoId, 0) [BancoId],            
               ISNULL(A.ExpedienteCreditoId, 0) [ExpedienteCreditoId],            
               ISNULL(EXPC.EstadoProcesoId, 0) [EstadoProcesoId],            
               ISNULL(EST.NombreLargo, '') [EstadoProcesoNombre],         
               ISNULL(B.Estado, '') [EstadoBancoNombre],            
               ISNULL(PER.DocumentoNum, '') [DocumentoNum],         
               ISNULL(PER.Nombre + ' ' + PER.ApePaterno + ' ' + PER.ApeMaterno, '') [NombreCompleto],        
               'Banco indicado no habilitado para validación de datos' [Observacion],             
               0 [EsValido]           
        FROM @TABLEEXPCRED A          
        LEFT JOIN @TABLEESTADO B ON A.Id = B.Id          
        LEFT JOIN SGF_ExpedienteCredito EXPC ON A.ExpedienteCreditoId = EXPC.ExpedienteCreditoId          
        LEFT JOIN SGF_Persona PER ON EXPC.TitularId = PER.PersonaId        
        LEFT JOIN SGF_Parametro EST on EXPC.EstadoProcesoId = EST.ParametroId and EST.DominioId = 38            
        ORDER BY A.ExpedienteCreditoId desc              
        OFFSET @Pagina * IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS FETCH NEXT IIF(@Tamanio <= 0, @TABLEEXPCRED_COUNT, @Tamanio) ROWS ONLY;          
    END            
END