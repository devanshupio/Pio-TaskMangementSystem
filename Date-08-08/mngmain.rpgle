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
   Ctl-Opt option(*nodebugio:*srcstmt) BndDir('TASKMS/ADMINB1');
   Ctl-Opt Nomain;
//------------------------------------------------------------------
//  File Declartion
//------------------------------------------------------------------


Dcl-f Loginpf    Usage(*Input:*Output:*Update) Keyed ;
Dcl-f MANAGERDSP Workstn  Indds(#IndicatorDs) Usropn;

//------------------------------------------------------------------
//  Ds Declartion
//------------------------------------------------------------------

Dcl-ds #IndicatorDs;
    Exit           Ind Pos(03);
    Back           Ind Pos(12);
    Refresh        Ind Pos(05);
    IndMngOpr      Ind Pos(31);
End-ds;


//-------------------------------------------------------------------
// variable Declartion
//-------------------------------------------------------------------




//-------------------------------------------------------------------
// Module Declartion
//-------------------------------------------------------------------

dcl-pr ProjectDashboard ;
end-pr;




//------------------------------------------------------------------
// Main Program
//------------------------------------------------------------------

Dcl-Proc ManagerDashboard Export;
   Open MANAGERDSP;
   Dow Exit = *off or Back = *off;
     FooterL1 = 'F3=Exit    F12=Cancel    Enter=Confirm';
     Heading = 'Manager DashBoard';
     Write Header;
     Write Footer;
     Exfmt MngMainSrn;
     clear ERRMSG;
     reset IndMngOpr;

     select;
       when Exit = *on Or Back = *on;
            Back = *off;
            Leave;
       other;
          MngSelectOption();
     endsl;
   enddo;
   close MANAGERDSP;
End-Proc;



  dcl-proc MngSelectOption;
    select;
      when MngOpr = '1';
        ProjectDashboard();
        Reset MngMainSrn;
      when MngOpr = '2';
        // WorkwithMessage();
      when MngOpr = '3';
        // Assigntask();
      when MngOpr = '4';
        // ReviewTask();
      other;
        ErrMsg = 'Enter Valid Option';
        IndMngOpr = *on;
    endsl;

  end-proc;


