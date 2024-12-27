-- This program is for testing basic GBC UI look-n-feel customizations.
-- By: Neil J Martin ( neilm@4js.com )

IMPORT os

IMPORT FGL fgldialog
--IMPORT FGL g2_lib.* -- crashes in GST
IMPORT FGL g2_lib.g2_init
IMPORT FGL g2_lib.g2_core
IMPORT FGL g2_lib.g2_about

CONSTANT C_PRGDESC = "Material Design Test"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGVER  = "3.3"
CONSTANT C_PRGICON = "logo_dark"
CONSTANT C_IMG     = "smiley"

CONSTANT C_COLOURSFILE = "colour_names.txt"
CONSTANT C_NOTICE      = "🔴"

CONSTANT PG_MAX = 1000

DEFINE m_forms DYNAMIC ARRAY OF STRING
TYPE t_colour RECORD
	c_key  STRING,
	c_name STRING,
	c_hex  STRING
END RECORD
TYPE t_icon RECORD
	i_name  STRING,
	i_file  STRING,
	i_glyph STRING,
	i_colr  STRING
END RECORD
DEFINE m_colours DYNAMIC ARRAY OF t_colour
DEFINE m_icons   DYNAMIC ARRAY OF t_icon

MAIN
	DEFINE l_rec RECORD
		fld1    CHAR(10),
		fld2    DATE,
		fld2a   INTERVAL HOUR TO MINUTE,
		fld3    DATE,
		fld4    STRING,
		fld5    STRING,
		fld6    STRING, -- Colour completer
		fld7    STRING,
		col_hex STRING, -- WebComponent
		fld8    STRING,
		fld9    STRING,
		fld10   STRING,
		fld11   STRING,
		okay    BOOLEAN,
		notokay BOOLEAN,
		nul     BOOLEAN
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		col1 DATE,
		col2 STRING,
		col3 SMALLINT,
		img  STRING
	END RECORD
	DEFINE l_listView DYNAMIC ARRAY OF RECORD
		col1 STRING,
		col2 STRING,
		img  STRING
	END RECORD
	DEFINE x     SMALLINT
	DEFINE l_tim DATETIME HOUR TO SECOND
	DEFINE l_tmp STRING

	CALL g2_core.m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
	CALL g2_init.g2_init(base.Application.getArgument(1), "matDesTest")
	CALL ui.Interface.setText(SFMT("%1 - %2", C_PRGDESC, C_PRGVER))

	CALL getIcons()
	FOR x = 1 TO 15
		LET l_arr[x].col1 = TODAY
		LET l_arr[x].col2 = "Row " || x
		LET l_arr[x].col3 = x
		LET l_arr[x].img  = C_IMG
	END FOR
	FOR x = 1 TO m_icons.getLength()
		LET l_listView[x].col1 = m_icons[x].i_name
		LET l_listView[x].col2 = SFMT("File: %1 Glypth: %2", m_icons[x].i_file, m_icons[x].i_glyph)
		LET l_listView[x].img  = m_icons[x].i_name
	END FOR
	LET l_rec.fld1    = "Active"
	LET l_rec.fld2    = TODAY
	LET l_rec.fld3    = TODAY-1
	LET l_tim         = TIME
	LET l_rec.fld2a   = ((l_tim + 90 UNITS MINUTE) - l_tim)
	LET l_rec.fld4    = "DarkViolet2"
	LET l_rec.fld5    = "Red"
	LET l_rec.fld6    = "Turquoise2"
	LET l_rec.fld7    = "Inactive"
	LET l_rec.fld8    = "Active"
	LET l_rec.fld9    = "Inactive"
	LET l_rec.fld10   = "Active"
	LET l_rec.fld11   = "Inactive"
	LET l_rec.okay    = TRUE
	LET l_rec.notokay = FALSE
	LET l_rec.nul     = NULL
	CALL getColours()

	OPEN FORM f FROM "matDesTest"
	DISPLAY FORM f

	DISPLAY fgl_getenv("FGLIMAGEPATH") TO imgpath
	DISPLAY getAUIAttrVal("StyleList", "fileName") TO stylefile
	DISPLAY fgl_getVersion() TO rtver
	DISPLAY SFMT("%1 %2 %3 %4", ui.Interface.getFrontEndName(), ui.Interface.getFrontEndVersion(), ui.Interface.getUniversalClientName(),  ui.Interface.getUniversalClientVersion()) TO client
	-- various attempt to bring listView page to front in folder, all FAIL!
	CALL ui.Window.getCurrent().getForm().ensureElementVisible("tab2info")
	DISPLAY ARRAY l_listView TO arr2.*
		BEFORE ROW EXIT DISPLAY
	END DISPLAY
	CALL ui.Interface.refresh()
	---------------------------------------------------------

	DIALOG ATTRIBUTE(UNBUFFERED, FIELD ORDER FORM)
		INPUT BY NAME l_rec.* ATTRIBUTES(WITHOUT DEFAULTS)
			ON CHANGE fld4
				CALL DIALOG.setFieldValue("col_hex", getColour(l_rec.fld4))
{ Can't change the content of a web component using this FC because it's in an iframe.
				TRY
					CALL ui.Interface.frontCall("mymodule","replace_html",["colour",l_rec.fld3],[x])
					DISPLAY SFMT("FC test: %1", x)
				CATCH
					DISPLAY SFMT("FC test failed! %1 %2", status, err_get(status))
				END TRY}
				LET l_rec.fld6 = l_rec.fld4
			ON CHANGE fld6
				CALL set_completer(DIALOG, l_rec.fld6)
				CALL DIALOG.setFieldValue("col_hex", getColour(l_rec.fld6))
			AFTER FIELD fld6
				CALL DIALOG.setFieldValue("col_hex", getColour(l_rec.fld6))
		END INPUT
		DISPLAY ARRAY l_arr TO arr1.* --ATTRIBUTES(ACCEPT=FALSE)
		END DISPLAY
		DISPLAY ARRAY l_listView TO arr2.*
			BEFORE ROW
				DISPLAY SFMT("On row %1 of %2", DIALOG.getCurrentRow("arr2"), l_listView.getLength()) TO tab2info
			ON UPDATE
				CALL g2_core.g2_winMessage("Update", "Update not available!", "exclamation")
			ON DELETE
				CALL g2_core.g2_winMessage("Delete", "Delete not available!", "exclamation")
		END DISPLAY
		DISPLAY ARRAY l_listView TO arr3.*
			BEFORE ROW
				DISPLAY SFMT("On row %1 of %2", DIALOG.getCurrentRow("arr3"), l_listView.getLength()) TO tab3info
		END DISPLAY
		DISPLAY ARRAY m_colours TO arr4.*
		END DISPLAY

		COMMAND "bomb"
			ERROR "Bang!"
		ON ACTION msg
			MESSAGE "Hello Message"
		ON ACTION err
			ERROR "Error Message"
		ON ACTION win
			CALL win()
		ON ACTION win_quest
			CALL fgl_winQuestion("Confirm", "Are you sure?", "Yes", "Yes|No", "question",0) RETURNING l_tmp
			CALL g2_core.g2_winMessage("Info", SFMT("Answer %1", l_tmp), "information")
		ON ACTION win_mess
			CALL notify(C_NOTICE)
			CALL g2_core.g2_winMessage("Info", "Testing", "information")
			CALL notify("")
		ON ACTION arr2
			CALL DIALOG.nextField("lvcol1")
		ON ACTION arr3
			CALL DIALOG.nextField("a3col1")

		ON ACTION constrct
			CALL constrct()

		ON ACTION wintitle
			CALL fgl_settitle("My Window Title")
		ON ACTION uitext
			CALL ui.Interface.setText("My UI Text")

		ON ACTION notify
			CALL notify(C_NOTICE)
			SLEEP 2
			CALL notify("")

		ON ACTION dyntext
			CALL gbc_replaceHTML("dyntext", "Dynamic Text:" || CURRENT)
		ON ACTION darklogo
			CALL gbc_replaceHTML("logocell", "<img src='./resources/img/logo_dark.png'/>")
		ON ACTION lightlogo
			CALL gbc_replaceHTML("logocell", "<img src='./resources/img/logo_light.png'/>")

		ON ACTION pg
			CALL pg(DIALOG.getForm(), 0)
		ON ACTION pg50
			CALL pg(DIALOG.getForm(), (PG_MAX / 2))
		ON ACTION sleep
			SLEEP 5
		ON ACTION showform
			CALL showForm()
		ON ACTION inactive
			CALL dummy()
		ON ACTION about
			CALL g2_about.g2_about()
		ON ACTION actiona
			ERROR "Control-A"
		ON ACTION actionb
			ERROR "Control-B"
		ON ACTION actionc
			ERROR "Control-C"
		ON ACTION actiond
			ERROR "Control-D"
		ON ACTION actione
			ERROR "Control-E"
		ON ACTION actionf
			ERROR "Control-F"
		ON ACTION actiong
			ERROR "Control-G"
		ON ACTION actionh
			ERROR "Control-H"
		ON ACTION actioni
			ERROR "Control-I"
		ON ACTION actionj
			ERROR "Control-J"
		ON ACTION actionk
			ERROR "Control-K"
		ON ACTION actionl
			ERROR "Control-L"
		ON ACTION actionm
			ERROR "Control-M"
		ON ACTION actionn
			ERROR "Control-N"
		ON ACTION actiono
			ERROR "Control-O"
		ON ACTION actionp
			ERROR "Control-P"
		ON ACTION actionq
			ERROR "Control-Q"
		ON ACTION actionr
			ERROR "Control-R"
		ON ACTION actions
			ERROR "Control-S"
		ON ACTION actiont
			ERROR "Control-T"
		ON ACTION actionu
			ERROR "Control-U"
		ON ACTION actionv
			ERROR "Control-V"
		ON ACTION actionw
			ERROR "Control-W"
		ON ACTION actionx
			ERROR "Control-X"
		ON ACTION actiony
			ERROR "Control-Y"
		ON ACTION actionz
			ERROR "Control-Z"
		ON ACTION asterisk
			ERROR "Asterisk"
		ON ACTION asterisk2
			ERROR "Asterisk2"
		ON ACTION f1
			ERROR "F1"
		ON ACTION f2
			ERROR "F2"
		ON ACTION f3
			ERROR "F3"
		ON ACTION f4
			ERROR "F4"
		ON ACTION f5
			ERROR "F5"
		ON ACTION f6
			ERROR "F6"
		ON ACTION f7
			ERROR "F7"
		ON ACTION f8
			ERROR "F8"
		ON ACTION f9
			ERROR "F9"
		ON ACTION f10
			ERROR "F10"
		ON ACTION f11
			ERROR "F11"
		ON ACTION f12
			ERROR "F12"
		ON ACTION clipset
			CALL clipSet("Hello world\nThis is a test!")
		ON ACTION clipshow
			CALL clipShow()
		ON ACTION fc_ismob
			CALL fgl_winMessage(
					"Mobile?", IIF(gbc_isMobile(), "App Running on Mobile device!", "App not running on Mobile device"),
					"information")
		ON ACTION close
			EXIT DIALOG
		ON ACTION quit
			EXIT DIALOG
		BEFORE DIALOG
			CALL pg(DIALOG.getForm(), (PG_MAX / 2))
			IF ui.Interface.getFrontEndName() != "GBC" THEN
				CALL DIALOG.setActionActive("darklogo", FALSE)
				CALL DIALOG.setActionActive("lightlogo", FALSE)
				CALL DIALOG.setActionActive("dyntext", FALSE)
			END IF
			CALL DIALOG.getForm().ensureElementVisible("tab2info") -- attempt to bring listView to front in folder
			CALL DIALOG.setFieldValue("col_hex", getColour(l_rec.fld4))
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
-- Function just to cause everything to go inactive
FUNCTION dummy()
	MENU "dummy"
		BEFORE MENU
			CALL DIALOG.getForm().setElementText("inactive", "Active")
			CALL DIALOG.getForm().setElementImage("inactive", "eye")
		ON ACTION inactive
			CALL DIALOG.getForm().setElementText("inactive", "Inactive")
			CALL DIALOG.getForm().setElementImage("inactive", "eye-slash")
			EXIT MENU
	END MENU
