/*--------------------------------------------------------------------------------------                                                                                                                        
' Nombre          : [dbo].[SGC_SP_User_By_Id]                                                                                                                                  
' Objetivo        : Busca la informacion del usuario a traves del UserId
' Creado Por      : Reynaldo Cauche                                                                                                     
' Día de Creación : 03/11/2023                                                                                                                                   
' Requerimiento   : SGC                      
' Cambios:                                
  - develop-refilter 03/11/2023 - Reynaldo Cauche - Se creo el procedimiento
'--------------------------------------------------------------------------------------*/ 
CREATE PROCEDURE SGC_SP_User_By_Id(
    @UserId int = 0
)
AS
BEGIN
    SELECT UserId, CargoId, EmailEmpresa
    FROM SGF_User
    WHERE UserId = @UserId
END