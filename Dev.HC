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

U0 PrintLine(CDC*dc=gr.dc,U8 *line,I64 startx,I64 starty,F64 scale=1){
 I64 factor = ToI64(scale*7);
 I64 i;
 for(i=0;i<StrLen(line);i++){
  GrChar(dc,line[i],startx+(i*factor),
                    starty,scale);
 }

}

class DevConsole{

 CDC *cmd;
 U8 *line0;
 U8 *line1;
 U8 *line2;
 U8 *line3;
 U8 *line4;
 U8 *line5;
 U8 *line6;
 U8 *line7;
 U8 *line8;
 U8 *line9;
 U8 *line10;

} devc;



U0 InitDev()
{
 devc.line0 = StrNew("ÿ"); 
 devc.line1 = StrNew("What do you want me to do for you?"); 
 devc.line2 = StrNew("knock and the door will be opened to you."); 
 devc.line3 = StrNew("seek and you will find;"); 
 devc.line4 = StrNew("Ask and it will be given to you;"); 
 devc.line5 = StrNew("No one comes to the Father except through me."); 
 devc.line6 = StrNew("I am the way and the truth and the life."); 
 devc.line7 = StrNew("I am Jesus of Nazareth."); 
 devc.line8 = StrNew("Peace be with you."); 
 devc.line9 = StrNew("Jesus Said:"); 
 devc.line10 = StrNew(""); 

}

CDC *RenderDev(){ 
 devc.cmd = DCNew(300,640);
 DCFill(devc.cmd, TRANSPARENT);
 devc.cmd->color=LTGREEN;
 PrintLine(devc.cmd,devc.line0,10,324,2); 
 devc.cmd->color=BLACK;
 PrintLine(devc.cmd,devc.line1,10,292,2); 
 PrintLine(devc.cmd,devc.line2,10,260,2); 
 PrintLine(devc.cmd,devc.line3,10,228,2); 
 PrintLine(devc.cmd,devc.line4,10,196,2); 
 PrintLine(devc.cmd,devc.line5,10,164,2);
 PrintLine(devc.cmd,devc.line6,10,132,2);  
 PrintLine(devc.cmd,devc.line7,10,100,2);
 PrintLine(devc.cmd,devc.line8,10,68,2);  
 PrintLine(devc.cmd,devc.line9,10,36,2);
 PrintLine(devc.cmd,devc.line10,10,4,2);  
 return devc.cmd; 
}

U0 DevKeyEnter(){
 Free(devc.line10);
 devc.line10 = devc.line9;
 devc.line9 = devc.line8;
 devc.line8 = devc.line7;
 devc.line7 = devc.line6;
 devc.line6 = devc.line5;
 devc.line5 = devc.line4;
 devc.line4 = devc.line3;
 devc.line3 = devc.line2;
 devc.line2 = devc.line1;

 I64 newLen = StrLen(devc.line0);//minus new char (keep null char)
 U8 *myNewStr= MAlloc(newLen);
 MemCpy(myNewStr,devc.line0,newLen-1);
 myNewStr[newLen-1] = '\0'; 
 devc.line0 = MStrPrint("%s",myNewStr);

//check input
 Free(myNewStr);

 devc.line1 = devc.line0;
 devc.line0 = StrNew("ÿ");//MStrPrint("",);
}

U0 AddDevChar(I64 buffer)
{
 I64 newLen = StrLen(devc.line0)+2;//plus new char and null char
 I64 insertLoc = StrLen(devc.line0);
 U8 *myNewStr= MAlloc(newLen);
 U8 convChar = ((U8)buffer);
 
 MemCpy(myNewStr,devc.line0,insertLoc);
 myNewStr[insertLoc-1] = convChar;
 myNewStr[insertLoc] = 'ÿ';
 myNewStr[insertLoc+1] = '\0';
 
 Free(devc.line0);
 devc.line0 = MStrPrint("%s",myNewStr);
 Free(myNewStr);

}

U0 DelDevChar()
{
 devc.line0[StrLen(devc.line0)-2]=0;
}

U0 PrintDevMessage(U8 *msg, Bool toFree=TRUE)
{
 Free(devc.line0);
 devc.line0 = MStrPrint("%s ",msg);
 if(toFree)
  Free(msg);
 DevKeyEnter;
}

InitDev;