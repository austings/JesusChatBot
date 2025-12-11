#include "Wad.HC";
#include "Dev.HC";
#include "Markov2.HC";
U8 *MARKOV_FILE = MStrPrint("%s%s",DirCur,"/jesusss.DD");

Bool thinking = FALSE;
U8 *lastReply;
U16 replyLength = 0;
U16 talkIndex = 0;
U16 openMouthPhase = 10;
U16 openMouthIndex = 0;
U16 closeMouthPhase = 10;
U16 closeMouthIndex = 0;
Bool talking;
I64 talkStep;
I64 totalTalkSteps;

U8 *Reply(U8 *a){
 if(!vocab)
  return StrNew("The");

 I64 len=StrLen(a);
 I64 i=len-1;

 while(i>=0 && (a[i]==' ' || a[i]=='\t' || a[i]=='\n'))
  i--;

 while(i>=0){
  I64 end=i;
  while(i>=0 && a[i]!=' ' && a[i]!='\t' && a[i]!='\n')
   i--;
  I64 start=i+1;

  I64 wlen=end-start+1;
  if(wlen>0){
   U8 *word=MAlloc(wlen+1);
   MemCpy(word,a+start,wlen);
   word[wlen]=0;

   I64 j=0;
   I64 k=0;
   while(word[j]){
    U8 c=word[j];
    if(c!='.' && c!=',' && c!='!' && c!='?' &&
       c!=';' && c!=':' && c!='"' && c!='\'' &&
       c!='(' && c!=')' && c!='[' && c!=']' &&
       c!='{' && c!='}'){
     word[k++]=c;
    }
    j++;
   }
   word[k]=0;

   if(k>0){
    U8 first=word[0];
    if(first>='a' && first<='z')
     word[0]=first-'a'+'A';

    CHashGeneric *gen=HashSingleTableFind(word,vocab,HTT_FRAME_PTR);
    if(gen)
     return word;
   }

   Free(word);
  }

  while(i>=0 && (a[i]==' ' || a[i]=='\t' || a[i]=='\n'))
   i--;
 }

 return StrNew("The");
}


U0 StartTalking(U8 *reply){
 replyLength=ToI64(StrLen(reply)/10)+1; 
 talkStep=0;
 openMouthIndex=0;
 closeMouthIndex=0;
 talking=TRUE;

 totalTalkSteps=replyLength*2;
 if(totalTalkSteps<4)
  totalTalkSteps=4;
}

U0 *GenerateJesusSpeech(){
 I64 userLen = StrLen(devc.line[0]);
 I64 r;

 if(userLen <= 5){
  // extremely short user message 
  r = 1 + (RandU16() % 3);    // 1-3 words
 }
 else{
  // normal or long user message
  I64 base = 8;               // minimum word count
  I64 variance = userLen / 3; // grows slowly with user length
  if(variance < 6)
   variance = 6;

  r = base + (RandU16() % variance);
 }

 U8 *word = Reply(devc.line[0]);
 U8 *speech2 = MarkovGenerate(DocPut,MARKOV_FILE,r,word); 
 lastReply = MStrPrint("%s%s.",word,speech2); 
 StartTalking(lastReply);
 Free(speech2);
}
//
// Task Functions
U0 DrawIt(CTask *task, CDC *dc){
 if(thinking){
  GrBlot3(dc,240,80,0,J3);
 }else if(talking){
  if(talkStep%2==0){
   GrBlot3(dc,240,80,0,J1);
   closeMouthIndex++;
   if(closeMouthIndex>=closeMouthPhase){
    closeMouthIndex=0;
    talkStep++;
   }
  }else{
   GrBlot3(dc,240,80,0,J2);
   openMouthIndex++;
   if(openMouthIndex>=openMouthPhase){
    openMouthIndex=0;
    talkStep++;
   }
  }

  if(talkStep>=totalTalkSteps){
   talking=FALSE;
   openMouthIndex=0;
   closeMouthIndex=0;
  }
 }else{
  GrBlot3(dc,240,80,0,J1);
 }

 GrBlot3(dc,0,0,0,RenderDev);
}



U0 Main(){
 //Set Device context, iterables, peripheral arguments
 CDC *dc=DCAlias; I64 arg1,arg2,msg_code,i,j;
 //Default Window set$UL,0$tings
 SettingsPush;WinMax;WinBorder;
 DocCursor;DocClear;MenuPush("");
 //Set Current Task Threads  
 Fs->draw_it=&DrawIt;
 //Fs->song_task=Spawn(&SongTask,mc,"Song",,Fs);
 while(TRUE){
  U8 input = GetMsg(&arg1,&arg2,
     1<<MSG_KEY_DOWN|1<<MSG_MS_L_DOWN
     |1<<MSG_MS_L_UP|1<<MSG_MS_MOVE|1<<MSG_KEY_UP);
  switch (input) {
   case MSG_KEY_UP:
    if(arg1 != 0) {
    // HandleCharKeyUp(arg1);
    }else{
    // HandleScanKeyUp(arg2.u8[0]);
    }
   break;
   case MSG_KEY_DOWN:
    if(arg1!=0){ 
     if((arg2.u8[0])==SC_ENTER){
      thinking = TRUE;
      DCFill;
      Refresh;
      Sleep(1);
      DCFill;
      DevKeyEnter;
      GenerateJesusSpeech;
      PrintDevMessage(lastReply,FALSE);
      thinking = FALSE;
     }else{
     AddDevChar(arg1);}
    }else{
     
    }
   break;
  }
  Refresh;
 }
 fs_end:
 DCDel(dc);
}

Main;