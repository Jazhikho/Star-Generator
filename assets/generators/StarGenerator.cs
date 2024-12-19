using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class StarGenerator
{
	public StarData StarData { get; private set; }

	private StarBasics starBasics;
	private MassiveStarGenerator massiveStarGen;
	private BrownDwarfGenerator brownDwarfGen;
	private CompactObjectGenerator compactObjectGen;
	private StarEvolution starEvolution;
	private StarLuminosity starLuminosity;
	private StarTemperature starTemperature;
	private StarRadius starRadius;
	private StellarParameters stellarParams;

	private int starId;

	public StarGenerator(int id, float massCap = float.MaxValue)
	{
		starId = id;
		InitializeSystems();
		GenerateStar(massCap);
	}

	private void InitializeSystems()
	{
		starLuminosity = new StarLuminosity();
		starTemperature = new StarTemperature();
		starRadius = new StarRadius();
	}

	private void GenerateStar(float massCap)
	{
		starBasics = new StarBasics();
		var massData = starBasics.CalculateMass(massCap);
		float mass = massData["mass"];
		float massVar = massData["mass_var"];
		string stellarClass = DetermineStellarClass(mass);
		
		GD.Print($"Stellar class is {stellarClass}");
		switch (stellarClass)
		{
			case "BROWN_DWARF":
				brownDwarfGen = new BrownDwarfGenerator();
				GenerateBrownDwarf(mass);
				break;
			case "MASSIVE_STAR":
				massiveStarGen = new MassiveStarGenerator();
				GenerateMassiveStar(mass, massVar);
				break;
			case "MAIN_SEQUENCE":
			default:
				GD.Print("Generating Main Sequence Star");
				GenerateMainSequenceStar(mass, massVar);
				break;
		}
		
		StarData.IsFlareStar = CalculateFlareStar(StarData.SpectralType);
		GD.Print($"FlareStar = {StarData.IsFlareStar}");
		StarData.StarId = starId;
		GD.Print($"StarData so far = {StarData}");
	}

	private string DetermineStellarClass(float mass)
	{
		if (mass < 0.08f) return "BROWN_DWARF";
		if (mass > 3.0f) return "MASSIVE_STAR";
		return "MAIN_SEQUENCE";
	}
	
	private bool CalculateFlareStar(string spectralType)
	{
		if (spectralType.StartsWith("M"))
		{
			return Roll.Dice() <= 14;
		}
		return false;
	}

	private void GenerateBrownDwarf(float mass)
	{
		starEvolution = new StarEvolution();
		float age = starEvolution.CalculateAge(mass);
		var bdData = brownDwarfGen.GenerateBrownDwarf(mass, age);
		
		StarData = new StarData
		{
			Mass = mass,
			Age = age,
			SpectralType = bdData.SpectralType,
			LuminosityClass = 0,
			Luminosity = bdData.Luminosity,
			Temperature = bdData.Temperature,
			Radius = bdData.Radius,
			CelestialBodies = new List<object>()
		};
	}

	private void GenerateMassiveStar(float mass, float massVar)
	{
		var msData = massiveStarGen.GenerateMassiveStar(mass, massVar.ToString());
		
		StarData = new StarData
		{
			Mass = mass,
			Age = msData.Age,
			SpectralType = msData.SpectralType,
			LuminosityClass = 5,
			Luminosity = msData.Luminosity,
			Temperature = msData.Temperature,
			Radius = msData.Radius,
			CelestialBodies = new List<object>()
		};
	}

	private void GenerateMainSequenceStar(float mass, float massVar)
	{
		starEvolution = new StarEvolution();
		float age = starEvolution.CalculateAge(mass);
		GD.Print($"Star Age = {age}");
		string evolutionaryStage = starEvolution.DetermineEvolutionaryStage(mass, age);
		
		stellarParams = new StellarParameters();
		var starParams = stellarParams.GetStellarParameters(mass, "MAIN_SEQUENCE");
		string spectralType = starParams.ContainsKey("Type") ? (string)starParams["Type"] : "Unknown";

		float luminosity, temperature, radius;
		int luminosityClass;

		switch (evolutionaryStage)
		{
			case "SUBGIANT":
				luminosityClass = 4;
				luminosity = starLuminosity.CalculateSubgiantLuminosity(mass, evolutionaryStage);
				temperature = starTemperature.CalculateSubgiantTemperature(Convert.ToSingle(starParams["Temperature"]), 0.1f);
				radius = starRadius.CalculateSubgiantRadius(mass);
				break;
			case "GIANT":
				luminosityClass = 3;
				luminosity = starLuminosity.CalculateGiantLuminosity(mass, evolutionaryStage);
				temperature = starTemperature.CalculateGiantTemperature();
				radius = starRadius.CalculateGiantRadius(mass);
				break;
			case "WHITE_DWARF":
				compactObjectGen = new CompactObjectGenerator();
				var wdData = compactObjectGen.GenerateWhiteDwarf(mass);
				luminosityClass = 7;
				luminosity = (float)wdData["luminosity"];
				temperature = (float)wdData["temperature"];
				radius = (float)wdData["radius"];
				break;
			case "MAIN_SEQUENCE":
			default:
				luminosityClass = 5;
				float minLuminosity = Convert.ToSingle(starParams["L-Min"]);
				GD.Print($"Calculating main sequence luminosity for mass {massVar}, age {age}, min luminosity {minLuminosity}");
				luminosity = starLuminosity.CalculateMainSequenceLuminosity(massVar.ToString(), age, minLuminosity);
				GD.Print($"Calculated luminosity: {luminosity}");
				temperature = starTemperature.CalculateMainSequenceTemperature(Convert.ToSingle(starParams["Temperature"]));
				radius = starRadius.CalculateMainSequenceRadius(mass);
				break;
		}

		StarData = new StarData
		{
			Mass = mass,
			Age = age,
			SpectralType = spectralType,
			LuminosityClass = luminosityClass,
			Luminosity = luminosity,
			Temperature = temperature,
			Radius = radius,
			CelestialBodies = new List<object>()
		};
	}
}
