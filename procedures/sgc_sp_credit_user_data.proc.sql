/*--------------------------------------------------------------------------------------                                                                                             
' Nombre          : [dbo].[[SGC_SP_ExpedienteCredito_Por_Id]]                                                                                                              
' Objetivo        : ESTE PROCEDIMIENTO OBTIENE DATOS DEL USUARIO                                                           
' Creado Por      :                                                                            
' Día de Creación :                                                                                                       
' Requerimiento   : SGC                                                                                                       
' Modificado por  : REYNALDO CAUCHE                                                                                      
' Día de Modificación : 12-01-2022  
	21/11/2022 - cristian silva - se creo para call center, ado y supevisor que si LocalId is null se asignara local 13(higeureta) y si ZonaID is null = 6 
'--------------------------------------------------------------------------------------*/             
CREATE PROCEDURE [dbo].[SGC_SP_Credit_User_Data]                   
(                   
 @UserId int,                   
 @Ubigeo varchar(6),                   
 @Content varchar(100) OUTPUT                   
)                   
as                   
 declare @CargoId int                   
 declare @EmpleadoId int                   
                   
 declare @IdSupervisor int                   
 declare @AdvId int                   
 declare @ZonaId int                   
 declare @LocalId int          
 declare @IdsSupervisores varchar(1000)       
 declare @IdsLocales varchar(1000)       
 declare @ProveedorLocalId int       
begin                   
 select @CargoId=ISNULL(CargoId,0),@EmpleadoId=ISNULL(EmpleadoId,0) from SGF_USER where UserId=@UserId                   
                   
 if (@CargoId=29)                   
 begin                   
  select                   
   @LocalId=IIF(LocalId IS NULL,13,LocalId),                   
   @ZonaId=IIF(ZonaId IS NULL,6,ZonaId),                   
   @IdSupervisor=IdSupervisor,       
   --@IdSupervisor=0,     
   --@AdvId=AdvId,      
   @AdvId=0,        
   @IdsSupervisores=' ',        
   @IdsLocales=' '         
  from SGF_Supervisor                   
  where IdSupervisor=@EmpleadoId                   
 end                   
                   
 else if (@CargoId=4)                   
 begin                   
  select                   
   @LocalId=IIF(AD.LocalId IS NULL,13,AD.LocalId),                   
   @ZonaId=IIF(AD.ZonaId IS NULL,6,AD.ZonaId),                   
   @IdSupervisor=0,         
   --@IdsSupervisores=(         
   --  STUFF(         
   -- ( SELECT CONVERT(VARCHAR(10), SP.IdSupervisor) + ','         
   --FROM SGF_Supervisor SP         
   --WHERE SP.AdvId = AD.AdvId AND SP.EsActivo = 1         
   --FOR XML PATH (''))         
   --  , 1, 0, '')         
   --),          
   @IdsSupervisores=0,     
   @AdvId=AdvId,        
   @IdsLocales=''                   
  from SGF_ADV AD                   
  where AD.AdvId=@EmpleadoId         
 end                 
                  
 -- ESTABLECIMIENTO                 
 else if (@CargoId=26)                   
 begin                   
  select                   
   @LocalId=LocalId,                   
   @ZonaId=ZonaId,                   
   @IdSupervisor=IdSupervisor,                   
   @AdvId=0,         
   @IdsSupervisores=' ',        
   @IdsLocales=' ',       
   @ProveedorLocalId=ProveedorLocalId       
  from SGF_ProveedorLocal                   
  where ProveedorLocalId=@EmpleadoId                   
 end           
 -- JEFE ZONA                 
 else if (@CargoId=2)                   
 begin                   
  select                   
   @LocalId=0,    
   @ZonaId=ZonaId,                   
   @IdSupervisor=0,                   
   @AdvId=0,       
   @IdsSupervisores=' ',       
   @IdsLocales=' '                   
  from SGF_JefeZona                   
  where JefeZonaId=@EmpleadoId                   
 end       
 -- REGIONAL       
 else if (@CargoId=52)       
   begin       
     select                   
    @LocalId=0,                   
    @ZonaId=0,                   
    @IdSupervisor=0,                   
    @AdvId=0,                   
    @CargoId=IIF(@CargoId IS NULL,0,@CargoId),         
    @IdsSupervisores=' ',       
    @IdsLocales=(STUFF(       
  (SELECT CONVERT(VARCHAR(100), LC.LocalId) + ','                      
         FROM SGF_JEFEREGIONAL JFR                          
         INNER JOIN SGF_ZONA ZN ON ZN.RegionZonaId = JFR.RegionId                    
         INNER JOIN SGF_LOCAL LC ON LC.ZonaId = ZN.ZonaId                          
         WHERE JFR.JefeRegionalId = @EmpleadoId  AND LC.esActivo = 1        
   FOR XML PATH ('')), 1, 0, ''))           
   end             
 else                   
 begin                   
  select                   
   @LocalId=IIF(LO.LocalId IS NULL,13,LO.LocalId),                   
   @ZonaId=IIF(LO.ZonaId IS NULL,6,LO.ZonaId),                   
   @IdSupervisor=0,                   
   @AdvId=0,                   
   @CargoId=IIF(@CargoId IS NULL,0,@CargoId),         
   @IdsSupervisores=' ',        
   @IdsLocales=' '         
  from SGF_UBIGEO UB                   
  left join SGF_Local LO                   
  on LO.LocalId=UB.LocalId                   
  where UB.CodUbigeo=@Ubigeo                   
 end                   
                   
 set @Content=(select CONCAT(IIF(@LocalId IS NULL,0,@LocalId),'/**/',     
                             IIF(@ZonaId IS NULL,0,@ZonaId),'/**/',     
        IIF(@IdSupervisor IS NULL,0,@IdSupervisor),'/**/',     
        IIF(@AdvId IS NULL,0,@AdvId),'/**/',     
        IIF(@CargoId IS NULL,0,@CargoId),'/**/',     
        @IdsSupervisores,'/**/',     
        @IdsLocales,'/**/',     
        IIF(@ProveedorLocalId IS NULL,0,@ProveedorLocalId)));          
            
 print @Content                   
end 