END FUNCTION
--------------------------------------------------------------------------------
-- ProgressBar tests
FUNCTION pg(l_f ui.Form, l_just_set INTEGER)
	DEFINE x    SMALLINT
	DEFINE l_dn om.DomNode
	LET l_dn = l_f.findNode("FormField", "formonly.pg")
	LET l_dn = l_dn.getFirstChild()
	CALL l_dn.setAttribute("valueMax", PG_MAX)
	IF l_just_set > 0 THEN
		DISPLAY l_just_set TO pg
		CALL ui.Interface.refresh()
	ELSE
		FOR x = 1 TO PG_MAX
			DISPLAY x TO pg
			CALL ui.Interface.refresh()
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- GBC ONLY - isMobile
FUNCTION gbc_isMobile() RETURNS BOOLEAN
	DEFINE l_bool BOOLEAN = FALSE
	IF ui.Interface.getFrontEndName() MATCHES "GM?" THEN
		RETURN TRUE
	END IF
	IF ui.Interface.getFrontEndName() = "GDC" THEN
		RETURN FALSE
	END IF
	CALL ui.Interface.frontCall("mymodule", "isMobile", [], l_bool)
	RETURN l_bool
END FUNCTION
--------------------------------------------------------------------------------
-- GBC ONLY - Dynamically replace HTML code
FUNCTION gbc_replaceHTML(l_obj STRING, l_txt STRING)
	DEFINE l_ret STRING
	IF ui.Interface.getFrontEndName() = "GBC" THEN
		CALL ui.Interface.frontCall("mymodule", "replace_html", [l_obj, l_txt], l_ret)
	ELSE
		CALL g2_winMessage("Error", "GBC Test only!", "exclamation")
	END IF
	DISPLAY "l_ret:", l_ret
