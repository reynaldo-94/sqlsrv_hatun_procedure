/*--------------------------------------------------------------------------------------                                                                                                                                            
' Nombre          : [dbo].[SGC_SP_Bancos_L]                                                                                                                                                         
' Objetivo        : ESTE PROCEDIMIENTO DARA DE BAJA LOS CREDITOS DE ALFIN DE FORMA MASIVA DE EVALUACION A SIN ATENCION                                                              
' Creado Por      : CRISTIAN SILVA                                                                                                                        
' Día de Creación : 10-10-2023                                                                                                                                                        
' Requerimiento   : SGC            
' Día de Modifica :            
' Cambios         :        
    - develop-rediseño 24/10/2023 - Reynaldo Cauche - Se agrego el campo CreadoAlfinLa, EstadoProcesoId  
'--------------------------------------------------------------------------------------*/                
              
CREATE PROCEDURE [dbo].[SGC_SP_GetExpedienteALfin_L]         
(      
@Pagina int = 1     
,@Tamanio int = 100      
,@Dias int      
,@Success int output      
)      
AS               
BEGIN               
      
  declare @TamanioNew int = iif(@Tamanio = 0,100,@Tamanio)  
      
  SELECT       
    ExpedienteCreditoId,CreadoAlfinLa,EstadoProcesoId      
  FROM SGF_ExpedienteCredito       
  WHERE       
       convert(date,FechaEvaluacion) =  convert(date, DATEADD(day, -(@Dias-1), dbo.getdate()))      
      and EstadoProcesoId = 5      
      and BancoId = 13      
   order by FechaActua desc      
   OFFSET @Pagina*@TamanioNew ROWS FETCH NEXT @TamanioNew ROWS only;  
      
END 