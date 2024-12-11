using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Generator;
using StellarLibraries;

public class SmallBodyGroup
{
	public struct BodyData
	{
		public float OrbitalPosition { get; set; }
		public Dictionary<string, int> BodyDistribution { get; set; }
		public Dictionary<string, int> SizeDistribution { get; set; }
		public List<string> SignificantBodies { get; set; }
		public float Desirability { get; set; }
		public Dictionary<string, float> TypePercentage { get; set; }

		public BodyData(float orbitalPosition, Dictionary<string, int> bodyDistribution,
			Dictionary<string, int> sizeDistribution, List<string> significantBodies,
			float desirability, Dictionary<string, float> typePercentage)
		{
			OrbitalPosition = orbitalPosition;
			BodyDistribution = bodyDistribution;
			SizeDistribution = sizeDistribution;
			SignificantBodies = significantBodies;
			Desirability = desirability;
			TypePercentage = typePercentage;
		}
	}

	private static readonly Dictionary<string, float> AsteroidTypes = new()
	{
		{ "A", 0.002f },
		{ "B", 0.006f },
		{ "C", 0.65f },
		{ "D", 0.08f },
		{ "E", 0.002f },
		{ "F", 0.006f },
		{ "G", 0.006f },
		{ "K", 0.006f },
		{ "L", 0.001f },
		{ "M", 0.04f },
		{ "P", 0.04f },
		{ "Q", 0.002f },
		{ "R", 0.003f },
		{ "S", 0.15f },
		{ "T", 0.005f },
		{ "V", 0.001f }
	};

	private string BodyType;
	private float OrbitalPosition;
	private int NumBodies;
	private BodyData GroupData;

	public SmallBodyGroup(string type, float orbit, int number)
	{
		BodyType = type;
		OrbitalPosition = orbit;
		NumBodies = number;
		GroupData = GenerateGroup();
	}

	public partial class AsteroidBelt : SmallBodyGroup
	{
		public AsteroidBelt(float orbit, int number) : base("Asteroid", orbit, number) { }
	}

	public partial class ShortPeriodCometCloud : SmallBodyGroup
	{
		public ShortPeriodCometCloud(float orbit, int number) : base("Short_Period_Comets", orbit, number) { }
	}

	public partial class LongPeriodCometCloud : SmallBodyGroup
	{
		public LongPeriodCometCloud(float orbit, int number) : base("Long_Period_Comets", orbit, number) { }
	}

	// Add a public property to access GroupData
	public BodyData Data => GroupData;

	// Additional implementation needed:
	private Dictionary<string, Dictionary<string, int>> bodySizeRanges = new()
	{
		{
			"Asteroid", new Dictionary<string, int>
			{
				{"500-1000", 0}, {"100-500", 0}, {"50-100", 0}, {"10-50", 0}, {"1-10", 0}
			}
		},
		{
			"Short_Period_Comets", new Dictionary<string, int>
			{
				{"10-16", 0}, {"9-10", 0}, {"6-9", 0}, {"3-6", 0}, {"1-3", 0}
			}
		},
		{
			"Long_Period_Comets", new Dictionary<string, int>
			{
				{"64-150", 0}, {"32-64", 0}, {"18-32", 0}, {"12-18", 0}, {"6-12", 0}, {"1-6", 0}
			}
		}
	};

	private BodyData GenerateGroup()
	{
		var typeDistribution = new Dictionary<string, int>();
		var sizeDistribution = bodySizeRanges[BodyType];
		var significantBodies = new List<string>();
		var typePercentages = CalculateTypeDistribution();
		float desirability = CalculateDesirability(typePercentages);

		// Generate type distribution
		foreach (var type in AsteroidTypes.Keys)
		{
			typeDistribution[type] = 0;
		}

		// Generate bodies
		for (int i = 0; i < NumBodies; i++)
		{
			string selectedType = SelectRandomType();
			typeDistribution[selectedType]++;
			
			// Add size distribution logic here
			// Add significant bodies logic here
		}

		return new BodyData(
			OrbitalPosition,
			typeDistribution,
			sizeDistribution,
			significantBodies,
			desirability,
			typePercentages
		);
	}

	private string SelectRandomType()
	{
		float randomValue = (float)new Random().NextDouble();
		float cumulativeProbability = 0;

		foreach (var type in AsteroidTypes)
		{
			cumulativeProbability += type.Value;
			if (randomValue <= cumulativeProbability)
			{
				return type.Key;
			}
		}

		return AsteroidTypes.Keys.ElementAt(AsteroidTypes.Count - 1);  // Use ElementAt instead of Last
	}
		private Dictionary<string, float> CalculateTypeDistribution()
	{
		var typeDistribution = new Dictionary<string, float>();

		foreach (var entry in AsteroidTypes)
		{
			float probability = entry.Value * NumBodies;
			typeDistribution[entry.Key] = probability;
		}

		return typeDistribution;
	}

	private float CalculateDesirability(Dictionary<string, float> typeDistribution)
	{
		float desirability = 0.0f;

		foreach (var entry in typeDistribution)
		{
			desirability += entry.Value;
		}

		return desirability;
	}
}