END FUNCTION
--------------------------------------------------------------------------------
-- Show a list .42f files in a Window and allow them to be viewed
FUNCTION showForm()
	DEFINE l_path, l_file STRING
	DEFINE l_handle       INTEGER
	IF m_forms.getLength() = 0 THEN
		LET l_path = os.Path.pwd()
		CALL os.Path.dirSort("name", 1)
		LET l_handle = os.Path.dirOpen(l_path)
		WHILE l_handle > 0
			LET l_file = os.Path.dirNext(l_handle)
			IF l_file IS NULL THEN
				EXIT WHILE
			END IF
			IF os.Path.extension(l_file) = "42f" THEN
				LET m_forms[m_forms.getLength() + 1] = l_file
			END IF
		END WHILE
		CALL os.Path.dirClose(l_handle)
	END IF
	OPEN WINDOW matDesTest_forms WITH FORM "matDesTest_forms"
	DISPLAY ARRAY m_forms TO arr.*
		ON ACTION accept
			CALL showForm2(m_forms[arr_curr()])
		ON ACTION win
			CALL win()
	END DISPLAY
	CLOSE WINDOW matDesTest_forms
END FUNCTION
--------------------------------------------------------------------------------
-- Open a window with the pass form name
FUNCTION showForm2(l_formName STRING)
	OPEN WINDOW aform WITH FORM l_formName
	MENU
		ON ACTION close
			EXIT MENU
		ON ACTION cancel
			EXIT MENU
		ON ACTION quit
			EXIT MENU
	END MENU
	CLOSE WINDOW aform
