#include <amxmodx>
#include <orpheu>
#define PLUGIN "File watcher"
#define VERSION "0.2"
#define AUTHOR "mazdan"

#define f "filew_atcher.log"

new Array:aRule
new Array:aFile
new Array:aRuleType

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_srvcmd("fw_add_file","file_add",_,"fw_add_file <ACCEPT | BLOCK> <filename>")
//    register_srvcmd("fw_rules","show_rules")
    aRule=ArrayCreate(1,32)
    aRuleType=ArrayCreate(1,32)
    aFile=ArrayCreate(128,32)
    server_cmd("exec filewatcher.cfg")
    OrpheuRegisterHook(OrpheuGetFunction("FS_Open"),"FS_Open", OrpheuHookPre)
} 



public OrpheuHookReturn:FS_Open(test[],b[])
{
    if(containi(b,"w")!=-1)
    {
        new rule
        strtolower(test)
        replace_all(test,strlen(test),"/","\")
        new len=strlen(test)
        new count=ArraySize(aFile)
        for(new i;(i<count && !rule);i++)
        {
            new file[128]
            ArrayGetString(aFile,i,file,127)
            switch(ArrayGetCell(aRuleType,i))
            {
                case 0:if(equal(test,file)) rule=i+1
                case 1:if(containi(test,file)==len-strlen(file)) rule=i+1
                case 2:if(containi(test,file)==0) rule=i+1
                case 3:if(containi(test,file)!=-1) rule=i+1
            }
        }
        if(rule)
        {
            if(ArrayGetCell(aRule,--rule))
            {
                log_to_file(f,"Rule [#%d] ACCEPT %s",rule,test)
                return OrpheuIgnored;
            }
            else
            {
                log_to_file(f,"Rule [#%d] BLOCK %s",rule,test)
                return OrpheuSupercede;
            }
        }
        else
        {
            log_to_file(f,"No rule BLOCK %s",test)
            return OrpheuSupercede;
        }
    }
    return OrpheuIgnored;
}


public file_add()
{
    new rule[10]
    new file[128]
    read_argv(1,rule,9)
    read_argv(2,file,127)
    if(!equal(rule,"ACCEPT") && !equal(rule,"BLOCK"))
    {
        log_to_file(f,"RULE ADD ERROR use <ACCEPT | BLOCK>")
        console_print(0,"RULE ADD ERROR use <ACCEPT | BLOCK>")
        return PLUGIN_HANDLED;
    }
    if(strlen(file)<1)
    {
        log_to_file(f,"RULE ADD ERROR ^" ^" to specify filename")
        console_print(0,"RULE ADD ERROR ^" ^" to specify filename")
        return PLUGIN_HANDLED;
    }
    ArrayPushCell(aRule,equal(rule,"ACCEPT"))
    ArrayPushCell(aRuleType,((file[0]==42) + 2*(file[strlen(file)-1]==42)) ) //Yep 42 :D
    replace_all(file,127,"*","")
    replace_all(file,127,"/","\")
    ArrayPushString(aFile,file)
    return PLUGIN_HANDLED;
}

public show_rules()
{
    if(!ArraySize(aFile))
        console_print(0,"NO RULES FOUND!")
    else
    {
        new count=ArraySize(aFile)
        for(new i;i<count;i++)
        {
            new file[128]
            ArrayGetString(aFile,i,file,127)
            console_print(0,"[%d] %s %s%s%s",i,(ArrayGetCell(aRule,i))?"ACCEPT":"BLOCK",(ArrayGetCell(aRuleType,i) & 1)?"*":"",file,(ArrayGetCell(aRuleType,i) & 2)?"*":"")
        }
    
    }

}