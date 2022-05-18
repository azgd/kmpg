def get_in(dictionary, keys):    
    if not keys:
        return dictionary  

    listkeys = keys.split('/')

    if len(listkeys) == 1:
        return dictionary.get(listkeys[0])
    else:
        return get_in(dictionary.get(listkeys[0]), "/".join(listkeys[1:]))