             
/*--------------------------------------------------------------------------------------                                                               
' Nombre          : [dbo].[SGC_SP_CREDITO_APROBADO_DATA]                                                                                
' Objetivo        : Este procedimiento obtiene los datos del credito para enviar al correo                                    
' Creado Por      : Reynaldo Cauche                                             
' Día de Creación : 18-07-2022                                                                         
' Requerimiento   : SGC                                                                         
' Cambios: 
  07/09/2022 - REYNALDO CAUCHE - Se agrego el Top(1) al supervisor
  22/09/2022 - REYNALDO CAUCHE - Se modifico la consulta para obtener el email, el where estaba mal                                                        
'--------------------------------------------------------------------------------------*/                     
ALTER PROCEDURE SGC_SP_CREDITO_APROBADO_DATA(               
 @SolicitudId int,       
 @Name varchar(1000) OUTPUT,       
 @Email varchar(500) OUTPUT,       
 @Supervisor varchar(1000) OUTPUT,       
 @TemplateId varchar(50) OUTPUT            
)               
as              
begin               
 set @Name = (SELECT TOP(1) pr.Nombre       
              FROM SGF_Solicitud sl       
              INNER JOIN SGF_Persona pr ON pr.PersonaId = sl.PersonaId       
              WHERE sl.SolicitudId = @SolicitudId);       
 set @Email = (SELECT TOP(1) pr.Correo       
              FROM SGF_Solicitud sl       
              INNER JOIN SGF_Persona pr ON pr.PersonaId = sl.PersonaId       
              WHERE sl.SolicitudId = @SolicitudId)     
 set @Supervisor = (SELECT TOP(1) sp.Nombre       
                    FROM SGF_Solicitud sl       
                    INNER JOIN SGF_ExpedienteCredito ex ON sl.SolicitudId = ex.SolicitudId       
                    INNER JOIN SGF_Supervisor sp ON ex.IdSupervisor = sp.IdSupervisor       
                    WHERE sl.SolicitudId = @SolicitudId)     
 set @TemplateId = (Select ValorParam from SGF_Parametro sp where sp.DominioId = 123 and sp.ParametroId = 11);       
end