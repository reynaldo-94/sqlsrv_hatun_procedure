ALTER PROCEDURE SGC_SP_Remove_Duplicate_DNI(
    @Success int OUTPUT,                     
    @Message varchar(8000) OUTPUT
)
AS
    DECLARE @tblPersonas TABLE (
        idx SMALLINT PRIMARY KEY IDENTITY(1,1),
        documentoNum varchar(20)
    )
    DECLARE @personaIdAntigua INT,
            @documentoNum varchar(20),
            @i INT = 1;
BEGIN
    BEGIN TRY                                         
        BEGIN TRANSACTION                                     
            SET @Success = 0; 

            -- Insert TblPersonas
            INSERT INTO @tblPersonas
            SELECT DocumentoNum AS documentoNum
            FROM SGF_Persona
            -- WHERE DocumentoNum = '41585703'
            GROUP BY DocumentoNum
            HAVING COUNT(*) > 1
    
            WHILE @i <= (SELECT MAX(idx) FROM @tblPersonas)        
                BEGIN
                    
                    SET @documentoNum = (SELECT documentoNum  FROM @tblPersonas WHERE idx = @i);
                    SET @personaIdAntigua = (SELECT TOP(1) PersonaId FROM SGF_Persona WHERE DocumentoNum = @documentoNum ORDER BY FechaCrea ASC);

                    -- Update Datos Laborales
                    UPDATE SGF_DatosLaborales
                    SET PersonaId = @personaIdAntigua
                    WHERE PersonaId IN (SELECT PersonaId FROM SGF_Persona  WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua);

                    -- Datos_Direccion
                    UPDATE SGF_DatosDireccion
                    SET PersonaId = @personaIdAntigua, EsFijo = 0
                    WHERE PersonaId IN (SELECT PersonaId FROM SGF_Persona  WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua);

                    -- ExpedienteCredito
                    UPDATE SGF_ExpedienteCredito
                    SET TitularId  = @personaIdAntigua
                    WHERE TitularId IN (SELECT PersonaId FROM SGF_Persona  WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua);

                    -- Datos Solicitud
                    UPDATE SGF_Solicitud
                    SET PersonaId  = @personaIdAntigua
                    WHERE PersonaId IN (SELECT PersonaId FROM SGF_Persona  WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua);

                    -- SGF_Evaluaciones
                    UPDATE SGF_Evaluaciones
                    SET PersonaId  = @personaIdAntigua
                    WHERE PersonaId IN (SELECT PersonaId FROM SGF_Persona  WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua);

                    -- Eliminar Persona 
                    DELETE FROM SGF_Persona WHERE DocumentoNum = @documentoNum AND PersonaId != @personaIdAntigua;    

                    SET @i = @i + 1;               

                END
        COMMIT;                                       
    END TRY                                         
    BEGIN CATCH                                   
        SET @Success = 0;                                         
        SET @Message = 'LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(100)) + ' ERROR: ' + ERROR_MESSAGE()                     
                     
        ROLLBACK;                                         
    END CATCH                                      
END   