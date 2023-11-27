  
/*--------------------------------------------------------------------------------------                                                                                           
' Nombre          : [dbo].[SGC_SP_Actualizar_Estado_CredDetalle]                                                                                                            
' Objetivo        : Se creo para actualizar el proceso de los detalles que tenga procesoId = 0, se actualizo con el credito anterior al ultimo
' Creado Por      : REYNALDO CAUCHE                                                                          
' Día de Creación : 24-11-2023                                                                                                      
' Requerimiento   : SGC          
' Cambios:
'--------------------------------------------------------------------------------------*/  

CREATE PROCEDURE SGC_SP_Actualizar_Estado_CredDetalle (@ExpedienteCreditoId int)  
AS  
DECLARE @EstadoDetalleMax INT, @EstadoDistinctCero INT,@ItemdIdCero int, @ItemIdMax INT, @EstadoItemIdCero INT;  
BEGIN  
    SET @EstadoDetalleMax = (select TOP(1) ProcesoId from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId order BY ItemId desc)  
    SET @ItemdIdCero = (select TOP(1) ItemId from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId and ProcesoId = 0)  
      
  
    if (@EstadoDetalleMax = 0)  
        BEGIN  
            SET @ItemIdMax = (select TOP(1) ItemId from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId order BY ItemId desc)  
            SET @EstadoDistinctCero = (select TOP(1) ProcesoId from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId = @ExpedienteCreditoId and ProcesoId != 0 order BY ItemId desc)  
  
            UPDATE SGF_ExpedienteCreditoDetalle  
            SET ProcesoId = @EstadoDistinctCero  
            WHERE ExpedienteCreditoId = @ExpedienteCreditoId and ItemId = @ItemIdMax  
        END 
END  