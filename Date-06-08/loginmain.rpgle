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
Ctl-Opt option(*nodebugio:*srcstmt) BndDir('TASKMS/LOGINB1');


//------------------------------------------------------------------
//  File Declartion
//------------------------------------------------------------------

Dcl-f Logindsply Workstn  Indds(#IndicatorDs);
Dcl-f Loginpf  Usage(*Input:*Output:*Update) Keyed;

//------------------------------------------------------------------
//  Ds Declartion
//------------------------------------------------------------------

Dcl-Ds #IndicatorDs;
   Exit           Ind Pos(03);
   Prompt         Ind Pos(04);
   Back           Ind Pos(12);
   Refresh        Ind Pos(05);
   IndId          Ind Pos(21);
   IndPass        Ind Pos(22);
   IndForgetPass  Ind Pos(10);
   IndUserID      Ind Pos(23);
   IndSecQus      Ind Pos(24);
   IndSecAns      Ind Pos(25);
   IndNewPass     Ind Pos(26);
   IndConPass     Ind Pos(27);
   IndProId       Ind Pos(80);
   IndProSecQue   Ind Pos(81);
End-Ds;


//-------------------------------------------------------------------
// variable Declartion
//-------------------------------------------------------------------

Dcl-S UserPrefix      Char(3);



//-------------------------------------------------------------------
// Module Declartion
//-------------------------------------------------------------------

dcl-pr ManagerDashboard;
end-pr;



//------------------------------------------------------------------
// Main Program
//------------------------------------------------------------------


Dow Exit = *Off;

   Funmsg = 'F3=Exit    F5=Refresh    F10=Forget Password';
   Heading = 'Login Screen';
   // IndicatorReset();
   Write Header;
   Write Footer;
   Exfmt Loginsrn;
   clear ErrMsg;
   Reset IndPass;
   Reset IndId;
   Select;
      when Exit = *on;
         leave;
      When IndForgetPass= *on;
         IndForgetPass = *off;
         ForgetPassProc();
         // clear SETNEWPASS;
      when Refresh = *on;
         Refresh = *off;
         Reset IndPass;
         Reset IndId;
         Clear ErrMsg;
      other;
         LoginProc();
         // clear SETNEWPASS;
   Endsl;

enddo;

*Inlr = *on;




//------------------------------------------------------------------
// Procedure Name: Login
// Description....: Procedure to handle login module
//------------------------------------------------------------------

dcl-proc LoginProc;

   UserPrefix = %subst(LUserId : 1:3);
   Validation();

   if ErrMsg <> ' ';
      return;
   endif;

   chain LUserId Loginpf;

   if %found();

      if LUserPass <> UserPass;
         ErrMsg = 'Password is incorrect';
         return;
      elseif UserPass = 'Welcome';
         FUserId = LUserId;
         SetPasswordProc();
      else;
         select;
            when UserPrefix = 'USR';
        //    UserModule()
            when UserPrefix = 'MNG';
              ManagerDashboard();
            when UserPrefix = 'TML';
        //    TeamLeadModule()
         endsl;
      endif;

   else;
      errmsg = 'User Id Not Found';
   endif;

End-Proc;


dcl-proc Validation ;

   select;
      when LUserId = '';
         ErrMsg = 'Please Enter Id';
         IndId= *On;
         // IndPass = *Off;
         return;
      when UserPrefix <> 'TML' and UserPrefix <> 'MNG' and UserPrefix <> 'USR';
         ErrMsg = 'Invalid User Id Not Allow';
         IndId=*on;
         return;
      when LUserPass = '';
         ErrMsg = 'Please Enter Password';
         // IndId = *off;
         IndPass = *On;
         return;
      other;
         IndicatorReset();
         clear ErrMsg;
         return;
   endsl;

end-proc;


dcl-proc IndicatorReset;

   IndId= *Off;
   IndPass = *off;
   IndConPass =*off;
   IndNewPass = *off;
   IndSecAns = *off;
   IndSecQus = *off;
   IndUserID = *off;
   IndProSecQue = *on;
   // clear ErrMsg;
   // clear LoginSrn;

end-proc;


dcl-proc SetPasswordProc;

   dow Exit = *off And Back = *off;
      funmsg = 'F3=Exit    F5=Refresh    F12=Back    Enter=Confirm';
      Heading = 'Set Password';
      clear Errmsg;
      Write Header;
      Write Footer;
      Exfmt SETNEWPASS;
      IndProId = *on;
      select;
         when Exit = *on;
            Leave;
         when Back = *On;
            Back = *off;
            Leave;
         when Refresh=*on;
            Refresh = *off;
            clear FNewPass;
            Clear FSecQues;
            Clear FSecAns;
            Clear FConPass;
         when Prompt = *on And %trim(fld) = 'FSECQUES';
            PromptSelectValue();
            back = *off;
         other;
            SaveNewPassword();
            if %trim(ErrMsg) = 'New Password in Set';
               clear SETNEWPASS;
               return;
            endif;
      endsl;
   enddo;

end-proc;


dcl-proc SaveNewPassword;

   ValidationSetPassword();

   if ErrMsg = ' ';

      chain FUserId Loginpf;

      if %Found();
         UserPass = FNewPass;
         SecQues = FSecQues;
         SecAns = FSecAns;
         Update Loginpfr;
         ErrMsg = 'New Password in Set';
      else;
         ErrMsg = 'User Id Not Found';
      endif;

   endif;

end-proc;


dcl-proc ValidationSetPassword;

   select;
      when FUserId = ' ';
         ErrMsg = 'Please Enter Your User ID';
         IndUserID = *on;
         return;
      when FSECQUES = ' ';
         ErrMsg = 'Please Select Securtiy Question';
         IndSecQus = *on;
         return;
      when FSECANS = ' ';
         ErrMsg = 'Please Enter Securtiy Answere';
         IndSecAns = *on;
         return;
      when FNewPass = '';
         ErrMsg = 'Please Enter New Password';
         IndNewPass = *on;
         return;
      when FConPass = ' ';
         ErrMsg = 'Please Enter Confirm Password';
         IndConPass =*on;
         return;
      when FNewPass <> FConPass;
         ErrMsg = 'New And Confirm password not Match';
      other;
         ErrMsg = ' ';
         IndicatorReset();
       // handle other conditions
   endsl;

end-proc;


dcl-proc PromptSelectValue;
   dow back = *off;
      clear Wopt;
      Exfmt LogQues;

      select;
         when back = *on;
            return;
         other;
            if WOPT = '1';
               FSecQues = 'What is your favorite Color';
               return;
            elseif WOPT = '2';
               FSecQues = 'What is your pet name';
               return;
            elseif WOPT = '3';
               FSecQues= 'What is your lucky number';
               return;
            elseif WOPT = '4';
               FSecQues = 'What is your School name';
               return;
            else;
               ErrMsg = 'Invalid Option';
               return;
            endif;
      endsl;
   enddo;
end-proc;


dcl-proc ForgetPassProc;

   funmsg = 'F3=Exit    F5=Refresh    F12=Back    Enter=Confirm';
   Heading = 'Forgot Password';
   dow exit = *off and Back = *off;
      Write Header;
      Write Footer;
      Exfmt SETNEWPASS;
      IndResetForForgotPassword();
      select;
         when Exit = *on;
            Leave;
         when Back = *On;
            Back = *off;
            Clear SetNewPass;
            Leave;
         when Refresh=*on;
            Refresh = *off;
            clear SETNEWPASS;
            IndResetForForgotPassword();
         when Prompt = *on And %trim(fld) = 'FSECQUES';
            PromptSelectValue();
            back = *off;
         other;
            SetNewPassword();
            if %trim(ErrMsg) = 'New Password in Set';
               return;
            endif;
      endsl;


   enddo;
end-proc;

dcl-proc IndResetForForgotPassword;
   clear ErrMsg;
   Reset IndConPass;
   Reset IndNewPass ;
   Reset IndSecAns ;
   Reset IndSecQus ;
   Reset IndUserID ;
   Reset IndProId ;
end-proc;


dcl-proc SetNewPassword;

   ValidationSetPassword();


   if ErrMsg = ' ';


      chain FUserId Loginpf;
      select;
         when %trim(FSecQues) <>  %trim(SecQues);
            ErrMsg = 'Select Correct Securtiy Question';
            return;
         when %trim(FSecAns) <> %trim(SecAns);
            ErrMsg = 'Please Enter Correct Answere';
            return;
         other;
      endsl;

      if %Found();
         UserPass = FNewPass;
         Update Loginpfr;
         ErrMsg = 'New Password in Set';
      else;
         ErrMsg = 'User Id Not Found';
      endif;

   endif;

end-proc;





