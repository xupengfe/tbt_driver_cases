echo -off

fs0:
if exist none_set.txt then
  if not exist none_set_done.txt then
    set_none.nsh
    echo "pass" > none_set_done.txt
    reset
  else
    boot.nsh
  endif
endif

if exist user_set.txt then
  if not exist user_set_done.txt then
    set_user.nsh
    echo "pass" > user_set_done.txt
    reset
  else
    boot.nsh
  endif
endif

if exist secure_set.txt then
  if not exist secure_set_done.txt then
    set_secure.nsh
    echo "pass" > secure_set_done.txt
    reset
  else
    boot.nsh
  endif
endif

if exist dp_set.txt then
  if not exist dp_set_done.txt then
    set_dp.nsh
    echo "pass" > dp_set_done.txt
    reset
  else
    boot.nsh
  endif
endif
boot.nsh