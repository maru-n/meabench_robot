mv ../../scope/scope.C ../../scope/scope_main.C
perl -p -i.bak -e 's/scope.C/scope_main.C/g' ../../scope/Makefile.am

mv ../../neurosock/neurosock.C ../../neurosock/neurosock_main.C
perl -p -i.bak -e 's/neurosock.C/neurosock_main.C/g' ../../neurosock/Makefile.am
