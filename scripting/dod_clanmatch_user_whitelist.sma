#include <amxmodx>
#include <amxmisc>

new g_szUsersFile[128]
new Trie:g_tUsers
new g_pClanMatch
new g_pEnable

public plugin_init()
{
	register_plugin("Clan Match Whitelist", "0.2", "Fysiks")
	register_concmd("dod_clanmatch_reload_whitelist", "cmdReload")
	g_pEnable = register_cvar("dod_clanmatch_whitelist", "1")

	g_tUsers = TrieCreate()

	get_configsdir(g_szUsersFile, charsmax(g_szUsersFile))
	add(g_szUsersFile, charsmax(g_szUsersFile), "/clanmatchusers.ini")

	loadFile(g_szUsersFile)
}

public plugin_cfg()
{
	g_pClanMatch = get_cvar_pointer("dod_clanmatch")
}

public client_authorized(id)
{
	if( get_pcvar_num(g_pClanMatch) && get_pcvar_num(g_pEnable) )
	{
		new szAuthID[32]
		get_user_authid(id, szAuthID, charsmax(szAuthID))

		if( !TrieKeyExists(g_tUsers, szAuthID) && !is_user_admin(id) )
		{
			new iUserId = get_user_userid(id)
			server_cmd("kick #%d", iUserId)
		}
	}
}

public cmdReload()
{
	loadFile(g_szUsersFile)
	return PLUGIN_HANDLED
}

loadFile(szFile[])
{
	TrieClear(g_tUsers)
	
	new szBuffer [38], iCount
	new f = fopen(szFile, "rt")
	if( f )
	{
		while( fgets(f, szBuffer, charsmax(szBuffer)) )
		{
			trim(szBuffer)
			if( szBuffer[0] == ';' || szBuffer[0] == EOS )
				continue
			TrieSetCell(g_tUsers, szBuffer, 1)
			iCount++
		}
		fclose(f)

		server_print("Clan Match User Whitelist loaded (%d users)", iCount)
	}
}

