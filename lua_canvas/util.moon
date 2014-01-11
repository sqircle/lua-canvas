simpleSplit = (str, patt="[^%,]+") ->
  tokens = {}
  i = 0
  for token in string.gmatch(str, patt) do
    i = i + 1
    tokens[i] = token\gsub("^%s*(.-)%s*$", "%1")
  
  return tokens

{
	:simpleSplit
}
