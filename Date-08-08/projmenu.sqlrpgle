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
Dcl-f Projectpf  Usage(*Input:*Output:*Update) Keyed;
Dcl-f UserPf     Usage(*Input:*Output:*Update) Keyed;
Dcl-f MANAGERDSP Workstn  Indds(#IndicatorDs) sfile(sflproj:Rrn#) sfile(SELTLSFL:Rrn#W) Usropn;

//------------------------------------------------------------------
//  Ds Declartion
//------------------------------------------------------------------

Dcl-ds #IndicatorDs;
    Exit            Ind Pos(03);
    Back            Ind Pos(12);
    Refresh         Ind Pos(05);
    SflDsp          Ind Pos(53);
    SflDspCtl       Ind Pos(54);
    SflClr          Ind POs(51);
    SflEnd          Ind Pos(52);
    IndAddnewProj   Ind Pos(06);
    IndProjName     Ind Pos(35);
    IndProjSdate    Ind Pos(36);
    IndProjEDate    Ind Pos(37);
    IndProjTm       Ind Pos(38);
    IndProjDetails  Ind Pos(39);
    IndProjStatus   Ind Pos(40);
    IndProjBudget   Ind Pos(41);
    IndProjLang     Ind Pos(42);
    IndProProjId    Ind Pos(44);
    SflDspWindow    Ind Pos(58);
    SflDspCtlWindow Ind Pos(59);
    SflClrWindow    Ind Pos(56);
    SflEndWindow    Ind Pos(57);
    Prompt          Ind Pos(04);
End-ds;


//-------------------------------------------------------------------
// variable Declartion
//-------------------------------------------------------------------

Dcl-S Rrn# zoned(4);
Dcl-S Rrn#W zoned(4);
Dcl-s ProjIdC Char(6);
Dcl-s ProjIdSubfix Packed(3);



//------------------------------------------------------------------
// Main Program
//------------------------------------------------------------------
Exec Sql
         Set Option Commit = *None;

Dcl-proc ProjectDashboard Export;
    Open MANAGERDSP;
    dow Exit = *Off Or Back = *Off;
        Heading =  'Work With Project';
        FooterL1 = 'F3=Exit    F5=Refresh    F6=Add New Project    F12=Cancel';
        Clear_sfl();
        Load_sfl();
        Dsply_sfl();
        select;
            when Exit = *on Or Back = *on;
                Back = *off;
                Leave;
            When IndAddnewProj = *on;
                CreateNewProject();
                Back = *off;
            other;

        endsl;
    enddo;
    close MANAGERDSP;
End-proc;



//------------------------------------------------------------------
// Clear_sfl Program For Creating Project
//------------------------------------------------------------------

Dcl-Proc Clear_sfl;
    sflclr = *on;
    Rrn# = 0;
    write SflProjCtl;
    sflclr = *off;
End-Proc;

// Load_sfl Program For Creating Project

Dcl-Proc Load_sfl;



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

    exec sql
        Close SflCursor;
End-Proc;

// Dsply_sfl Program For Creating Project

Dcl-Proc Dsply_sfl;
    SflDsp    = *On;
    SflDspCtl = *On;
    SflEnd    = *On;

    If Rrn# < 1;
        SflDsp = *Off;
    EndIf;
    write header;
    write footer;
    Exfmt SflProjCtl;
End-Proc;
//------------------------------------------------------------------
// CreateNewProject Program For Creating Project
//------------------------------------------------------------------
dcl-proc CreateNewProject;

    Dow Exit = *off;
        Heading = 'Work With Projects';
        FooterL1 = 'F3=Exit    F5=Refresh     F12=Cancel    Enter=Confirm';
        GenrateNewId();
        Write Header;
        Write Footer;
        Exfmt CRTPROJ;
        ResetIndNewProj();
        Clear ErrMsg;
        // Clear CrtProj;

        Select;
            when Exit = *on Or Back = *on;
                Back = *off;
                leave;
            when Refresh = *on;
                Refresh = *off;
                ResetIndNewProj();
                clear CrtProj;
            when Prompt = *on And %trim(fld) = 'S1PTEAMLEA';
                PromptTeamLeadDeatils();
                Back = *off;
            other;
                AddValueToDb();
        Endsl;

    enddo;

end-proc;
//Add Value to Db for Add Project
dcl-proc AddValueToDb;

    // S1ProjId = ProjID + 1;

    ValidationAddProject();

    if ErrMsg = ' ';
        EXEC Sql
            Insert Into ProjectPf
            (ProjId,PName,PStrDate,PendDate,PTeamLead,PDetails,PStatus,PBudget,PLang)
            Values
            (:S1ProjId,:S1Pname,:S1PStrDate,:S1PendDate,
             :S1PTeamLea,:S1PDetails,:S1PStatus,:S1PBudget,:S1PLang);
        ErrMsg = 'New Project Add';
    Else;
        ErrMsg = 'Data Add failed';
    Endif;


end-proc;
//Validation for Add Project
dcl-proc  ValidationAddProject;

    Select;
        When S1PNAME = *blank;
            ErrMsg = 'Please Enter Project Name';
            IndProjName  = *on;
        When %Char(S1PSTRDATE) = '0001-01-01';
            ErrMsg = 'Please Enter Starting Date';
            IndProjSdate = *on;
        When  %Char(S1PENDDATE) = '0001-01-01';
            ErrMsg = 'Please Enter Starting Date';
            IndProjEDate = *on;
        When S1PTEAMLEA = *blank;
            ErrMsg = 'Please Select Team Lead';
            IndProjTm = *on;
        When S1PDETAILS = *blank;
            ErrMsg = 'Please Enter Some Details About Project';
            IndProjDetails = *on;
        When S1PSTATUS = *blank;
            ErrMsg = 'Please Enter Status Of Project';
            IndProjStatus = *on;
        When S1PBUDGET = *zero;
            ErrMsg = 'Please Enter Project Budget';
            IndProjBudget = *on;
        When S1PLANG = *blank;
            ErrMsg = 'Please Enter Languages';
            IndProjLang = *on;
        Other;
            ErrMsg = ' ';
            ResetIndNewProj();
    endsl;

end-proc;
// Set Ind for Add Project
dcl-proc ResetIndNewProj;
    IndProjName  = *off;
    IndProjSdate = *off;
    IndProjEDate = *off;
    IndProjTm = *off;
    IndProjDetails = *off;
    IndProjStatus = *off;
    IndProjBudget = *off;
    IndProjLang = *off;
end-proc;
// Gerating New Id for Add Project
dcl-proc GenrateNewId ;
    Exec Sql
       Select Max(ProjId) Into  :ProjIdC From Projectpf;

    If ProjIdC = *Blank;
        S1ProjId = 'PRJ001';
    Else;
        ProjIdSubfix = %Int(%subst(ProjIdC :4)) + 1;
        S1ProjId = 'PRJ' + %editc(ProjIdSubfix :'X');
    EndIf;
    S1PStatus = 'Pending';
end-proc;


//------------------------------------------------------------------
// Window_Sfl_ Program
//------------------------------------------------------------------

dcl-proc PromptTeamLeadDeatils;

    dow Back = *off;
        Clear_window_sfl();
        Load_window_sfl();
        Dsply_window_sfl();

        select;
            when Back = *on;
                Leave;
            other;
                ValidateOptValue();
        endsl;

    enddo;


end-proc;


// clear sfl

dcl-proc Clear_window_sfl;
    SflClrWindow = *on;
    Rrn#W = 0;
    write SELTLCTL;
    SflClrWindow = *off;
end-proc;
//Load Sfl
dcl-proc Load_window_sfl;
    Exec Sql
         Declare SflWindowCursor Cursor for
         Select Userid, UName From
         UserPf;
    Exec sql
     Open SflWindowCursor;

    dow SqlCode = 0;
        Exec sql
   Fetch From SflWindowCursor into
   :WUserId, :WUName;
        Rrn#W = Rrn#W + 1;

        if Rrn#W>9999;
            Leave;
        endif;

        Write SelTlSfl;
    enddo;

    exec sql
     Close SflWindowCursor;

end-proc;
// Display sfl
Dcl-Proc Dsply_window_sfl;
    SflDspWindow    = *On;
    SflDspCtlWindow = *On;
    SflEndWindow    = *On;

    If Rrn#W < 1;
        SflDspWindow = *Off;
    EndIf;

    Exfmt SELTLCTL;
End-Proc;

// validations on window sfl

dcl-proc ValidateOptValue;
            // Chain OPTTLVAL SELTLSFL;
            Readc SelTlSfl;
            Dow Not %EOF();
            select;
               when OptTlVal = '1';
                  PTeamLead = WUserId;
                  Back = *on;
                  Leave;
              other;
                ErrMsg = 'InValid Options';
            endsl;
            Readc SELTLSFL;
           enddo;
end-proc;



