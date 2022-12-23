 
/*--------------------------------------------------------------------------------------                                                                                                  
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Registrados_L]                                                                                                            
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE TODOS LOS CREDITOS DE LA PERSONA, EL FILTRO ES DOCUMENTONUM                                                          
' Creado Por      : Reynaldo Cauche                                                                              
' Día de Creación :                                                                                                            
' Requerimiento   : SGC
' Cambios:          
  17/11/2022 - REYNALDO CAUCHE - Se agrego el parametro Id 
                                                                                                        
'--------------------------------------------------------------------------------------*/    

ALTER PROCEDURE [dbo].[SGC_SP_ExpedienteCredito_Registrados_L] 
( 
  @Id int
  ,@DocumentoNum varchar(12) 
) 
AS 
BEGIN

  -- Obtengo el numero de documento 
  IF (@Id > 0)
    BEGIN
      SET @DocumentoNum = (
        SELECT ISNULL(pr.DocumentoNum,'0')
        FROM SGF_ExpedienteCredito ex 
        INNER JOIN SGF_Persona pr ON ex.TitularId = pr.PersonaId
        WHERE ExpedienteCreditoId = @Id
      )
    END

  SELECT ex.ExpedienteCreditoId, ex.EstadoProcesoId 
  FROM SGF_ExpedienteCredito as ex 
  INNER JOIN SGF_Persona as pr ON pr.PersonaId = ex.TitularId 
  WHERE pr.DocumentoNum = @DocumentoNum

END