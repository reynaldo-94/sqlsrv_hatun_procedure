  
/*--------------------------------------------------------------------------------------                                                                                           
' Nombre          : [dbo].[sgc_sp_actualizar_creditos]                                                                                                            
' Objetivo        : Se creo para actualizar los creditos que esten mal asignado al ADO (por su local)
' Creado Por      : REYNALDO CAUCHE                                                                          
' Día de Creación : 24-11-2023                                                                                                      
' Requerimiento   : SGC          
' Cambios:
'--------------------------------------------------------------------------------------*/  

CREATE PROCEDURE sgc_sp_actualizar_creditos (@LocalId int)   
AS  
    declare @expedienteCreditoId  int, @advIdNuevo int,  @i int = 1; ;  
begin  
  
    DECLARE @tblExpedientes TABLE (            
        idx smallint Primary Key IDENTITY(1,1),            
        expedienteCreditoId int ,            
        advid int,            
        localId int           
    )            
              
    --EXEC sp_xml_preparedocumenT @nId OUTPUT, @cXML;            
  
 SET @advIdNuevo = (select A.advId    from SGF_ADV_Atencion A   inner join SGF_ADV B on A.AdvId = B.AdvId   inner join SGF_Zona C on C.ZonaId = B.ZonaId   inner join SGF_Local D on D.LocalId = B.LocalId   where D.LocalId = @LocalId and RegionId != 6)  
              
    insert into @tblExpedientes  
 select a.ExpedienteCreditoId,            
        a.AdvId,            
        localId   from SGF_ExpedienteCredito A  left join SGF_ADV B on A.AdvId = B.AdvId  where A.ExpedienteCreditoLocalId = @LocalId  and B.LocalId != @LocalId  and EstadoExpedienteId = 1  and A.TipoBanca != 2  
  
    WHILE @i <= (select MAX(idx) from @tblExpedientes)            
    BEGIN       
        SET @expedienteCreditoId = (SELECT expedientecreditoid FROM @tblExpedientes WHERE idx = @i)  
  
        update sgf_expedientecredito  
        set AdvId = @advIdNuevo  
        WHERE ExpedienteCreditoId = @expedienteCreditoId  
  
  SET @i = @i + 1      
  
    END  
              
      
end