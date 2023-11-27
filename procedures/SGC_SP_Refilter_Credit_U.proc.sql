/*--------------------------------------------------------------------------------------                                                                                                                          
' Nombre          : [dbo].[SGC_SP_Refilter_Credit_U]                                                                                                                                    
' Objetivo        :                                                                                      
' Creado Por      : Reynaldo Cauche                                                                                                       
' Día de Creación : 27/10/2023                                                                                                                                     
' Requerimiento   : SGC                        
' Cambios:                                  
  - develop-rediseño 27/10/2023 - Reynaldo Cauche - Se creo el procedimiento  
'--------------------------------------------------------------------------------------*/     
ALTER PROCEDURE SGC_SP_Refilter_Credit_U(  
@cXML nvarchar(max) = '',  
@ExpedienteCreditoId int = 0,  
@UserId int = 0,  
@EstadoProcesoId int,  
@Success int = 0 OUTPUT,  
@Message varchar(800) = '' OUTPUT  
)  
AS  
    DECLARE @TblEvaluaciones TABLE (  
        Idx smallint Primary Key  IDENTITY(1,1),  
        BancoId int,  
        Observacion varchar(500),  
        ResultadoId int,  
        EsTitular bit,  
        TipoPersonaId int,  
        Ofertas varchar(500),  
        CanalAlfinId int,  
        ObservacionOfertas varchar(max),
        ObservacionOfertasAnterior varchar(max)
    );  
    DECLARE @Insertar varchar(100),  
            @nId int,  
            @MaxEvaluacionId int,  
            @PersonaId int,  
            @Observacion varchar(500),  
            @BancoId int,  
            @ResultadoId int,  
            @EsTitular bit,  
            @TipoPersonaId int,  
            @Ofertas varchar(500),  
            @CanalAlfinId int,  
            @ObservacionOfertas varchar(max), 
            @ObservacionOfertasAnterior varchar(max), 
            @DescOfertas varchar(max) = '',  
            @ItemId int,  
            @i int = 1  
BEGIN TRAN @Insertar  
  
    EXEC sp_xml_preparedocumenT @nId OUTPUT, @cXML;  
  
    INSERT INTO @TblEvaluaciones  
    SELECT  
        BancoId,  
        Observacion,  
        ResultadoId,  
        Estitular,  
        TipoPersonaId,  
        Ofertas,  
        CanalAlfinId,  
        ObservacionOfertas,
        ObservacionOfertasAnterior
    FROM openxml(@nId, 'registros/rows', 2)  
    WITH (  
        BancoId int,  
        Observacion varchar(500),  
        ResultadoId int,  
        EsTitular bit,  
        TipoPersonaId int,  
        Ofertas varchar(500),  
        CanalAlfinId int,  
        ObservacionOfertas varchar(max), 
        ObservacionOfertasAnterior varchar(max)  
    )  
  
    -- Delete Evaluaciones  
    DELETE FROM SGF_Evaluaciones WHERE ExpedienteCreditoId = @ExpedienteCreditoId  
  
    SET @MaxEvaluacionId = (SELECT MAX(EvaluacionId) FROM SGF_Evaluaciones)  
    SET @PersonaId = (SELECT TitularId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId)  
    -- SET @EstadoProcesoId = (SELECT EstadoProcesoId FROM SGF_ExpedienteCredito WHERE ExpedienteCreditoId = @ExpedienteCreditoId)  
  
    WHILE @i <= (SELECT MAX(Idx) FROM @TblEvaluaciones)  
    BEGIN  
          
        SET @MaxEvaluacionId = @MaxEvaluacionId + 1;  
        SET @Observacion = (SELECT Observacion FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @BancoId = (SELECT BancoId FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @ResultadoId = (SELECT ResultadoId FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @EsTitular = (SELECT EsTitular FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @TipoPersonaId = (SELECT TipoPersonaId FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @Ofertas = (SELECT Ofertas FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @CanalAlfinId = (SELECT CanalAlfinId FROM @TblEvaluaciones WHERE Idx = @i);  
        SET @ObservacionOfertas = (SELECT ObservacionOfertas FROM @TblEvaluaciones WHERE Idx = @i);
        SET @ObservacionOfertasAnterior = (SELECT ObservacionOfertasAnterior FROM @TblEvaluaciones WHERE Idx = @i)
  
        IF (@BancoId = 13)      
            BEGIN  
                SET @DescOfertas = @ObservacionOfertasAnterior;
            END  
  
        INSERT INTO SGF_Evaluaciones  
        VALUES (@MaxEvaluacionId,@ExpedienteCreditoId,@PersonaId,@ResultadoId,(IIF(@BancoId = 13, @ObservacionOfertas,@Observacion)),@EsTitular,@UserId,null,dbo.getDate(),null,@TipoPersonaId,@BancoId,@Ofertas,@CanalAlfinId);  
  
        SET @i = @i + 1;  
    END;  
  
    UPDATE SGF_ExpedienteCredito  
    SET FechaActua = dbo.getdate(),  
        UserIdActua = @UserId  
    WHERE ExpedienteCreditoId = @ExpedienteCreditoId  
  
    IF (@EstadoProcesoId = 2)  
        BEGIN  
            UPDATE SGF_ExpedienteCredito SET FechaProspecto = dbo.getdate() WHERE ExpedienteCreditoId = @ExpedienteCreditoId  
        END  
    ELSE IF (@EstadoProcesoId = 3)  
        BEGIN  
            UPDATE SGF_ExpedienteCredito SET FechaGestion = dbo.getdate() WHERE ExpedienteCreditoId = @ExpedienteCreditoId  
        END  
    ELSE IF (@EstadoProcesoId = 11)  
        BEGIN  
            UPDATE SGF_ExpedienteCredito SET FechaNoCalifica = dbo.getdate() WHERE ExpedienteCreditoId = @ExpedienteCreditoId  
        END  
  
    SET @ItemId = (SELECT MAX(ItemId) FROM SGF_ExpedienteCreditoDetalle WHERE ExpedienteCreditoId = @ExpedienteCreditoId)  
  
    INSERT INTO SGF_ExpedienteCreditoDetalle  
    VALUES (@ExpedienteCreditoId,@ItemId+1,@EstadoProcesoId,null,null,dbo.getdate(),null,null,null,null,@UserId,  
    'SE HA RE FILTRADO AL CLIENTE' + IIF(@DescOfertas != '', ', ' + @DescOfertas, '')   
    ,null,null,null,null,null,null,null,null,null,null,null,null)  
  
    EXEC sp_xml_removedocument @nId;    
  
    SET @Message = 'Se realizo el proceso con éxito.';  
    SET @Success = 1;  
          
          
    IF @@Error != 0          
    BEGIN          
        ROLLBACK TRAN @Insertar          
        SET @Message = 'Se produjo un error durante el procedimiento.'         
        SET @Success = 0;   
        RETURN -1;          
    END          
          
COMMIT TRAN @Insertar;