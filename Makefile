all: run

compile:
	ozc -c GUI.oz -o GUI.ozf
	ozc -c PlayerManager.oz -o PlayerManager.ozf
	ozc -c Input.oz -o Input.ozf
	ozc -c Stack.oz -o Stack.ozf
	ozc -c Pacman091smart.oz -o Pacman091smart.ozf
	ozc -c Ghost091smart.oz -o Ghost091smart.ozf
	ozc -c Main.oz -o Main.ozf

run: compile

clean: 
	rm -rf *.ozf
	rm -rf *~

mrproper: clean
