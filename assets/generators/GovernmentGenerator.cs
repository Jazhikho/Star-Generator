using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class GovernmentGenerator
{
	private static readonly string[] GOVERNMENT_RUN = new string[]
	{
		"Espionage Facility", "Government Research Station", "Naval Base", "Prison", "Patrol Base"
	};
	private static readonly string[] CRIMINAL_RUN = new string[] 
	{ 
		"Pirate Base", "Rebel Base", "Black Market" 
	};
	private static readonly Dictionary<string, int> GOVERNMENTS = new Dictionary<string, int>
	{
		{"Clan", 6}, {"Corporation", 15}, {"Participating Democracy", 16},
		{"Republican Democracy", 17}, {"Social Democracy", 18}, {"Technocracy", 20},
		{"Bureaucracy", 24}, {"Aristocracy", 25}, {"Oligarchy", 26},
		{"Dictatorship", 27}, {"Theocracy", 28}
	};
	private static readonly Dictionary<string, int> VARIANT = new Dictionary<string, int>
	{
		{"", 11}, {"Particratic ", 13}, {"Stratocratic", 15},
		{"Patriarchic ", 16}, {"Matriarchic ", 18}
	};

	public Dictionary<string, object> GenerateGovernment(int techLevel, string factions, int factionNumber, string outpostType = "")
	{
		if (!string.IsNullOrEmpty(outpostType))
		{
			if (GOVERNMENT_RUN.Contains(outpostType))
				return new Dictionary<string, object> { {"type", "Government Run"} };
			if (CRIMINAL_RUN.Contains(outpostType))
				return new Dictionary<string, object> { {"type", "Criminally Run"} };
			return new Dictionary<string, object> { {"type", "Independent"} };
		}

		int mod = Mathf.Min(techLevel, 10);

		if (factions == "Diffuse")
			return GenerateDiffuseGovernment(factionNumber * 10, mod);
		else
			return GenerateUnifiedGovernment(factionNumber, mod);
	}

	private Dictionary<string, object> GenerateDiffuseGovernment(int number, int mod)
	{
		var govTypes = new Dictionary<string, int>();
		while (number > 0)
		{
			int govType = Roll.Dice();
			string selectedGov = Roll.Seek(GOVERNMENTS, govType + mod);
			string variant = Roll.Seek(VARIANT);
			string govName = variant + selectedGov;
			govTypes[govName] = govTypes.GetValueOrDefault(govName, 0) + 1;
			number--;
		}

		int total = govTypes.Values.Sum();
		var result = new Dictionary<string, object>();
		foreach (var gov in govTypes.Keys)
		{
			float percentage = ((float)govTypes[gov] / total) * 100;
			result[gov] = Mathf.Round(percentage * 100) / 100;
		}

		result["Overall Control"] = Mathf.Max(Roll.Dice(2, 6, -7), 1);
		return result;
	}

	private Dictionary<string, object> GenerateUnifiedGovernment(int number, int mod)
	{
		var govTypes = new Dictionary<string, object>();
		while (number > 0)
		{
			int govType = Roll.Dice();
			string selectedGov = Roll.Seek(GOVERNMENTS, govType + mod);
			string variant = Roll.Seek(VARIANT, Roll.Dice(3, 6, mod));
			int relativeStrength = Roll.Dice(2);
			float control = Mathf.Max((Roll.Dice(2) - 7 + govType), 0) / 4.0f;
			govTypes[variant + selectedGov] = new int[] {relativeStrength, Mathf.RoundToInt(control)};
			number--;
		}
		return govTypes;
	}
}
