%IDC_EDIT101 = 101
%IDC_LABEL102 = 102
'------------------------------------------------------------------------------
FUNCTION InputDlg(BYVAL hParent AS DWORD,BYVAL promptStr AS STRING,BYREF rsStr AS STRING,OPT titleStr AS STRING,_
          defaultStr AS STRING,xx AS LONG,yy AS LONG)AS LONG
  LOCAL hDlg AS DWORD, hCtl AS DWORD
  LOCAL ttStr   AS STRING
  LOCAL orgiStr AS STRING
  LOCAL xpos    AS LONG
  LOCAL ypos    AS LONG
  LOCAL desktopw AS LONG
  LOCAL desktoph AS LONG
  'LOCAL rsStr   AS STRING 'asciiz * 200
  LOCAL rsLng   AS LONG
  LOCAL dwStyle AS LONG
  LOCAL pX,pY,pW,pH AS LONG
  LOCAL tmpLng    AS LONG
  LOCAL rc          AS RECT
  LOCAL pt          AS POINTAPI

  ttStr="提示"
  orgiStr=""

  DESKTOP GET CLIENT TO desktopw,desktoph
  IF ISFALSE ISMISSING(titleStr) THEN
    ttStr=titleStr
  END IF
  IF ISFALSE ISMISSING(defaultStr) THEN
    orgiStr=defaultStr
  END IF
  IF ISFALSE ISMISSING(xx) THEN
    xpos=xx
  END IF
  IF ISFALSE ISMISSING(yy) THEN
    ypos=yy
  END IF
  DIALOG NEW 0, ttStr,xpos,ypos , 200, 123, _
              %WS_POPUP OR %WS_CAPTION OR %WS_THICKFRAME,%WS_EX_TOOLWINDOW TO hDlg
  IF ISMISSING(xx) OR ISMISSING(yy) THEN
    IF hParent=0 THEN
      dwStyle=GetWindowLong(hDlg,%GWL_STYLE)
      SetWindowLong(hDlg,%GWL_STYLE,dwStyle OR %DS_CENTER)
    ELSE
       CenterDialog(hParent,hDlg,200,123)
    END IF
  END IF
  DIALOG GET LOC hDlg TO pX,pY
  DIALOG SET USER hDlg,1,VARPTR(rsStr)
  DIALOG SEND hDlg, %WM_SETICON, %ICON_SMALL, LoadIcon(%NULL, BYVAL %IDI_APPLICATION)
  DIALOG SEND hDlg, %WM_SETICON, %ICON_BIG, LoadIcon(%NULL, BYVAL %IDI_APPLICATION)
  CONTROL ADD TEXTBOX, hDlg, %IDC_EDIT101, orgiStr, 5, 101, 187, 15, _
              %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_AUTOHSCROLL, _
              %WS_EX_CLIENTEDGE OR %WS_EX_NOPARENTNOTIFY
  CONTROL ADD BUTTON, hDlg, %IDOK, "确定", 139, 6, 53, 12, _
              %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP, _
              %WS_EX_NOPARENTNOTIFY
  CONTROL ADD BUTTON, hDlg, %IDCANCEL, "取消", 139, 23, 53, 12, _
              %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP, _
              %WS_EX_NOPARENTNOTIFY
  CONTROL ADD LABEL, hDlg, %IDC_LABEL102, promptStr, 7, 6, 127, 89, _
              %WS_CHILD OR %WS_VISIBLE, _
              %WS_EX_NOPARENTNOTIFY
  DIALOG SHOW MODAL hDlg, CALL InputDlgProc TO rsLng
  IF rsLng=0 THEN
    rsStr=""
    FUNCTION=0
  ELSE
    FUNCTION=1
  END IF
END FUNCTION
CALLBACK FUNCTION InputDlgProc()AS LONG
  LOCAL tmpStr  AS STRING
  LOCAL tmpLng  AS LONG
  LOCAL pRsStr  AS STRING PTR
  LOCAL xx,yy   AS LONG

  SELECT CASE CB.MSG
    CASE %WM_SIZE
      IF CBWPARAM = %SIZE_MINIMIZED THEN EXIT FUNCTION
      DIALOG GET CLIENT CB.HNDL TO xx,yy
      IF xx<120 THEN
        xx=120
        DIALOG SET CLIENT CB.HNDL,xx,yy
      END IF
      IF yy<120 THEN
        yy=120
        DIALOG SET CLIENT CB.HNDL,xx,yy
      END IF
      CONTROL SET SIZE CB.HNDL,%IDC_EDIT101, xx-15, 15
      CONTROL SET LOC  CB.HNDL,%IDC_EDIT101, 5, yy-25
      CONTROL SET SIZE CB.HNDL,%IDC_LABEL102, xx-70, yy-36
      CONTROL SET LOC CB.HNDL, %IDOK, xx-58, 10
      CONTROL SET LOC CB.HNDL, %IDCANCEL, xx-58, 30
      DIALOG REDRAW CB.HNDL
    CASE %WM_COMMAND
      'Messages from controls and menu items are handled here.
      '-------------------------------------------------------
      IF CB.CTLMSG <> %BN_CLICKED THEN EXIT FUNCTION
      SELECT CASE CBCTL
       CASE %IDCANCEL
         DIALOG END CBHNDL, 0
       CASE %IDOK
         CONTROL GET TEXT CB.HNDL,%IDC_EDIT101 TO tmpStr
         DIALOG GET USER CB.HNDL,1 TO tmpLng
         pRsStr=tmpLng
         @pRsStr=tmpStr
         'MSGBOX tmpStr
         DIALOG END CB.HNDL,1
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION CenterDialog(BYVAL hParent AS DWORD,BYVAL hDlg AS DWORD,BYVAL dlgWidth AS LONG,BYVAL dlgHeight AS LONG)AS LONG
  LOCAL x,y   AS LONG
  LOCAL rc    AS RECT
  LOCAL pt    AS POINTAPI
  GetWindowRect hParent,rc
  DIALOG PIXELS hDlg,rc.nLeft,rc.nTop TO UNITS rc.nLeft,rc.nTop
  DIALOG PIXELS hDlg,rc.nRight,rc.nBottom TO UNITS rc.nRight,rc.nBottom

  IF ISFALSE IsWindow(hParent) THEN
    hParent=%HWND_DESKTOP
  ELSE
    IF ISFALSE iswindowVisible(hParent) THEN
      hParent=%HWND_DESKTOP
    END IF
  END IF

  IF hParent<>%HWND_DESKTOP THEN
    DIALOG SET LOC hDlg, rc.nLeft+(rc.nRight-rc.nLeft-dlgWidth)\2, rc.nTop+(rc.nBottom-rc.nTop-dlgHeight)\2
  END IF
END FUNCTION
