/*--------------------------------------------------------------------------------------                                                                                                                          
' Nombre          : [dbo].[SGF_SP_NotificationPush_Token_G]                                                                                                                                           
' Objetivo        :  obtiene el token                                                                                      
' Creado Por      : cristian silva                                                                                                    
' Día de Creación : 20/03/2023                                                                                                                               
' Requerimiento   : SGC                                                                                                                                    
                            
'--------------------------------------------------------------------------------------*/                             
CREATE PROCEDURE [dbo].[SGC_SP_NotificationPush_Token_G]                            
(                            
 @UserId int = 0      
 ,@NotiTotalUnRead INT OUTPUT      
)                            
AS                            
BEGIN     
    
 SET @NotiTotalUnRead = (select isnull(count(N.IdUsuario),0)                     
                   from SGF_Notificacion N                  
                      inner join SGF_Parametro TN on TN.ParametroId=N.IdTipoNotificacion and TN.DominioId=144                  
                      inner join SGF_USER U on U.UserId=N.UserIdCrea                  
                   where N.IdUsuario = @UserId and isnull(N.Leido,0) = 0                
                  );     
              
 select           
    ustok.Token [TokenId]      
 ,ustok.DispositivoId      
 from SGF_USER_TOKEN ustok          
    inner join SGF_USER us on us.UserId =  ustok.UserId          
 where ustok.UserId =  @UserId                 
END 