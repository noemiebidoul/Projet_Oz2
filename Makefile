all: run

compile:
	ozc -c src/GUI.oz -o GUI.ozf
	ozc -c src/PlayerManager.oz -o PlayerManager.ozf
	ozc -c src/Input.oz -o Input.ozf
	ozc -c src/Stack.oz -o Stack.ozf
	ozc -c src/Pacman091smart.oz -o Pacman091smart.ozf
	ozc -c src/Ghost091smart.oz -o Ghost091smart.ozf
	ozc -c src/Main.oz -o Main.ozf

run: compile

clean: 
	rm -rf *.ozf
	rm -rf *~

mrproper: clean
