#include "Wad.HC";
#include "Dev.HC";
#include "Markov2.HC";
U8 *MARKOV_FILE = MStrPrint("%s%s",DirCur,"/jesusss.DD");

Bool thinking = FALSE;


U8 *Reply(U8 *a)
{
 U8 * gen = HashSingleTableFind(a, tokens, HTT_FRAME_PTR);
 
}

U8 *GenerateJesusSpeech(){
 //I64 r = 5 + (RandU16() % 21);
 I64 r = 1 + (RandU16() % (StrLen(devc.line[0]))/2);

 U8 *speech2 = MarkovGenerate(DocPut,MARKOV_FILE,r,"The"); 
 U8 *speech = MStrPrint("%s%s.","The",speech2); 
 Free(speech2);
 return speech;
}
//
// Task Functions
U0 DrawIt(CTask *task, CDC *dc){
 if(!thinking)
  GrBlot3(dc,240,80,0,J1);
 else
  GrBlot3(dc,240,80,0,J3);

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
      PrintDevMessage(GenerateJesusSpeech,FALSE);
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