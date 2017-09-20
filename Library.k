Import Algorithm
Import Exception

Package String {
	Concat(strings) {
		(s ss) = strings
		Concat = Throw:Unexpected("Can't concatenate " strings)
		Concat = String:Append(s Recur(ss))
		Concat = When(Nil?(s) "")
		Concat = When(Equal-Type(Class-Of(strings) Class-Of("")) strings)
	}

	Collate(string-tree) {
		Collate = Nil?(string-tree) : "" string-tree

		(sl sr) = string-tree
		Collate = String:Append(Recur(sl) Recur(sr))
	}
}

Package Library {
	Package XML {
		Format-Symbol(sym) {
			(symtag name arglist comment graph) = sym

			Format-Symbol = When(Equal-Type(symtag "Symbol") 
				String:Collate("<symbol id='" name "'>"
				Algorithm:Map(a => ("<args>" a " </args>") arglist)
					String:Length(comment) > #0 : ("<comment>" comment "</comment>") 
												   ""
				"</symbol>\n"))
		}

		Format-Package(pack) {
			(packtag name contents) = pack
			Format-Package = When(Equal-Type(packtag "Package")
				String:Collate("<package id='" name "'>\n"
					Format-Items(contents)
					"</package>\n"))
		}

		Format-Items(pack-contents) {
			(p ps) = pack-contents
			Format-Items = Throw:Invalid-Argument("Invalid library metadata " pack-contents)
			Format-Items = When(Nil?(pack-contents) "")
			Format-Items = Format-Symbol(pack-contents)
			Format-Items = Format-Package(pack-contents)
			Format-Items = (Format-Symbol(p) Recur(ps))
			Format-Items = (Format-Package(p) Recur(ps))
		}
	}

	Get-XML(root) {
		Get-XML = String:Collate(XML:Format-Items(Get-Library-Metadata(root)))
	}
}