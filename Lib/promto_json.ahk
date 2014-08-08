class PromtoJSON{
	__New(){
		this.file_path := "promto_data.json"
    this.obj := {}
    this.obj.companies := []
	}

  get_companies(){
    Global db
    For each, value in list := db.get_values("*", "empresas"){
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
    For each, value in list := db.get_values("*", table){
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
    For each, value in list := db.get_values("*", table){
      if(values[A_Index, 3] = 1){
        families.insert(this.Helper.families_values(list, prev_mask, values[A_Index, 3]))
        this.get_subfamilies(
        (JOIN 
          families[families.maxindex()].subfamilies,
          this.Helper.get_next_table("Subfamilia", prev_mask list[A_Index, 1]),
          prev_mask list[A_Index, 2]
        )) 
      }else{
        families.insert(this.Helper.families_values(list, prev_mask, values[A_Index, 3]))
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

    For each, value in list := db.get_values("*", table){
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

    For each, value in list := db.get_values("*", table){
     models.insert(this.Helper.models_values(list, prev_mask))   
    }
  }
  #include lib\promto_json_helper.ahk
}
