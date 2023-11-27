ALTER PROCEDURE SGC_SP_Alfin_Log_I  
(@cXML nvarchar(max),                 
 @Success int OUTPUT,                         
 @Message varchar(8000) OUTPUT)                         
AS                   
DECLARE @Insertar varchar(100),            
  @nId INT;            
            
BEGIN TRAN @Insertar          
          
EXEC sp_xml_preparedocumenT @nId OUTPUT, @cXML;          
              
INSERT INTO SGF_LOG (ExpedienteCreditoId, Resultado, FechaCrea)          
select          
    expedienteCreditoId,          
    resultado,          
    dbo.getDate()          
from openxml(@nId, 'registros/rows', 2)          
with          
(expedienteCreditoId int,        
resultado text        
)          
          
COMMIT TRAN @Insertar