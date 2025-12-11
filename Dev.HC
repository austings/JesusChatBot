U0 GrChar(CDC *dc=gr.dc,U8 ch,I64 x,I64 y,I64 scale){
  I64 i,j,k=0;
  for(i=0;i<FONT_HEIGHT;i++){
    for(j=0;j<FONT_WIDTH;j++){
      if(Bt(&text.font[ch],k++)){
        GrRect(dc,x+j*scale,y+i*scale,scale,scale);
      }
    }
  }
}

#define DEV_MAX_COLS 40
#define TSCALE 12
I64 PrintLine(CDC *dc=gr.dc,U8 *line,I64 startx,I64 starty,F64 scale=1){
 I64 wFactor=ToI64(scale*7);
 I64 hFactor=ToI64(scale*TSCALE);
 I64 row=0;
 I64 col=0;
 I64 i=0;
 I64 len=StrLen(line);

 while(i<len){
  U8 ch=line[i];

  if(col==0){
   while(i<len && line[i]==' ')
    i++;
   if(i>=len)
    break;
  }

  I64 wordStart=i;
  while(i<len && line[i]!=' ' && line[i]!='\n')
   i++;
  I64 wordEnd=i;
  I64 wordLen=wordEnd-wordStart;

  Bool hasSpace=FALSE;
  if(i<len && line[i]==' ')
   hasSpace=TRUE;

  if(wordLen>DEV_MAX_COLS){
   I64 wIdx=0;
   while(wIdx<wordLen){
    if(col>=DEV_MAX_COLS){
     col=0;
     row++;
    }
    GrChar(dc,
     line[wordStart+wIdx],
     startx+col*wFactor,
     starty+row*hFactor,
     scale);
    col++;
    wIdx++;
   }
  }else{
   if(col>0 && col+wordLen>DEV_MAX_COLS){
    col=0;
    row++;
   }

   I64 k;
   for(k=0;k<wordLen;k++){
    GrChar(dc,
     line[wordStart+k],
     startx+col*wFactor,
     starty+row*hFactor,
     scale);
    col++;
   }
  }

  if(hasSpace){
   i++;
   if(col>=DEV_MAX_COLS){
    col=0;
    row++;
   }else{
    GrChar(dc,
     ' ',
     startx+col*wFactor,
     starty+row*hFactor,
     scale);
    col++;
   }
  }
 }
 return row+1;
}
class DevConsole{
 CDC *cmd;
 U8 *input;   //current input
 U8 *label[10];   // "User Said:" / "Jesus Said:"
 U8 *line[10];    // actual message text
 Bool isUser[10]; // TRUE if message is from user
} devc;




U0 InitDev(){
 I64 i;

 devc.input=StrNew("ÿ");

 for(i=0;i<10;i++){
  devc.label[i]=StrNew("");
  devc.line[i]=StrNew("");
  devc.isUser[i]=FALSE;
 }

 Free(devc.label[0]);
 devc.label[0]=StrNew("Jesus Said:");
 Free(devc.line[0]);
 devc.line[0]=StrNew("What do you want me to do for you?");
 devc.isUser[0]=FALSE;

 Free(devc.label[1]);
 devc.label[1]=StrNew("Jesus Said:");
 Free(devc.line[1]);
 devc.line[1]=StrNew("knock and the door will be opened to you.");
 devc.isUser[1]=FALSE;

 Free(devc.label[2]);
 devc.label[2]=StrNew("Jesus Said:");
 Free(devc.line[2]);
 devc.line[2]=StrNew("seek and you will find;");
 devc.isUser[2]=FALSE;

 Free(devc.label[3]);
 devc.label[3]=StrNew("Jesus Said:");
 Free(devc.line[3]);
 devc.line[3]=StrNew("Ask and it will be given to you;");
 devc.isUser[3]=FALSE;

 Free(devc.label[4]);
 devc.label[4]=StrNew("Jesus Said:");
 Free(devc.line[4]);
 devc.line[4]=StrNew("No one comes to the Father except through me.");
 devc.isUser[4]=FALSE;

 Free(devc.label[5]);
 devc.label[5]=StrNew("Jesus Said:");
 Free(devc.line[5]);
 devc.line[5]=StrNew("I am the way and the truth and the life.");
 devc.isUser[5]=FALSE;

 Free(devc.label[6]);
 devc.label[6]=StrNew("Jesus Said:");
 Free(devc.line[6]);
 devc.line[6]=StrNew("I am Jesus of Nazareth.");
 devc.isUser[6]=FALSE;

 Free(devc.label[7]);
 devc.label[7]=StrNew("Jesus Said:");
 Free(devc.line[7]);
 devc.line[7]=StrNew("Peace be with you.");
 devc.isUser[7]=FALSE;

 Free(devc.label[8]);
 devc.label[8]=StrNew("");
 Free(devc.line[8]);
 devc.line[8]=StrNew("");
 devc.isUser[8]=FALSE;

 Free(devc.label[9]);
 devc.label[9]=StrNew("");
 Free(devc.line[9]);
 devc.line[9]=StrNew("");
 devc.isUser[9]=FALSE;
}


