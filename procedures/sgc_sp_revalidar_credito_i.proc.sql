-- La idea crear 2 procedimientos para revalidar credito, uno multiple y el otro personal, para solucionar los 2 casos q me dio Francisco

CREATE PROCEDURE [dbo].[SGC_SP_Revalidar_Credito_I]
(
@Observacion varchar(500),
@EvaluacionId int,
@BancoId int,
@ExpedienteCreditoId int,
@PersonaId int,
@ResultadoId int,
@EsTitular int,
@UserIdCrea int,
@FechaCrea varchar(50),
@TipoPersonaId int,
@Ofertas varchar(500),
@CanalAlFinId int
)
AS
DECLARE @NuevoEvaluacionId int;
BEGIN TRY
    BEGIN TRANSACTION

    delete from sgf_evaluaciones where EvaluacionId = @EvaluacionId

    SET @NuevoEvaluacionId = (SELECT MAX(EvaluacionId) + 1 FROM SGF_Evaluaciones)

    insert into sgf_evaluaciones values (@NuevoEvaluacionId,@ExpedienteCreditoId,@PersonaId,@ResultadoId,@Observacion,@EsTitular,@UserIdCrea,NULL,dbo.getDate(),NULL,@TipoPersonaId,@BancoId,@Ofertas,@CanalAlFinId)

    update sgf_Ex

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH