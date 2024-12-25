using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class StarEvolution
{
	public float CalculateAge(float starMass)
	{
		Console.WriteLine("Calculating age");
		if (starMass > 3)
		{
			return CalculateMassiveStarAge(starMass);
		}

		var ageData = Roll.Search(StarsData.STELLAR_AGE) as double[];

		float baseAge = (float)ageData[0];
		float ageModifier1 = (float)ageData[1];
		float ageModifier2 = (float)ageData[2];

		return Roll.Vary(baseAge +
						 Roll.Dice(1, 6, -1) * ageModifier1 +
						 Roll.Dice(1, 6, -1) * ageModifier2);
	}

	private float CalculateMassiveStarAge(float starMass)
	{
		int massStr = (int)Math.Round(starMass);
		var massData = Roll.Search(StarsData.MASSIVE_STARS, massStr) as Dictionary<string, object>;
		
		if (massData != null && massData.ContainsKey("Stable Span"))
		{
			float stableSpan = Convert.ToSingle(massData["Stable Span"]);
			return Roll.Vary(Roll.Dice() * stableSpan / 18);
		}

		Console.WriteLine("Invalid mass data or Stable Span for massive star");
		return 1.0f;
	}

	public string DetermineEvolutionaryStage(float mass, float age)
	{
		int massroll = (int)(mass * 1000);
		string massStr = Roll.Seek(StarsData.STELLAR_VAR, massroll).ToString();
		GD.Print($"MassString: {massStr}");
		var evolutionData = Roll.Search<Dictionary<string, object>>(StarsData.STELLAR_EVOLUTION, massStr);
		if (evolutionData != null)
		{
			float mainSequenceSpan = evolutionData.ContainsKey("M-Span") ? Convert.ToSingle(evolutionData["M-Span"]) : float.PositiveInfinity;
			GD.Print($"M-span: {mainSequenceSpan}");
			float subgiantSpan = evolutionData.ContainsKey("S-Span") ? Convert.ToSingle(evolutionData["S-Span"]) : float.PositiveInfinity;
			GD.Print($"S-span: {subgiantSpan}");
			float giantSpan = evolutionData.ContainsKey("G-Span") ? Convert.ToSingle(evolutionData["G-Span"]) : float.PositiveInfinity;
			GD.Print($"G-span: {giantSpan}");

			if (age <= mainSequenceSpan)
			{
				return "MAIN_SEQUENCE";
			}
			else if (age <= mainSequenceSpan + subgiantSpan)
			{
				return "SUBGIANT";
			}
			else if (age <= mainSequenceSpan + subgiantSpan + giantSpan)
			{
				return "GIANT";
			}
		}

		return "WHITE_DWARF";
	}
}

	/*
	I don't know why this was in the original file, I can't find a reason for it, but I'm going to 
	include it in the comments as it was in GDScript in case I need to use it later

	func calculate_remaining_lifespan(mass: float, age: float) -> float:
		var mass_str = Roll.seek(stellar_data["STELLAR_VAR"], mass * 1000)
		var total_lifespan = stellar_data["STELLAR_EVOLUTION"][mass_str]["M-Span"] + \
							 stellar_data["STELLAR_EVOLUTION"][mass_str].get("S-Span", 0) + \
							 stellar_data["STELLAR_EVOLUTION"][mass_str].get("G-Span", 0)
		return max(0, total_lifespan - age)
	*/
