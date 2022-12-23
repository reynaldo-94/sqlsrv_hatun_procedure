/*--------------------------------------------------------------------------------------                                                                                                                                   
' Nombre          : [dbo].[SGC_SP_ExpedienteCredito_Gestion_Derivar_U]                                                                                                                                                    
' Objetivo        : ESTE PROCEDIMIENTO ACTUALIZA E INSERTA LAS TABLAS NECESARIOS PARA HACER EL CAMBIO DE ESTADO                                                        
' Creado Por      : Reynaldo Cauche                                                                                                                
' Día de Creación : 22/12/2022                                                                                                                                            
' Requerimiento   : SGC                                                                                                                                             
' Cambios:                     
  22/12/2022 - Reynaldo Cauche - Se creo el procedimiento  
'--------------------------------------------------------------------------------------*/                                                                                       
                                                                                   
ALTER PROCEDURE SGC_SP_ExpedienteCredito_Gestion_Derivar_U
@ExpedienteCreditoId int,
@UserId INT,                    
@RolId int,                              
@LocalId int,                              
@ZonaId int,            
@Success INT OUTPUT ,                                                   
@Message varchar(max) OUTPUT                                                   
as 
    declare @advId int
    declare @advIdrol int
    declare @titularId int
    declare @ItemId int 
