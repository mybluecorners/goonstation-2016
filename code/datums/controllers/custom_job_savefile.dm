//some of this stuff is shamelessly copied from savefile.dm. yay!! blame MBC if it breaks.

datum/job_controller/proc/savefile_path(client/user)
	var/ckey = user.ckey
	if (src.load_another_ckey)
		ckey = src.load_another_ckey
	return "data/admin_custom_job_saves/[ckey].sav"

datum/job_controller/proc/savefile_path_exists(client/user)
	var/path = savefile_path(user)
	if (!fexists(path))
		return 0
	return path

datum/job_controller/proc/savefile_delete(client/user, profileNum=1)
	fdel(savefile_path(user))

datum/job_controller/proc/savefile_save(client/user, profileNum=1)
	profileNum = max(1, min(profileNum, CUSTOMJOB_SAVEFILE_PROFILES_MAX))
	var/savefile/F = new /savefile(src.savefile_path(user), -1)
	F.Lock(-1)

	F["[profileNum]_saved"] << 1
	F["[profileNum]_job_name"] << src.job_creator.name
	F["[profileNum]_job_datum"] << src.job_creator

	return 1

datum/job_controller/proc/savefile_load(client/user, var/profileNum = 1)
	var/path = savefile_path(user)
	if (!fexists(path))
		return 0

	profileNum = max(1, min(profileNum, CUSTOMJOB_SAVEFILE_PROFILES_MAX))

	var/savefile/F = new /savefile(path, -1)

	var/sanity_check = null
	F["[profileNum]_saved"] >> sanity_check
	if (isnull(sanity_check))
		for (var/i=1, i <= CUSTOMJOB_SAVEFILE_PROFILES_MAX, i++)
			F["[i]_saved"] >> sanity_check
			if (!isnull(sanity_check))
				break
		if (isnull(sanity_check))
			fdel(path)
		return 0

	F["[profileNum]_job_datum"] >> src.job_creator

	return 1

datum/job_controller/proc/savefile_get_job_name(client/user, var/profileNum = 1)
	var/path = savefile_path_exists(user)
	if (!path)
		return 0

	profileNum = max(1, min(profileNum, CUSTOMJOB_SAVEFILE_PROFILES_MAX))

	var/savefile/F = new /savefile(path, -1)

	var/job_name = null
	F["[profileNum]_job_name"] >> job_name

	if (isnull(job_name))
		return 0

	return job_name