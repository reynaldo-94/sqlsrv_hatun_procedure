/*--------------------------------------------------------------------------------------                                                                 
' Nombre          : [dbo].[SGC_SP_Reconfirmations_File_Upload_G]                                                   
' Objetivo        : Este procedimiento obtiene los datos de la carga del expedienteREconfirmacion                                            
' Creado Por      : Cristian                                            
' Día de Creación : 21-07-2022                                                   
' Requerimiento   : SGC                                                   
' Cambios:          
  29/08/2022 - REYNALDO CAUCHE - Se Cambió el mensaje de Credito en otro estado por Operación en estado <Nombre del Estado>          
  29/08/2022 - REYNALDO CAUCHE - Se Agrego una nueva validación, esta consiste en que para poder reconfirmar tiene que ser mayor a 3 días   
  02/09/2022 - REYNALDO CAUCHE - El numero de verificacion ahora empiezo en 1, la validación de 3 días cambiarlo a 5 días  
  26/09/2022 - REYNALDO CAUCHE - Se agreo el Max(FechaCrea) para que solo obtenga la ultima operacion subida y con esa operacion hacer las validaciones 
'--------------------------------------------------------------------------------------*/                                 
                              
ALTER PROCEDURE [dbo].[SGC_SP_Reconfirmations_File_Upload_G]                      
(                                  
 @StringExcel varchar(max)                       
 ,@Pagina int                                                                                                                
 ,@Tamanio int                
 ,@Todos bit = 0                
 ,@Success int output                      
)                                  
AS                            
                      
BEGIN                
                
    -- Crear una tabla temporal                
    CREATE TABLE #tblReconfirmacion(Id int,ExpedienteCreditoId int, NumVerificacion varchar(50), ExisteExpediente varchar(2))                
    INSERT INTO #tblReconfirmacion(Id,ExpedienteCreditoId)                
    SELECT position as Id, cast(value as int) as ExpedienteCreditoId              
    FROM dbo.fn_Split(@StringExcel,',')            
            
    -- Actualizar la tabla temporal - Estado diferente a Evaluacion            
    UPDATE #tblReconfirmacion            
    SET NumVerificacion = x.NumVerificacion, ExisteExpediente = x.ExisteExpediente              
    FROM (            
        SELECT  
            -- Estado Evaluacion  
            case when exc.EstadoProcesoId = 5     
                then          
                    -- Mayor a 5 días  
                    case when dbo.FN_Aniadir_DiasLaborables(isnull(MAX(exr.FechaCrea),(dbo.getDate() - 10)), 5) < convert(date,dbo.getDate(),23)          
                        then  
                            case when ISNULL(exr.Interesado,1) = 1  
                                then  
                                    case when exr.Estado = 1             
                                        then 'Por Confirmar en Lote Anterior'             
                                        else cast(COUNT(exr.ExpedienteCreditoId) + 1 as varchar)             
                                    end  
                                else  
                                    'No Interesado'  
                            end  
                        else
                            case when ISNULL(exr.Interesado,1) = 1  
                                then  
                                    case when exr.Estado = 1             
                                        then 'Por Confirmar en Lote Anterior'             
                                        else 'Deben pasar 5 días para subir'             
                                    end  
                                else  
                                    'No Interesado'  
                            end                            
                    end             
                else          
                    CONCAT('Operación en estado ',(SELECT NombreCorto FROM SGF_Parametro where DominioId = 38 AND ParametroId = exc.EstadoProcesoId))  
                      
            end as NumVerificacion,  
  
        case when exc.EstadoProcesoId = 5           
            then          
                case when dbo.FN_Aniadir_DiasLaborables(isnull(MAX(exr.FechaCrea),(dbo.getDate() - 10)), 5) < convert(date,dbo.getDate(),23)     
                    then  
                        case when ISNULL(exr.Interesado,1) = 1  
                            then   
              case when exr.Estado = 1             
                                    then 'NO'             
                                    else 'SI'  
                                end  
                            else     
                                'NO'          
                        end             
                    else             
                        'NO'              
                end          
            else          
                'NO'             
        end as ExisteExpediente,  
  
        exc.ExpedienteCreditoId              
        FROM SGF_ExpedienteCredito exc                
        INNER JOIN SGF_Evaluaciones eva ON exc.ExpedienteCreditoId = eva.ExpedienteCreditoId                
        LEFT JOIN SGF_ExpedienteCredito_Reconfirmacion exr ON exc.ExpedienteCreditoId = exr.ExpedienteCreditoId                        
        WHERE exc.ExpedienteCreditoId in (SELECT value from dbo.fn_Split(@StringExcel,','))                
        GROUP BY exc.EstadoExpedienteId, exr.Estado,exc.ExpedienteCreditoId,exc.EstadoProcesoId,exr.Interesado       
 ) x            
    WHERE #tblReconfirmacion.ExpedienteCreditoId = x.ExpedienteCreditoId;            
                
    -- Actualizar la tabla temporal                
    UPDATE #tblReconfirmacion                
    SET NumVerificacion = y.NumVerificacion                
    FROM (                
        SELECT case when count(eva.ExpedienteCreditoId) = 0 then 'Operación no se encuentra en Evaluación' else '' end as NumVerificacion                
        ,exc.ExpedienteCreditoId                
        FROM SGF_ExpedienteCredito exc                
        LEFT JOIN SGF_Evaluaciones eva ON exc.ExpedienteCreditoId = eva.ExpedienteCreditoId                 
        WHERE exc.ExpedienteCreditoId in (SELECT ExpedienteCreditoId from #tblReconfirmacion where isnull(NumVerificacion,'') = '')                
        GROUP BY exc.ExpedienteCreditoId    
    ) y                
    WHERE #tblReconfirmacion.ExpedienteCreditoId = y.ExpedienteCreditoId;                
                
    -- Obtiene el listado total, sin paginado                
    IF (@Todos = 1)                
     BEGIN                
            SET @Success = 1;             
            SELECT ISNULL(tbr.NumVerificacion,'Operación no se encuentra en BD') as NumVerificacion          
            ,tbr.ExpedienteCreditoId              
            ,ISNULL(tbr.ExisteExpediente,'NO') as ExisteExpediente                
            FROM #tblReconfirmacion tbr                
            LEFT JOIN SGF_ExpedienteCredito exc on tbr.ExpedienteCreditoId = exc.ExpedienteCreditoId                
            LEFT JOIN SGF_Persona pe ON exc.TitularId = pe.PersonaId                
            ORDER BY exc.ExpedienteCreditoId DESC;                
        END                
    ELSE                
        BEGIN                
            SET @Success = (SELECT count(*) FROM #tblReconfirmacion);                
                      
            SELECT ISNULL(tbr.NumVerificacion,'Operación no se encuentra en BD') as NumVerificacion                
            ,tbr.ExpedienteCreditoId                
            ,ISNULL(pe.Nombre,'') + ' ' + ISNULL(pe.ApePaterno,'') + ' ' + ISNULL(pe.ApeMaterno,'') as Nombre                
            ,pe.DocumentoNum as NumDocumento                
            ,ISNULL(tbr.ExisteExpediente,'NO') as ExisteExpediente                
            FROM #tblReconfirmacion tbr                
            LEFT JOIN SGF_ExpedienteCredito exc on tbr.ExpedienteCreditoId = exc.ExpedienteCreditoId                
            LEFT JOIN SGF_Persona pe ON exc.TitularId = pe.PersonaId                
            ORDER BY exc.ExpedienteCreditoId DESC  
            OFFSET @Pagina*@Tamanio ROWS FETCH NEXT @Tamanio ROWS ONLY;                
        END                
                      
END