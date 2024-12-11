using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class StarLuminosity
{
	public float CalculateMainSequenceLuminosity(string massStr, float starAge, float minLuminosity)
	{
		var massData = Roll.Search(StarsData.STELLAR_EVOLUTION, massStr) as Dictionary<string, object>;
		float maxLuminosity = massData.ContainsKey("L-Max") ? Convert.ToSingle(massData["L-Max"]) : minLuminosity;
		float mainSequenceSpan = massData.ContainsKey("M-Span") ? Convert.ToSingle(massData["M-Span"]) : float.PositiveInfinity;

		float resultLuminosity = Roll.Vary(minLuminosity);
		if (maxLuminosity > 0)
		{
			resultLuminosity += Roll.Vary((starAge / mainSequenceSpan) * (maxLuminosity - minLuminosity));
		}

		return resultLuminosity;
	}

	public float CalculateGiantLuminosity(float mass, string evolutionaryStage)
	{
		float baseLuminosity = (float)Math.Pow(mass, 3.5);

		return evolutionaryStage switch
		{
			"SUBGIANT" => Roll.Vary(baseLuminosity * 2),
			"GIANT" => Roll.Vary(baseLuminosity * 25),
			_ => baseLuminosity
		};
	}

	public float CalculateSubgiantLuminosity(float mass, string evolutionaryStage)
	{
		return CalculateGiantLuminosity(mass, evolutionaryStage);
	}
}
