using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SmallBodyBasics
{
	private static readonly Dictionary<Vector2I, int> ASTEROID_SIZES = new()
	{
		{new Vector2I(500, 1000), 1},
		{new Vector2I(100, 500), 10},
		{new Vector2I(50, 100), 100},
		{new Vector2I(10, 50), 1000},
		{new Vector2I(1, 10), 10000}
	};

	private static readonly Dictionary<Vector2, int> SP_COMET_SIZES = new()
	{
		{new Vector2(10, 16), 1},
		{new Vector2(9, 10), 10},
		{new Vector2(6, 9), 100},
		{new Vector2(3, 6), 1000},
		{new Vector2(1, 3), 10000},
	};

	private static readonly Dictionary<Vector2, int> LP_COMET_SIZES = new()
	{
		{new Vector2(64, 150), 1},
		{new Vector2(32, 64), 10},
		{new Vector2(20, 32), 100},
		{new Vector2(18, 20), 1000},
		{new Vector2(12, 18), 10000},
		{new Vector2(6, 12), 10000},
		{new Vector2(1, 6), 10000},
	};

	public static (int size, Vector2I[] sizeRange) GetBodySize(string bodyType)
	{
		Dictionary<Vector2I, int> sizeRanges = bodyType switch
		{
			"Asteroid" => ASTEROID_SIZES,
			"Short_Period_Comets" => SP_COMET_SIZES.ToDictionary(
				kvp => new Vector2I((int)kvp.Key.X, (int)kvp.Key.Y), 
				kvp => kvp.Value),
			"Long_Period_Comets" => LP_COMET_SIZES.ToDictionary(
				kvp => new Vector2I((int)kvp.Key.X, (int)kvp.Key.Y), 
				kvp => kvp.Value),
			_ => throw new ArgumentException("Invalid body type")
		};

		Vector2I[] ranges = sizeRanges.Keys.ToArray();
		float[] probabilities = sizeRanges.Values.Select(v => (float)v).ToArray();

		Vector2I selectedRange = Roll.Choice(ranges, probabilities);
		int smallBodySize = Roll.Dice(1, selectedRange.Y - selectedRange.X + 1, selectedRange.X - 1);

		return (smallBodySize, sizeRanges.Keys.ToArray());
	}

	public static string GetSizeDistributionKey(string bodyType, float size)
	{
		return bodyType switch
		{
			"Asteroid" => size switch
			{
				>= 500 => "500-1000",
				>= 100 => "100-500",
				>= 50 => "50-100",
				>= 10 => "10-50",
				_ => "1-10"
			},
			"Short_Period_Comets" => size switch
			{
				>= 10 => "10-16",
				>= 9 => "9-10",
				>= 6 => "6-9",
				>= 3 => "3-6",
				_ => "1-3"
			},
			"Long_Period_Comets" => size switch
			{
				>= 64 => "64-150",
				>= 32 => "32-64",
				>= 18 => "18-32",
				>= 12 => "12-18",
				>= 6 => "6-12",
				_ => "1-6"
			},
			_ => ""
		};
	}

	public static Dictionary<string, float> CalculateTypePercentages(Dictionary<string, int> bodyDistribution)
	{
		int total = bodyDistribution.Values.Sum();
		
		var percentages = bodyDistribution.ToDictionary(
			kvp => kvp.Key, 
			kvp => (float)kvp.Value / total * 100
		);

		return percentages.OrderByDescending(x => x.Value)
						  .ToDictionary(x => x.Key, x => x.Value);
	}
}
