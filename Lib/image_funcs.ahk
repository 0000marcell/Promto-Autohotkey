Class Image {
	
	/*
	Carrega a imagem na janela principal
	*/
	load_image_in_main_window(){
		Global empresa, tipo, familia, info,db, global_image_path
		
		codtable := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		
		
		db.load_codigos_combobox(codtable)

		/*
			Pega a foto linkada com o determinado modelo
		*/
		tabela2_value := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		
		image_name_value := db.Imagem.get_image_full_path(tabela2_value)

		if(image_name_value = ""){
			image_name_value := "img\sem_foto.jpg" 
		}
		show_image_and_code(image_name_value)
	}

	/*
	Carrega a formacao do codigo na janela principal
	*/
	load_formation_in_main_window(info){
		Global db
		
		/*
			Inicia o gdi
		*/
		newgdi({w:710,h:350})

		/*
		 Cria os blocos com os nomes dos prefixos
		*/
		panel_color := "coolblue" 
		text_panel_color := "00ff00"
		bloq_w := 65
		bloq_h := 50
		prefix_table := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] "prefixo"
		prefix_values := db.load_table_in_array(prefix_table)
		x := 10
		y := 10 
		if(prefix_values.maxindex() = 3){
			fields := ["Empresa", "Familia" , "Modelo"]
		}else{
			fields := ["Tipo", "Empresa", "Familia" , "Modelo"]
		}

		for, each, value in fields{
			if(value = "")
				Continue
			panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: value, textsize: 12, boardsize: 0})
			x += bloq_w + 5
		}

		/*
			Cria os blocos com os nomes dos campos
		*/
		tabela1 := info.empresa[2] info.tipo[2] info.familia[2] info.subfamilia[2] info.modelo[2] info.modelo[1]
		oc_table := db.get_reference("oc", tabela1)
		;MsgBox, % "oc table " oc_table
		oc_values := db.load_table_in_array(oc_table)
		campos_sem_espaco := []
		for, each, value in oc_values{
			oc_name := oc_values[A_Index, 2]
			if(oc_name = "")
				Continue
			panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: oc_name, textsize: 8, boardsize: 0})
			StringReplace, oc_name, oc_name, %A_Space%,, All
			campos_sem_espaco.insert(oc_name)
			x += bloq_w + 5
		} 
	 	
		/*
			Cria os blocos com os valores dos prefixos
		*/
		x := 10
		y += 80
		for, each, value in prefix_values{
			current_prefix := prefix_values[A_Index, 2]
			if(current_prefix = "")
				Continue
			panel({x:x,y:y, w: bloq_w, h: bloq_h,color: panel_color,text: current_prefix, textsize: 20, boardsize: 0})
			x += bloq_w + 5
		} 

		/*
			Cria os blocos com os valores dos campos
		*/
		for, each, value in campos_sem_espaco{
			;MsgBox, % "valor ser espaco " value
			campo_table := db.get_reference(value, tabela1)
			;MsgBox, % "campo table " campo_table
			if(campo_table = "")
				Continue
			campo_values := db.load_table_in_array(campo_table)
			if(campo_values[1, 1] = "")
				Continue
			panel({x:x, y:y, w: bloq_w, h: bloq_h, color: panel_color, text: 	campo_values[1, 1], textsize: 20, boardsize: 0})
			x += bloq_w + 5
		}	
		savetofile("img\formation.png")
		Gui, M:Default
		GuiControl,, fmcode, % "img\formation.png" 
	}

	/*
		Carrega o logo na janela principal
	*/
	load_logo_in_main(){
		image_source := "img\promtologo.png"
		show_image_and_code(image_source, 0)
	}

	carregandologo(){
		Global 
		;GC1:="grey"
		;GC2:="darkgrey"
		;GC3:="lightgrey"
		;GC4:="darkgrey"
		;GC5:="orange"
		If !pToken := Gdip_Startup()
		{
		    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		    ExitApp
		}
		Gui, carregandologo: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
		Gui, carregandologo: Show, NA
		hwnd1 := WinExist()
		sw:=A_ScreenWidth,sh:=A_ScreenHeight
		logow:=sw*0.17,logoh:=sh*0.19
		promtologo([GC1,GC2,GC3,GC4,GC5],logow,logoh,0)
		savetofile("logopequeno.png")
		loadintowindow("logopequeno.png",hwnd1)
		_cog:=0

		return 		
	}

	getcolors(colorname){
		colors:=[]

		if(colorname="blue")
			colors[1]:="0xff2661dd",colors[2]:="0xff1941A5"
		if(colorname="black")
			colors[1]:="0xff000000",colors[2]:="0xff000000"
		if(colorname="red")
			colors[1]:="0xFFF90101",colors[2]:="0xFFA50101"
		if(colorname="yellow")
			colors[1]:="0xFFF2B50F",colors[2]:="0xFFFFCC11"
		if(colorname="green")
			colors[1]:="0xFF00933B",colors[2]:="0xFF00533B"
		if(colorname="lightblue")
			colors[1]:="0xff75c2d4",colors[2]:="0xff3f8c9e"
		if(colorname="floralwhite")
			colors[1]:="0xfffffaf0",colors[2]:="0xfffffaf0"
		if(colorname="ghostwhite")
			colors[1]:="0xfff8f8ff",colors[2]:="0xfff8f8ff"
		if(colorname="darkblue")
			colors[1]:="0xff1e3364",colors[2]:="0xff1e3364"
		if(colorname="pink")
			colors[1]:="0xffff00ff",colors[2]:="0xffff00ff"
		if(colorname="darkgrey")
			colors[1]:="0xff545454",colors[2]:="0xffA4A4A4"
		if(colorname="grey")
			colors[1]:="0xffC0C0C0",colors[2]:="0xffffffff"
		if(colorname="lightgrey")
			colors[1]:="0xffAEAEAE",colors[2]:="0xffCECECE"
		if(colorname="white")
			colors[1]:="0xffffffff",colors[2]:="0xffffffff"
		if(colorname="nocolor")
			colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
		if(colorname="verydarkblue")
			colors[1]:="0xff102E37",colors[2]:="0xff162f3E"
		if(colorname="turquoise")
			colors[1]:="0xff2BBBD8",colors[2]:="0xff2FBFDF"
		if(colorname="lightorange")
			colors[1]:="0xffF78D3F",colors[2]:="0xffFD8F3F"
		if(colorname="nocolor")
			colors[1]:="0x00ffffff",colors[2]:="0x00ffffff"
		if(colorname="darkgreen")
			colors[1]:="0xff009A31",colors[2]:="0xff009A31"
		if(colorname="limegreen")
			colors[1]:="0xff84CF96",colors[2]:="0xff84CF96"
		if(colorname="verylightgreen")
			colors[1]:="0xffC6E7CE",colors[2]:="0xffC6E7CE"
		if(colorname="coolgreen")
			colors[1]:="0xff669900",colors[2]:="0xff225500"
		if(colorname="coolblue")
			colors[1]:="0xff0099FF",colors[2]:="0xff0055AA"
		if(colorname="cooldarkblue")
			colors[1]:="0xff0033CC",colors[2]:="0xff000088"
		if(colorname="orange")
			colors[1]:="0xffff3311",colors[2]:="0xffff7722"
		if(colorname="purple")
			colors[1]:="0xff9933CC",colors[2]:="0xff5511aa"
		return colors
	}

	;################## load window #####################################   ;atualiza a janela de carregamento
	loadintowindow(imagepath,hwnd1){
		pBitmap := Gdip_CreateBitmapFromFile(imagepath)
		;If !pBitmap
		;{
		;    MsgBox, 48, File loading error!, Could not load the image specified
		;    ExitApp
		;}
		Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
		hbm := CreateDIBSection(Width, Height)
		hdc := CreateCompatibleDC()
		obm := SelectObject(hdc, hbm)
		G := Gdip_GraphicsFromHDC(hdc)
		Gdip_SetInterpolationMode(G, 7)
		Gdip_DrawImage(G, pBitmap,0,0, Width, Height, 0, 0, Width, Height)
		UpdateLayeredWindow(hwnd1, hdc,(A_ScreenWidth//2)-(Width//2),(A_ScreenHeight//2)-(Height),Width,Height)
		SelectObject(hdc, obm)
		DeleteObject(hbm)
		DeleteDC(hdc)
		Gdip_DeleteGraphics(G)
		Gdip_DisposeImage(pBitmap)
		Return
	}

	;##############destroy carregando lib#########################
	destroycarregandologo(){
		gui,carregandologo:destroy
		;SetTimer,carregandoaction,Off
		return
	}

	;##########################Showimageandcode################################################
	show_image_and_code(image, with_desc = 1){
		Global
		
		;MsgBox, % "show image and code"
		newgdi({w:850,h:280})
		image := Gdip_CreateBitmapFromFile(image)
		w := Gdip_GetImageWidth(image), h := Gdip_GetImageHeight(image)
		Gdip_DrawImage(G, image, 10, 10, 247, 142, 0, 0, w, h)
		if(text = ""){

			/*
				Pega a descricao 
			*/
			if(with_desc){
				desc_ := db.Modelo.get_desc(info)
				StringSplit, desc_, desc_ ,|,
				descricao_model := desc_1
				already_logo := false
			}else{
				if(already_logo)
					return
				descricao_model := ""
				already_logo := true
			}

			/*
				Printa a descricao
			*/
			panel({x:265 ,y:10,w:550,h:250,text2:descricao_model,text2size:textsize,color: "coolblue",boardsize: 0})
		}else{
			panel({x:265 ,y:10,w:550,h:250,text2:text,text2size:textsize,color: "coolblue",boardsize: 0})
		}
		FileDelete, "img/simpleplot.png"  
		Gdip_SaveBitmapToFile(pBitmap,"img/simpleplot.png")
		Gdip_DisposeImage(pBitmap)
		Gdip_DisposeImage(image)	
		Gdip_DeleteGraphics(G)
		Gui, M:default 
		Guicontrol,,ptcode,img/simpleplot.png
	}

	;#########################PLOTPTCODE#########################################################
	plotptcode(prefixpt,prefixpt2,modelpt,_showcode=0,iwidth=820,iheight=1076){
		global
		camptable:=prefixpt modelpt "oc"
		;loop utilizado para determinar o tamanho da foto.
		for,each,value in listcount:=db.getvalues("Campos",camptable){
			campnamecount:=listcount[A_Index,1]
			StringReplace,campnamecount,campnamecount,%A_Space%,,All
			result:=db.iquery("SELECT CODIGO FROM " prefixpt modelpt campnamecount ";")
			count:=result.Rows.Count()
			if(count>countprev)
				countprev:=count
		}
		result.close()
		iheight:=300
		iheight+=countprev*90
		newgdi({w:iwidth,h:iheight})
		;panel({x:0,y:0,w:iwidth,h:iheight,color: "white"})
		image := Gdip_CreateBitmapFromFile("image.png")
		Width := Gdip_GetImageWidth(image), Height :=Gdip_GetImageHeight(image)
		Gdip_DrawImage(G, image,10,10,250,250,0,0,Width,Height)
		table:=db.query("SELECT descricao FROM " prefixpt modelpt "Desc;")
		panel({x: 265 , y: 10 ,w:550,h:250,text2:table["descricao"],text2size: 40,text2color:"000000",textcolor:"000000",color: "nocolor",boardsize: 0})
		panel({x:10,y: 265,w: 90,h: 80,text2:prefixpt2,color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
		panel({x:105,y: 265,w: 90,h: 80,text2:modelpt,color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
		ix:=200,iy:=265
		for,each,value in list:=db.getvalues("Campos",camptable){
			campname:=list[A_Index,1]
			StringReplace,campname,campname,%A_Space%,,All
			result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='" campname "' AND tabela1='" prefixpt modelpt selectmodel "'")
			camplist:=result["tabela2"]
			for,each,value in list2:=db.getvalues("CODIGO,DR",camplist){
				if(A_Index=1){
					i2y:=iy
					panel({x:ix,y:i2y,w: 90,h: 80,text:list2[A_Index,2],text2y:40,text2:list2[A_Index,1],color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
				}else{
					i2y+=85 
					panel({x:ix,y:i2y,w: 90,h: 80,text:list2[A_Index,2],text2y:40,text2:list2[A_Index,1],color: "nocolor",boardsize: 0,textcolor:"000000",text2color:"000000"})
				}	 
			} 	
			ix+=100
		} 
		FileDelete,testeplot.png  
		Gdip_SaveBitmapToFile(pBitmap,A_WorkingDir "\temp\" prefixpt2 modelpt "grupo.png")
		Gdip_DisposeImage(pBitmap)
		Gdip_DisposeImage(image)
		Gdip_DeleteGraphics(G)
		if(_showcode=1)
			run,% A_WorkingDir "\temp\" prefixpt2 modelpt "grupo.png"
		return 
	}

	plot_pt_code_list(){
		global
		;## calcula o tamanho do arquivo final ##.
		newgdi({w:680,h:items_to_plot.maxindex()*170})
		panel({x:0,y:0,w:680,h:items_to_plot.maxindex()*170,color: "white",boardcolor: "0x00000000"})
		y := 10  
		for,each,item in items_to_plot{
			prefixpt := EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] 
			result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" EmpresaMascara AbaMascara FamiliaMascara items_to_plot[A_Index,2] items_to_plot[A_Index,1] "'") 
			model_image := result["tabela2"]
			result.close()
			IfnotExist,% A_WorkingDir "\img\" model_image ".png"
			{
				model_image := db.load_image_to_file("","",model_image)
			}
			image := Gdip_CreateBitmapFromFile(A_WorkingDir "\img\" model_image ".png")
			Width := Gdip_GetImageWidth(image), Height := Gdip_GetImageHeight(image)
			Gdip_DrawImage(G,image,10,y,100,100,0,0,Width,Height)
			Gdip_DisposeImage(image)
			table := db.query("SELECT descricao FROM " prefixpt "Desc;")
			panel({x: 110 , y: y ,w:550,h:100,text2:table["descricao"],text2size: 20,text2color:"000000",textcolor:"000000",color: "nocolor",boardsize: 0})
			updateprogress("Imprimindo : " prefixpt items_to_plot[A_Index,1],1)
			y += 120
		}
		Gdip_SaveBitmapToFile(pBitmap,A_WorkingDir "\temp\" FamiliaName ".png")
		Gdip_DisposeImage(pBitmap)
		Gdip_DeleteGraphics(G)
		run,% A_WorkingDir "\temp\" FamiliaName ".png"
		return 
	}

	;############logopromto##################################
	promtologo(colors,w,h,notext){
		global 
		newgdi({w:w,h:h})
		if(notext!=1){
			L:=w*0.4
			;panel({x:0,y:0,w:w,h:h,color:"grey",boardcolor: "0xff000000",boardsize:5})
			panel({x:w*0.37,y:h*0.026,w:L,h:L,color: colors[3],boardcolor: "0xffffffff",boardsize: w*0.01})
			panel({x:w*0.31,y:h*0.18,w:L*0.8,h:L*0.8,color: colors[2],boardcolor: "0xffffffff",boardsize:w*0.01})
			panel({x:w*0.27,y:h*0.36,w:L*0.5,h:L*0.5,color: colors[1],boardcolor: "0xffffffff",boardsize:w*0.01})
			txcolor1:=getcolors(colors[4]) , txcolor2:=getcolors(colors[5])
			txcolor1:=txcolor1[1] , txcolor2:=txcolor2[2]
			StringReplace,txcolor1,txcolor1,0x,, All
			StringReplace,txcolor2,txcolor2,0x,, All
			panel({x:w*0.06,y:h*0.62,w:w*0.85,h:L*0.3,color: "nocolor",text: "ProMTo!!!",textcolor: txcolor1, textsize:w*0.16,boardcolor: "0x00000000",textalign:"Centre"})
			panel({x:w*0.04,y:h*0.82,w:w*0.9,h:L*0.3,color: "nocolor",text: "product manager tool",textcolor: txcolor2, textsize: w*0.08,boardcolor: "0x00000000",textalign:"Centre"})		
		}else{
			L:=w*0.55
			panel({x:w*0.27,y:h*0.040,w:L,h:L,color: colors[3],boardcolor: "0xffffffff",boardsize:w*0.01})
			panel({x:w*0.21,y:h*0.23,w:L*0.8,h:L*0.8,color: colors[2],boardcolor: "0xffffffff",boardsize:w*0.01})
			panel({x:w*0.17,y:h*0.54,w:L*0.5,h:L*0.5,color: colors[1],boardcolor: "0xffffffff",boardsize:w*0.01})
		}
		return
	}

	;##############banner#########################
	banner(color,ByRef Variable, Text="", TextOptions="x0p y10 s30 Center cffffffff r4 Bold", Font="verdana",r=5){
    GuiControlGet, Pos, Pos, Variable
    GuiControlGet, hwnd, hwnd, Variable
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
		pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
		Gdip_FillRoundedRectangle(G, pBrush, 0, 0, w, h,r)
		Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text,TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
	}

	;############banner1############################################################################

	banner1(color,Variable,Text="",TextOptions="x0p y15p s60p Center cffffffff r4 Bold", Font="verdana",r=1){
    GuiControlGet, Pos, Pos,%Variable%
    GuiControlGet, hwnd, hwnd,%Variable%
    pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
    w:=posw,h:=posh
    colors:=getcolors(color)
		pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h,colors[1],colors[2])
		Gdip_FillRoundedRectangle(G, pBrush, 0, 0,w,h,r)
		Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G,Text, TextOptions, Font, Posw, Posh)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    SetImage(hwnd, hBitmap)
    Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
    Return, 0
	}

	;############### createtag #################################
	createtag(prefix, prefix2, model, selectmodel, codelist, codigos_array = "", textsize = 30, textcolor = "ff000000", imagepath = "image.png"){
		Global db, global_image_path

		code_rect_size := 125 ; tamanho do retangulo onde vai o codigo
		code_rect_spacing := 130 ; tamanho do espacamento entre os retangulos 

		if(codigos_array[1, 1] = ""){
			table := db.load_table_in_array(codelist)
		}else{
			table := codigos_array
		}
		
		progress(table.maxindex())
		totalheight := 500.17 * table.maxindex()
		newgdi({w:1200, h:totalheight})
		prefix_in_string := get_prefix_in_string(prefix2)
		StringLen, prefixlength, prefix_in_string
		
		y := 80
		 
		panel({x:0, y:0, w:1200, h:totalheight, color: "white", boardcolor: "0x00000000"})
		
		for, each, value in table{
			if(table[A_Index,1] = "")
				Continue
			x:=30	
			updateprogress("Criando Tags: " table[A_Index,1],1)
			
			; Pega a imagem
			imagepath := db.Imagem.get_image_full_path(table[A_Index, 1])
			
			/*
				Insere o prefixo
			*/
			f_hight := y-60
			for, each, value in prefix2{
				if(prefix2[A_Index] = "")
					Continue
				panel({x:x, y:f_hight, w:code_rect_size, h:50, color: "nocolor", text:"Prefixo", textsize: 10, textcolor: textcolor, boardersize:0})
				panel({x:x, y:f_hight+60, w:code_rect_size, h:50, color: "nocolor", text:prefix2[A_Index], textsize: textsize, textcolor: "ffff3311"})	
				x += code_rect_spacing
			}
			x -= code_rect_spacing

			/*
			panel({x:x,y:y-60,w:code_rect_size,h:50,color: "nocolor",text:"Familia",textsize: 10,textcolor: textcolor,boardersize:0})
			panel({x:x,y:y,w:code_rect_size,h:50,color: "nocolor",text:prefix2,textsize: textsize,textcolor: textcolor})
			panel({x:x+=code_rect_spacing,y:y-60,w:code_rect_size,h:50,color: "nocolor",text:"Modelo",textsize: 10,textcolor: textcolor,boardersize:0})
			panel({x:x,y:y,w:code_rect_size,h:50,color: "nocolor",text: model,textsize: textsize,textcolor: textcolor})
			*/

			codigo := table[A_Index,1]	

			StringTrimleft,codigo,codigo, prefixlength
			
			/*
				Pega a tabela de campos, para pega o nome dos campos
			*/
			camp_table := db.get_reference("oc", prefix model selectmodel)
			
			table_camp := db.load_table_in_array(camp_table)


			for, each, value in table_camp{

				if(table_camp[A_Index, 2] = ""){
					Continue
				}

				campname := table_camp[A_Index, 2]
				StringReplace, campname, campname, %A_Space%,, All
				camp_esp_table := db.get_reference(campname, prefix model selectmodel)
				
				table_camp_esp := db.load_table_in_array(camp_esp_table)

				for, each, value in table_camp_esp{

					;if(table_camp_esp[A_Index,1] = "")
					;	Continue

					codepiece := table_camp_esp[A_Index,1]


					StringLen, length, codepiece

					
					if(length != ""){
						StringLeft, codepiece, codigo, length
						StringTrimLeft, codigo, codigo, length
						Break
					}
				} 	
				/*
					Insere os campos especificos
				*/
				panel({x:x+=code_rect_spacing,y:y-60,w:code_rect_size,h:50,color: "nocolor",text: table_camp[A_Index,2], textsize:8, textcolor: textcolor})
				panel({x:x, y:y, w:code_rect_size, h:50, color: "nocolor", text:codepiece, textsize: textsize, textcolor: textcolor})
			}

			; Insere a foto na plaqueta  
			panel({x:30,y:y+=60,w:200,h:200,color: "nocolor", imagepath: imagepath})

			/*
				Insere a descricao
			*/
			panel({x:245,y: y,w: 800,h: 200,color: "nocolor",text: table[A_Index,2],textsize: 30,textcolor: textcolor})	

			dottedliney := y + 234.17	
			pPen := Gdip_CreatePen(0xff000000, 3)
			DrawDottedLine(0, dottedliney, 1500, dottedliney)
			Gdip_DeletePen(pPen)
			y += 234.17+81
		}
		Gui,progress:destroy
		MsgBox, 64, Sucesso, % "O arquivo foi salvo!!"
		
		formated_model := format_file_name(selectmodel)
		savetofile("temp\" formated_model ".png")
		MsgBox, % "ira rodar o arquivo " formated_model
		run, % "temp\" formated_model ".png"
	}

	DrawDottedLine(sx,sy,ex,ey){
		Global 
		Loop{
			ex2:=sx+10
			Gdip_DrawLine(G, pPen,sx,sy,ex2,sy)
			sx+=15
			if(sx>ex)
				Break
		}
	}

	;#################save an image to a file#####################
	savetofile(imagename,show=0){
		Global pBitmap

		FileDelete, % imagename  
		Gdip_SaveBitmapToFile(pBitmap, imagename)
		Gdip_DisposeImage(pBitmap)
		if(show=1)
			run,%imagename%
	}

	newgdi(a){
		Global

		a.w:= (a.w="") ? 500 : a.w
		a.h:= (a.h="") ? 500 : a.h
		pBitmap := Gdip_CreateBitmap(a.w,a.h), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)
		return 
	}

	;############ imprime as estruturas ##############
	printestrutura(item,offset,textcolor = "ff000000",ownercode = "",quantidade = ""){ ; o offset determina a distancia entre os items
		Global
		Local table,maincodes,quantidade_text_size
		squarecolor := "lightgrey", quantidade_text_size := 30
		if item =
			return
		nivel.="`t"
		offset += 30
		if(%ownercode% != "")
			%ownercode% := ""
		table := db.query("SELECT item,componente,QUANTIDADE FROM ESTRUTURAS WHERE item='" . item . "'")
		if(table["componente"] = ""){
			if(ownercode != ""){
			 	IfNotInString,%ownercode%,%item%
			 	{
			 		%ownercode% .= "`n" item
			 		StringReplace,item,item,>>,|,All
					StringSplit,item,item,|
			 		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" item1 "'")
					if(result["tabela2"] != ""){
						imagepath := db.loadimage("","",result["tabela2"])
					}else{
						imagepath := "noimage.png"
					}
					result.close()
			 		panel({x:offset,y:y += 130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
			 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:item1 "`n" item2,textsize:10,textcolor: textcolor,boardsize: 0})
			 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0,textalign: "center"})
			 	}	
			 }else{
			 	IfNotInString,maincodes,%item%
			 	{
					maincodes .= "`n" item
			 		StringReplace,item,item,>>,|,All
					StringSplit,item,item,|
			 		result := db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" item1 "'")
					if(result["tabela2"] != ""){
						imagepath := db.loadimage("","",result["tabela2"])
					}else{
						imagepath := "noimage.png"
					}
					result.close()
					;StringLeft,codetype,item1,1
			 		panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
			 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:item1 "`n" item2,textsize:10,textcolor: textcolor,boardsize: 0})
			 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
			 	}
			 }	
		 }
		while(!table.EOF){
			tableitem := table["item"]
			if(ownercode!=""){	
				IfNotInString,%ownercode%,%tableitem%
				{
					%ownercode%.="`n" tableitem
					StringReplace,tableitem,tableitem,>>,|,All
					StringSplit,tableitem,tableitem,|
					result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'")
					if(result["tabela2"]!=""){
						imagepath:=db.loadimage("","",result["tabela2"])
					}else{
						imagepath:="noimage.png"
					}
					result.close()
					;StringLeft,codetype,tableitem1,1
					panel({x:offset,y:y+=130,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
			 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:tableitem1 "`n" tableitem2,textsize: 10,textcolor: textcolor,boardsize: 0})
			 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
				}
			}else{
				IfNotInString,maincodes,%tableitem%
			 	{
					maincodes.="`n" tableitem
					StringReplace,tableitem,tableitem,>>,|,All
					StringSplit,tableitem,tableitem,|
					result:=db.query("SELECT tabela2 FROM reltable WHERE tipo='image' AND tabela1='" tableitem1 "'")
					if(result["tabela2"]!=""){
						imagepath:=db.loadimage("","",result["tabela2"])
					}else{
						imagepath:="noimage.png"
					}
					result.close()
					;StringLeft,codetype,tableitem1,1
					panel({x:offset,y:y+=210,w:100,h:100,color: "nocolor",imagepath: imagepath,boardsize: 0})
			 		panel({x:offset+105,y:y,w:450,h:100,color:"nocolor",text:tableitem1 "`n" tableitem2,textsize: 10,textcolor: textcolor,boardsize: 0})
			 		panel({x:offset+560,y:y,w:100,h:100,color:"nocolor",text:quantidade "`n",textsize:quantidade_text_size,textcolor: textcolor,boardsize: 0, textalign: "center"})
			 	}
			}
			StringReplace,parseditem,tableitem,>>,|,All
			StringSplit,parseditem,parseditem,|
			StringReplace,parseditem1,parseditem1,%A_Space%,,All
			printestrutura(table["componente"],offset,textcolor,parseditem1,table["QUANTIDADE"])
			table.MoveNext()
		}
		table.close()
		return 
	}

	;############PANEL###################################
	panel(a){
		Global

		if(a.imagepath!=""){
			pBitmapFile1:=Gdip_CreateBitmapFromFile(a.imagepath)
			Width := Gdip_GetImageWidth(pBitmapFile1), Height := Gdip_GetImageHeight(pBitmapFile1)
			Gdip_DrawImage(G,pBitmapFile1,a.x,a.y,a.w,a.h,0,0,Width,Height)
		}
		colors:=getcolors((a.color="") ? "blue" : a.color)
		pBrush := Gdip_CreateLineBrushFromRect(a.x,a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,colors[1],colors[2])
		Gdip_FillRoundedRectangle(G,pBrush,(a.x="") ? 100 : a.x,(a.y="") ? 100 : a.y,(a.w="") ? 100 : a.w,(a.h="") ? 100 : a.h,(a.r="") ? 1 : a.r)
		pPen := Gdip_CreatePen((a.boardcolor="") ? "0xff000000" : a.boardcolor,(a.boardsize="") ? 2 : a.boardsize)
		Gdip_DrawRoundedRectangle(G,pPen,a.x,a.y,a.w,a.h,a.r)
		a.textx:=(a.textx="") ? a.x+5 : a.x+a.textx
		a.texty:=(a.texty="") ? a.y+5 : a.y+a.texty
		a.textsize:=(a.textsize="") ? 8 : a.textsize
		a.textalign:=(a.textalign="") ? "left" : a.textalign
		a.textcolor:=(a.textcolor="") ? "ffffffff" : a.textcolor
		TextOptions:="x" a.textx " y" a.texty  " s" a.textsize " " a.textalign " c" a.textcolor  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
		Gdip_TextToGraphics(G,a.text,TextOptions,Font,a.w,a.h) 
		a.text2x:=(a.text2x="") ? a.x+5 : a.x+a.text2x
		a.text2y:=(a.text2y="") ? a.y+20 : a.y+a.text2y
		a.text2size:=(a.text2size="") ? 20 : a.text2size
		a.text2align:=(a.text2align="") ? "left" : a.text2align
		a.text2color:=(a.text2color="") ? "ffffffff" : a.text2color
		TextOptions:="x" a.text2x " y" a.text2y  " s" a.text2size " " a.text2align " c" a.text2color  " r4 Bold",Font:=(a.font="") ? "arial" : a.font
		Gdip_TextToGraphics(G,a.text2,TextOptions,Font,a.w,a.h) 
		Gdip_DisposeImage(pBitmapFile1)
	}
} ; /// Image