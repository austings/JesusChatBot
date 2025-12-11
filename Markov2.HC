U64 ToLower(U64 ch) {
  if ('A' <= ch && ch <= 'Z') return ch - 'A' + 'a';
  return ch;
}


// Capitalize only the first letter after '.', '!', or '?'
// Works safely on non-null-terminated buffers; stops when caller stops.
U8 *GetWord(U8 **_ptr) {
  static Bool capitalize_next = TRUE;  // remember across calls
  U8 *ptr = *_ptr;
  U8 buf[STR_LEN];
  I64 out_idx = 0;
  buf[0] = 0;

  // skip until we reach a relevant character
  while (*ptr && !(Bt(char_bmp_alpha, *ptr) || StrOcc(",.", *ptr)))
    ++ptr;

  if (StrOcc(",.'", *ptr)) {
    buf[out_idx++] = *ptr++;
  } else {
    while (Bt(char_bmp_alpha, *ptr)) {
      U8 ch = *ptr++;
      if (capitalize_next && Bt(char_bmp_alpha, ch)) {
        buf[out_idx++] = ToUpper(ch);
        capitalize_next = FALSE;
      } else {
        buf[out_idx++] = ToLower(ch);
      }
    }
  }
  buf[out_idx] = 0;
  
  // Special case: capitalize standalone "i"
  if (out_idx == 1 && (buf[0] == 'i' || buf[0] == 'I'))
    buf[0] = 'I';
  // Mark next sentence start after '.', '!', or '?'
  if (StrOcc(".!?", *(ptr - 1)))
    capitalize_next = TRUE;

  *_ptr = ptr;
  return StrNew(buf);
}

CHashTable *vocab=NULL;

U8 *MarkovGenerate(CDoc *to=NULL,U8 *filename,I64 cnt=300,U8 *start_word){
 if(!FileFind(filename))
  return StrNew("");

 U8 *buf=FileRead(filename);
 if(!buf)
  return StrNew("");

 U8 *p=buf;
 U8 *dialog=StrNew("");
 I64 linecounter=0;

 CHashTable *t=HashTableNew(0x1000);
 CHashGeneric *gen;
 I64 idx,idx2;
 F64 *probs,sum,coin;

 t->next=Fs->hash_table;
 Fs->hash_table=t;

 U8 *a=GetWord(&p);
 U8 *b=GetWord(&p);

 if(!vocab){
  vocab=HashTableNew(0x1000);
  CHashTable *old=Fs->hash_table;
  vocab->next=old;
  Fs->hash_table=vocab;

  U8 *vp=buf;
  U8 *w=GetWord(&vp);
  while(*vp){
   if(!HashSingleTableFind(w,vocab,HTT_FRAME_PTR))
    FramePtrAdd(StrNew(w),NULL);
   Free(w);
   w=GetWord(&vp);
  }
  Free(w);

  Fs->hash_table=old;
 }

 while(*p){
  for(idx=1;gen=HashSingleTableFind(a,t,HTT_FRAME_PTR,idx);idx++){
   if(!StrCmp(gen->user_data0,b)){
    ++gen->user_data1;
    goto skip_pair;
   }
  }
  FramePtrAdd(a,StrNew(b));
skip_pair:
  Free(a);
  a=StrNew(b);
  b=GetWord(&p);
 }

 Free(a);
 Free(b);

 Fs->hash_table=t;

 gen=HashSingleTableFind(start_word,t,HTT_FRAME_PTR);
 if(gen){
  U8 *cur=start_word;

  while(--cnt>=0){
   for(idx=1;gen=HashSingleTableFind(cur,t,HTT_FRAME_PTR,idx);idx++);
   if(idx<=1)
    break;

   probs=CAlloc(8*idx);
   sum=0;
   for(idx2=1;gen=HashSingleTableFind(cur,t,HTT_FRAME_PTR,idx2);idx2++){
    probs[idx2-1]=gen->user_data1+1;
    sum+=gen->user_data1+1;
   }
   for(idx2=1;idx2<idx;idx2++)
    probs[idx2-1]/=sum;

   coin=Rand;
   sum=0;
   for(idx2=1;idx2<idx;idx2++){
    sum+=probs[idx2-1];
    if(sum+.0001>=coin){
     gen=HashSingleTableFind(cur,t,HTT_FRAME_PTR,idx2);
     cur=gen->user_data0;

     U8 *dialogWord;
     if(StrLen(cur)==1 && StrCmp(cur,"I")!=0 && StrCmp(cur,"a")!=0 && StrCmp(cur,"i")!=0)
      dialogWord=MStrPrint("%s",cur);
     else
      dialogWord=MStrPrint(" %s",cur);

     linecounter+=StrLen(dialogWord);
     dialog=MStrPrint("%s%s",dialog,dialogWord);
     Free(dialogWord);

     break;
    }
   }

   Free(probs);
  }
 }

 Fs->hash_table=t->next;
 HashTableDel(t);
 Free(buf);

 return dialog;
}

