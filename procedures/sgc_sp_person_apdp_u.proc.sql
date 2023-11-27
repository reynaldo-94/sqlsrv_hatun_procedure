/*--------------------------------------------------------------------------------------                                                                                                        
' Nombre          : [dbo].[SGC_SP_Person_APDP_U]                                                                                                                         
' Objetivo        : ESTE PROCEDIMIENTO ACTUALIZA LOS APDP DE LA TABLA PERSONA                                                                      
' Creado Por      : cristian silva                                                                                  
' Día de Creación : 21/02/2023                                                                                                                 
' Requerimiento   : SGC                                                                                                                  
' cambios  :          
 - 14-03-2023 - REYNALDO CAUCHE - Se cambio el nombre del procedure a SGC_SP_Person_APDP_U(estaba con SGF), se agrego el parametro @MedioAutorizacion, insert en la tabla SGF_APDP 
'--------------------------------------------------------------------------------------*/           
CREATE PROCEDURE [dbo].[SGC_SP_Person_APDP_U]          
(          
 @Documento varchar(13),          
 @APDP bit,          
 @IpAPDP  varchar(15),          
 @ModeloDispositivoAPDP  varchar(50),          
 @NavegadorAPDP  varchar(50),          
 @PubliAPDP bit, 
 @MedioAutorizacion int = 0,    
 @Success int OUTPUT,                                            
 @Message varchar(8000) OUTPUT          
)          
AS          
BEGIN          
    declare @Validate varchar(13);  
    declare @PersonaId int;   
    
    set @Validate = (select top 1 DocumentoNum from SGF_Persona where DocumentoNum = @Documento)    
    BEGIN TRY          
    BEGIN TRANSACTION          
        SET @Success = 0;     
        IF(@Validate IS NOT NULL or @Validate <> '')    
        BEGIN    
            if(len(@Documento) = 8 or len(@Documento)= 12 or len(@Documento) = 11)    
            begin 
 
                set @PersonaId = (SELECT TOP(1) PersonaId FROM SGF_Persona where DocumentoNum = @Documento) 
 
                -- Inserta tabla sgf_apdp 
                insert into SGF_APDP(PersonaId,MedioAutorizacion,APDP,IpAPDP,FechaAPDP,NavegadorAPDP,ModeloDispositivoAPDP,PubliAPDP) 
                values (@PersonaId, @MedioAutorizacion, @APDP, @IpAPDP, dbo.GETDATE(), @NavegadorAPDP,@ModeloDispositivoAPDP, @PubliAPDP) 
 
                update SGF_Persona          
                set APDP= @APDP          
                    ,FechaAPDP=dbo.getdate()          
                    ,IpAPDP = @IpAPDP          
                    ,ModeloDispositivoAPDP=@ModeloDispositivoAPDP          
                    ,NavegadorAPDP = @NavegadorAPDP        
                    ,PubliAPDP =@PubliAPDP 
                    ,MedioAutorizacion = @MedioAutorizacion        
                where DocumentoNum = @Documento          
                     
                SET @Success = 1;                                           
                SET @Message = 'OK';     
            end    
            else    
            begin    
                SET @Success = 2;                                           
                SET @Message = 'Documento no Valido';     
            end    
        END    
        ELSE    
        BEGIN    
            SET @Success = 2;                                           
            SET @Message = 'Documento no Existe';     
        END    
          
    COMMIT          
   END TRY          
   BEGIN CATCH               
      SET @Success = 0;          
      SET @Message = 'LINEA: '+ CAST(ERROR_LINE() AS VARCHAR(200))+ 'ERROR: '+ ERROR_MESSAGE()          
   END CATCH          
          
END