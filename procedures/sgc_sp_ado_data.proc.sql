CREATE PROCEDURE SGC_SP_ADO_DATA(  
 @AdoId int,  
 @ExpedienteCreditoId int,  
 @Name varchar(8000) OUTPUT,  
 @Email varchar(8000) OUTPUT,  
 @Content varchar(max) OUTPUT  
)  
as  
 declare @Bank varchar(8000)  
 declare @AprobationDate varchar(8000)  
 declare @Document varchar(8000)  
 declare @MontoE varchar(8000)  
 declare @MontoM varchar(8000)  
 declare @Phone varchar(8000)  
 declare @PersonId varchar(8000)  
begin  
 set @Name = (select Nombre from SGF_ADV where AdvId = @AdoId);  
 set @Email = (select Email from SGF_ADV where AdvId = @AdoId);  
 set @AprobationDate = (select FORMAT (ss.FechaAprobacion , 'dd/MM/yyyy ') from SGF_Solicitud ss where ss.SolicitudId  
       = @ExpedienteCreditoId);  
 set @MontoE = (select ss.MontoEfectivoApro from SGF_Solicitud ss where ss.SolicitudId  
       = @ExpedienteCreditoId);  
 set @MontoM = (select ss.MontoMaterialApro from SGF_Solicitud ss where ss.SolicitudId  
       = @ExpedienteCreditoId);  
 set @Document = (select sp.DocumentoNum from SGF_persona sp inner join SGF_Solicitud se  
     on se.PersonaId = sp.PersonaId where se.SolicitudId = @ExpedienteCreditoId);  
 set @PersonId = (select sp.PersonaId from SGF_persona sp inner join SGF_Solicitud se  
     on se.PersonaId = sp.PersonaId where se.SolicitudId = @ExpedienteCreditoId);  
 set @Phone = (select sp.Celular from SGF_persona sp inner join SGF_Solicitud se  
     on se.PersonaId = sp.PersonaId where se.SolicitudId = @ExpedienteCreditoId);  
 set @Bank = (select sb.Nombre from SGF_Solicitud ss inner join SGF_Agencia sa on sa.AgenciaId =  
     ss.AgenciaId inner join SGB_Banco sb on sb.BancoId = sa.BancoId where ss.SolicitudId = @ExpedienteCreditoId);  
 set @Content = (select CONCAT(@AprobationDate , ' /**/ ' ,@Name , ' /**/ ' ,@Document , ' /**/ ',@Bank , ' /**/ '  
      ,@MontoE , ' /**/ ',@MontoM , ' /**/ ',sp.Descripcion, '/**/', YEAR(GETDATE()), ' /**/ ' , @Phone, '/**/' , @PersonId)  
      from SGF_Parametro sp inner join SGF_Dominio sd on sp.DominioId   
      = sd.DominioId where sp.DominioId = 123 and sp.ParametroId = 3);  
end