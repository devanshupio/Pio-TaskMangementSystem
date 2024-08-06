**Free
// -------------------------------------------------------------------------------
// Created By..........: Programmers.io @ 2024
// Created Date........: 2024/24/07
// Developer...........: Devanshu Sharma
// Description.........: Login Main Programm
// -------------------------------------------------------------------------------
// MODIFICATION LOG:
// -------------------------------------------------------------------------------
// Date    | Mod_ID  | Developer  | Case and Description
// --------|---------|------------|-----------------------------------------------
// 24/24/07|         | Devanshu S | File Created
// -------------------------------------------------------------------------------

// Compilation Instruction
Ctl-Opt option(*nodebugio:*srcstmt);
Ctl-Opt Nomain;


//------------------------------------------------------------------
//  File Declartion
//------------------------------------------------------------------


Dcl-f Loginpf    Usage(*Input:*Output:*Update) Keyed;
Dcl-f MANAGERDSP Workstn  Indds(#IndicatorDs);

//------------------------------------------------------------------
//  Ds Declartion
//------------------------------------------------------------------

Dcl-ds #IndicatorDs;
    Exit           Ind Pos(03);
    Back           Ind Pos(12);
    Refresh        Ind Pos(05);
    SflDsp         Ind Pos(53);
    SflDspCtl      Ind Pos(54);
    SflClr         Ind POs(51);
    SflEnd         Ind Pos(52);
End-ds;


//-------------------------------------------------------------------
// variable Declartion
//-------------------------------------------------------------------

  Dcl-S Rrn# zoned(4);



//------------------------------------------------------------------
// Main Program
//------------------------------------------------------------------


 Dcl-proc ProjectDashboard  export;
    dow Exit = *off;
       Clear_sfl();
       Load_sfl();
       Dsply_sfl();
    enddo;
 End-proc;




Dcl-Proc Clear_sfl;
   sflclr = *on;
   Rrn# = 0;
   write SflProjCtl;
   sflclr = *off;
End-Proc;

Dcl-Proc Load_sfl;

     Exec Sql
         Set Option Commit = *None;

    Exec Sql
         Declare SflCursor Cursor for
         Select Projid, PName, PTeamLead, PstrDate, PStatus From
         ProjectPf;

    Exec Sql
        Open SflCursor;

    Dow SqlCode = 0;
        Exec sql
        Fetch Next From SflCursor into
        :DProjId, :DPName, :DPTeamLead, :DPstrDate, :DPStatus;
        Rrn# = Rrn# +1;

        If Rrn# > 9999;
          Leave;
        Endif;

        Write SflProj;
    enddo;
End-Proc;


Dcl-Proc Dsply_sfl;
    SflDsp    = *On;
    SflDspCtl = *On;
    SflEnd    = *On;

    If Rrn# < 1;
       SflDsp = *Off;
    EndIf;

    Exfmt  SflProjCtl  ;

End-Proc;
