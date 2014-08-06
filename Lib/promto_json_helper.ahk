class Helper{
	companies_values(value){
    values := {
        (JOIN
          "name": value[A_Index, 1], "mask": value[A_Index, 2], 
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
          "name": value[A_Index, 1], "mask": value[A_Index, 2], 
          "prev_mask": prev_mask,
          "families": []
        )}
    return values	
  }
}