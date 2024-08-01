#PBFORMS CREATED V1.51
'------------------------------------------------------------------------------
' 文件首行是PB/Forms 语句.
' 它应该总是在文件第一行。其它PB/Forms语句放在称为命名块的开始与结束语句中
' 这样可以直接调用PB/Forms进行编辑. 不要手工修改或删除这些语句，否则Do not manually edit or delete these
' PB/Forms可能无法正确地重读窗体
' 查阅PB/Forms文档可获得更多信息
' 开始命名块，如:    #PBFORMS BEGIN ...
' 结束命名块，如:      #PBFORMS END ...
' 其它 PB/Forms 语句，如:
'     #PBFORMS DECLARATIONS
' 都是由PB/Forms插入的额外代码
' 文件中的其它位置可自由修改
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** 头文件 **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#IF NOT %DEF(%WINAPI)
  #INCLUDE "WIN32API.INC"
#ENDIF
#INCLUDE "CommCtrl.inc"
#INCLUDE "util.bas"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** 窗体及控件ID声明 **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1  =  101

%IDC_STATUS   = 104
%IDC_SYSLISTLV  = 110
%IDC_REFRESHBT  = 111
%IDC_REMOVEBT   = 112
%IDC_BACKUPBT   = 113
%IDC_RENAMEBT   = 114
%IDC_STARTBT    = 115
%IDC_SHUTDOWNBT = 116
%IDC_DEFAULTBT  = 117
%IDC_CLOSEBT    = 118
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** 函数声明 **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** 主应用程序入口 **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** 对话框回调 **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
  LOCAL xx,yy   AS LONG
  LOCAL tmpStr AS STRING
  LOCAL dwStyle AS DWORD
  LOCAL commandStr AS STRING
  LOCAL fileName AS STRING
  LOCAL newSysname AS STRING
  LOCAL rs AS LONG

  SELECT CASE AS LONG CBMSG
    CASE %WM_INITDIALOG
      CONTROL SEND CBHNDL, %IDC_SYSLISTLV, %LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0 TO dwStyle
      dwStyle = dwStyle OR %LVS_EX_FULLROWSELECT OR %LVS_EX_INFOTIP OR %LVS_EX_GRIDLINES
      CONTROL SEND CBHNDL, %IDC_SYSLISTLV, %LVM_SETEXTENDEDLISTVIEWSTYLE, 0, dwStyle
      getSysList(CB.HNDL)
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CBWPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF
    CASE %WM_SIZE
      IF CBWPARAM = %SIZE_MINIMIZED THEN EXIT FUNCTION
      DIALOG GET CLIENT CB.HNDL TO xx,yy
      IF xx<260 THEN
        xx=260
        DIALOG SET CLIENT CB.HNDL,xx,yy
      END IF
      IF yy<220 THEN
        yy=220
        DIALOG SET CLIENT CB.HNDL,xx,yy
      END IF
      CONTROL SET SIZE CB.HNDL, %IDC_SYSLISTLV, xx-60, YY-30
'      CONTROL SET SIZE CB.HNDL, %IDC_TEXT, xx-60, 20
'      CONTROL SET SIZE CB.HNDL, %IDC_REMARK, xx-60, 20
      CONTROL SET LOC CB.HNDL, %IDC_REFRESHBT, xx-50, 5
      CONTROL SET LOC CB.HNDL, %IDC_DEFAULTBT, xx-50, 30
      CONTROL SET LOC CB.HNDL, %IDC_REMOVEBT, xx-50, 55
      CONTROL SET LOC CB.HNDL, %IDC_BACKUPBT, xx-50, 80
      CONTROL SET LOC CB.HNDL, %IDC_RENAMEBT, xx-50, 105
      CONTROL SET LOC CB.HNDL, %IDC_STARTBT, xx-50, 130
      CONTROL SET LOC CB.HNDL, %IDC_SHUTDOWNBT, xx-50, 155
      CONTROL SET LOC CB.HNDL, %IDC_STATUS, 5, yy-20
      CONTROL SET SIZE CB.HNDL, %IDC_STATUS, xx-60, 12
