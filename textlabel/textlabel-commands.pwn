CMD:createlabel(playerid, params[])
{
    new name[258], Float:x, Float:y, Float:z, Float:a;
    if(PlayerInfo[playerid][pAdmin] < 7) return SendClientMessage(playerid, COLOR_SYNTAX, "Your not autorized to use this command.");
    if(sscanf(params, "s[258]", name)) return SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /createlabel [name]");
    
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    for(new i = 0; i < MAX_LABEL; i ++)
	{
	    if(!LabelInfo[i][lbExists])
	    {
			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "INSERT INTO textlabels (name, pos_x, pos_y, pos_z, pos_a) VALUES('%e', '%f', '%f', '%f', '%f')", name, x, y, z, a);
			mysql_tquery(connectionID, queryBuffer, "CreateDynamicLabel", "iisffff", playerid, i, name, x, y, z, a);
			return 1;
		}
	}
    return 1;
}

CMD:destroylabel(playerid, params[])
{
    new id;
    if(PlayerInfo[playerid][pAdmin] < 7) return SendClientMessage(playerid, COLOR_SYNTAX, "Your not autorized to use this command.");
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /destroylabel [id]");
    if(!(0 <= id < MAX_LABEL) || !LabelInfo[id][lbExists]) return SendClientMessage(playerid, COLOR_SYNTAX, "Invalid label.");

	DestroyDynamic3DTextLabel(LabelInfo[id][lbText]);
    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "DELETE FROM textlabels WHERE id = %i", LabelInfo[id][lbID]);
    mysql_tquery(connectionID, queryBuffer);

	LabelInfo[id][lbExists] = 0;
	LabelInfo[id][lbID] = 0;

    SendMessage(playerid, COLOR_WHITE, "** You have removed label  %i.", id);
    return 1;
}

CMD:gotolabel(playerid, params[])
{
	new id;
    if(PlayerInfo[playerid][pAdmin] < 7) return SendClientMessage(playerid, COLOR_SYNTAX, "Your not autorized to use this command.");
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /gotolabel [id]");
	if(!(0 <= id < MAX_LABEL) || !LabelInfo[id][lbExists]) return SendClientMessage(playerid, COLOR_SYNTAX, "Invalid label.");

	GameTextForPlayer(playerid, "~w~Teleported", 5000, 1);
	SetPlayerPos(playerid, LabelInfo[id][LabelX], LabelInfo[id][LabelY], LabelInfo[id][LabelZ]);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetCameraBehindPlayer(playerid);
	return 1;
}
CMD:editlabel(playerid, params[])
{
	new id, option[14], param[64];
	if(PlayerInfo[playerid][pAdmin] < 7)
	{
	    return SendClientMessage(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");
	}
	if(sscanf(params, "is[14]S()[64]", id, option, param))
	{
	    SendClientMessage(playerid, COLOR_SYNTAX, "Usage: /editlabel [id] [option]");
	    SendClientMessage(playerid, COLOR_WHITE, "Available options: name, position");
	    return 1;
	}
	if(!(0 <= id < MAX_LABEL) || !LabelInfo[id][lbExists])
	{
	    return SendClientMessage(playerid, COLOR_SYNTAX, "Invalid label.");
	}
	if(!strcmp(option, "name", true))
	{
	    new name[258];
	    if(sscanf(param, "s[258]", name))
	    {
	        return SendClientMessage(playerid, COLOR_SYNTAX, "Usage: /editlabel [id] [name] [text]");
		}
		strcpy(LabelInfo[id][lbName], name, 258);
		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE textlabels SET name = '%e' WHERE id = %i", LabelInfo[id][lbName], LabelInfo[id][lbID]);
	    mysql_tquery(connectionID, queryBuffer);

		ReloadLabel(id);
	    SendMessage(playerid, COLOR_WHITE, "** You've changed the name of text label %i to '%s'.", id, name);
	}
	else if(!strcmp(option, "position", true))
	{
	    GetPlayerPos(playerid, LabelInfo[id][LabelX], LabelInfo[id][LabelY], LabelInfo[id][LabelZ]);
		GetPlayerFacingAngle(playerid, LabelInfo[id][LabelA]);
		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE textlabels SET pos_x = %f, pos_y = %f, pos_z = %f, pos_a = %f WHERE id = %i", LabelInfo[id][LabelX], LabelInfo[id][LabelY], LabelInfo[id][LabelZ], LabelInfo[id][LabelA], LabelInfo[id][lbID]);
	    mysql_tquery(connectionID, queryBuffer);

		ReloadLabel(id);
	    SendMessage(playerid, COLOR_WHITE, "You've changed the position of text label %i.", id);
	}
	return 1;
}