          
/*--------------------------------------------------------------------------------------                                                                                                                      
' Nombre          : [dbo].[SGC_Client_Login]                                                                                                                                       
' Objetivo        : Este procedimiento sirve para la otra web, me valida los datos de acceso
' Creado Por      : REYNALDO CAUCHE                                                                                                                                                                                                                                  
' Requerimiento   : SGC                                                                                                                                
' cambios  :         
 - 03-10-2022 - REYNALDO CAUCHE - Se creo el procedimiento
'                                                                                                                           
'--------------------------------------------------------------------------------------*/            
   
CREATE PROC [dbo].[SGC_Client_Login](                
 @DocumentoNum varchar(15),
 @Password varchar(200),
 @Success INT OUTPUT ,                                                      
 @Message varchar(max) OUTPUT
)                
AS                
    DECLARE @CountUser int                 
BEGIN TRY                                           
    BEGIN TRANSACTION   
        
        SET @Success = 1;                                                     
        SET @Message = 'OK'; 
        
        SET @CountUser = (SELECT Count(UserId) FROM SGF_USER where UserLogin = @DocumentoNum and UserPassword = @Password)

         IF @CountUser = 0                                                      
            BEGIN                                                      
                SET @Success = 2;                                                      
                SET @Message = 'Datos incorrectos'                      
            END
    COMMIT;      
END TRY                                              
BEGIN CATCH                                                        
    SET @Success = 0;                              
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()                                     
    ROLLBACK;                                                        
END CATCH