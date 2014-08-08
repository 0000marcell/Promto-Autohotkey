class PromtoSearch{

	any_word_in_array(keyword, list){
    result := []
		for, each, value in list{
      i++
      string2 := this.put_array_in_single_line(A_Index, 12, list)
      StringSplit, splitted_string, keyword, %A_Space%
      _exists_in_all := 0
			Loop, % splitted_string0
			{
				value_to_search := trim(splitted_string%A_Index%)
				IfInString, string2, %value_to_search%
        {
          _exists_in_all := 1
        }else{
        	_exists_in_all := 0
        	Break
        }	
			}
			if(_exists_in_all = 1)
				result.insert(i)
    }
    return result
	}

  put_array_in_single_line(line, count, list){
    loop, % count
    {
      string .= list[line, A_Index] 
    }
    return string
  }
	#include, lib\promto_search_lv.ahk 
}