#define MAX_LABEL		200

enum LabelEnum
{
    lbExists,
	lbID,
    lbName[128],
    Float:LabelX,
    Float:LabelY,
    Float:LabelZ,
	Float:LabelA,
    Text3D:lbText,
};
new LabelInfo[MAX_LABEL][LabelEnum];

ReloadLabel(labelid) {
    if(LabelInfo[labelid][lbExists]) {
	    new string[1028];
		DestroyDynamic3DTextLabel(LabelInfo[labelid][lbText]);
        format(string, sizeof(string), "Label Info\n\n%s\nID: %d", LabelInfo[labelid][lbName], labelid);
        LabelInfo[labelid][lbText] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, LabelInfo[labelid][LabelX], LabelInfo[labelid][LabelY], LabelInfo[labelid][LabelZ]+0.5,10.0);
    }
    return 1;
}

forward LoadDynamicLabel();
public LoadDynamicLabel()
{
	new rows = cache_num_rows();
	if(rows) 
	{
		for(new i; i < rows; i++) 
		{
			LabelInfo[i][lbExists] = 1;
			cache_get_field_content(i, "name", LabelInfo[i][lbName], connectionID, 258);
			LabelInfo[i][lbID] = cache_get_field_content_int(i, "id");
			LabelInfo[i][LabelX] = cache_get_field_content_float(i, "pos_x");
			LabelInfo[i][LabelY] = cache_get_field_content_float(i, "pos_y");
			LabelInfo[i][LabelZ] = cache_get_field_content_float(i, "pos_z");
			LabelInfo[i][LabelA] = cache_get_field_content_float(i, "pos_a");

			new string[128];
			format(string, sizeof(string), "Label Info\n\n%s\nID: %d", LabelInfo[i][lbName], i);
			LabelInfo[i][lbText] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, LabelInfo[i][LabelX], LabelInfo[i][LabelY], LabelInfo[i][LabelZ]+0.7,10.0);
			ReloadLabel(i);
		}
	}
	printf("[MySQL] %i textlabel loaded.", rows);
	return 1;
}

forward CreateDynamicLabel(playerid, labelid, name[], Float:x, Float:y, Float:z, Float:a);
public CreateDynamicLabel(playerid, labelid, name[], Float:x, Float:y, Float:z, Float:a)
{
	strcpy(LabelInfo[labelid][lbName], name, 258);
	LabelInfo[labelid][lbExists] = 1;
	LabelInfo[labelid][lbID] = cache_insert_id(connectionID);
	LabelInfo[labelid][LabelX] = x;
	LabelInfo[labelid][LabelY] = y;
	LabelInfo[labelid][LabelZ] = z;
	LabelInfo[labelid][LabelA] = a;
	LabelInfo[labelid][lbText] = Text3D:INVALID_3DTEXT_ID;
	ReloadLabel(labelid);
	SendAdminMessage(COLOR_LIGHTRED,"AdmCmd: %s has created text label %d", GetPlayerNameEx(playerid), labelid);
}
