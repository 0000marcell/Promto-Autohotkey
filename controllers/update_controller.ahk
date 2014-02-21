make_update:
Run, %comspec% /K git reset --hard && git pull
MsgBox, 4,,E preciso reiniciar o programa para que as mudancas tenham efeito `n deseja reiniciar agora? 
IfMsgBox Yes
{
	Reload
}
return