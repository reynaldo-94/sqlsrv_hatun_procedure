delete from SGF_ExpedienteCredito where ExpedienteCreditoId in (710145710146,710149)
delete from sgf_ExpedienteCreditoDetalle where ExpedienteCreditoId in (710145,710146,710149)
delete from SGF_Evaluaciones where ExpedienteCreditoId in (710145,710146,710149)
delete from SGF_Persona where PersonaId in (610244,610245,610229)
delete from SGF_DatosDireccion where PersonaId in (610244,610245,610229)

select * from SGF_ExpedienteCredito where ExpedienteCreditoId = 710055


delete from SGF_ExpedienteCredito where ExpedienteCreditoId in (710055)
delete from sgf_ExpedienteCreditoDetalle where ExpedienteCreditoId in (710055)
delete from SGF_Evaluaciones where ExpedienteCreditoId in (710055)
delete from SGF_Persona where PersonaId in (610179)
delete from SGF_DatosDireccion where PersonaId in (610179)



delete from SGF_ExpedienteCredito where ExpedienteCreditoId in (1159912)
delete from sgf_ExpedienteCreditoDetalle where ExpedienteCreditoId in (1159912)
delete from SGF_Evaluaciones where ExpedienteCreditoId in (1159912)
delete from SGF_Persona where PersonaId in (929353)
delete from SGF_DatosDireccion where PersonaId in (929353)