class Helper{
  
	companies_values(value){
    MsgBox, % "company A_Index " A_Index
    values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "types": []
        )}
    return values
  }

  get_next_table(tipo, tabela1){
    Global db
    next_table := db.get_reference(tipo, tabela1)
    return next_table
  }

  types_values(value, prev_mask){
  	values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "prev_mask": prev_mask,
          "families": []
        )}
    return values	
  }


  families_values(value, prev_mask, subfamily){
    if(subfamily = 1){
      values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "prev_mask": prev_mask,
          "subfamilies": []
        )}
    }else{
      values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "prev_mask": prev_mask,
          "models": []
        )}
    }  
    return values 
  }


  subfamilies_values(value, prev_mask){
    values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "prev_mask": prev_mask,
          "models": []
        )}
    return values 
  }

  models_values(value, prev_mask){
   Global db
   values := {
        (JOIN
          "name": value[A_Index, 1], "mask": "|" value[A_Index, 2], 
          "prev_mask": prev_mask
        )}
    return values
  }

  insert_model_fields(list, prev_mask, models){
    Global db 
    this.models := models 
    tabela1 := prev_mask list[A_Index, 2] list[A_Index, 1]
    field_table := db.get_reference("Campo", tabela1)
    if(field_table = "")
      return
    For each, value in list := db.get_values("*", field_table){ 
      tipo := AHK.rem_space(list[A_Index, 2])
      ;AHK.append_debug("tipo " tipo)
      esp_field_table := db.get_reference(tipo, tabela1)
      ;AHK.append_debug("esp table " esp_field_table)
      fields_values := this.get_fields(esp_field_table)
      ;AHK.append_debug("gonna insert values max index " fields_values.maxindex() " tipo " tipo)
      this.insert_fields(fields_values, tipo)
    }
  }

  insert_fields(values, camp_name) {
    hash := {
        (JOIN
          "name": camp_name, 
          "values": []
        )}
    this.models.fields := []
    this.models.fields.insert(hash)
    ;AHK.append_debug("model fields max index this " this.models.fields.maxindex())
    this.models.fields[this.models.fields.maxindex()].values.insert(values)
  }

  get_fields(table) {
    Global db
    if(table = "")
      return
    list := db.get_values("*", table)
    return list
  }
}