END FUNCTION
--------------------------------------------------------------------------------
-- A simple modal window
FUNCTION win()
	OPEN WINDOW win WITH FORM "matDesTest_modal"
	MENU
		ON ACTION close
			EXIT MENU
		ON ACTION cancel
			EXIT MENU
	END MENU
	CLOSE WINDOW win
END FUNCTION
--------------------------------------------------------------------------------
-- A value of aui node
FUNCTION getAUIAttrVal(l_nodeName STRING, l_attName STRING) RETURNS STRING
	DEFINE l_ret STRING
	DEFINE l_nl  om.NodeList
	LET l_nl = ui.Interface.getRootNode().selectByTagName(l_nodeName)
	IF l_nl.getLength() = 0 THEN
		RETURN NULL
	END IF
	LET l_ret = l_nl.item(1).getAttribute(l_attName)
	RETURN l_ret
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION notify(l_notif STRING)
	DEFINE l_text STRING
	LET l_text = ui.Interface.getText()
	IF l_notif IS NOT NULL THEN
		LET l_text = SFMT("%1 %2", l_notif, l_text)
	END IF
	--CALL ui.Interface.setText(l_text)
	CALL ui.Window.getCurrent().setText(l_text)
	CALL ui.Interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION constrct()
	DEFINE l_const STRING
	LET int_flag = FALSE
	CONSTRUCT BY NAME l_const ON fld1, fld2, fld3, fld4
	IF NOT int_flag THEN
		CALL fgl_winMessage("Query", l_const, "information")
	END IF
	LET int_flag = FALSE
