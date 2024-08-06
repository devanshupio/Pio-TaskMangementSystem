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


Dcl-f Loginpf    Usage(*Input:*Output:*Update) Keyed;
Dcl-f MANAGERDSP Workstn  Indds(#IndicatorDs);

//------------------------------------------------------------------
//  Ds Declartion
//------------------------------------------------------------------

Dcl-ds #IndicatorDs;
    Exit           Ind Pos(03);
    Back           Ind Pos(12);
    Refresh        Ind Pos(05);
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
   Dow Exit = *off;
     Write Header;
     Write Footer;
     Exfmt MngMainSrn;
     clear ERRMSG;

     select;
       when Exit = *on And Back = *on;
            Back = *off;
            Leave;
       other;
          MngSelectOption();
     endsl;
   enddo;
End-Proc;



  dcl-proc MngSelectOption;
    select;
      when MngOpr = '1';
        ProjectDashboard();
      when MngOpr = '2';
        // WorkwithMessage();
      when MngOpr = '3';
        // Assigntask();
      when MngOpr = '4';
        // ReviewTask();
      other;
        ErrMsg = 'Enter Valid Option';
    endsl;

  end-proc;