'      CONTROL SET LOC CB.HNDL, %IDC_BUTTON2, XX-100, YY-30
      CONTROL SET LOC CB.HNDL, %IDC_CLOSEBT, XX-50, YY-30
      DIALOG REDRAW CB.HNDL
    CASE %WM_COMMAND
      ' Process control notifications
      IF CBCTLMSG <> %BN_CLICKED AND CBCTLMSG <> 1 THEN
        EXIT FUNCTION
      END IF
      SELECT CASE AS LONG CBCTL

        CASE %IDC_REFRESHBT
          getSysList(CB.HNDL)
        CASE %IDC_DEFAULTBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "请选择系统",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          getSysList(CB.HNDL)
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "设置默认系统完成  "  + commandStr
        CASE %IDC_REMOVEBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "请选择系统",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          rs = MSGBOX("未备份时移除，会导致数据丢失，要继续移除吗?",%MB_YESNO OR %MB_ICONQUESTION,"提示")
          IF rs = %IDNO THEN
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --unregister " + tmpStr
          SHELL commandStr,0
          getSysList(CB.HNDL)
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "移除系统完成  "  + commandStr
        CASE %IDC_BACKUPBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "请选择系统",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          DISPLAY SAVEFILE CB.HNDL,,,"选择备份位置及文件名",EXE.PATH$ + "bak", CHR$("TAR", 0, "*.tar", 0), _
              tmpStr + "_"+getDateTime, "tar", 0 TO fileName
          IF fileName = "" OR RIGHT$(LCASE$(fileName),4) <> ".tar" THEN
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --export " + tmpStr + " " + $DQ + fileName + $DQ
          SHELL commandStr,1,EXIT TO rs
          DIALOG DOEVENTS
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "备份完成  " + commandStr
        CASE %IDC_RENAMEBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "请选择系统",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          rs = InputDlg(CB.HNDL,"请输入新名称",newSysname)
          'msgbox str$(rs) + $crlf + newSysname
          newSysname = TRIM$(newSysname)
          IF rs = 0 OR newSysname = "" THEN
            EXIT FUNCTION
          END IF
          IF newSysname = "" THEN
            MSGBOX "新名称不能为空"
            EXIT FUNCTION
          END IF
          IF checkSysname(CB.HNDL,newSysname,tmpStr)=0 THEN
            MSGBOX "该名称已被使用",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          fileName = EXE.PATH$ + "bak\" + tmpStr + "_" + getDateTime + "_temp.tar"
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --export " + tmpStr + " " + $DQ + fileName + $DQ
          SHELL commandStr,1,EXIT TO rs
          DIALOG DOEVENTS
          'mkdir EXE.PATH$+newSysname
          'dialog doevents
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --import "+newSysname+" "+EXE.PATH$+newSysname+" "+fileName+" --version 2"
          SHELL commandStr,1,EXIT TO rs
          SHELL ENVIRON$("COMSPEC") + " /C wsl --unregister " + tmpStr,1,EXIT TO rs
          getSysList(CB.HNDL)
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "重命名成功 " + commandStr
        CASE %IDC_STARTBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "请选择系统",%MB_OK,"提示"
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          commandStr = ENVIRON$("COMSPEC") + " /C wsl"
          rs  = SHELL(commandStr)
          'dialog doevents
          SLEEP 3000
          getSysList(CB.HNDL)
        CASE %IDC_SHUTDOWNBT
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --shutdown"
          SHELL commandStr,1
          getSysList(CB.HNDL)
        CASE %IDC_CLOSEBT
            DIALOG END CB.HNDL,0
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** 对话框1 **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL remarkStr AS STRING

  #PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "wsl操作", , , 300, 200, %WS_POPUP OR _
                        %WS_BORDER OR %WS_DLGFRAME OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
                        %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME _
                        OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT OR %WS_THICKFRAME, _
                        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
                        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD LISTVIEW,hDlg, %IDC_SYSLISTLV,"", 5,5,160,100,%LVS_REPORT OR %LVS_SHOWSELALWAYS OR %LVS_SINGLESEL OR %WS_TABSTOP, _
      %WS_EX_STATICEDGE
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,1,"",15,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,2,"名称",100,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,3,"状态",50,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,4,"版本",30,2

    CONTROL ADD BUTTON, hDlg,%IDC_REFRESHBT,"刷新", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_DEFAULTBT,"默认", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_REMOVEBT,"移除", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_BACKUPBT,"备份", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_RENAMEBT,"重命名", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_STARTBT,"启动", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_SHUTDOWNBT,"关机", 170, 5, 45, 20, %BS_FLAT
    'CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT,    "",       5,  5, 160, 20, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    'CONTROL ADD TEXTBOX,  hDlg, %IDC_REMARK,  remarkStr, 5,  30,200, 20, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    CONTROL ADD TEXTBOX,  hDlg, %IDC_STATUS,  "状态: 就绪",    25, 40,100, 14, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    'CONTROL ADD BUTTON, hDlg, %IDC_BUTTON1, "浏览",   170, 5, 45, 20, %bs_text
    'CONTROL ADD BUTTON, hDlg, %IDC_BUTTON2, "生成", 80, 90, 45, 20
    CONTROL ADD BUTTON, hDlg, %IDC_CLOSEBT, "关闭", 130, 90, 45, 20, %BS_FLAT

  #PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

  #PBFORMS BEGIN CLEANUP %IDD_DIALOG1
  #PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION getSysList(BYVAL hWnd AS DWORD)AS LONG
  LOCAL fn AS LONG
  LOCAL tmpStr AS STRING
  LOCAL tmpArr() AS STRING
  LOCAL tmpArr1() AS STRING
  LOCAL i,j AS LONG
  LOCAL hHandle AS LONG
  LOCAL exitCode AS LONG
  LOCAL commandStr AS STRING
  commandStr = ENVIRON$("COMSPEC") + " /C wsl -l -v > list.txt"
  SHELL commandStr,0, EXIT TO exitCode
  DIALOG DOEVENTS
  'msgbox exe.path$ + "list.txt"
  fn = FREEFILE
  OPEN EXE.PATH$ + "list.txt" FOR BINARY AS #fn
  IF ERR THEN
    MSGBOX "错误 #" + FORMAT$(ERR) + " - " + ERROR$(ERR) + $CR + _
        "打开文件时出错: list.text", %MB_ICONEXCLAMATION, "提示"
    EXIT FUNCTION
  END IF
  '读文件到缓存
  tmpStr = SPACE$(LOF(#fn))
  GET #fn, 1, tmpStr
  CLOSE #fn
  tmpStr = ACODE$(tmpStr)
  WHILE INSTR(tmpStr,"  ")>0
    REPLACE "  " WITH " " IN tmpStr
  WEND
  REDIM tmpArr(PARSECOUNT(tmpStr,$CRLF)-1)
  PARSE tmpStr,tmpArr(),$CRLF
  'msgbox tmpStr
  LISTVIEW RESET hWnd, %IDC_SYSLISTLV
  FOR i=1 TO UBOUND(tmpArr())
    tmpStr = tmpArr(i)
    'msgbox tmpStr
    IF tmpStr = "" THEN
      ITERATE FOR
    END IF
    REDIM tmpArr1(3)
    PARSE tmpStr,tmpArr1()," "
    LISTVIEW INSERT ITEM hWnd,%IDC_SYSLISTLV,i,0,tmpArr1(0)
    FOR j=0 TO 3
      LISTVIEW SET TEXT hWnd,%IDC_SYSLISTLV,i,j+1,tmpArr1(j)
    NEXT j
  NEXT i
  CONTROL SET TEXT hWnd, %IDC_STATUS, "刷新完成  "  + commandStr
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION getSelectedSysName(BYVAL hWnd AS DWORD,BYVAL index AS INTEGER)AS STRING
  LOCAL listcount AS LONG
  LOCAL i AS LONG
  LOCAL rowstate AS LONG
  LOCAL tmpStr AS STRING
  LISTVIEW GET COUNT hWnd,%IDC_SYSLISTLV TO listcount
  IF listcount<=0 THEN
    FUNCTION=""
    EXIT FUNCTION
  END IF
  FOR i=1 TO listcount
    rowstate=0
    LISTVIEW GET STATE hWnd,%IDC_SYSLISTLV,i,1 TO rowstate
    IF ISTRUE rowstate THEN
      LISTVIEW GET TEXT hWnd,%IDC_SYSLISTLV,i,index TO tmpStr
      FUNCTION=tmpStr
      EXIT FUNCTION
    END IF
  NEXT i
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------
' 返回用于文件名的当前日间字符串，例:160108232
'------------------------------------------------
FUNCTION getDateTime()AS STRING
  LOCAL st AS SYSTEMTIME
  GetLocalTime st
  FUNCTION = FORMAT$(st.wYear,"0000") & FORMAT$(st.wMonth,"00") & FORMAT$(st.wDay,"00") & _
             FORMAT$(st.wHour,"00") & FORMAT$(st.wMinute,"00") & FORMAT$(st.wSecond,"00") & _
             FORMAT$(st.wMilliseconds,"000")
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION checkSysname(BYVAL hWnd AS DWORD, BYVAL newSysname AS STRING, BYVAL oldSysname AS STRING)AS LONG
  LOCAL listcount AS LONG
  LOCAL i AS LONG
  LOCAL rowstate AS LONG
  LOCAL tmpStr AS STRING

  IF newSysname = oldSysname THEN
    FUNCTION = 0
    EXIT FUNCTION
  END IF
  LISTVIEW GET COUNT hWnd,%IDC_SYSLISTLV TO listcount
  IF listcount<=0 THEN
    FUNCTION = 0
    EXIT FUNCTION
  END IF
  FOR i=1 TO listcount
    LISTVIEW GET TEXT hWnd,%IDC_SYSLISTLV,i,2 TO tmpStr
    IF tmpStr = newSysname THEN
      FUNCTION = 0
      EXIT FUNCTION
    END IF
  NEXT i
  FUNCTION = 1
END FUNCTION
'------------------------------------------------------------------------------
