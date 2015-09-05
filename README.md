Ruby Food Chain
-----------------
Features:
	-Simulation of beings within closed 2D System.
	-Genetic algorithms to determine children stats
	-Simple 4 Type Food Chain [Parasites, Predators, Symbiotes[Plants,Predated]]
		Parasites Eat:
			-Predators
			-Plants
			-Predated
		Plants Eat:
			-Dead Predated
			-Dead Plants
			-Dead Parasites
		Predated Eat:
			-Plants
		Predators Eat:
			-Predated

Functionality:
	Parasites Passively Feed on life
	Plants Passively Feed on death
	Herbivores Actively Feed On The Living
	Predators Actively Feed On The Dead

Requirements:
	Ruby: 2.0.0 (May not be required, but used 2.0.0 for development)
	Gem: Gosu

Usage:
	-Run: "ruby foodchain.rb"