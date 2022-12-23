/*--------------------------------------------------------------------------------------                                                                                                                       
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Reconfirmacion_Maestros_L]                                                                                                                                        
' Objetivo        : Obtiene la data de las tablas maestras y devuelve mas de 2 campos(no solo el nombre y el id)
' Creado Por      : REYNALDO CAUCHE                                                                                                      
' Día de Creación : 12-10-2022                                                                                                                                    
' Requerimiento   : SGC                                                                                                                                 
' Modificado por  : Reynaldo Cauche                                                                                                               
'--------------------------------------------------------------------------------------*/                                                                   
CREATE PROCEDURE SGC_SP_ExpedienteCredito_Reconfirmacion_Maestros_L
(
    @DominioId int
)                                 
AS                                     
BEGIN
    SELECT DominioId, ParametroId, NombreLargo, NombreCorto, ValorParam
    FROM SGF_Parametro
    WHERE DominioId = @DominioId AND IndicadorActivo = 1
END  