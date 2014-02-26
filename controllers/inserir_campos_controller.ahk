remove_table_link(info, linked_table, field_name){
  Global db

  StringReplace, field_name, field_name, %A_Space%,, All
  native_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] field_name
  append_debug("native_table " native_table " linked table " linked_table)  
  if(linked_table = native_table){
    MsgBox, 16, Informacao, % "A relacao existente no momento ja e a relacao padrao `n por isso nao pode ser removida!" 
    return
  }
  append_debug("ira resetar a ligacao native table " native_table " linked_table " linked_table " field_name " field_name)
  db.Modelo.reset_table_relation(info, native_table, field_name)
}