BEGIN TRY                                        
    BEGIN TRANSACTION                                                     
                                                          
        SET @Success = 0;                                                  
        SET @Message = '';

        SET @titularId = (select sec.TitularId from SGF_ExpedienteCredito sec where sec.ExpedienteCreditoId = @ExpedienteCreditoId);
        set @ItemId =( select ISNULL(MAX(ItemId) + 1,1) from SGF_ExpedienteCreditoDetalle where ExpedienteCreditoId=@ExpedienteCreditoId);

        SET @advId =(SELECT TOP(1) a.advid                         
                    FROM sgf_adv_atencion  a                             
                    inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                         
                    inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                          
                    inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                         
                    inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                           
                    where rezo.esActivo = 1 and zo.zonaid = @ZonaId and lo.localid=@LocalId                         
                    ORDER BY a.FechaAsignacion ASC);
        set @advIdrol = isnull((select  AdvId from SGF_ExpedienteCredito where expedienteCreditoId =@ExpedienteCreditoId),0); 

        IF (@advId > 0 and @RolId = 29)--supervisor
            BEGIN
                if(@advIdrol = 0)
                    BEGIN
                        UPDATE SGF_ExpedienteCredito                                                    
                        SET EstadoProcesoId  = 3 ,                                                 
                            FechaAgenda = dbo.GETDATE(),                                               
                            FechaGestion = dbo.GETDATE(),                                   
                            FechaActua = dbo.GETDATE(),                 
                            UserIdActua = @UserId,    
                            AdvId = @advId               
                        WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;

                        UPDATE SGF_Persona                                                    
                        SET EstadoPersonaId  = 3 ,                                                                  
                            FechaActua = dbo.GETDATE(),                 
                            UserIdActua = @UserId                 
                        WHERE PersonaId  = @titularId;     
                                                                         
                        INSERT INTO SGF_ExpedienteCreditoDetalle      
                            (ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                 
                        VALUES      
                            (@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')
                        
                        UPDATE SGF_ADV_atencion                             
                        set FechaAsignacion = dbo.GETDATE()                     
                        where AdvId = @advId;

                        SET @Success = 1;                                                   
                        SET @Message = 'OK'
                    END 
                
                if(@advIdrol > 0)  
                    BEGIN
                        UPDATE SGF_ExpedienteCredito                                                    
                        SET EstadoProcesoId  = 3 ,                                                 
                            FechaAgenda = dbo.GETDATE(),                                               
                            FechaGestion = dbo.GETDATE(),                                   
                            FechaActua = dbo.GETDATE()                                   
                        WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;

                        UPDATE SGF_Persona                                             
                        SET EstadoPersonaId  = 3 ,                                                                  
                            FechaActua = dbo.GETDATE(),                 
                            UserIdActua = @UserId                 
                        WHERE PersonaId  = @titularId;

                        INSERT INTO SGF_ExpedienteCreditoDetalle      
                            (ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                                                           
                        VALUES      
                            (@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')

                        SET @Success = 1;                                                   
                        SET @Message = 'OK'
                    END
            END 
        ELSE      
            BEGIN                                                   
                SET @Success = 2;   
                SET @Message = ''+'No se puede enviar a Gestión, por que no hay ADV Registrado'                                                         
            END

        IF(@advIdrol > 0 and @RolId = 4)--adv                         
            BEGIN                         
                UPDATE SGF_ExpedienteCredito                                                    
                SET EstadoProcesoId  = 3 ,                                                 
                FechaAgenda = dbo.GETDATE(),                                               
                FechaGestion = dbo.GETDATE(),                           
                FechaActua = dbo.GETDATE()                                  
                WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;

                UPDATE SGF_Persona                                                    
                SET EstadoPersonaId  = 3 ,                                                                  
                FechaActua = dbo.GETDATE(),                 
                UserIdActua = @UserId                 
                WHERE PersonaId  = @titularId;

                INSERT INTO SGF_ExpedienteCreditoDetalle      
                    (ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                     
                VALUES      
                    (@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')

                UPDATE SGF_ADV_atencion                             
                set FechaAsignacion = dbo.GETDATE()                             
                where AdvId = @advIdrol;

                SET @Success = 1;                                                   
                SET @Message = 'OK'
            END

        IF( @RolId = 11)--call center                      
        BEGIN      
            declare @advIdcall int      
            SET @advIdcall =(SELECT TOP(1) a.advid                         
                            FROM sgf_adv_atencion  a                             
                            inner join SGF_RegionZona rezo on rezo.RegionZonaId = a.RegionId                         
                            inner join SGF_Zona zo on zo.RegionZonaId = rezo.RegionZonaId                          
                            inner join SGF_Local lo on lo.ZonaId = zo.ZonaId                         
                            inner join sgf_adv ad on ad.AdvId = a.AdvId and ad.EsActivo = 1                           
                            where rezo.esActivo = 1 and zo.zonaid = 6 and lo.localid=13                         
                            ORDER BY a.FechaAsignacion ASC) 

            UPDATE SGF_ExpedienteCredito                                                    
            SET EstadoProcesoId  = 3 ,                                                 
                FechaAgenda = dbo.GETDATE(),                                               
                FechaGestion = dbo.GETDATE(),                                   
                FechaActua = dbo.GETDATE(),                 
                UserIdActua = @UserId,      
                AdvId = @advIdcall        
            WHERE ExpedienteCreditoId  = @ExpedienteCreditoId;

            UPDATE SGF_Persona                                                    
            SET EstadoPersonaId  = 3 ,                                                                  
                FechaActua = dbo.GETDATE(),
                UserIdActua = @UserId
            WHERE PersonaId  = @titularId;

            INSERT INTO SGF_ExpedienteCreditoDetalle      
                (ExpedienteCreditoId,ItemId,ProcesoId,Fecha,DiaAgenda,UsuarioId,Observacion)                 
            VALUES      
                (@ExpedienteCreditoId,@ItemId,3,dbo.GETDATE(),cast(dbo.GETDATE() as date),@UserId,'SE ENVIO A GESTIÓN DESDE PROSPECTO')  

            UPDATE SGF_ADV_atencion                             
            set FechaAsignacion = dbo.GETDATE()                             
            where AdvId = @advIdcall;

            SET @Success = 1;                                                   
            SET @Message = 'OK' 
        END          
   COMMIT;   
END TRY                                           
BEGIN CATCH                                                     
    SET @Success = 0;                           
    SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(200)) + ' ERROR: ' + ERROR_MESSAGE()                                                   
    ROLLBACK;                                                     
END CATCH