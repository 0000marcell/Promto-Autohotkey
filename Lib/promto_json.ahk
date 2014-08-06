class PromtoJSON{
	__New(){
		this.file_path := "promto_data.json"
    this.obj := {}
    this.obj.companies := []
	}

  get_companies(){
    Global db
    For each, value in list := db.get_values("*", "empresas"){
      this.obj.companies.insert(this.Helper.companies_values(value))
      this.get_types(
        (JOIN 
          this.obj.companies.types,
          this.Helper.get_next_table("Aba", value[A_Index, 1]),
          value[A_Index, 2]
        ))
    }
  }

  get_types(types, table, prev_mask){
    Global db

    For each, value in list := db.get_values("*", table){
      types.insert(this.Helper.types_values(value, prev_mask))
      this.get_families(
        (JOIN 
          types.families,
          this.get_next_table("Familia", prev_mask value[A_Index, 1]),
          prev_mask value[A_Index, 2]
        ))
    }

  }

  get_families(families, table, prev_mask){
    Global db
  }

  get_subfamilies(){
    Global db
  }

  get_models(){
    Global db
  }

  get_model_info(){
    Global db
  }
  #include lib\promto_json_helper.ahk
}
