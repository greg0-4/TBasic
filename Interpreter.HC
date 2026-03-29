
Bool g_Running = TRUE;
Bool g_CursorHidden = TRUE;
Bool g_Skip = FALSE;
Bool g_MetIf = FALSE;
I64 g_IfLevel = 0;

U0 RunScript(U8 *file_ptr);



U8 *g_NextPos = NULL;

class TBasicVar : CQue {
  U8 name[32];
  I64 value;
};

class TBasicQue : CQue {
  U8 name[32];
  TBasicVar var_head
};

TBasicVar var_head;

TBasicQue que_head;

TBasicQue *g_ActiveQue = NULL;

QueInit(&var_head);
QueInit(&que_head);

TBasicVar *FindVar(U8 *name)
{
  TBasicVar *temp;
  

  if(g_ActiveQue)
  {
    temp = g_ActiveQue->var_head.next;
    while(temp != &g_ActiveQue->var_head)
    {
      if(!StrICmp(temp->name, name))
      {
	return temp;
      }
      temp = temp->next;
    }
  }

  temp = var_head.next;
  while(temp != &var_head)
  {
    if(!StrICmp(temp->name, name))
    {
      return temp;
    }
    temp = temp->next;
  }
  return NULL;
}

I64 ResolveValue(U8 *s)
{
  if (!s || !*s) return 0;
  TBasicVar *v = FindVar(s);
  if(v) return v->value;

  if(*s >= '0' && *s <= '9' || *s == '-')
  {
    return Str2I64(s);
  }

  return 0;
}

TBasicQue *FindQue(U8 *name)
{
  TBasicQue *temp = que_head.next;
  while(temp != &que_head)
  {
    if(!StrICmp(temp->name, name))
    {
      return temp;
    }
    temp = temp->next;
  }
  return NULL;
}

U0 MakeQue(U8 *name)
{
  TBasicQue *myQue = FindQue(name);
  if(myQue == NULL)
  {
    myQue = CAlloc(sizeof(TBasicQue));
    StrCpy(myQue->name, name);
    QueInit(&myQue->var_head);
    QueIns(myQue, que_head.last);
  }
}

U0 DelQue(U8 *name)
{
  TBasicQue *myQue = FindQue(name);
  if(myQue)
  {
    QueRem(myQue);
    Free(myQue);
  }
}

U0 SetVar(U8 *name, I64 value)
{
  TBasicVar *myVar = FindVar(name);
  if(myVar == NULL)
  {
    myVar = CAlloc(sizeof(TBasicVar));
    StrCpy(myVar->name, name);
    if(g_ActiveQue)
    {
      QueIns(myVar, g_ActiveQue->var_head.last);
    }else{
      QueIns(myVar, var_head.last);
    }
  }
  myVar->value = value;
}

U0 DelVar(U8 *name)
{
  TBasicVar *myVar = FindVar(name);
  if(myVar)
  {
    QueRem(myVar);
    Free(myVar);
  }
}

Bool CheckCondition(U8 *var1, U8 *operator, U8 *var2)
{
  I64 val1 = ResolveValue(var1);
  I64 val2 = ResolveValue(var2);
  if(!StrCmp(operator, "==")) return val1==val2;
  if(!StrCmp(operator, "!=")) return val1!=val2;
  if(!StrCmp(operator, ">")) return val1>val2;
  if(!StrCmp(operator, "<")) return val1<val2;
  if(!StrCmp(operator, "<=")) return val1<=val2;
  if(!StrCmp(operator, ">=")) return val1>=val2;
  return FALSE;
}

U64 RandomRange(U64 min, U64 max)
{
  if(max <= min) return min;
  U64 result = min + RandU64() % (max - min + 1);
  return result;
}



SetVar("g_TBKey", 0);
I64 k_arg1, k_arg2;
I64 msg_code;