CDC *RenderDevOld(){
 F64 scale=1;
 I64 hFactor=ToI64(scale*TSCALE);
 I64 y=4;
 I64 rows;
 I64 i;

 devc.cmd=DCNew(300,640);
 DCFill(devc.cmd,TRANSPARENT);

 for(i=9;i>=0;i--){
  if(devc.line[i]==NULL)
   goto skip;
  if(StrLen(devc.line[i])==0)
   goto skip;

  devc.cmd->color=LTGRAY;
  rows=PrintLine(devc.cmd,devc.label[i],10,y,scale);
  y+=rows*hFactor;

  if(devc.isUser[i])
   devc.cmd->color=LTGREEN;
  else
   devc.cmd->color=BLACK;

  rows=PrintLine(devc.cmd,devc.line[i],10,y,scale);
  y+=rows*hFactor;
  skip:
 }

 devc.cmd->color=LTGREEN;
 PrintLine(devc.cmd,devc.input,10,y,scale);

 return devc.cmd;
}
CDC *RenderDev(){
 F64 scale=1;
 I64 hFactor=ToI64(scale*TSCALE);
 I64 y=4;
 I64 rows;
 I64 i;
 Bool havePrev=FALSE;
 Bool prevIsUser=FALSE;
 devc.cmd=DCNew(300,640);
 DCFill(devc.cmd,TRANSPARENT);
 for(i=9;i>=0;i--){
  if(devc.line[i]==NULL)
   goto skip;
  if(StrLen(devc.line[i])==0)
   goto skip;

  Bool curIsUser=devc.isUser[i];

  if(!havePrev || curIsUser!=prevIsUser){
   devc.cmd->color=DKGRAY;
   rows=PrintLine(devc.cmd,devc.label[i],10,y,scale);
   y+=rows*hFactor;
  }

  if(curIsUser)
   devc.cmd->color=LTGREEN;
  else
   devc.cmd->color=BLACK;

  rows=PrintLine(devc.cmd,devc.line[i],10,y,scale);
  y+=rows*hFactor;

  havePrev=TRUE;
  prevIsUser=curIsUser;
  skip:
 }
 devc.cmd->color=LTGREEN;
 PrintLine(devc.cmd,devc.input,10,y,scale);

 return devc.cmd;
}

U0 PrintDevMessage(U8 *msg,Bool fromUser,Bool toFree=TRUE){
 I64 i;

 Free(devc.label[9]);
 Free(devc.line[9]);

 for(i=9;i>0;i--){
  devc.label[i]=devc.label[i-1];
  devc.line[i]=devc.line[i-1];
  devc.isUser[i]=devc.isUser[i-1];
 }

 if(fromUser)
  devc.label[0]=StrNew("User Said:");
 else
  devc.label[0]=StrNew("Jesus Said:");

 devc.line[0]=MStrPrint("%s",msg);
 devc.isUser[0]=fromUser;

 if(toFree)
  Free(msg);
}

U0 DevKeyEnter(){
 I64 len=StrLen(devc.input);

 if(len>1){
  I64 msgLen=len-1;
  U8 *msg=MAlloc(msgLen+1);
  MemCpy(msg,devc.input,msgLen);
  msg[msgLen]=0;

  PrintDevMessage(msg,TRUE,FALSE);
 }

 Free(devc.input);
 devc.input=StrNew("ÿ");
}


U0 AddDevChar(I64 buffer){
 I64 newLen=StrLen(devc.input)+2;
 I64 insertLoc=StrLen(devc.input);
 U8 *myNewStr=MAlloc(newLen);
 U8 convChar=(U8)buffer;

 MemCpy(myNewStr,devc.input,insertLoc);
 myNewStr[insertLoc-1]=convChar;
 myNewStr[insertLoc]='ÿ';
 myNewStr[insertLoc+1]='\0';

 Free(devc.input);
 devc.input=MStrPrint("%s",myNewStr);
 Free(myNewStr);
}

U0 DelDevChar(){
 I64 len=StrLen(devc.input);
 if(len>1)
  devc.input[len-2]=0;
}


InitDev;