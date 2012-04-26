/* AMX Mod script. (Nov 10th, 2002)
*
* Task Scheduler 0.2
*  by JustinHoMi
*
* amx_task time "task" flags
* flags:
*  m - time is in minutes
*  s - time is in seconds
*  r - repeat task
*  t - specific time
*
*/

#include <amxmodx>

new task_cmds[32][108]
new task_times[32][16]
new numtasks = 0

public load_task()
{
	if (read_argc() < 4) {
		server_print("[AMX] Usage:  amx_task < time > ^"command^" < flags >")
		return PLUGIN_HANDLED
	}

	new args[128]
	read_args(args,128)
	new clock[6], cmd[108], flags[5]

	parse(args,clock,6,cmd,108,flags,5)
	new Float:time_f = floatstr(clock)

	new flag[2] = ""
	if (contain(flags,"r") != -1)
		flag="b"
	if (contain(flags,"m") != -1)
		time_f = time_f * 60

	if (contain(flags,"t") != -1)
	{
		copy(task_cmds[numtasks],108,cmd)
		copy(task_times[numtasks],6,clock)
		numtasks++
		return PLUGIN_HANDLED
	}

	set_task(time_f,"run_task",0,cmd,108,flag)

	return PLUGIN_CONTINUE
}

public run_task(cmd[])
{
	server_cmd(cmd)
	return PLUGIN_HANDLED
}

public check_time()
{
	new curtime[16]
	get_time("%H:%M",curtime,16)

	for(new i=0; i<numtasks; i++)
		if(equal(curtime,task_times[i]))
			server_cmd(task_cmds[i])

	return PLUGIN_CONTINUE
}

public plugin_init()
{
	register_plugin("Task Scheduler","0.2","JustinHoMi")
	register_srvcmd("amx_task","load_task")
	set_task(60.0,"check_time",1,"",0,"b")
	return PLUGIN_CONTINUE
}