U0 Execute(U8 *input, U8 *file_buffer)
{
    U8 *cmd;
    U8 *arg;
    input = StrUtil(input, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
    cmd = StrFirstOcc(input, " ");
    if(cmd)
    {
      *cmd = 0;
      arg = cmd + 1;
    } else {
     arg = "";
    }

    while(msg_code = ScanMsg(&k_arg1, k_arg2, 1 << MSG_KEY_DOWN | 1 << MSG_KEY_UP))
    {
      if(msg_code == MSG_KEY_DOWN)
      {
        SetVar("g_TBKey", k_arg1);
      }else if(msg_code == MSG_KEY_UP){
        SetVar("g_TBKey", 0);
      }
    }

    if(g_Skip)
    {
      if(!StrICmp(input, "if"))
      {
	g_IfLevel++;
      }
      if(!StrICmp(input, "endif"))
      {
	if (g_IfLevel > 0)
        {
	  g_IfLevel--;
	}
	else
	{
	  g_Skip = FALSE;
	}
      }
      if(!StrICmp(input, "else") && g_IfLevel == 0)
      {
	g_Skip = FALSE;
      }
      return;
    }

    if(!StrICmp(input, "print")) {
      TBasicVar *v = FindVar(arg);
      if(v)
      {
        "%d\n", v->value;
      }else{
        "%s\n",arg;
      }
    }
    else if(!StrICmp(input, "get"))
    {
      if(*arg)
      {
        U8 *var_name = StrUtil(arg, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
	">> ", var_name;
	U8 *st = GetStr;
        I64 result = Str2I64(st);
	SetVar(var_name, result);
	Free(st);
      }
    }
    else if(!StrICmp(input, "delete"))
    {
      if(*arg)
      {
        U8 *var_name2 = StrUtil(arg, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
        DelVar(var_name2);
      }
    }
    else if(!StrICmp(input, "list"))
    {
      TBasicVar *temp = var_head.next;
      while(temp != &var_head)
      {
	"%s [%d]\n",temp->name, temp->value;
        temp = temp->next;
      } 
    }
    else if(!StrICmp(input, "if"))
    {
      U8 *if_operator_ptr = StrFirstOcc(arg, " ");
      if(if_operator_ptr)
      {
        *if_operator_ptr = 0;
        U8 *if_operator = if_operator_ptr + 1;
        U8 *if_var2_ptr = StrFirstOcc(if_operator, " ");
        if(if_var2_ptr)
        {
          *if_var2_ptr = 0;
          U8 *if_var2 = if_var2_ptr + 1;
          U8 *if_cmd_ptr = StrFirstOcc(if_var2, " ");
          if(if_cmd_ptr)
          {
	    *if_cmd_ptr = 0;
            U8 *if_cmd = if_cmd_ptr + 1;
            if(StrIMatch("then", if_cmd))
            {
	      if(!CheckCondition(arg, if_operator, if_var2))
              {
                g_Skip = TRUE;
		g_IfLevel = 0;
              }
              return;
            }
            if(CheckCondition(arg, if_operator, if_var2))
            {
	      Execute(if_cmd, file_buffer);
            }
          }
        }
      }
    }
    else if(!StrICmp(input, "goto"))
    {
      U8 *goto_tLabel = arg;
      StrUtil(goto_tLabel, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
      g_NextPos = NULL;

      if(file_buffer == NULL)
      {
	"Error: goto Only works in a file!\n";
      }
      U8 *goto_search_str = MStrPrint("label %s", goto_tLabel);
      U8 *goto_found = StrIMatch(goto_search_str, file_buffer);
      if(goto_found)
      {
	U8 *next_line = StrFirstOcc(goto_found, "\n");
        if(next_line)
        {
	  g_NextPos = next_line + 1;
        }
        else
	{
	  g_NextPos = goto_found;
	}
      }else
      {
	"Couldnt find label [%s]\n",goto_tLabel;
      }
      Free(goto_search_str);
    }
    else if(!StrICmp(input, "else"))
    {
      g_Skip = TRUE;
      g_IfLevel = 0;
    }
    else if(!StrICmp(input, "endif"))
    {
      return;
    }
    else if(!StrICmp(input, "poke"))
    {
      U8 *poke_yPos_ptr = StrFirstOcc(arg, " ");
      if(poke_yPos_ptr)
      {
        *poke_yPos_ptr = 0;
        U8 *poke_yPos_str = poke_yPos_ptr + 1;
        U8 *poke_backColor_ptr = StrFirstOcc(poke_yPos_str, " ");
        if(poke_backColor_ptr)
        {
          *poke_backColor_ptr = 0;
          U8 *poke_backColor_str = poke_backColor_ptr + 1;
          U8 *poke_frontColor_ptr = StrFirstOcc(poke_backColor_str, " ");
          if(poke_frontColor_ptr)
          {
	    *poke_frontColor_ptr = 0;
	    U8 *poke_frontColor_str = poke_frontColor_ptr + 1;
            U8 *poke_ascii_ptr = StrFirstOcc(poke_frontColor_str, " ");
            if(poke_ascii_ptr)
            {
	      *poke_ascii_ptr = 0;
	      U8 *poke_ascii_str = poke_ascii_ptr + 1;
              I64 poke_xPos = ResolveValue(arg);
              I64 poke_yPos = ResolveValue(poke_yPos_str);
              I64 poke_backColor = ResolveValue(poke_backColor_str);
              I64 poke_frontColor = ResolveValue(poke_frontColor_str);
	      I64 poke_ascii = ResolveValue(poke_ascii_str);
              I64 poke_combined = (poke_backColor << 12) | (poke_frontColor << 8) | poke_ascii;
              TextChar(Fs, 0, poke_xPos, poke_yPos, poke_combined);
	    }
	  }
        }
      }
    }
    else if(!StrICmp(input, "math"))
    {
      U8 *operator_ptr = StrFirstOcc(arg, " ");

      if(operator_ptr)
      {
        *operator_ptr = 0;
        U8 *var1 = arg;
        U8 *operator = operator_ptr + 1;
        U8 *var2_ptr = StrFirstOcc(operator, " ");
        if(var2_ptr)
        {
	  *var2_ptr = 0;
          U8 *var2 = var2_ptr + 1;
          U8 *output_ptr = StrFirstOcc(var2, " ");
	  if(output_ptr)
          {
	    *output_ptr = 0;
	    U8 *output_name = output_ptr + 1;
            I64 v1 = ResolveValue(var1);
	    I64 v2 = ResolveValue(var2);
	    I64 res = 0;
	    if(!StrCmp(operator, "+")) { res = v1 + v2; }
	    else if(!StrCmp(operator, "-")) { res = v1 - v2; }
	    else if(!StrCmp(operator, "*")) { res = v1 * v2; }
	    else if(!StrCmp(operator, "/")) { res = v1 / v2; }
	    SetVar(output_name, res);
          }
        }
      }
    }
    else if(!StrICmp(input, "queinit"))
    {
      if(*arg)
      {
	U8 *queinit_name = StrUtil(arg, SUF_REM_TRAILING | SUF_REM_LEADING | SUF_REM_CTRL_CHARS);
	MakeQue(queinit_name);
      }      
    }
    else if(!StrICmp(input, "quecnt")) {
      U8 *quecnt_name = arg;
      U8 *quecnt_res_ptr = StrFirstOcc(arg, " ");
      if(quecnt_res_ptr) {
        *quecnt_res_ptr = 0;
        TBasicQue *quecnt_que = FindQue(quecnt_name);
        if(quecnt_que) SetVar(quecnt_res_ptr + 1, QueCnt(&quecnt_que->var_head));
      }
    }
    else if(!StrICmp(input, "quepush"))
    {
      U8 *quepush_name = arg;
      U8 *quepush_val_ptr = StrFirstOcc(arg, " ");
      if(quepush_val_ptr)
      {
	*quepush_val_ptr = 0;
	I64 quepush_val = ResolveValue(quepush_val_ptr + 1);
	TBasicQue *quepush_que = FindQue(quepush_name);
	if(quepush_que) {
	  TBasicVar *new_item = CAlloc(sizeof(TBasicVar));
	  new_item->value = quepush_val;
	  StrCpy(new_item->name, "");
	  QueIns(new_item, quepush_que->var_head.last);
	}
      }
    }
    else if(!StrICmp(input, "quepop"))
    {
      U8 *quepop_name = arg;
      StrUtil(quepop_name, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
      if(quepop_name)
      {
	TBasicQue *quepop_que = FindQue(quepop_name);
	if(quepop_que && quepop_que->var_head.last != quepop_que->var_head)
	{
	  TBasicVar *quepop_var = quepop_que->var_head.last;
	  QueRem(quepop_var);
	  Free(quepop_var);
	}
      }

    }
    else if(!StrICmp(input, "queget"))
    {
      U8 *queget_name = arg;
      StrUtil(queget_name, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
      U8 *queget_index_ptr = StrFirstOcc(arg, " ");
      if(queget_index_ptr)
      {
	*queget_index_ptr = 0;
	I64 queget_index = ResolveValue(queget_index_ptr + 1);
	U8 *queget_resvar_ptr = StrFirstOcc(queget_index_ptr + 1, " ");
        if(queget_resvar_ptr)
        {
          *queget_resvar_ptr = 0;
	  U8 *queget_resvar = queget_resvar_ptr + 1;
          StrUtil(queget_resvar, SUF_REM_LEADING | SUF_REM_TRAILING | SUF_REM_CTRL_CHARS);
	  TBasicQue *queget_que = FindQue(queget_name);
	  if(queget_que)
          {
	    I64 queget_i = 0;
	    TBasicVar *queget_var;
	    for(queget_var = queget_que->var_head.next;
		queget_var != &queget_que->var_head && queget_i<queget_index;
		queget_var = queget_var->next)
	    {
	      queget_i++;
	    }
	    if(queget_var != &queget_que->var_head)
	    {
	      SetVar(queget_resvar, queget_var->value);
	    }
          }
        }
      }
    }
    else if(!StrICmp(input, "quelist"))
    {
      TBasicQue *quelist_que = que_head.next;
      "Que List\n";
      while(quelist_que != &que_head)
      {
        "%s [%d]\n",quelist_que->name, QueCnt(&quelist_que->var_head);
	quelist_que = quelist_que->next;
      }
    }
    else if(!StrICmp(input, "quedel"))
    {
      if(*arg)
      {
	U8 *quedel_name = StrUtil(arg, SUF_REM_TRAILING | SUF_REM_LEADING | SUF_REM_CTRL_CHARS);
	DelQue(quedel_name); 
     }
    }
    else if(!StrICmp(input, "getkey"))
    {
      if(*arg)
      {
        U8 *gkey_var1 = StrUtil(arg, SUF_REM_TRAILING | SUF_REM_LEADING | SUF_REM_CTRL_CHARS);
        I64 gkey = GetChar;
        SetVar(gkey_var1, gkey);
      }
    }
    else if(!StrICmp(input, "sleep"))
    {
      if(*arg)
      {
	U8 *sleep_msS = StrUtil(arg, SUF_REM_TRAILING | SUF_REM_LEADING | SUF_REM_CTRL_CHARS);
	I64 sleep_ms = ResolveValue(sleep_msS);
        if(sleep_ms > 0) Sleep(sleep_ms);
      }
    }
    else if(!StrICmp(input, "toggleCursor"))
    {
      g_CursorHidden = !g_CursorHidden;
      DocCursor(g_CursorHidden);
    }
    else if(!StrICmp(input, "random"))
    {
      U8 *random_max_ptr = StrFirstOcc(arg, " ");
      if(random_max_ptr)
      {
        *random_max_ptr = 0;
        U8 *random_min = arg;
        U8 *random_max = random_max_ptr + 1;
        U8 *random_var_ptr = StrFirstOcc(random_max, " ");
        if(random_var_ptr)
        {
	  *random_var_ptr = 0;
          U8 *random_var = random_var_ptr + 1;
          I64 random_Imin = ResolveValue(random_min);
          I64 random_Imax = ResolveValue(random_max);
          if(random_Imax <= random_Imin) random_Imax = random_Imin + 1;
          U64 random_result = RandomRange(random_Imin, random_Imax);
	  SetVar(random_var, random_result);
        }
        
      }
    }
    else if(!StrICmp(input, "set")) 
    {
      U8 *val_ptr = StrFirstOcc(arg, " ");
      if(val_ptr)
      {
        *val_ptr = 0;
        U8 *name = arg;
        U8 *value_str = val_ptr + 1;
	SetVar(name, Str2I64(value_str));
      }else{
        "Usage: set <var_name> <value>\n";
      }
    }
    else if(!StrICmp(input, "cls")) {
      DocClear;
    }
    else if(!StrICmp(input, "label")) {
      return;
    }
    else if(!StrICmp(input, "rem")) {
      return;
    }
    else if(!StrICmp(input, "exit")) {
      g_Running = FALSE;
    }
}


U0 RunScript(U8 *file_ptr)
{
  U8 *current_pos = file_ptr;
  U8 *line_end;
  U8 *line_copy;
  I64 len;


  while(current_pos && *current_pos && g_Running)
  {
    Yield;
    g_NextPos = NULL;
    line_end = StrFirstOcc(current_pos, "\n");

    if(line_end)
    {
      len = line_end - current_pos;
    }
    else
    {
      len = StrLen(current_pos);
    }
    line_copy = MAlloc(len + 1);
    MemCpy(line_copy, current_pos, len);
    line_copy[len] = 0;

    Execute(line_copy, file_ptr);

    Free(line_copy);

    if(g_NextPos)
    {
      current_pos = g_NextPos;
    }else if(line_end)
    {
      current_pos = line_end + 1;
    }
    else{
      break;
    }


  }
  g_Skip = FALSE;
  g_Running = TRUE;
}

U0 TB_Load(U8 *file_name)
{
  if(FileFind(file_name))
  {
    U8 *file = FileRead(file_name);
    RunScript(file);
  }
}


U0 TB_Shell()
{
  U8 *input;
  "Welcome to TBasic Shell v0.1\n";
  while(g_Runni$WW,1$ng)
  {
    input = GetStr("> ");
    if(input)
    {
      if(*input)
      {
      	Execute(input, NULL);
      }
      Free(input);
    }
    Yield;
  }
}

U0 TB_Run(U8 *file)
{
  if(file)
  {
    TB_Load(file);
  }
  TB_Shell;
}

