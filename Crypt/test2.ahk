test := ["marcell", "joao", "jose", "carlos"]
Loop, % 2
{
	MsgBox, % test.MaxIndex()
	test.Remove(test.MaxIndex())
}
for, each, value in test{
	MsgBox, % value
}