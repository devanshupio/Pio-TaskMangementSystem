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

Ctl-Opt DftActGrp(*No);

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
Dcl-S ValInd Ind Inz(*off);


//------------------------------------------------------------------
// Main Program
//------------------------------------------------------------------


Dow Exit = *Off;

   Funmsg = 'F3=Exit    F5=Refresh    F10=Forget Password';
   Heading = 'Login Screen';
   IndicatorChange();
   Write Header;
   Write Footer;
   Exfmt Loginsrn;
   Select;
      when Exit = *on;
         leave;
      When IndForgetPass= *on;
         IndForgetPass = *off;
         ForgetPassProc();
         clear SETNEWPASS;
      when Refresh = *on;
         Refresh = *off;
         clear LoginSrn;
      other;
         LoginProc();
         clear SETNEWPASS;
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

   if ValInd = *on;

      ValInd = *off;
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
        //    ManagerModule()
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
         ValInd = *On;
         IndId= *On;
         return;
      when LUserPass = '';
         ErrMsg = 'Please Enter Password';
         ValInd = *On;
         IndPass = *On;
         return;
      when UserPrefix <> 'TML' and UserPrefix <> 'MNG' and UserPrefix <> 'USR';
         ErrMsg = 'Invalid User Id Not Allow';
         ValInd = *On;
         return;
      other;
         IndicatorChange();
         IndPass = *Off;
         return;
   endsl;

end-proc;


dcl-proc IndicatorChange;

   ValInd = *Off;
   IndId= *Off;
   IndConPass =*off;
   IndNewPass = *off;
   IndSecAns = *off;
   IndSecQus = *off;
   IndUserID = *off;
   IndProSecQue = *on;
   clear ErrMsg;
   clear LoginSrn;

end-proc;



dcl-proc SetPasswordProc;

   dow Exit = *off And Back = *off;
      funmsg = 'F3=Exit    F5=Refresh    F12=Back    Enter=Confirm';
      Heading = 'Set Password';
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
            clear SETNEWPASS;
         when Prompt = *on And %trim(fld) = 'FSECQUES';
            PromptSelectValue();
            back = *off;
         other;
            SaveNewPassword();
      endsl;
   enddo;

end-proc;


dcl-proc SaveNewPassword;

   ValidationFP();

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






dcl-proc ValidationFP;

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
         IndicatorChange();
       // handle other conditions
   endsl;

end-proc;


dcl-proc PromptSelectValue;
   dow back = *off;
      Exfmt LogQues;
      select;
         when back = *on;
            return;
         other;
            if WOPT = '1';
               FSecQues = 'What is your favorite Color';
            elseif WOPT = '2';
               FSecQues = 'What is your pet name';
            elseif WOPT = '3';
               FSecQues= 'What is your lucky number';
            elseif WOPT = '4';
               FSecQues = 'What is your School name';
            endif;
      endsl;
   enddo;
end-proc;




dcl-proc ForgetPassProc;

   dow exit = *off and Back = *off;
      funmsg = 'F3=Exit    F5=Refresh    F12=Back    Enter=Confirm';
      Heading = 'Forgot Password';
      Write Header;
      Write Footer;
      Exfmt SETNEWPASS;
      IndProId = *off;
      select;
         when Exit = *on;
            Leave;
         when Back = *On;
            Back = *off;
            Leave;
         when Refresh=*on;
            Refresh = *off;
            clear SETNEWPASS;
         when Prompt = *on And %trim(fld) = 'FSECQUES';
            PromptSelectValue();
            back = *off;
         other;
            SetNewPassword();
      endsl;


   enddo;
end-proc;


dcl-proc SetNewPassword;

   ValidationFP();
   chain FUserId Loginpf;
   ValidationSecQusAns();

   if ErrMsg = ' ';
      if %Found();
         UserPass = FNewPass;
         Update Loginpfr;
         ErrMsg = 'New Password in Set';
      else;
         ErrMsg = 'User Id Not Found';
      endif;

   endif;

end-proc;

dcl-proc ValidationSecQusAns;

   select;
      when %trim(FSecQues) <>  %trim(SecQues);
         ErrMsg = 'Select Correct Securtiy Question';
         return;
      when %trim(FSecAns) <> %trim(SecAns);
         ErrMsg = 'Please Enter Correct Answere';
         return;
      other;
       // handle other conditions
   endsl;

end-proc;



