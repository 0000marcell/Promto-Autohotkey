class PromtoJSON{

	__New(){
    this.obj := {}
    this.obj.companies := []
	}

  get_companies(){
    Global db
    For each, value in list := db.get_values("*", "empresas"){
      if(list.maxindex() = A_Index){
        this.obj.companies.max_index := A_Index  
      }
      this.obj.companies.insert(this.Helper.companies_values(list))
      this.get_types(
        (JOIN 
          this.obj.companies[this.obj.companies.maxindex()].types,
          this.Helper.get_next_table("Aba", list[A_Index, 1]),
          list[A_Index, 2]
        ))
    }
    JSON_save(this.obj, "promto_JSON.json")
    string := JSON_to(this.obj) 
    MsgBox, % string 
  }

  get_types(types, table, prev_mask){
    Global db
    if(table = "")
      return  
    For each, value in list := db.get_values("*", table){
      if(list.maxindex() = A_Index){
        types.max_index := A_Index  
      }
      types.insert(this.Helper.types_values(list, prev_mask))
      this.get_families(
        (JOIN 
          types[types.maxindex()].families,
          this.Helper.get_next_table("Familia", prev_mask list[A_Index, 1]),
          prev_mask list[A_Index, 2]
        ))
    }
  }

  get_families(families, table, prev_mask){
    Global db
    if(table = "")
      return 
    For each, value in list := db.get_values("*", table){
      if(list.maxindex() = A_Index){
        families.max_index := A_Index  
      }
      if(list[A_Index, 3] = 1){
        families.insert(this.Helper.families_values(list, prev_mask, list[A_Index, 3]))
        this.get_subfamilies(
        (JOIN 
          families[families.maxindex()].subfamilies,
          this.Helper.get_next_table("Subfamilia", prev_mask list[A_Index, 1]),
          prev_mask list[A_Index, 2]
        )) 
      }else{
        families.insert(this.Helper.families_values(list, prev_mask, list[A_Index, 3]))
        this.get_models(
        (JOIN 
          families[families.maxindex()].models,
          this.Helper.get_next_table("Modelo", prev_mask list[A_Index, 1]),
          prev_mask list[A_Index, 2]
        ))
      }
    }
  }

  get_subfamilies(subfamilies, table, prev_mask){
    Global db
    if(table = "")
      return
    For each, value in list := db.get_values("*", table){
      if(list.maxindex() = A_Index){
        subfamilies.max_index := A_Index  
      }
     subfamilies.insert(this.Helper.subfamilies_values(list, prev_mask))   
     this.get_models(
        (JOIN 
          subfamilies[subfamilies.maxindex()].models,
          this.Helper.get_next_table("Modelo", prev_mask AHK.rem_space(list[A_Index, 1])),
          prev_mask list[A_Index, 2]
        ))
    }
  }

  get_models(models, table, prev_mask){
    Global db
    if(table = "")
      return
    For each, value in list := db.get_values("*", table){
      if(list.maxindex() = A_Index){
        models.max_index := A_Index  
      }
     models.insert(this.Helper.models_values(list, prev_mask))
     AHK.append_debug("model max index passes " models.maxindex())
     this.Helper.insert_model_fields(list, prev_mask, models[models.maxindex()])  
    }
  }
  #include lib\promto_json_helper.ahk
}