END FUNCTION
--------------------------------------------------------------------------------
-- sets the completer items of a current form field
FUNCTION set_completer(l_d ui.Dialog, l_in_str STRING)
	DEFINE l_items DYNAMIC ARRAY OF STRING
	DEFINE i       INT
	IF l_in_str.getLength() > 0 THEN
		FOR i = 1 TO m_colours.getLength()
			IF m_colours[i].c_name.toUpperCase() MATCHES l_in_str.toUpperCase().append("*") THEN -- case insensitive filter
				LET l_items[l_items.getLength() + 1] = m_colours[i].c_name
				IF l_items.getLength() == 50 THEN
					EXIT FOR
				END IF -- Completer is limited to 50 items			
			END IF
		END FOR
	END IF
	CALL l_d.setCompleterItems(l_items)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getColour(l_colName STRING) RETURNS STRING
	DEFINE l_cnt SMALLINT
	FOR l_cnt = 1 TO m_colours.getLength()
		IF m_colours[l_cnt].c_name = l_colName THEN
			DISPLAY SFMT("getColour: %1 Hex: %2", l_colName, m_colours[l_cnt].c_hex)
			RETURN m_colours[l_cnt].c_hex
		END IF
	END FOR
	DISPLAY SFMT("getColour: %1 Not Found", l_colName)
	RETURN NULL
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION cb_colour(l_cb ui.ComboBox) RETURNS()
	DEFINE l_cnt SMALLINT
	FOR l_cnt = 1 TO m_colours.getLength()
		CALL l_cb.addItem(m_colours[l_cnt].c_name.trim(), m_colours[l_cnt].c_name.trim())
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getIcons() RETURNS()
	DEFINE c base.Channel
	DEFINE l_icon RECORD
		fld1 STRING,
		fld2 STRING,
		fld3 STRING
	END RECORD
	DEFINE l_cnt  SMALLINT = 0
	DEFINE l_file STRING
	DEFINE l_imgp STRING
	DEFINE l_tok  STRING
	DEFINE x      SMALLINT
	DEFINE l_toks base.StringTokenizer
	LET l_imgp = fgl_getenv("FGLIMAGEPATH")
	LET l_toks = base.StringTokenizer.create(l_imgp, ":")
	WHILE l_toks.hasMoreTokens()
		LET l_tok = l_toks.nextToken()
		IF l_tok MATCHES "*.txt" THEN
			LET l_file = l_tok
			EXIT WHILE
		END IF
	END WHILE
	IF l_file IS NULL OR l_file.getLength() < 2 THEN
		LET l_file = os.Path.join(base.Application.getFglDir(), "lib")
		LET l_file = os.Path.join(l_file, "image2font.txt")
	END IF
	DISPLAY SFMT("getIcons from %1", l_file)
	LET c = base.Channel.create()
	CALL c.setDelimiter(":")
	CALL c.openFile(l_file, "r")
	WHILE NOT c.isEof()
		IF c.read([l_icon.*]) THEN
			IF l_icon.fld1.getCharAt(1) = "#" THEN CONTINUE WHILE END IF
			--IF l_icon.fld1.subString(1, 3) = "fa-" OR l_icon.fld1.subString(1, 4) = "fas-" THEN
				LET x                                  = l_icon.fld1.getIndexOf("=", 1)
				LET m_icons[l_cnt := l_cnt + 1].i_name = l_icon.fld1.subString(1, x - 1)
				LET m_icons[l_cnt].i_file              = l_icon.fld1.subString(x + 1, l_icon.fld1.getLength())
				LET m_icons[l_cnt].i_glyph             = l_icon.fld2
				LET m_icons[l_cnt].i_colr              = l_icon.fld3
			--END IF
		END IF
	END WHILE
	CALL c.close()
	DISPLAY SFMT("getIcons from %1 got %2 icons", l_file, m_icons.getLength())
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getColours() RETURNS()
	DEFINE c     base.Channel
	DEFINE l_col t_colour
	DEFINE l_cnt SMALLINT = 0
	DEFINE l_file STRING

	LET l_file = os.Path.join(base.Application.getProgramDir(),C_COLOURSFILE )
	IF NOT os.Path.exists(l_file) THEN
		DISPLAY SFMT("Didn't find '%1'.", l_file)
		LET l_file = os.Path.join("../etc/", C_COLOURSFILE)
	END IF
	IF NOT os.Path.exists(l_file) THEN
		DISPLAY SFMT("Didn't find '%1'.", l_file)
		RETURN
	END IF
	DISPLAY SFMT("Loading '%1' ...", l_file)
	LET c = base.Channel.create()
	CALL c.openFile(l_file, "r")
	WHILE NOT c.isEof()
		IF c.read([l_col.*]) THEN
			LET m_colours[l_cnt := l_cnt + 1].c_name = l_col.c_name.trim()
			LET m_colours[l_cnt].c_hex               = l_col.c_hex
		END IF
	END WHILE
	CALL c.close()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION clipSet(l_text STRING) RETURNS()
	DEFINE l_res STRING
	CALL ui.Interface.frontCall("standard", "cbset", l_text, l_res)
	MESSAGE (SFMT("Result: %1", IIF(l_res, "Success", "Failed")))
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION clipShow() RETURNS()
	DEFINE l_res STRING
	CALL ui.Interface.frontCall("standard", "cbget", [], l_res)
	CALL fgl_winMessage("Clipboard", l_res, "information")
END FUNCTION
