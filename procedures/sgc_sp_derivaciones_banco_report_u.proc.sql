/*-------------------------------------------------------------------------------------- 
' Nombre        : [dbo].[SGC_SP_Derivaciones_Banco_Report_U] 
' Objetivo      : Actualizar FechaDescarga luego de descargar el Reporte de Derivaciones 
' Creado Por    : FRANCISCO LAZARO 
' Día Creación  : 20-10-2022 
' Requerimiento : SGC 
' Modificado por:  
' Cambios       : 
'--------------------------------------------------------------------------------------*/   
CREATE PROCEDURE [dbo].[SGC_SP_Derivaciones_Banco_Report_U] 
(@ExpedienteCreditoId INT,         
 @Success INT OUTPUT,         
 @Message VARCHAR(8000) OUTPUT) 
AS 
BEGIN 
    BEGIN TRY         
        BEGIN TRANSACTION 
        SET @Success = 0; 
 
		UPDATE SGF_ExpedienteCredito 
		SET FechaDescarga = dbo.getdate() 
		WHERE ExpedienteCreditoId = @ExpedienteCreditoId 
         
        SET @Success = 1;         
        SET @Message = 'OK'         
        COMMIT; 
    END TRY         
    BEGIN CATCH         
        SET @Success = 0;         
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()         
        ROLLBACK;         
    END CATCH 
END