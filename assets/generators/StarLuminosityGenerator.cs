using Godot;
using System;
using System.Collections.Generic;
using Generator;
using StellarLibraries;

public class StarLuminosity
{
	public float CalculateMainSequenceLuminosity(string massStr, float starAge, float minLuminosity)
	{
		GD.Print($"Looking up mass data for {massStr}");
		var massData = Roll.Search(StarsData.STELLAR_EVOLUTION, massStr) as Dictionary<string, object>;
		
		if (massData == null)
		{
			GD.Print($"No mass data found for {massStr}");
			return minLuminosity;
		}

		float maxLuminosity = massData.ContainsKey("L-Max") ? Convert.ToSingle(massData["L-Max"]) : minLuminosity;
		float mainSequenceSpan = massData.ContainsKey("M-Span") ? Convert.ToSingle(massData["M-Span"]) : float.PositiveInfinity;

		GD.Print($"Min luminosity: {minLuminosity}, Max luminosity: {maxLuminosity}, Main sequence span: {mainSequenceSpan}");

		float resultLuminosity = Roll.Vary(minLuminosity);
		GD.Print($"Base luminosity after variation: {resultLuminosity}");

		if (maxLuminosity > 0)
		{
			float ageFactor = starAge / mainSequenceSpan;
			float luminosityRange = maxLuminosity - minLuminosity;
			float additionalLuminosity = Roll.Vary(ageFactor * luminosityRange);
			resultLuminosity += additionalLuminosity;
			
			GD.Print($"Age factor: {ageFactor}, Luminosity range: {luminosityRange}, Additional luminosity: {additionalLuminosity}");
		}

		GD.Print($"Final luminosity: {resultLuminosity}");
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
