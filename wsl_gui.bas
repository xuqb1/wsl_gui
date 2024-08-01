#PBFORMS CREATED V1.51
'------------------------------------------------------------------------------
' �ļ�������PB/Forms ���.
' ��Ӧ���������ļ���һ�С�����PB/Forms�����ڳ�Ϊ������Ŀ�ʼ����������
' ��������ֱ�ӵ���PB/Forms���б༭. ��Ҫ�ֹ��޸Ļ�ɾ����Щ��䣬����Do not manually edit or delete these
' PB/Forms�����޷���ȷ���ض�����
' ����PB/Forms�ĵ��ɻ�ø�����Ϣ
' ��ʼ�����飬��:    #PBFORMS BEGIN ...
' ���������飬��:      #PBFORMS END ...
' ���� PB/Forms ��䣬��:
'     #PBFORMS DECLARATIONS
' ������PB/Forms����Ķ������
' �ļ��е�����λ�ÿ������޸�
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** ͷ�ļ� **
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
'   ** ���弰�ؼ�ID���� **
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
'   ** �������� **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** ��Ӧ�ó������ **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** �Ի���ص� **
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
            MSGBOX "��ѡ��ϵͳ",%MB_OK,"��ʾ"
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          getSysList(CB.HNDL)
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "����Ĭ��ϵͳ���  "  + commandStr
        CASE %IDC_REMOVEBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "��ѡ��ϵͳ",%MB_OK,"��ʾ"
            EXIT FUNCTION
          END IF
          rs = MSGBOX("δ����ʱ�Ƴ����ᵼ�����ݶ�ʧ��Ҫ�����Ƴ���?",%MB_YESNO OR %MB_ICONQUESTION,"��ʾ")
          IF rs = %IDNO THEN
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --unregister " + tmpStr
          SHELL commandStr,0
          getSysList(CB.HNDL)
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "�Ƴ�ϵͳ���  "  + commandStr
        CASE %IDC_BACKUPBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "��ѡ��ϵͳ",%MB_OK,"��ʾ"
            EXIT FUNCTION
          END IF
          DISPLAY SAVEFILE CB.HNDL,,,"ѡ�񱸷�λ�ü��ļ���",EXE.PATH$ + "bak", CHR$("TAR", 0, "*.tar", 0), _
              tmpStr + "_"+getDateTime, "tar", 0 TO fileName
          IF fileName = "" OR RIGHT$(LCASE$(fileName),4) <> ".tar" THEN
            EXIT FUNCTION
          END IF
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --set-default " + tmpStr
          SHELL commandStr,0
          commandStr = ENVIRON$("COMSPEC") + " /C wsl --export " + tmpStr + " " + $DQ + fileName + $DQ
          SHELL commandStr,1,EXIT TO rs
          DIALOG DOEVENTS
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "�������  " + commandStr
        CASE %IDC_RENAMEBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "��ѡ��ϵͳ",%MB_OK,"��ʾ"
            EXIT FUNCTION
          END IF
          rs = InputDlg(CB.HNDL,"������������",newSysname)
          'msgbox str$(rs) + $crlf + newSysname
          newSysname = TRIM$(newSysname)
          IF rs = 0 OR newSysname = "" THEN
            EXIT FUNCTION
          END IF
          IF newSysname = "" THEN
            MSGBOX "�����Ʋ���Ϊ��"
            EXIT FUNCTION
          END IF
          IF checkSysname(CB.HNDL,newSysname,tmpStr)=0 THEN
            MSGBOX "�������ѱ�ʹ��",%MB_OK,"��ʾ"
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
          CONTROL SET TEXT CB.HNDL,%IDC_STATUS, "�������ɹ� " + commandStr
        CASE %IDC_STARTBT
          tmpStr = getSelectedSysName(CB.HNDL, 2)
          IF tmpStr = "" THEN
            MSGBOX "��ѡ��ϵͳ",%MB_OK,"��ʾ"
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
'   ** �Ի���1 **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL remarkStr AS STRING

  #PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "wsl����", , , 300, 200, %WS_POPUP OR _
                        %WS_BORDER OR %WS_DLGFRAME OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
                        %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME _
                        OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT OR %WS_THICKFRAME, _
                        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
                        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD LISTVIEW,hDlg, %IDC_SYSLISTLV,"", 5,5,160,100,%LVS_REPORT OR %LVS_SHOWSELALWAYS OR %LVS_SINGLESEL OR %WS_TABSTOP, _
      %WS_EX_STATICEDGE
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,1,"",15,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,2,"����",100,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,3,"״̬",50,2
    LISTVIEW INSERT COLUMN hDlg,%IDC_SYSLISTLV,4,"�汾",30,2

    CONTROL ADD BUTTON, hDlg,%IDC_REFRESHBT,"ˢ��", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_DEFAULTBT,"Ĭ��", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_REMOVEBT,"�Ƴ�", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_BACKUPBT,"����", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_RENAMEBT,"������", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_STARTBT,"����", 170, 5, 45, 20, %BS_FLAT
    CONTROL ADD BUTTON, hDlg,%IDC_SHUTDOWNBT,"�ػ�", 170, 5, 45, 20, %BS_FLAT
    'CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT,    "",       5,  5, 160, 20, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    'CONTROL ADD TEXTBOX,  hDlg, %IDC_REMARK,  remarkStr, 5,  30,200, 20, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    CONTROL ADD TEXTBOX,  hDlg, %IDC_STATUS,  "״̬: ����",    25, 40,100, 14, %ES_READONLY OR %ES_MULTILINE,%WS_EX_STATICEDGE
    'CONTROL ADD BUTTON, hDlg, %IDC_BUTTON1, "���",   170, 5, 45, 20, %bs_text
    'CONTROL ADD BUTTON, hDlg, %IDC_BUTTON2, "����", 80, 90, 45, 20
    CONTROL ADD BUTTON, hDlg, %IDC_CLOSEBT, "�ر�", 130, 90, 45, 20, %BS_FLAT

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
    MSGBOX "���� #" + FORMAT$(ERR) + " - " + ERROR$(ERR) + $CR + _
        "���ļ�ʱ����: list.text", %MB_ICONEXCLAMATION, "��ʾ"
    EXIT FUNCTION
  END IF
  '���ļ�������
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
  CONTROL SET TEXT hWnd, %IDC_STATUS, "ˢ�����  "  + commandStr
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
' ���������ļ����ĵ�ǰ�ռ��ַ�������:160108232
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
