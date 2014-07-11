; GUI for the Laser Game Project - SMEAGOL - INETS - RWTH AACHEN UNIVERSTIY
; © July 2014, Alexander Nähring
; 

EnableExplicit

XIncludeFile "mainWindow.pbf"

Global PrSF
Global PrSFLISTEN
Global Event
Global WaitInit
Global GameRunning

Global dir$
dir$ = GetCurrentDirectory()
Debug dir$

Global BulletsShot, BulletsMax
Global TimeMax, TimeStart, TimeLeft
Global MoteT1, MoteT2, MoteT3, ReceivedMoteID

InitSound()
UseOGGSoundDecoder()
Global SoundShot = LoadSound(#PB_Any, dir$+"gun.ogg")
Global Dim SoundHit(4)
Define i
For i = 0 To 3
SoundHit(i) = LoadSound(#PB_Any, dir$+"hit"+Str(i)+".ogg")
Next

Declare addLog(logEntry$)
Declare close()
Declare init(*dummy)
Declare updateProgressBar()
Declare sfsend(identifier, moteID, payload1, payload2)
Declare sfsendStop()
Declare sfsendBullets(bullets)
Declare sflistenHandleOutput(Output$)
Declare startGame()
Declare stopGame()
Declare toggleGame()

Procedure addLog(logEntry$)
  Debug logEntry$
  Protected text$
  logEntry$ = logEntry$ + Chr(10)
  logEntry$ = FormatDate("%hh:%ii:%ss - ",Date()) + logEntry$
  
  text$ = GetGadgetText(GadgetEditorLog)
  text$ = logEntry$ + text$
  SetGadgetText(GadgetEditorLog, text$)
EndProcedure

Procedure close()
  addLog("shuting down GUI...")
  HideWindow(WindowMain, #True)
  CloseWindow(WindowMain)
  
  KillProgram(PrSF)
  CloseProgram(PrSF)
  KillProgram(PrSFLISTEN)
  CloseProgram(PrSFLISTEN)
  
  End
EndProcedure

Procedure init(*dummy) ; Init Thread
  addLog("Starting SF...")
  PrSF = RunProgram(dir$+"sf", "9001 /dev/ttyUSB0 115200", "./", #PB_Program_Open|#PB_Program_Read|#PB_Program_Error)
  If Not IsProgram(PrSF)
    addLog("Could not run SF")
    MessageRequester("Error","Could not run SF", #PB_MessageRequester_Ok)
    close()
  EndIf
  Delay(800) ; wait for SF to start  
  
  addLog("Starting SFLISTEN...")
  PrSFLISTEN = RunProgram(dir$+"sflisten", "localhost 9001", "./", #PB_Program_Open|#PB_Program_Read|#PB_Program_Error)
  If Not IsProgram(PrSF)
    addLog("Could not run SFLISTEN")
    MessageRequester("Error","Could not run SFLISTEN", #PB_MessageRequester_Ok)
    close()
  EndIf
  Delay(500) ; wait for sflisten
  
  addLog("Initialization complete...")
  WaitInit = #False
  ProcedureReturn #True
EndProcedure

Procedure updateProgressBar() ; update graphical interface for remeaining bullets
  SetGadgetAttribute(GadgetProgressBarBullets, #PB_ProgressBar_Minimum, 0)
  SetGadgetAttribute(GadgetProgressBarBullets, #PB_ProgressBar_Maximum, BulletsMax)
  SetGadgetState(GadgetProgressBarBullets, BulletsMax-BulletsShot)
  
  If GameRunning
     TimeLeft = TimeMax - (Date() - TimeStart)
    SetGadgetAttribute(GadgetProgressBarTime, #PB_ProgressBar_Minimum, 0)
    SetGadgetAttribute(GadgetProgressBarTime, #PB_ProgressBar_Maximum, TimeMax)
    SetGadgetState(GadgetProgressBarTime, TimeLeft)
  Else
    SetGadgetState(GadgetProgressBarTime, 0)
  EndIf
EndProcedure

Procedure sfsend(identifier, moteID, payload1, payload2)
  Protected prog, out$, command$, arg$, payload$
  payload$ = Str(identifier) + " " + Str(moteID) + " " + Str(payload1) + " " + Str(payload2)
  command$ = dir$+"sfsend"
  arg$ = "localhost 9001 0x00 0xff 0xff 0xff 0xff 0x04 0x22 0x06 " + payload$
  ;addlog(command$ + " " + arg$)
  prog = RunProgram(command$, arg$, "./", #PB_Program_Open|#PB_Program_Read|#PB_Program_Error)
  
  ; wait for execution to finish and print stderr and stdout
  If Not prog
    addLog("error calling sfsend")
  Else
    Repeat  
      out$ = ReadProgramError(prog)
      Delay(10) ; wait for error output!
   Until out$
   addLog("sfsend: " + out$)
   While ProgramRunning(prog)
     Delay(10)
   Wend
   KillProgram(prog)
   CloseProgram(prog)
  EndIf
  
  ProcedureReturn prog
EndProcedure

Procedure sfsendStop()
  ProcedureReturn sfsend(0, 0, 0, 0)
EndProcedure

Procedure sfsendBullets(bullets)
  If bullets < 0
    bullets = 0
  ElseIf bullets > 127
    bullets = 127
  EndIf
  ; reset shot bullets
  BulletsMax = bullets
  BulletsShot = 0
  
  ;ID 1,  Mote 0, pay1, pay2 = bullets
  ProcedureReturn sfsend(1, 0,  0, bullets)
EndProcedure

Procedure sfsendAssignID(moteID)
  ProcedureReturn sfsend(2,moteID,0,0)  
EndProcedure

Procedure sfsendMovement(moteID, openTime, closeTime, randomize = #True)
  If randomize
    Debug opentime
    openTime = openTime + -openTime/4+Random(openTime/2)
    Debug openTime
    closeTime = closeTime + -closeTime/4+Random(closeTime/2)
  EndIf
  If moteID < 1
    moteID = 1
  ElseIf moteID > 3
    moteID = 3
  EndIf 
   
  If openTime < 1
    openTime = 1
  EndIf
  If closeTime < 1
    closeTime = 1
  EndIf
  If openTime > 127
    openTime = 127
  EndIf
  If closeTime > 127
    closeTime = 127
  EndIf
  
  sfsend(1,moteID,openTime,closeTime)
EndProcedure




Procedure sflistenHandleOutput(Output$) 
  Debug "sflisten: '" + Output$ + "'"
  Protected header$ = "00 ff ff ff 01 04 3f 06 "
  ; hex -> str with: Str("$ff")
  
  ; search header
  If CountString(Output$, header$)
    ; strip away header
    Output$ = RemoveString(Output$, header$)
    ;Debug "'"+Output$+"'"
    
    Global identifier, moteID, payload1, payload2
    
    identifier  = Val("$" + Mid(Output$, 1, 2))
    moteID  = Val("$" + Mid(Output$, 4, 2))
    payload1 = Val("$" + Mid(Output$, 7, 2))
    payload2 = Val("$" + Mid(Output$, 10, 2))
    ;Debug "(id, moteID, pay1, pay2) = ("+Str(identifier)+", "+Str(moteID)+", "+Str(payload1)+", "+Str(payload2)+")"
    
    Select identifier
        
      Case 3 ; shot
        If moteID = 0 ; gun mote
          If IsSound(SoundShot)
            PlaySound(SoundShot)
          EndIf
          ; bullets: '03 00 00 count '
          BulletsShot = payload2
          addLog("gunmote released " + Str(BulletsShot) + "/" + Str(BulletsMax) + " bullets")
          If BulletsShot >= BulletsMax 
            BulletsShot = BulletsMax
            stopGame()
          EndIf
        EndIf
        
      Case 4
        ; target mote telling hits
        ; Hits = payload2
        Protected Sound
        Sound = SoundHit(Random(3))
        If IsSound(sound)
          PlaySound(sound)
        EndIf
        addLog("hit registered from mote "+Str(moteID))
        
      Case 5 ; Feedback for ID assignment
        addLog("sflisten: received feedback from moteID "+Str(moteID))
        Select moteID
          Case 1
              moteT1 = #True 
          Case 2
              moteT2 = #True 
          Case 3
              moteT3 = #True 
          EndSelect
      EndSelect
  Else
    ; no header found
    addLog("sflisten: unknown message: "+Output$)
  EndIf

EndProcedure


Procedure startGame()
  If GameRunning
    ProcedureReturn #False
  EndIf
  addLog("starting a new game...")
  SetGadgetText(GadgetButtonToggleGame, "Stop Game")
  
  Protected randomize
  randomize = #False
  
  If MoteT1
    sfsendMovement(1, Val(GetGadgetText(GadgetStringT1Open)), Val(GetGadgetText(GadgetStringT1Close)), randomize)
  EndIf
  If MoteT2
    sfsendMovement(2, Val(GetGadgetText(GadgetStringT2Open)), Val(GetGadgetText(GadgetStringT2Close)), randomize)
  EndIf
  If MoteT3
    sfsendMovement(3, Val(GetGadgetText(GadgetStringT3Open)), Val(GetGadgetText(GadgetStringT3Close)), randomize)
  EndIf
  
  sfsendBullets(Val(GetGadgetText(GadgetSpinBullets)))
  
  
  GameRunning = #True
  TimeStart = Date()
  TimeMax = GetGadgetState(GadgetSpinTime)
  ProcedureReturn #True
EndProcedure

Procedure stopGame()
  If Not GameRunning
    ProcedureReturn #False
  EndIf
  addlog("stopping current game...")
  SetGadgetText(GadgetButtonToggleGame, "Start Game")
  sfsendStop()
  BulletsMax = 0
  BulletsShot = 0
  GameRunning = #False
  ProcedureReturn #True
EndProcedure

Procedure toggleGame()
  If GameRunning
    stopGame()
  Else
    startGame()
  EndIf
EndProcedure

Procedure registerTargetMote(moteID)
    addLog("Register new mote with id "+Str(moteID))
    
    Select moteID
      Case 1
        MoteT1 = #False
      Case 2 
        MoteT2 = #False
      Case 3
        MoteT3 = #False
    EndSelect
    
    ;MessageRequester("Registering a new target mote", "Please press the user button on ONE target mote NOW!"+Chr(13)+"Afterwards, click OK", #PB_MessageRequester_Ok)
    ; assume that target mote is now waiting for ID
    ; send ID to target mote
        
    sfsendAssignID(moteID)
EndProcedure

;----------------------------




OpenWindowMain()
addLog("Starting GUI...")
SetGadgetState(GadgetSpinBullets, 16)
SetGadgetState(GadgetSpinTime, 60)
AddGadgetItem(GadgetComboDifficulty, -1, "easy")
AddGadgetItem(GadgetComboDifficulty, -1, "normal")
AddGadgetItem(GadgetComboDifficulty, -1, "hard")
AddGadgetItem(GadgetComboDifficulty, -1, "custom")

WaitInit = #True
CreateThread(@init(),0)


HideWindow(WindowMain, #False)
Global LastUpdate = 0

Repeat ; main loop
  Event = WaitWindowEvent(100) ; check new events w/o waiting
  
  If LastUpdate < ElapsedMilliseconds()-100 ; check gadgets etc every 100 ms
    LastUpdate = ElapsedMilliseconds()
    
    If WaitInit
      ;{ Initialization not finished
      ; keep all controls disabled and don't do anything
      ;}
    Else
      ; init is finished -> normal mode
      Global Output$
      
      ;{ SF
      Output$ = ReadProgramError(PrSF)
      If Output$
        Output$ = "SF error: "+Output$
        addLog(Output$)
        If Not CountString(Output$, "Note") ; do not prompt notes
          MessageRequester("Error", Output$, #PB_MessageRequester_Ok)
        EndIf
      EndIf 
      If AvailableProgramOutput(PrSF)
        Output$ = "sf: " + ReadProgramString(PrSF)
        addLog(Output$)
      EndIf
      If Not ProgramRunning(PrSF)
        MessageRequester("Error", "SF has stopped!", #PB_MessageRequester_Ok)
        close()
      EndIf
      ;}
      
      ;{ SFLISTEN
       Output$ = ReadProgramError(PrSFLISTEN)
       If Output$
        Output$ = "SFLISTEN error: "+Output$
        addLog(Output$)
        MessageRequester("Error", Output$, #PB_MessageRequester_Ok)
      EndIf 
      If AvailableProgramOutput(PrSFLISTEN)
        Output$ = ReadProgramString(PrSFLISTEN)
        If Output$
          sflistenHandleOutput(Output$)
        EndIf
        
      EndIf
      If Not ProgramRunning(PrSFLISTEN)
        MessageRequester("Error", "SFLISTEN has stopped!", #PB_MessageRequester_Ok)
        close()
      EndIf
      ;}
      
      ;{ Gadgets
      updateProgressBar()
      
      
      Define last_MoteT1, last_MoteT2, last_MoteT3
      
      If Not MoteT1 = last_MoteT1
        last_MoteT1 = MoteT1
        If MoteT1
          DisableGadget(GadgetStringT1Open, #False)
          DisableGadget(GadgetStringT1Close, #False)
        Else
          DisableGadget(GadgetStringT1Open, #True)
          DisableGadget(GadgetStringT1Close, #True)
        EndIf 
      EndIf
      If Not MoteT2 = last_MoteT2
        last_MoteT2 = MoteT2
        If MoteT2
          DisableGadget(GadgetStringT2Open, #False)
          DisableGadget(GadgetStringT2Close, #False)
        Else
          DisableGadget(GadgetStringT2Open, #True)
          DisableGadget(GadgetStringT2Close, #True)
        EndIf 
      EndIf
      If Not MoteT3 = last_MoteT3
        last_MoteT3 = MoteT3
        If MoteT3
          DisableGadget(GadgetStringT3Open, #False)
          DisableGadget(GadgetStringT3Close, #False)
        Else
          DisableGadget(GadgetStringT3Open, #True)
          DisableGadget(GadgetStringT3Close, #True)
        EndIf 
      EndIf
            
      If MoteT1 Or MoteT2 Or MoteT3 ; at least one target has to be online in order to start a new game
        DisableGadget(GadgetButtonToggleGame, #False  )
        DisableGadget(GadgetSpinBullets, #False)
        DisableGadget(GadgetComboDifficulty, #False)
        DisableGadget(GadgetSpinTime, #False)
        
      Else
        DisableGadget(GadgetButtonToggleGame, #True)
        DisableGadget(GadgetSpinBullets, #True)
        DisableGadget(GadgetComboDifficulty, #True)
        DisableGadget(GadgetSpinTime, #True)
        If GameRunning
          stopGame()
        EndIf
      EndIf
            
      ;}
      
    EndIf
  EndIf ; LastUpdate
  
  ;{ Events
  Select event ; handle events
    Case #PB_Event_CloseWindow
      close()

    Case #PB_Event_Gadget
      Select EventGadget()
        Case GadgetButtonToggleGame
          toggleGame()
        Case GadgetButtonRegisterT
        Case GadgetButtonRegisterT1
          registerTargetMote(1)
        Case GadgetButtonRegisterT2
          registerTargetMote(2)
        Case GadgetButtonRegisterT3
          registerTargetMote(3)
          
      EndSelect
      
    Case #PB_Event_Menu
      Select EventMenu()
          
      EndSelect

  EndSelect
  ;} 
  
ForEver
; IDE Options = PureBasic 5.11 (Linux - x86)
; CursorPosition = 207
; FirstLine = 127
; Folding = O+3-
; EnableThread
; EnableXP
; Executable = LGGUI
; EnableCompileCount = 151
; EnableBuildCount = 2
; EnableExeConstant
