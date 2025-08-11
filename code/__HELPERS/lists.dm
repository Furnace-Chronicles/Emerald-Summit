/proc/build_singleton_list(master_type)
	var/list/built_list = list()

	for(var/path in typesof(master_type))
		if(is_abstract(path))
			continue
		built_list[path] = new path()

	return built_list
