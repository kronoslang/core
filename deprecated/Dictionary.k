Import Algorithm

Package Dictionary {
	Find(dict key) {
		;; Finds an entry in key-value list 'dict' whose key matches 'key'; or nil if nothing found.
		((k v) kvs) = dict
		Find = Equal-Type(k key)      : (key v)
			   Nil?(dict) 			  : nil
			   Recur(Rest(dict) key)
	}

	Remove(dict key) {
		;; Removes an entry in key-value list 'dict' whose key matches 'key'; returns the modified collection.
		Remove = Algorithm:Filter((k v) => k == key dict)
	}

	Insert(dict key value)	{
		;; Inserts a 'key'-'value' pair into 'dict'; if 'key' already exists in 'dict', the value is replaced. The modified collection is returned.
		Insert = ((key value) Remove(dict key))
	}
}